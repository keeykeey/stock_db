import datetime

import psycopg

import db
from jquants_client import JQuantsClient

DEFAULT_LOOKBACK_DAYS = 5


def _recent_business_days(days: int, today: datetime.date) -> list[datetime.date]:
    """Last `days` weekday-only dates up to and including `today`. Does not
    account for JPX market holidays, only weekends - good enough for an
    overlap window meant to re-catch retroactive Adj* revisions, not as an
    exact trading calendar."""
    result = []
    d = today
    while len(result) < days:
        if d.weekday() < 5:
            result.append(d)
        d -= datetime.timedelta(days=1)
    return result


def run(cur: psycopg.Cursor, client: JQuantsClient, lookback_days: int = DEFAULT_LOOKBACK_DAYS) -> int:
    """Re-fetches the last `lookback_days` business days of
    GET /v2/equities/bars/daily and UPSERTs, so retroactive Adj* revisions
    (splits/mergers) get picked up on every run.

    The API only accepts `date` (single day, all codes), `code` (single
    code, any date range), or both - not `from`/`to` alone across all codes
    - so this fetches one day at a time.
    """
    rows = []
    for day in _recent_business_days(lookback_days, datetime.date.today()):
        for raw in client.get_all("/v2/equities/bars/daily", {"date": day.isoformat()}):
            if raw["Va"] is None:
                # no trade that day (suspension, pre-listing, etc.) - skip
                continue
            rows.append(
                {
                    "target_date": raw["Date"],
                    "code": raw["Code"],
                    "ul": int(raw["UL"]),
                    "ll": int(raw["LL"]),
                    "va": raw["Va"],
                    "adj_o": raw["AdjO"],
                    "adj_h": raw["AdjH"],
                    "adj_l": raw["AdjL"],
                    "adj_c": raw["AdjC"],
                    "adj_vo": raw["AdjVo"],
                }
            )

    db.upsert(cur, "equity_history", rows, conflict_columns=["code", "target_date"])
    return len(rows)
