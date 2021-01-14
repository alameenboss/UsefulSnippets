Select 'Union Select '''+ TABLE_NAME +''', Count(*) from ' + TABLE_NAME from Information_Schema.tables Where TABLE_TYPE ='BASE TABLE'
Select 'DBCC CHECKIDENT ('''+ TABLE_NAME +''')' from Information_Schema.tables Where TABLE_TYPE ='BASE TABLE'
Select * from Information_Schema.tables Where TABLE_TYPE ='BASE TABLE'
DBCC CHECKIDENT ('Emp')  