import datetime
from typing import Any

import psycopg

import db
from jquants_client import JQuantsClient


def _blank_to_none(v: Any) -> Any:
    return None if v == "" else v


def _to_int(v: Any) -> int | None:
    v = _blank_to_none(v)
    return None if v is None else int(float(v))


def _to_float(v: Any) -> float | None:
    v = _blank_to_none(v)
    return None if v is None else float(v)


def run(cur: psycopg.Cursor, client: JQuantsClient, target_date: datetime.date | None = None) -> int:
    """Fetches GET /v2/fins/summary disclosures for one date and UPSERTs.

    All numeric/date fields come back as strings, with "" (not null) for
    missing values - _to_int/_to_float/_blank_to_none normalize that.
    """
    target_date = target_date or datetime.date.today()
    doc_type_by_label: dict[str, int] = {}

    rows = []
    for raw in client.get_all("/v2/fins/summary", {"date": target_date.isoformat()}):
        doc_type_label = raw["DocType"]
        if doc_type_label not in doc_type_by_label:
            doc_type_by_label[doc_type_label] = db.fetch_code_by_label(
                cur, "doc_type", doc_type_label, column="label_en"
            )

        rows.append(
            {
                "disc_no": raw["DiscNo"],
                "disc_date": raw["DiscDate"],
                "code": raw["Code"],
                "doc_type_code": doc_type_by_label[doc_type_label],
                "cur_per_type": raw["CurPerType"],
                "cur_per_st": _blank_to_none(raw.get("CurPerSt")),
                "cur_per_en": _blank_to_none(raw.get("CurPerEn")),
                "cur_fy_st": _blank_to_none(raw.get("CurFYSt")),
                "cur_fy_en": _blank_to_none(raw.get("CurFYEn")),
                "sales": _to_int(raw.get("Sales")),
                "op": _to_int(raw.get("OP")),
                "odp": _to_int(raw.get("OdP")),
                "np": _to_int(raw.get("NP")),
                "eps": _to_float(raw.get("EPS")),
                "dep": _to_float(raw.get("DEPS")),
                "ta": _to_int(raw.get("TA")),
                "eq": _to_int(raw.get("Eq")),
                "eq_ar": _to_float(raw.get("EqAR")),
                "bps": _to_float(raw.get("BPS")),
                "cfo": _to_int(raw.get("CFO")),
                "cfi": _to_int(raw.get("CFI")),
                "cff": _to_int(raw.get("CFF")),
                "cash_eq": _to_int(raw.get("CashEq")),
                "div_ann": _to_int(raw.get("DivAnn")),
                "div_unit": _to_int(raw.get("DivUnit")),
                "div_total_ann": _to_int(raw.get("DivTotalAnn")),
                "payout_ratio_ann": _to_float(raw.get("PayoutRatioAnn")),
                "f_div_ann": _to_int(raw.get("FDivAnn")),
                "f_div_unit": _to_int(raw.get("FDivUnit")),
                "f_div_total_ann": _to_int(raw.get("FDivTotalAnn")),
                "f_payout_ratio_ann": _to_float(raw.get("FPayoutRatioAnn")),
                "sh_out_fy": _to_int(raw.get("ShOutFY")),
                "tr_sh_fy": _to_int(raw.get("TrShFY")),
                "roe": _to_float(raw.get("ROE")),
            }
        )

    db.upsert(cur, "fin_summary", rows, conflict_columns=["disc_no"])
    return len(rows)
