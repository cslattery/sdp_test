import logging
from typing import Any, Iterator

from google.cloud import bigquery

logger = logging.getLogger(__name__)


class BigQueryIO:
    def __init__(self, project_id: str) -> None:
        self._client = bigquery.Client(project=project_id)
        self._project_id = project_id

    def read_batches(
        self,
        source_table: str,
        batch_size: int,
    ) -> Iterator[list[dict[str, Any]]]:
        query = f"SELECT * FROM `{source_table}`"
        rows = self._client.query(query).result(page_size=batch_size)

        batch: list[dict[str, Any]] = []
        for row in rows:
            batch.append(dict(row.items()))
            if len(batch) >= batch_size:
                yield batch
                batch = []

        if batch:
            yield batch

    def ensure_target_table(self, source_table: str, target_table: str) -> None:
        job_config = bigquery.QueryJobConfig(
            destination=target_table,
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        )
        query = (
            f"SELECT * FROM `{source_table}` WHERE FALSE"
        )
        self._client.query(query, job_config=job_config).result()
        logger.info("Prepared empty target table %s", target_table)

    def write_batch(self, target_table: str, rows: list[dict[str, Any]]) -> None:
        if not rows:
            return

        errors = self._client.insert_rows_json(target_table, rows)
        if errors:
            raise RuntimeError(f"BigQuery insert failed: {errors[:3]}")
        logger.info("Wrote %s rows to %s", len(rows), target_table)