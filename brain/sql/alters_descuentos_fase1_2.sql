/* =========================================================
   ROAD TOLEDANO - ALTERS FASE 1.2 (Descuentos/Combos SAP)
   Autor: Codex
   Fecha: 2026-06-01

   OBJETIVO
   - Facilitar trazabilidad de integración SAP -> ROAD sin romper
     el motor comercial vigente en P_DESCUENTO / P_DESCUENTO_COMBO_DET.

   PRINCIPIOS
   - No destruir ni reestructurar claves actuales.
   - Mantener compatibilidad con BOF/RDC7/HH.
   - Documentar semántica funcional por columna (MS_Description).

   REGLAS DE NEGOCIO YA CONFIRMADAS
   - CTIPO es catálogo fijo (0..14) hardcodeado en BOF/HH.
   - PTIPO es catálogo fijo; en Fase 1.2 se habilita valor 6=combo.
   - GLOBDESC='S': aplica al total de factura.
   - GLOBDESC='N': aplica por línea de producto.
   - CLIENTE='*': aplica para todos los clientes (según CTIPO correspondiente).
   - PRODUCTO='*': aplica a todos los productos.
   ========================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   TABLA: dbo.P_DESCUENTO
   ========================================================= */

/*
  1) ES_ORIGEN_INTEGRACION
  Propósito:
    Identificar si la fila de descuento/recargo proviene de integración SAP/WebAPI.
  Uso operativo:
    - Soporte y auditoría.
    - Filtrado para análisis de incidencias por origen.
  Valores:
    0 = ROAD interno (mantenimientos BOF, procesos locales, carga legacy)
    1 = Integración externa (payload SAP)
*/
IF COL_LENGTH('dbo.P_DESCUENTO', 'ES_ORIGEN_INTEGRACION') IS NULL
BEGIN
    ALTER TABLE dbo.P_DESCUENTO
    ADD ES_ORIGEN_INTEGRACION bit NOT NULL
        CONSTRAINT DF_P_DESCUENTO_ES_ORIGEN_INTEGRACION DEFAULT (0);
END
GO

/*
  2) ID_CONDICION_EXTERNA / ID_PROMOCION_EXTERNA / TIPO_CONDICION_EXTERNA
  Propósito:
    Trazabilidad directa de campos SAP sin depender de parseo de NOMBRE.
  Relación esperada:
    - ID_CONDICION_EXTERNA  ~ RegCond (KNUMH)
    - ID_PROMOCION_EXTERNA  ~ Promo (KNUMA_AG)
    - TIPO_CONDICION_EXTERNA ~ KSCHL (ZK94..ZR97)
  Impacto:
    No altera cálculo comercial, solo transparencia de integración.
*/
IF COL_LENGTH('dbo.P_DESCUENTO', 'ID_CONDICION_EXTERNA') IS NULL
BEGIN
    ALTER TABLE dbo.P_DESCUENTO
    ADD ID_CONDICION_EXTERNA nvarchar(25) NULL;
END
GO

IF COL_LENGTH('dbo.P_DESCUENTO', 'ID_PROMOCION_EXTERNA') IS NULL
BEGIN
    ALTER TABLE dbo.P_DESCUENTO
    ADD ID_PROMOCION_EXTERNA nvarchar(25) NULL;
END
GO

IF COL_LENGTH('dbo.P_DESCUENTO', 'TIPO_CONDICION_EXTERNA') IS NULL
BEGIN
    ALTER TABLE dbo.P_DESCUENTO
    ADD TIPO_CONDICION_EXTERNA nvarchar(4) NULL;
END
GO

IF COL_LENGTH('dbo.P_DESCUENTO', 'ID_TRAZA_INTEGRACION') IS NULL
BEGIN
    ALTER TABLE dbo.P_DESCUENTO
    ADD ID_TRAZA_INTEGRACION nvarchar(60) NULL;
END
GO

/*
  3) Restricción CTIPO (catálogo fijo hardcodeado)
  Catálogo válido:
    0 = Todos clientes
    1 = Código cliente
    2 = Tipo de negocio
    3 = Tipo de cliente
    4 = Subtipo cliente
    5 = Canal
    6 = Subcanal
    7 = Región
    8 = Sucursal
    9 = Nivel precio
    10 = Grupo clientes
    11 = Ruta
    12 = Tipologia - Ramo 3
    13 = Priorizacion
    14 = Ramo 4
  Nota:
    Se aplica WITH NOCHECK para evitar bloqueo por registros históricos.
  Regla complementaria:
    Puede coexistir CLIENTE='*' para reglas "todos" (ej. CTIPO=0).
*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_P_DESCUENTO_CTIPO_0_14'
)
BEGIN
    ALTER TABLE dbo.P_DESCUENTO WITH NOCHECK
    ADD CONSTRAINT CK_P_DESCUENTO_CTIPO_0_14
    CHECK (CTIPO BETWEEN 0 AND 14);
END
GO

/*
  4) Restricción PTIPO (catálogo fijo + extensión combo)
  Valores permitidos:
    0..5 = catálogo legado ROAD
    6    = combo
  Regla fase 1.2:
    Cuando PTIPO=6, la mecánica debe resolver detalle en P_DESCUENTO_COMBO_DET.
*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_P_DESCUENTO_PTIPO_0_6'
)
BEGIN
    ALTER TABLE dbo.P_DESCUENTO WITH NOCHECK
    ADD CONSTRAINT CK_P_DESCUENTO_PTIPO_0_6
    CHECK (PTIPO BETWEEN 0 AND 6);
END
GO

/* =========================================================
   TABLA: dbo.P_DESCUENTO_COMBO_DET
   ========================================================= */

/*
  5) TIPO_PARTICIPACION_COMBO (opcional recomendado)
  Propósito:
    Hacer explícito el rol del producto dentro del combo.
  Valores:
    D = DISPARADOR (producto condición para activar combo)
    B = BENEFICIO  (producto al que se aplica descuento/recargo)
  Nota:
    Se mantiene GRUPO para compatibilidad legacy y transición progresiva.
*/
IF COL_LENGTH('dbo.P_DESCUENTO_COMBO_DET', 'TIPO_PARTICIPACION_COMBO') IS NULL
BEGIN
    ALTER TABLE dbo.P_DESCUENTO_COMBO_DET
    ADD TIPO_PARTICIPACION_COMBO char(1) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_P_DESCUENTO_COMBO_DET_PARTICIPACION'
)
BEGIN
    ALTER TABLE dbo.P_DESCUENTO_COMBO_DET WITH NOCHECK
    ADD CONSTRAINT CK_P_DESCUENTO_COMBO_DET_PARTICIPACION
    CHECK (TIPO_PARTICIPACION_COMBO IN ('D', 'B') OR TIPO_PARTICIPACION_COMBO IS NULL);
END
GO

/* =========================================================
   DESCRIPCIONES (MS_Description) resumidas por columna nueva
   ========================================================= */

-- P_DESCUENTO.ES_ORIGEN_INTEGRACION
BEGIN TRY
    EXEC sp_dropextendedproperty @name='MS_Description',
      @level0type='SCHEMA',@level0name='dbo',
      @level1type='TABLE',@level1name='P_DESCUENTO',
      @level2type='COLUMN',@level2name='ES_ORIGEN_INTEGRACION';
END TRY BEGIN CATCH END CATCH;
EXEC sp_addextendedproperty @name='MS_Description',
  @value='Origen de regla: 0=ROAD interno (BOF/local), 1=integración externa (SAP/WebAPI).',
  @level0type='SCHEMA',@level0name='dbo',
  @level1type='TABLE',@level1name='P_DESCUENTO',
  @level2type='COLUMN',@level2name='ES_ORIGEN_INTEGRACION';
GO

-- P_DESCUENTO.ID_CONDICION_EXTERNA
BEGIN TRY
    EXEC sp_dropextendedproperty @name='MS_Description',
      @level0type='SCHEMA',@level0name='dbo',
      @level1type='TABLE',@level1name='P_DESCUENTO',
      @level2type='COLUMN',@level2name='ID_CONDICION_EXTERNA';
END TRY BEGIN CATCH END CATCH;
EXEC sp_addextendedproperty @name='MS_Description',
  @value='Id externo de condición recibido por integración (equivalente a RegCond/KNUMH).',
  @level0type='SCHEMA',@level0name='dbo',
  @level1type='TABLE',@level1name='P_DESCUENTO',
  @level2type='COLUMN',@level2name='ID_CONDICION_EXTERNA';
GO

-- P_DESCUENTO.ID_PROMOCION_EXTERNA
BEGIN TRY
    EXEC sp_dropextendedproperty @name='MS_Description',
      @level0type='SCHEMA',@level0name='dbo',
      @level1type='TABLE',@level1name='P_DESCUENTO',
      @level2type='COLUMN',@level2name='ID_PROMOCION_EXTERNA';
END TRY BEGIN CATCH END CATCH;
EXEC sp_addextendedproperty @name='MS_Description',
  @value='Id externo de promoción recibido por integración (equivalente a Promo/KNUMA_AG).',
  @level0type='SCHEMA',@level0name='dbo',
  @level1type='TABLE',@level1name='P_DESCUENTO',
  @level2type='COLUMN',@level2name='ID_PROMOCION_EXTERNA';
GO

-- P_DESCUENTO.TIPO_CONDICION_EXTERNA
BEGIN TRY
    EXEC sp_dropextendedproperty @name='MS_Description',
      @level0type='SCHEMA',@level0name='dbo',
      @level1type='TABLE',@level1name='P_DESCUENTO',
      @level2type='COLUMN',@level2name='TIPO_CONDICION_EXTERNA';
END TRY BEGIN CATCH END CATCH;
EXEC sp_addextendedproperty @name='MS_Description',
  @value='Tipo de condición externa (KSCHL SAP): ZK94..ZK97 y ZR94..ZR97.',
  @level0type='SCHEMA',@level0name='dbo',
  @level1type='TABLE',@level1name='P_DESCUENTO',
  @level2type='COLUMN',@level2name='TIPO_CONDICION_EXTERNA';
GO

-- P_DESCUENTO.ID_TRAZA_INTEGRACION
BEGIN TRY
    EXEC sp_dropextendedproperty @name='MS_Description',
      @level0type='SCHEMA',@level0name='dbo',
      @level1type='TABLE',@level1name='P_DESCUENTO',
      @level2type='COLUMN',@level2name='ID_TRAZA_INTEGRACION';
END TRY BEGIN CATCH END CATCH;
EXEC sp_addextendedproperty @name='MS_Description',
  @value='Identificador de traza técnica para correlación request/respuesta (traceId integración).',
  @level0type='SCHEMA',@level0name='dbo',
  @level1type='TABLE',@level1name='P_DESCUENTO',
  @level2type='COLUMN',@level2name='ID_TRAZA_INTEGRACION';
GO

-- P_DESCUENTO_COMBO_DET.TIPO_PARTICIPACION_COMBO
BEGIN TRY
    EXEC sp_dropextendedproperty @name='MS_Description',
      @level0type='SCHEMA',@level0name='dbo',
      @level1type='TABLE',@level1name='P_DESCUENTO_COMBO_DET',
      @level2type='COLUMN',@level2name='TIPO_PARTICIPACION_COMBO';
END TRY BEGIN CATCH END CATCH;
EXEC sp_addextendedproperty @name='MS_Description',
  @value='Rol del producto en combo: D=Disparador, B=Beneficio.',
  @level0type='SCHEMA',@level0name='dbo',
  @level1type='TABLE',@level1name='P_DESCUENTO_COMBO_DET',
  @level2type='COLUMN',@level2name='TIPO_PARTICIPACION_COMBO';
GO

/* FIN SCRIPT */
