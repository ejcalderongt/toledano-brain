/*
Validacion post-deploy de scripts ejecutados (QAS/PRD)
Fecha: 2026-06-08
Uso: ejecutar en contexto de BD objetivo.
*/

SET NOCOUNT ON;

/* =========================================================
   A) SPs y tipos (DBX-20260608-001, DBX-20260608-002)
   ========================================================= */
SELECT 'PROC' AS object_type, name
FROM sys.procedures
WHERE name IN (
    'usp_Liquidacion_GuardarBatch_v1',
    'usp_COLA_TRANSACCIONES_ReadActive_v1',
    'usp_COLA_TRANSACCIONES_TryAcquire_v1',
    'usp_COLA_TRANSACCIONES_ReleaseByUserType_v1',
    'usp_COLA_TRANSACCIONES_ReleaseBatch_v1'
)
ORDER BY name;

SELECT 'TYPE' AS object_type, name
FROM sys.types
WHERE is_table_type = 1
  AND name IN (
      'TvpLiquidacionDetalle',
      'tvp_COLA_TRANSACCIONES_CODIGO_v1'
  )
ORDER BY name;

/* =========================================================
   B) Indices (DBX-20260608-002, DBX-20260608-003)
   ========================================================= */
SELECT
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.filter_definition
FROM sys.tables t
INNER JOIN sys.indexes i ON i.object_id = t.object_id
WHERE i.name IN (
    'IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR',
    'IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ',
    'IX_P_INVENTARIO_RUTA_CODLIQ',
    'IX_D_DEPOS_CODLIQ',
    'IX_P_COLA_TRANSACCIONES_USR_PROC'
)
ORDER BY t.name, i.name;

/* =========================================================
   C) Baseline de consultas CODIGOLIQUIDACION (diagnostico)
   ========================================================= */
SELECT TOP (12)
    qs.execution_count,
    CAST(qs.total_logical_reads * 1.0 / NULLIF(qs.execution_count, 0) AS DECIMAL(18,2)) AS avg_logical_reads,
    CAST(qs.total_worker_time / 1000.0 / NULLIF(qs.execution_count, 0) AS DECIMAL(18,2)) AS avg_cpu_ms,
    CAST(qs.total_elapsed_time / 1000.0 / NULLIF(qs.execution_count, 0) AS DECIMAL(18,2)) AS avg_elapsed_ms,
    qs.last_execution_time,
    LEFT(REPLACE(REPLACE(
        SUBSTRING(st.text,
                  (qs.statement_start_offset/2)+1,
                  ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1),
        CHAR(13), ' '), CHAR(10), ' '), 260) AS stmt_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.dbid = DB_ID()
  AND st.text LIKE '%SET CODIGOLIQUIDACION%WHERE CODIGOLIQUIDACION%'
ORDER BY avg_logical_reads DESC;

/* =========================================================
   D) Estado de cola activa (operacional)
   ========================================================= */
SELECT
    COUNT(*) AS cola_activa_total
FROM dbo.P_COLA_TRANSACCIONES
WHERE PROCESADO = 0;
