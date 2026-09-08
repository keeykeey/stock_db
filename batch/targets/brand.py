import psycopg

import db
from jquants_client import JQuantsClient


def run(cur: psycopg.Cursor, client: JQuantsClient) -> int:
    """Full replace of `brand` from GET /v2/equities/master."""
    scale_cat_by_label: dict[str, int] = {}
    rows = []
    for raw in client.get_all("/v2/equities/master", {}):
        scale_cat_label = raw["ScaleCat"]
        if scale_cat_label not in scale_cat_by_label:
            scale_cat_by_label[scale_cat_label] = db.fetch_code_by_label(
                cur, "scale_cat", scale_cat_label
            )

        rows.append(
            {
                "code": raw["Code"],
                "co_name": raw["CoName"],
                "co_name_en": raw.get("CoNameEn"),
                "sec_17_code": raw["S17"],
                "sec_33_code": raw["S33"],
                "scale_cat": scale_cat_by_label[scale_cat_label],
                "market_code": raw["Mkt"],
                "mrgn_code": raw["Mrgn"],
                "prod_cat_code": raw["ProdCat"],
            }
        )

    db.upsert(cur, "brand", rows, conflict_columns=["code"], touch_updated_at=True)
    return len(rows)
