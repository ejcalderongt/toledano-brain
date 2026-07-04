 SELECT P_USUARIO.CODIGO, P_USUARIO.NOMBRE AS DESCRIPCION, SUCURSAL,P_USUARIO.ACTIVO,P_USUARIO.CLAVE, P_USUARIO.COD_ROL
 FROM P_USUARIO LEFT JOIN P_ROL ON P_USUARIO.COD_ROL = P_ROL.COD_ROL  
 WHERE P_USUARIO.Nombre LIKE '%quija%' AND SUCURSAL = '3905' AND P_USUARIO.ACTIVO = 1

 select * from P_MENUROL where IDMENU ='1.10.4' and VISIBLE = 1

 select distinct ROL, CODIGO, SUCURSAL
 from P_USUARIO_SUCURSAL 
 where ROL in ( select COD_ROL from P_MENUROL where IDMENU ='1.10.4' and VISIBLE = 1)
 and CODIGO in (select codigo from P_USUARIO where ACTIVO = 1)
 

 select us.SUCURSAL, u.CODIGO, u.NOMBRE, us.ROL--, r.NOMBRE, us.SUCURSAL
 from P_USUARIO u inner join 
      P_USUARIO_SUCURSAL us ON us.CODIGO = u.CODIGO inner join
	  P_ROL r on r.COD_ROL = us.ROL and r.COD_SUCURSAL = us.SUCURSAL inner join
      P_MENUROL m on us.ROL = m.COD_ROL and us.SUCURSAL = m.COD_SUCURSAL 
 where u.ACTIVO = 1 and m.IDMENU ='1.10.4' and m.VISIBLE = 1  

 select * from P_USUARIO_SUCURSAL where ROL in (13,55)
select * from P_USUARIO where CODIGO in ('cfuentes','admin','jsantimateo')

 select * from P_MENUROL where COD_ROL = 13 and  IDMENU ='1.10.4' and VISIBLE = 1