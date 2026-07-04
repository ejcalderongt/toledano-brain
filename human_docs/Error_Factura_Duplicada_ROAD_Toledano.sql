select * from d_Factura where corel in ('8033-1_240916095321','8033-1_240916094002')
select * from d_Facturad where corel in ('8033-1_240916095321','8033-1_240916094002')

select * from mi3_sap where codigoliquidacion = 327918 and estatus = 'T'

select * from d_factura where serie = '201' and corelativo = 1321
select * from d_facturad where corel = '8033-1_240916095321'
select * from d_facturad_lotes where corel = '8033-1_240916095321'
select * from d_factura where serie = '201' and corelativo = 1320
select * from d_facturad where corel = '8033-1_240916094002'
select * from d_facturad_lotes where corel = '8033-1_240916094002'

select * from d_facturad where corel in (select corel from d_factura where ruta = '8033-1' and fecha = '20240916')
and PRODUCTO = '0493'

select * from p_stock where ruta = '8033-1' and fecha = '20240916' and codigo = '0493'