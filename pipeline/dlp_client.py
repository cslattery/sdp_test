import logging
import time
from typing import Optional

from google.api_core import exceptions as api_exceptions
from google.cloud import dlp_v2

logger = logging.getLogger(__name__)

MAX_TABLE_VALUES = 50_000
MAX_REQUEST_BYTES = 450_000
DEFAULT_DLP_CHUNK_SIZE = 5000


class DlpClient:
    def __init__(self, project_id: str, location: str) -> None:
        self._client = dlp_v2.DlpServiceClient()
        self._parent = f"projects/{project_id}/locations/{location}"

    def deidentify_batch(
        self,
        texts: list[Optional[str]],
        deidentify_template: str,
        inspect_template: str,
        chunk_size: int = DEFAULT_DLP_CHUNK_SIZE,
        max_retries: int = 5,
    ) -> list[Optional[str]]:
        if chunk_size <= 0:
            raise ValueError("chunk_size must be positive")
        if chunk_size > MAX_TABLE_VALUES:
            raise ValueError(f"chunk_size cannot exceed {MAX_TABLE_VALUES}")

        results = list(texts)
        pending: list[tuple[int, str]] = []
        for index, text in enumerate(texts):
            if text is None or text == "":
                continue
            pending.append((index, text))

        if not pending:
            return results

        offset = 0
        while offset < len(pending):
            chunk = _take_chunk(pending, offset, chunk_size, MAX_REQUEST_BYTES)
            if not chunk:
                _, text = pending[offset]
                raise ValueError(
                    "Single text value exceeds DLP request size limit "
                    f"({MAX_REQUEST_BYTES} bytes)"
                )

            masked_values = self._deidentify_table(
                [text for _, text in chunk],
                deidentify_template=deidentify_template,
                inspect_template=inspect_template,
                max_retries=max_retries,
            )
            if len(masked_values) != len(chunk):
                raise RuntimeError(
                    "DLP returned unexpected row count: "
                    f"expected {len(chunk)}, got {len(masked_values)}"
                )

            for (result_index, _), masked in zip(chunk, masked_values):
                results[result_index] = masked

            offset += len(chunk)
            logger.info(
                "Masked %s/%s text values via DLP",
                min(offset, len(pending)),
                len(pending),
            )

        return results

    def _deidentify_table(
        self,
        texts: list[str],
        deidentify_template: str,
        inspect_template: str,
        max_retries: int,
    ) -> list[str]:
        request = {
            "parent": self._parent,
            "deidentify_template_name": deidentify_template,
            "inspect_template_name": inspect_template,
            "item": {
                "table": {
                    "headers": [{"name": "text"}],
                    "rows": [
                        {"values": [{"string_value": text}]}
                        for text in texts
                    ],
                }
            },
        }

        response = _call_with_retries(
            self._client.deidentify_content,
            request,
            max_retries=max_retries,
        )
        table = response.item.table
        return [row.values[0].string_value for row in table.rows]


def _take_chunk(
    items: list[tuple[int, str]],
    offset: int,
    max_count: int,
    max_bytes: int,
) -> list[tuple[int, str]]:
    chunk: list[tuple[int, str]] = []
    total_bytes = 0
    end = min(offset + max_count, len(items))

    for index in range(offset, end):
        item = items[index]
        text_bytes = len(item[1].encode("utf-8"))
        if text_bytes > max_bytes:
            return []
        if chunk and total_bytes + text_bytes > max_bytes:
            break
        chunk.append(item)
        total_bytes += text_bytes

    return chunk


def _call_with_retries(callable_, request: dict, max_retries: int):
    for attempt in range(max_retries + 1):
        try:
            return callable_(request=request)
        except api_exceptions.GoogleAPICallError as exc:
            if attempt >= max_retries or not _is_retryable(exc):
                raise
            delay = min(2**attempt, 30)
            logger.warning(
                "DLP call failed (attempt %s/%s): %s; retrying in %ss",
                attempt + 1,
                max_retries,
                exc,
                delay,
            )
            time.sleep(delay)

    raise RuntimeError("unreachable")


def _is_retryable(exc: api_exceptions.GoogleAPICallError) -> bool:
    return isinstance(
        exc,
        (
            api_exceptions.TooManyRequests,
            api_exceptions.ServiceUnavailable,
            api_exceptions.InternalServerError,
            api_exceptions.DeadlineExceeded,
        ),
    )