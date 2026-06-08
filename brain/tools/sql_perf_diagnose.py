#!/usr/bin/env python3
"""
#EJC20260608 mejora(liquidacion-bof): diagnostico no invasivo de rendimiento SQL Server.

Uso:
  python sql_perf_diagnose.py --server 172.16.10.9 --database ROADSAP --user roadprod --password "***" --out report.md
"""

from __future__ import annotations

import argparse
import datetime as dt
import decimal
import json
from pathlib import Path
from typing import Any

import pyodbc


def rows_to_dicts(cursor: pyodbc.Cursor) -> list[dict[str, Any]]:
    cols = [c[0] for c in cursor.description]
    rows: list[dict[str, Any]] = []
    for row in cursor.fetchall():
        item: dict[str, Any] = {}
        for i, val in enumerate(row):
            if isinstance(val, (dt.datetime, dt.date, dt.time)):
                item[cols[i]] = val.isoformat(sep=" ")
            elif isinstance(val, decimal.Decimal):
                item[cols[i]] = float(val)
            else:
                item[cols[i]] = val
        rows.append(item)
    return rows


def run_query(conn: pyodbc.Connection, sql: str) -> list[dict[str, Any]]:
    cur = conn.cursor()
    cur.execute(sql)
    result = rows_to_dicts(cur)
    cur.close()
    return result


def to_md_table(rows: list[dict[str, Any]], max_rows: int = 20) -> str:
    if not rows:
        return "_Sin datos_"
    rows = rows[:max_rows]
    cols = list(rows[0].keys())
    header = "| " + " | ".join(cols) + " |"
    sep = "| " + " | ".join(["---"] * len(cols)) + " |"
    body = []
    for r in rows:
        body.append("| " + " | ".join(str(r.get(c, "")) for c in cols) + " |")
    return "\n".join([header, sep] + body)


def build_queries(db_name: str) -> dict[str, str]:
    return {
        "server_context": f"""
SET NOCOUNT ON;
SELECT @@SERVERNAME AS server_name,
       DB_NAME() AS db_name,
       SUSER_SNAME() AS login_name,
       (SELECT sqlserver_start_time FROM sys.dm_os_sys_info) AS sqlserver_start_time,
       HAS_PERMS_BY_NAME(NULL, NULL, 'VIEW SERVER STATE') AS has_view_server_state,
       HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'VIEW DATABASE STATE') AS has_view_db_state;
""",
        "active_requests": f"""
SET NOCOUNT ON;
SELECT TOP (30)
    r.session_id, r.status, r.command,
    r.cpu_time AS cpu_ms, r.total_elapsed_time AS elapsed_ms,
    r.wait_type, r.wait_time AS wait_ms, r.blocking_session_id,
    s.host_name, s.program_name, s.login_name,
    SUBSTRING(st.text, (r.statement_start_offset/2)+1,
      ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2)+1
    ) AS running_stmt
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id <> @@SPID
  AND r.database_id = DB_ID('{db_name}')
ORDER BY r.total_elapsed_time DESC;
""",
        "wait_stats_top": """
SET NOCOUNT ON;
WITH w AS (
    SELECT wait_type, wait_time_ms, signal_wait_time_ms, waiting_tasks_count,
           100.0 * wait_time_ms / SUM(wait_time_ms) OVER() AS pct
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK','SLEEP_SYSTEMTASK',
        'SQLTRACE_BUFFER_FLUSH','WAITFOR','LOGMGR_QUEUE','CHECKPOINT_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH',
        'XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT','CLR_AUTO_EVENT',
        'DISPATCHER_QUEUE_SEMAPHORE','FT_IFTS_SCHEDULER_IDLE_WAIT','XE_DISPATCHER_WAIT',
        'XE_DISPATCHER_JOIN','BROKER_EVENTHANDLER','TRACEWRITE','ONDEMAND_TASK_QUEUE',
        'BROKER_RECEIVE_WAITFOR','PREEMPTIVE_OS_GETPROCADDRESS','PREEMPTIVE_OS_AUTHENTICATIONOPS',
        'PREEMPTIVE_OS_GENERICOPS','SOS_WORK_DISPATCHER','SOS_SCHEDULER_YIELD','SP_SERVER_DIAGNOSTICS_SLEEP'
    )
)
SELECT TOP (20)
    wait_type,
    CAST(wait_time_ms/1000.0 AS DECIMAL(18,2)) AS wait_s,
    CAST(signal_wait_time_ms/1000.0 AS DECIMAL(18,2)) AS signal_s,
    waiting_tasks_count,
    CAST(pct AS DECIMAL(6,2)) AS pct_total
FROM w
ORDER BY wait_time_ms DESC;
""",
        "top_queries_by_avg_elapsed": f"""
SET NOCOUNT ON;
SELECT TOP (20)
    qs.execution_count,
    CAST(qs.total_elapsed_time/1000.0/NULLIF(qs.execution_count,0) AS DECIMAL(18,2)) AS avg_elapsed_ms,
    CAST(qs.total_worker_time/1000.0/NULLIF(qs.execution_count,0) AS DECIMAL(18,2)) AS avg_cpu_ms,
    CAST(qs.total_logical_reads*1.0/NULLIF(qs.execution_count,0) AS DECIMAL(18,2)) AS avg_reads,
    qs.last_execution_time,
    LEFT(REPLACE(REPLACE(
      SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
      ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1),
      CHAR(13), ' '), CHAR(10), ' '), 260) AS stmt_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.dbid = DB_ID('{db_name}')
  AND qs.execution_count >= 5
ORDER BY avg_elapsed_ms DESC;
""",
        "top_queries_codliq_reset": f"""
SET NOCOUNT ON;
SELECT TOP (20)
    qs.execution_count,
    CAST(qs.total_logical_reads*1.0/NULLIF(qs.execution_count,0) AS DECIMAL(18,2)) AS avg_logical_reads,
    CAST(qs.total_worker_time/1000.0/NULLIF(qs.execution_count,0) AS DECIMAL(18,2)) AS avg_cpu_ms,
    CAST(qs.total_elapsed_time/1000.0/NULLIF(qs.execution_count,0) AS DECIMAL(18,2)) AS avg_elapsed_ms,
    qs.last_execution_time,
    LEFT(REPLACE(REPLACE(
      SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
      ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1),
      CHAR(13), ' '), CHAR(10), ' '), 260) AS stmt_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.dbid = DB_ID('{db_name}')
  AND st.text LIKE '%SET CODIGOLIQUIDACION%WHERE CODIGOLIQUIDACION%'
ORDER BY avg_logical_reads DESC;
""",
        "key_tables_rowcount": """
SET NOCOUNT ON;
SELECT t.name AS table_name, SUM(p.row_count) AS rows_total
FROM sys.dm_db_partition_stats p
INNER JOIN sys.tables t ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
  AND t.name IN (
      'P_INVENTARIO_RUTA','P_INVENTARIO_BARRAS_RUTA','D_FACTURA','D_CxC',
      'D_NOTACRED','P_STOCK','P_STOCKB','D_DEPOS','D_MOV','P_COLA_TRANSACCIONES'
  )
GROUP BY t.name
ORDER BY rows_total DESC;
""",
        "codliq_index_coverage": """
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
WITH t AS (
    SELECT name FROM sys.tables
    WHERE name IN ('P_INVENTARIO_RUTA','P_INVENTARIO_BARRAS_RUTA','D_FACTURA','D_CxC','D_NOTACRED','P_STOCK','P_STOCKB','D_DEPOS','D_MOV')
), idx AS (
    SELECT t.name AS table_name, i.name AS index_name
    FROM sys.tables t
    INNER JOIN sys.indexes i ON i.object_id = t.object_id
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE c.name = 'CODIGOLIQUIDACION'
      AND ic.is_included_column = 0
)
SELECT t.name AS table_name,
       CASE WHEN EXISTS (SELECT 1 FROM idx WHERE idx.table_name = t.name) THEN 1 ELSE 0 END AS has_key_index_codigoliquidacion,
       STUFF((
         SELECT ';' + idx2.index_name
         FROM idx idx2
         WHERE idx2.table_name = t.name
         FOR XML PATH(''), TYPE
       ).value('.', 'nvarchar(max)'),1,1,'') AS indexes
FROM t
ORDER BY t.name;
""",
        "missing_indexes_top": f"""
SET NOCOUNT ON;
SELECT TOP (15)
    CONVERT(DECIMAL(18,2), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_score,
    OBJECT_NAME(mid.object_id, mid.database_id) AS table_name,
    LEFT(ISNULL(mid.equality_columns,''),150) AS eq_cols,
    LEFT(ISNULL(mid.inequality_columns,''),120) AS ineq_cols,
    LEFT(ISNULL(mid.included_columns,''),150) AS inc_cols,
    migs.user_seeks, migs.user_scans, migs.last_user_seek
FROM sys.dm_db_missing_index_group_stats migs
INNER JOIN sys.dm_db_missing_index_groups mig ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID('{db_name}')
ORDER BY improvement_score DESC;
""",
        "io_file_stats": f"""
SET NOCOUNT ON;
SELECT DB_NAME(vfs.database_id) AS db_name,
       mf.type_desc,
       mf.name AS logical_name,
       mf.physical_name,
       vfs.num_of_reads, vfs.num_of_writes,
       CAST(vfs.io_stall_read_ms / NULLIF(vfs.num_of_reads,0) AS DECIMAL(18,2)) AS avg_read_ms,
       CAST(vfs.io_stall_write_ms / NULLIF(vfs.num_of_writes,0) AS DECIMAL(18,2)) AS avg_write_ms,
       CAST((vfs.num_of_bytes_read/1024.0/1024.0) AS DECIMAL(18,1)) AS mb_read,
       CAST((vfs.num_of_bytes_written/1024.0/1024.0) AS DECIMAL(18,1)) AS mb_written
FROM sys.dm_io_virtual_file_stats(DB_ID('{db_name}'), NULL) vfs
INNER JOIN sys.master_files mf ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
ORDER BY mf.type_desc, mf.file_id;
""",
    }


def write_report_md(out_md: Path, server: str, database: str, results: dict[str, list[dict[str, Any]]]) -> None:
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines: list[str] = []
    lines.append(f"# SQL Perf Diagnose - {database}")
    lines.append("")
    lines.append(f"- Generated at: `{now}`")
    lines.append(f"- Server: `{server}`")
    lines.append(f"- Database: `{database}`")
    lines.append("- Scope: lectura no invasiva (DMVs / metadata)")
    lines.append("")

    ordered_sections = [
        ("server_context", "Contexto Servidor"),
        ("active_requests", "Solicitudes Activas"),
        ("wait_stats_top", "Top Wait Stats"),
        ("top_queries_by_avg_elapsed", "Top Queries por Avg Elapsed"),
        ("top_queries_codliq_reset", "Top Queries CODIGOLIQUIDACION Reset"),
        ("key_tables_rowcount", "Tamanio Tablas Clave"),
        ("codliq_index_coverage", "Cobertura de Indices CODIGOLIQUIDACION"),
        ("missing_indexes_top", "Missing Indexes (Top)"),
        ("io_file_stats", "I/O por Archivo"),
    ]

    for key, title in ordered_sections:
        lines.append(f"## {title}")
        lines.append(to_md_table(results.get(key, []), max_rows=20))
        lines.append("")

    out_md.parent.mkdir(parents=True, exist_ok=True)
    out_md.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Diagnostico SQL Server no invasivo.")
    parser.add_argument("--server", required=True)
    parser.add_argument("--database", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--timeout", type=int, default=30)
    parser.add_argument("--out", required=True, help="Ruta salida markdown")
    parser.add_argument("--out-json", default="", help="Ruta salida json (opcional)")
    args = parser.parse_args()

    conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={args.server};"
        f"DATABASE={args.database};"
        f"UID={args.user};"
        f"PWD={args.password};"
        "TrustServerCertificate=yes;"
    )

    results: dict[str, list[dict[str, Any]]] = {}
    queries = build_queries(args.database)

    with pyodbc.connect(conn_str, timeout=args.timeout) as conn:
        for name, sql in queries.items():
            results[name] = run_query(conn, sql)

    out_md = Path(args.out).resolve()
    write_report_md(out_md, args.server, args.database, results)

    if args.out_json:
        out_json = Path(args.out_json).resolve()
        out_json.parent.mkdir(parents=True, exist_ok=True)
        out_json.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"OK: report -> {out_md}")
    if args.out_json:
        print(f"OK: json -> {Path(args.out_json).resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
