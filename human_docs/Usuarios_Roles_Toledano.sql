select u.CODIGO Código, u.NOMBRE Usuario,us.SUCURSAL Sucursal, us.ROL IdRol, r.NOMBRE Rol, r.DESCRIPCION Descripcion_Rol
from P_USUARIO_SUCURSAL us inner join P_USUARIO u ON us.CODIGO = u.CODIGO
inner join P_ROL r on u.COD_ROL = r.COD_ROL