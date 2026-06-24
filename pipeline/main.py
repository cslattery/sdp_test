import logging
import sys
from typing import Optional

from config import PipelineConfig
from bq_io import BigQueryIO
from dlp_client import DlpClient

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


def mask_batch(
    rows: list[dict],
    freetext_columns: tuple[str, ...],
    dlp: DlpClient,
    deidentify_template: str,
    inspect_template: str,
    dlp_chunk_size: int,
) -> list[dict]:
    masked_rows = [dict(row) for row in rows]
    texts: list[Optional[str]] = []
    positions: list[tuple[int, str]] = []

    for row_index, row in enumerate(masked_rows):
        for column in freetext_columns:
            if column not in row:
                raise KeyError(f"Column '{column}' not found in source row")
            texts.append(row[column])
            positions.append((row_index, column))

    masked_texts = dlp.deidentify_batch(
        texts,
        deidentify_template=deidentify_template,
        inspect_template=inspect_template,
        chunk_size=dlp_chunk_size,
    )

    for (row_index, column), masked_text in zip(positions, masked_texts):
        masked_rows[row_index][column] = masked_text

    return masked_rows


def run(config: PipelineConfig) -> None:
    bq = BigQueryIO(config.project_id)
    dlp = DlpClient(config.project_id, config.dlp_location)

    if config.dry_run:
        logger.info("DRY_RUN enabled; processing first batch only")
        batches = bq.read_batches(config.source_table, config.batch_size)
        first_batch = next(batches, [])
        if not first_batch:
            logger.info("Source table is empty")
            return
        masked = mask_batch(
            first_batch,
            config.freetext_columns,
            dlp,
            config.deidentify_template,
            config.inspect_template,
            config.dlp_chunk_size,
        )
        for row in masked[:3]:
            logger.info("Sample masked row: %s", row)
        return

    bq.ensure_target_table(config.source_table, config.target_table)

    total_rows = 0
    for batch in bq.read_batches(config.source_table, config.batch_size):
        masked = mask_batch(
            batch,
            config.freetext_columns,
            dlp,
            config.deidentify_template,
            config.inspect_template,
            config.dlp_chunk_size,
        )
        bq.write_batch(config.target_table, masked)
        total_rows += len(masked)
        logger.info("Processed %s rows so far", total_rows)

    logger.info("Finished masking %s rows into %s", total_rows, config.target_table)


def main() -> int:
    try:
        config = PipelineConfig.from_env()
    except ValueError as exc:
        logger.error("%s", exc)
        return 1

    logger.info(
        "Starting pipeline: %s -> %s (columns=%s)",
        config.source_table,
        config.target_table,
        ",".join(config.freetext_columns),
    )
    run(config)
    return 0


if __name__ == "__main__":
    sys.exit(main())