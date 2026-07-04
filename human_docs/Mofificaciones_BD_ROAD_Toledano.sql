alter table p_medida
alter COLUMN CODIGO_CGI NVARCHAR(15) NULL

ALTER TABLE P_EMPRESA
ADD UNIDAD_MEDIDA_DEFECTO NVARCHAR(15) NULL

ALTER TABLE D_NOTACRED ALTER COLUMN CUFE_FACTURA NVARCHAR(150)NULL

alter table p_empresa add AMBIENTE nvarchar(10) null

ALTER TABLE D_CXC ADD TIPO_DOCUMENTO NVARCHAR(10) null

--UPDATE P_EMPRESA SET UNIDAD_MEDIDA_DEFECTO = 'und'

select * from P_RUTA where WLFOLD like '%movil%'


select * from P_MENUSISTEMA where NOMBRE_LGCO = 'tsmiReportes'
select * from P_MENUSISTEMA where NOMBRE_LGCO = 'tsmiSeguridad'

select * from P_USUARIO where COD_ROL in (
select * from P_MENUROL where IDMENU = '5' and COD_ROL in (4,17,31,45))and SUCURSAL = '3900'
select * from P_MENUROL where IDMENU = '5' and COD_ROL in (4,17,31,45)
select * from P_MENUROL where IDMENU = '4' and COD_ROL in (4,17,31,45)

select * from P_ROL where nombre = 'Visor' 


