import os
import time
from typing import Any, Iterator

import requests

DEFAULT_BASE_URL = "https://api.jquants.com"
MAX_RETRIES = 5
RETRYABLE_STATUS = {429, 500, 502, 503, 504}


class JQuantsClient:
    def __init__(self, api_key: str | None = None, base_url: str | None = None) -> None:
        self.api_key = api_key or os.environ["JQUANTS_API_KEY"]
        self.base_url = base_url or os.environ.get("JQUANTS_BASE_URL", DEFAULT_BASE_URL)
        self.session = requests.Session()
        self.session.headers["x-api-key"] = self.api_key

    def _get(self, path: str, params: dict[str, Any]) -> dict[str, Any]:
        url = f"{self.base_url}{path}"
        for attempt in range(MAX_RETRIES):
            resp = self.session.get(url, params=params, timeout=30)
            if resp.status_code in RETRYABLE_STATUS and attempt < MAX_RETRIES - 1:
                time.sleep(2**attempt)
                continue
            resp.raise_for_status()
            return resp.json()
        raise RuntimeError(f"exhausted retries calling {path}")

    def get_all(self, path: str, params: dict[str, Any]) -> Iterator[dict[str, Any]]:
        """GETs every page of `path`, following pagination_key, and yields each row."""
        params = dict(params)
        while True:
            body = self._get(path, params)
            yield from body.get("data", [])
            pagination_key = body.get("pagination_key")
            if not pagination_key:
                return
            params["pagination_key"] = pagination_key
