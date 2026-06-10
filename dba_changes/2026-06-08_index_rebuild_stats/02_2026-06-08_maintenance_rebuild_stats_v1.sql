SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

/*
Mantenimiento post-purga (enfoque controlado):
1) Reorganize 10-30% frag en indices grandes
2) Rebuild >30% frag en indices grandes
3) UPDATE STATISTICS FULLSCAN en tablas clave de liquidacion
*/

DECLARE @cmd NVARCHAR(MAX);

DECLARE c_reorg CURSOR FAST_FORWARD FOR
SELECT
    'ALTER INDEX [' + i.name + '] ON [' + OBJECT_SCHEMA_NAME(ips.object_id) + '].[' + OBJECT_NAME(ips.object_id) + '] REORGANIZE;'
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_id > 0
  AND ips.page_count >= 1000
  AND ips.avg_fragmentation_in_percent >= 10
  AND ips.avg_fragmentation_in_percent < 30;

OPEN c_reorg;
FETCH NEXT FROM c_reorg INTO @cmd;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @cmd;
    EXEC sp_executesql @cmd;
    FETCH NEXT FROM c_reorg INTO @cmd;
END
CLOSE c_reorg;
DEALLOCATE c_reorg;

DECLARE c_rebuild CURSOR FAST_FORWARD FOR
SELECT
    'ALTER INDEX [' + i.name + '] ON [' + OBJECT_SCHEMA_NAME(ips.object_id) + '].[' + OBJECT_NAME(ips.object_id) + '] REBUILD WITH (SORT_IN_TEMPDB = ON);'
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_id > 0
  AND ips.page_count >= 1000
  AND ips.avg_fragmentation_in_percent >= 30;

OPEN c_rebuild;
FETCH NEXT FROM c_rebuild INTO @cmd;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @cmd;
    EXEC sp_executesql @cmd;
    FETCH NEXT FROM c_rebuild INTO @cmd;
END
CLOSE c_rebuild;
DEALLOCATE c_rebuild;

UPDATE STATISTICS dbo.P_STOCK WITH FULLSCAN;
UPDATE STATISTICS dbo.P_STOCKB WITH FULLSCAN;
UPDATE STATISTICS dbo.P_INVENTARIO_RUTA WITH FULLSCAN;
UPDATE STATISTICS dbo.P_INVENTARIO_BARRAS_RUTA WITH FULLSCAN;
UPDATE STATISTICS dbo.P_COLA_TRANSACCIONES WITH FULLSCAN;
UPDATE STATISTICS dbo.D_FACTURA WITH FULLSCAN;
UPDATE STATISTICS dbo.D_NOTACRED WITH FULLSCAN;
UPDATE STATISTICS dbo.D_CxC WITH FULLSCAN;
UPDATE STATISTICS dbo.D_COBRO WITH FULLSCAN;
UPDATE STATISTICS dbo.D_MOV WITH FULLSCAN;
UPDATE STATISTICS dbo.D_DEPOS WITH FULLSCAN;
