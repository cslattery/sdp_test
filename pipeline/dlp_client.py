import logging
import time
from typing import Optional

from google.api_core import exceptions as api_exceptions
from google.cloud import dlp_v2

logger = logging.getLogger(__name__)


class DlpClient:
    def __init__(self, project_id: str, location: str) -> None:
        self._client = dlp_v2.DlpServiceClient()
        self._parent = f"projects/{project_id}/locations/{location}"

    def deidentify(
        self,
        text: Optional[str],
        deidentify_template: str,
        inspect_template: str,
        max_retries: int = 5,
    ) -> Optional[str]:
        if text is None:
            return None
        if text == "":
            return ""

        request = {
            "parent": self._parent,
            "deidentify_template_name": deidentify_template,
            "inspect_template_name": inspect_template,
            "item": {"value": text},
        }

        for attempt in range(max_retries + 1):
            try:
                response = self._client.deidentify_content(request=request)
                return response.item.value
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