Declare @Test as Table (TestId Int Identity(1,1),Id Int)
Insert into @Test (Id) values (1),(2),(3)

Declare @TestUpdation as Table (Id Int)
Insert into @TestUpdation values (1),(4),(5),(6)

MERGE @Test AS TARGET
USING @TestUpdation AS SOURCE 
ON (TARGET.Id = SOURCE.Id) 

WHEN MATCHED
THEN UPDATE SET TARGET.Id = SOURCE.ID

WHEN NOT MATCHED BY TARGET 
THEN INSERT (Id) VALUES (SOURCE.Id)

WHEN NOT MATCHED BY SOURCE 
THEN DELETE ;
Select * from @Test;
GO


