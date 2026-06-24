import os
from dataclasses import dataclass


@dataclass(frozen=True)
class PipelineConfig:
    project_id: str
    source_table: str
    target_table: str
    freetext_columns: tuple[str, ...]
    inspect_template: str
    deidentify_template: str
    batch_size: int
    dlp_chunk_size: int
    dlp_location: str
    dry_run: bool

    @classmethod
    def from_env(cls) -> "PipelineConfig":
        freetext = os.environ.get("FREETEXT_COLUMNS", "")
        columns = tuple(c.strip() for c in freetext.split(",") if c.strip())
        if not columns:
            raise ValueError("FREETEXT_COLUMNS must list at least one column")

        return cls(
            project_id=_require("PROJECT_ID"),
            source_table=_require("SOURCE_TABLE"),
            target_table=_require("TARGET_TABLE"),
            freetext_columns=columns,
            inspect_template=_require("INSPECT_TEMPLATE"),
            deidentify_template=_require("DEIDENTIFY_TEMPLATE"),
            batch_size=int(os.environ.get("BATCH_SIZE", "1000")),
            dlp_chunk_size=int(os.environ.get("DLP_CHUNK_SIZE", "5000")),
            dlp_location=os.environ.get("DLP_LOCATION", "global"),
            dry_run=os.environ.get("DRY_RUN", "").lower() in {"1", "true", "yes"},
        )


def _require(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise ValueError(f"{name} is required")
    return value