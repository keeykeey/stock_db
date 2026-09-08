import os
from typing import Any

import psycopg
from psycopg import sql


def get_conn() -> psycopg.Connection:
    return psycopg.connect(
        host=os.environ.get("DB_HOST", "db"),
        port=os.environ.get("DB_PORT", "5432"),
        dbname=os.environ["POSTGRES_DB"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
    )


def upsert(
    cur: psycopg.Cursor,
    table: str,
    rows: list[dict[str, Any]],
    conflict_columns: list[str],
    touch_updated_at: bool = False,
) -> None:
    """INSERT ... ON CONFLICT (conflict_columns) DO UPDATE for every row.

    All rows must share the same set of keys. Set touch_updated_at=True for
    tables (like brand) that have an updated_at column to bump on conflict.
    """
    if not rows:
        return

    columns = list(rows[0].keys())
    update_columns = [c for c in columns if c not in conflict_columns]

    set_clauses = [
        sql.SQL("{c} = EXCLUDED.{c}").format(c=sql.Identifier(c)) for c in update_columns
    ]
    if touch_updated_at:
        set_clauses.append(sql.SQL("updated_at = now()"))

    query = sql.SQL(
        "INSERT INTO {table} ({columns}) VALUES ({placeholders}) "
        "ON CONFLICT ({conflict}) DO UPDATE SET {updates}"
    ).format(
        table=sql.Identifier(table),
        columns=sql.SQL(", ").join(sql.Identifier(c) for c in columns),
        placeholders=sql.SQL(", ").join(sql.Placeholder(c) for c in columns),
        conflict=sql.SQL(", ").join(sql.Identifier(c) for c in conflict_columns),
        updates=sql.SQL(", ").join(set_clauses),
    )
    cur.executemany(query, rows)


def fetch_code_by_label(cur: psycopg.Cursor, table: str, label: str, column: str = "label") -> Any:
    query = sql.SQL("SELECT code FROM {table} WHERE {column} = %s").format(
        table=sql.Identifier(table), column=sql.Identifier(column)
    )
    cur.execute(query, (label,))
    row = cur.fetchone()
    if row is None:
        raise ValueError(f"no row in {table} with {column}={label!r}")
    return row[0]
