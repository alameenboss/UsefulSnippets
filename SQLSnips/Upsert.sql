Drop Table Employee
Create Table Employee  
(  
    Id INT IDENTITY(1,1) PRIMARY KEY,  
    EmpName VARCHAR(35),  
    Position VARCHAR(50),  
    [Location] VARCHAR(50),  
    Age INT,  
    Salary DECIMAL 
)

Declare @tblTypeEmployee AS TABLE  
(  
    Id INT ,  
    EmpName VARCHAR(35),  
    Position VARCHAR(50),  
    [Location] VARCHAR(50),  
    Age INT,  
    Salary DECIMAL  
)
INSERT INTO @tblTypeEmployee ([ID],[EmpName],[Position],[Location],Age,Salary)   
VALUES (1,'Cedric Kelly','Senior Javascript Developer','Edinburgh',22,43360)  
      ,(2,'Dai Riosy','Personnel Lead','London',22,43360)  
      ,(3,'Cara Stevens','Sales Assistant','Edinburgh',22,43360)  
      ,(4,'Thor Walton','Senior Developer','Sydney',27,217500)  
      ,(5,'Paul Byrd','Team Leader','Sydney',42,92575)  
      ,(6,'Finn Camacho','Software Engineer','California',34,372000)  
      ,(7,'Rhona Davidson','Integration Specialist','Newyork',37,725000)  
      ,(12,'Michelle House','Support Engineer','California',28,98540)
SET IDENTITY_INSERT [dbo].[Employee] ON 
MERGE Employee  AS dbEmployee  
    USING @tblTypeEmployee AS tblTypeEmp  
    ON (dbEmployee.Id = tblTypeEmp.Id)  
  
    WHEN  MATCHED THEN  
        UPDATE SET  EmpName = tblTypeEmp.EmpName,   
                    Position = tblTypeEmp.Position,  
                    [Location]= tblTypeEmp.[Location],  
                    Age= tblTypeEmp.Age,  
                    Salary= tblTypeEmp.Salary  
  
    WHEN NOT MATCHED THEN  
        INSERT ([Id],[EmpName],[Position],[Location],Age,Salary)  
        VALUES (tblTypeEmp.Id,tblTypeEmp.EmpName,tblTypeEmp.Position,tblTypeEmp.[Location],tblTypeEmp.Age,tblTypeEmp.Salary); 

SET IDENTITY_INSERT [dbo].[Employee] OFF

		Select * from Employee