SET NOCOUNT ON;

/*
Diagnostico sistematico de rendimiento post-purga:
- Fragmentacion por indice
- Estadisticas desactualizadas
- Densidad/paginas de tablas clave
*/

DECLARE @dbid INT = DB_ID();

;WITH frag AS
(
    SELECT
        OBJECT_SCHEMA_NAME(ips.object_id, @dbid) AS schema_name,
        OBJECT_NAME(ips.object_id, @dbid) AS table_name,
        i.name AS index_name,
        ips.index_type_desc,
        ips.avg_fragmentation_in_percent,
        ips.page_count
    FROM sys.dm_db_index_physical_stats(@dbid, NULL, NULL, NULL, 'SAMPLED') ips
    JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
    WHERE ips.database_id = @dbid
      AND ips.index_id > 0
      AND ips.page_count >= 1000
)
SELECT TOP (200)
    schema_name, table_name, index_name, index_type_desc,
    CAST(avg_fragmentation_in_percent AS DECIMAL(10,2)) AS frag_pct,
    page_count
FROM frag
ORDER BY avg_fragmentation_in_percent DESC, page_count DESC;

;WITH st AS
(
    SELECT
        OBJECT_SCHEMA_NAME(s.object_id, @dbid) AS schema_name,
        OBJECT_NAME(s.object_id, @dbid) AS table_name,
        s.name AS stats_name,
        sp.last_updated,
        sp.rows,
        sp.modification_counter
    FROM sys.stats s
    OUTER APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
    WHERE OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
)
SELECT TOP (300)
    schema_name, table_name, stats_name, last_updated, rows, modification_counter
FROM st
WHERE last_updated IS NULL
   OR modification_counter >= 1000
ORDER BY modification_counter DESC, last_updated ASC;

SELECT
    t.name AS table_name,
    SUM(ps.row_count) AS rows_total,
    SUM(ps.reserved_page_count) * 8.0 / 1024 AS reserved_mb
FROM sys.dm_db_partition_stats ps
JOIN sys.tables t ON t.object_id = ps.object_id
WHERE ps.index_id IN (0,1)
  AND t.name IN ('P_STOCKB','P_STOCK','P_INVENTARIO_BARRAS_RUTA','P_INVENTARIO_RUTA','P_COLA_TRANSACCIONES','D_FACTURA','D_NOTACRED','D_CxC')
GROUP BY t.name
ORDER BY reserved_mb DESC;

