import argparse
import datetime
import sys

import db
from jquants_client import JQuantsClient
from targets import brand, equity_history, fin_summary


def main() -> None:
    parser = argparse.ArgumentParser(description="jquants -> stock_db batch")
    sub = parser.add_subparsers(dest="target", required=True)

    sub.add_parser("brand", help="full replace of brand from /v2/equities/master")

    eq_parser = sub.add_parser(
        "equity_history", help="re-fetch recent days of /v2/equities/bars/daily and upsert"
    )
    eq_parser.add_argument(
        "--days",
        type=int,
        default=equity_history.DEFAULT_LOOKBACK_DAYS,
        help="number of business days to re-fetch (default: %(default)s)",
    )

    fin_parser = sub.add_parser("fin_summary", help="fetch one day of /v2/fins/summary and upsert")
    fin_parser.add_argument(
        "--date",
        type=datetime.date.fromisoformat,
        default=None,
        help="disclosure date to fetch, YYYY-MM-DD (default: today)",
    )

    args = parser.parse_args()
    client = JQuantsClient()

    with db.get_conn() as conn:
        with conn.cursor() as cur:
            if args.target == "brand":
                count = brand.run(cur, client)
            elif args.target == "equity_history":
                count = equity_history.run(cur, client, lookback_days=args.days)
            elif args.target == "fin_summary":
                count = fin_summary.run(cur, client, target_date=args.date)
            else:
                raise AssertionError(f"unhandled target {args.target!r}")
        conn.commit()

    print(f"{args.target}: upserted {count} rows", file=sys.stderr)


if __name__ == "__main__":
    main()
