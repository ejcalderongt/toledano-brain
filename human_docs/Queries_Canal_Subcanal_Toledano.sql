select CODIGO, NOMBRE, CANAL, SUBCANAL from P_CLIENTE where canal in (select CODIGO from p_canal  where CODIGO between '01' and '99')
or  subcanal in (select CODIGO from P_CANALSUB   where CANAL between '01' and '99')
select distinct canal, SUBCANAL from D_CLINUEVOT where canal in (select CODIGO from p_canal  where CODIGO between '01' and '99')
or subcanal in (select CODIGO from P_CANALSUB   where CANAL between '01' and '99')

select * from p_canal where codigo in (select * from D_CLINUEVO)

select * from P_CLIENTE
select * from D_CLINUEVO
select * from D_CLINUEVOT
select * from p_canal  where CODIGO between '01' and '99'
select * from P_CANALSUB   where CANAL between '01' and '99'


