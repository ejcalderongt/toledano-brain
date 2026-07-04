use ROADSAP
select * from P_STOCK where documento = '0083630542'
select * from P_STOCKB where documento = '0083630542'

 select * from P_STOCK where documento = '0083629772'
  select * from P_STOCKB where documento = '0083629772'

select distinct DOCUMENTO, CODIGO from P_STOCK where  ruta = '4032-6' and fecha = '20230207'
select distinct DOCUMENTO, CODIGO  from P_STOCKB where  ruta = '4032-6' and fecha = '20230207'





insert into p_doc_enviados_hh values('0083629772','4032-6','20230207',1)
delete from p_doc_enviados_hh where documento = '0083630542'

--update P_STOCK set enviado = 1, corel_d_mov = '4032-6_230207124743' where documento = '0083630542'
--update P_STOCKB  set enviado = 1, corel_d_mov = '4032-6_230207124743' where documento = '0083630542'
update P_STOCK set enviado =1, corel_d_mov = '4032-6_230207124743' where documento = '0083629772'
update P_STOCKB  set enviado = 1, corel_d_mov = '4032-6_230207124743' where documento = '0083629772'
update P_STOCK set enviado = 0, corel_d_mov = '' where documento = '0083630542'
update P_STOCKB  set enviado = 0, corel_d_mov = '' where documento = '0083630542'