begin transaction

update P_USUARIO set ACTIVO = 0, FEC_AGR = GETDATE(), FEC_MOD = GETDATE(), USER_AGR = 'cfuentes', USER_MOD = 'cfuentes'
where codigo not in ('aguerrero','adminbt','adminch','admindi','admin','agutierrez','aarena','Amedina','arivas',
'AMateo','atorres','asistente_3900','robot_3900','apinzon','asamaniego','bdgracia ','cbarrios','cfuentes','CConcha ',
'drodriguezch','dmoreno','dmerchant','ddiaz','dvergara','darauz','etejeira','earauzch','EGracia','evillarreal','eagudelo',
'fsolis','gisaza','gaguirre','gperez','gremon','GGaitan','Giperez','icastañeda','irodriguez ','jguerra','jquiroz',
'jvigilbt','jcarriondi','jarosemena ','jvillarreal','jhenriquez','jsantimateo','jvega','jzerda','kquijada','kmontenegro',
'karauzch ','kalvarez','lhase','LBARRIA','lbonilladi','LBurgos','lgonzalez','lsamaniego','mfernandez','mcontedi','mespino',
'mdegraciabt','natencio','NMascol','nnoriega','ncedeno','nreyes','OGONZALEZ','prleon','rtack','rgilliard','rcadiz',
'scedeno','svergara','Stecnico','thernandezbt','tsolanilla ','vwong ','vvisuettich','yespinosa','YMartinez ','YMerchant ',
'ydominguez','ytorresdi','yquielch','YRamos','yescobar','zmacias')

update P_USUARIO set ACTIVO = 1, FEC_AGR = GETDATE(), FEC_MOD = GETDATE(), USER_AGR = 'cfuentes', USER_MOD = 'cfuentes'
where codigo in ('aguerrero','adminbt','adminch','admindi','admin','agutierrez','aarena','Amedina','arivas',
'AMateo','atorres','asistente_3900','robot_3900','apinzon','asamaniego','bdgracia ','cbarrios','cfuentes','CConcha ',
'drodriguezch','dmoreno','dmerchant','ddiaz','dvergara','darauz','etejeira','earauzch','EGracia','evillarreal','eagudelo',
'fsolis','gisaza','gaguirre','gperez','gremon','GGaitan','Giperez','icastañeda','irodriguez ','jguerra','jquiroz',
'jvigilbt','jcarriondi','jarosemena ','jvillarreal','jhenriquez','jsantimateo','jvega','jzerda','kquijada','kmontenegro',
'karauzch ','kalvarez','lhase','LBARRIA','lbonilladi','LBurgos','lgonzalez','lsamaniego','mfernandez','mcontedi','mespino',
'mdegraciabt','natencio','NMascol','nnoriega','ncedeno','nreyes','OGONZALEZ','prleon','rtack','rgilliard','rcadiz',
'scedeno','svergara','Stecnico','thernandezbt','tsolanilla ','vwong ','vvisuettich','yespinosa','YMartinez ','YMerchant ',
'ydominguez','ytorresdi','yquielch','YRamos','yescobar','zmacias')

insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3900'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('aguerrero','admin','agutierrez','aarena','Amedina','arivas','AMateo','atorres','asistente_3900',
'robot_3900','apinzon','asamaniego','bdgracia ','cbarrios','cfuentes','CConcha ','dmoreno','ddiaz','dvergara',
'etejeira','evillarreal','eagudelo','fsolis','gisaza','gperez','gremon','GGaitan','Giperez','icastañeda','irodriguez ',
'jguerra','jquiroz','jarosemena ','jvillarreal','jhenriquez','jsantimateo','jvega','jzerda','kalvarez','lhase','LBARRIA',
'lgonzalez','lsamaniego','mfernandez','mcontedi','mespino','NMascol','nnoriega','ncedeno','nreyes','OGONZALEZ',
'prleon','rtack','rgilliard','scedeno','svergara','Stecnico','tsolanilla ','vwong ','vvisuettich','yespinosa',
'YMartinez ','YMerchant ','ydominguez','YRamos','yescobar','zmacias')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3900' and r.IDMODULO =1 )

insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3903'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('aguerrero','admin','agutierrez','aarena','Amedina','arivas','AMateo','atorres','asistente_3900',
'robot_3900','apinzon','asamaniego','bdgracia ','cbarrios','cfuentes','CConcha ','dmoreno','ddiaz','dvergara',
'etejeira','evillarreal','eagudelo','fsolis','gisaza','gperez','gremon','GGaitan','Giperez','icastañeda','irodriguez ',
'jguerra','jquiroz','jarosemena ','jvillarreal','jhenriquez','jsantimateo','jvega','jzerda','kalvarez','lhase','LBARRIA',
'lgonzalez','lsamaniego','mfernandez','mcontedi','mespino','NMascol','nnoriega','ncedeno','nreyes','OGONZALEZ',
'prleon','rtack','rgilliard','scedeno','svergara','Stecnico','tsolanilla ','vwong ','vvisuettich','yespinosa',
'YMartinez ','YMerchant ','ydominguez','YRamos','yescobar','zmacias')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3903' and r.IDMODULO =1 )

insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3904'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('aguerrero','admin','agutierrez','aarena','Amedina','arivas','AMateo','atorres','asistente_3900',
'robot_3900','apinzon','asamaniego','bdgracia ','cbarrios','cfuentes','CConcha ','dmoreno','ddiaz','dvergara',
'etejeira','evillarreal','eagudelo','fsolis','gisaza','gperez','gremon','GGaitan','Giperez','icastañeda','irodriguez ',
'jguerra','jquiroz','jarosemena ','jvillarreal','jhenriquez','jsantimateo','jvega','jzerda','kalvarez','lhase','LBARRIA',
'lgonzalez','lsamaniego','mfernandez','mcontedi','mespino','NMascol','nnoriega','ncedeno','nreyes','OGONZALEZ',
'prleon','rtack','rgilliard','scedeno','svergara','Stecnico','tsolanilla ','vwong ','vvisuettich','yespinosa',
'YMartinez ','YMerchant ','ydominguez','YRamos','yescobar','zmacias')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3904' and r.IDMODULO =1 )

insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3905'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('aguerrero','admin','agutierrez','aarena','Amedina','arivas','AMateo','atorres','asistente_3900',
'robot_3900','apinzon','asamaniego','bdgracia ','cbarrios','cfuentes','CConcha ','dmoreno','ddiaz','dvergara',
'etejeira','evillarreal','eagudelo','fsolis','gisaza','gperez','gremon','GGaitan','Giperez','icastañeda','irodriguez ',
'jguerra','jquiroz','jarosemena ','jvillarreal','jhenriquez','jsantimateo','jvega','jzerda','kalvarez','lhase','LBARRIA',
'lgonzalez','lsamaniego','mfernandez','mcontedi','mespino','NMascol','nnoriega','ncedeno','nreyes','OGONZALEZ',
'prleon','rtack','rgilliard','scedeno','svergara','Stecnico','tsolanilla ','vwong ','vvisuettich','yespinosa',
'YMartinez ','YMerchant ','ydominguez','YRamos','yescobar','zmacias')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3905' and r.IDMODULO =1 )

--Solo Bocas
insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL],
'3904'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('adminbt','jvigilbt','mdegraciabt','thernandezbt')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3904' and r.IDMODULO =1 )

--Solo David
insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3903'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('adminch','drodriguezch','dmerchant','darauz','earauzch','EGracia','kmontenegro','karauzch ',
'rcadiz','yquielch')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3903' and r.IDMODULO =1 )

--Solo Divisa
insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3905'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('admindi','jcarriondi','kquijada','lbonilladi','LBurgos','ytorresdi')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3905' and r.IDMODULO =1 )

--Solo Panamá
insert into P_USUARIO_SUCURSAL
select ROW_NUMBER() OVER(ORDER BY codigo ASC) + 
(select isnull(max([IDUSUARIOSUCURSAL]),0) FROM P_USUARIO_SUCURSAL) AS [IDUSUARIOSUCURSAL], 
'3900'[SUCURSAL], [CODIGO], COD_ROL [ROL],1 [IDMODULO], 1 [ACTIVO], 
'cfuentes' [USER_AGR], getdate()[FEC_AGR],  'cfuentes' [USER_MOD], getdate()[FEC_MOD]
from P_USUARIO u
where CODIGO in ('natencio')
and exists (select COD_ROL from P_ROL r where r.COD_ROL = u.COD_ROL and r.COD_SUCURSAL = '3900' and r.IDMODULO =1 )
commit transaction