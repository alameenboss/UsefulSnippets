USE [master]
GO

Drop Database IF EXISTS [CommonAuditTable] 
GO

Create Database [CommonAuditTable]
GO

USE [CommonAuditTable]
GO

DROP TABLE IF EXISTS [dbo].[CommonAuditLog]
GO
DROP TABLE IF EXISTS [dbo].[Book]
GO
DROP TRIGGER IF EXISTS [dbo].[TrgBookIUD]
GO

CREATE TABLE CommonAuditLog (
	CommonAuditLogId bigint IDENTITY(1,1),
	TableName varchar(100) Not Null,
    Id bigint NOT NULL,
    OldRowData nvarchar(1000) CHECK(ISJSON(OldRowData) = 1),
    NewRowData nvarchar(1000) CHECK(ISJSON(NewRowData) = 1),
    DmlType varchar(10) NOT NULL CHECK (DmlType IN ('INSERT', 'UPDATE', 'DELETE')),
    DmlTimestamp datetime NOT NULL,
    TrxTimestamp datetime NOT NULL,
    PRIMARY KEY (CommonAuditLogId)
) 
GO

CREATE TABLE Book (
    BookId bigint IDENTITY(1,1),
    Author nvarchar(255),
    PriceInCents int,
    Publisher varchar(255),
    Title varchar(255),
    PRIMARY KEY (BookId)
) 

GO

CREATE TRIGGER [dbo].[TrgBookIUD] 
    ON [dbo].[Book] 
    FOR INSERT, UPDATE, DELETE 
AS 
	DECLARE @transactionTimestamp datetime = SYSUTCdatetime()
    IF (SELECT COUNT(*) FROM inserted) > 0 
    BEGIN 
        IF (SELECT COUNT(*) FROM deleted) > 0 
        BEGIN 
			INSERT INTO CommonAuditLog (Id,TableName,OldRowData,NewRowData,DmlType,DmlTimestamp,TrxTimestamp)
			VALUES((SELECT BookId FROM Inserted),'Book',
			(SELECT * FROM Deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
			(SELECT * FROM Inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
			'UPDATE',CURRENT_TIMESTAMP,@transactionTimestamp);
        END 
        ELSE 
        BEGIN 
			INSERT INTO CommonAuditLog (Id,TableName,OldRowData,NewRowData,DmlType,DmlTimestamp,TrxTimestamp)
			VALUES(
			(SELECT BookId FROM Inserted),'Book',null,
			(SELECT * FROM Inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),'INSERT',CURRENT_TIMESTAMP,@transactionTimestamp); 
        END 
    END 
    ELSE 
    BEGIN 
		INSERT INTO CommonAuditLog (Id,TableName,OldRowData,NewRowData,DmlType,DmlTimestamp,TrxTimestamp)
		VALUES((SELECT BookId FROM Deleted),'Book',(SELECT * FROM Deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
		null,'DELETE',CURRENT_TIMESTAMP,@transactionTimestamp);
END 

GO

CREATE TABLE Employee (
    EmployeeId bigint IDENTITY(1,1),
    [Name] nvarchar(255),
    DepartmentId int
    PRIMARY KEY (EmployeeId)
) 

GO

CREATE TRIGGER [dbo].[TrgEmployeeIUD] 
    ON [dbo].[Employee] 
    FOR INSERT, UPDATE, DELETE 
AS 
	DECLARE @transactionTimestamp datetime = SYSUTCdatetime()
    IF (SELECT COUNT(*) FROM inserted) > 0 
    BEGIN 
        IF (SELECT COUNT(*) FROM deleted) > 0 
        BEGIN 
			INSERT INTO CommonAuditLog (Id,TableName,OldRowData,NewRowData,DmlType,DmlTimestamp,TrxTimestamp)
			VALUES((SELECT EmployeeId FROM Inserted),'Employee',
			(SELECT * FROM Deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
			(SELECT * FROM Inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
			'UPDATE',CURRENT_TIMESTAMP,@transactionTimestamp);
        END 
        ELSE 
        BEGIN 
			INSERT INTO CommonAuditLog (Id,TableName,OldRowData,NewRowData,DmlType,DmlTimestamp,TrxTimestamp)
			VALUES(
			(SELECT EmployeeId FROM Inserted),'Employee',null,
			(SELECT * FROM Inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),'INSERT',CURRENT_TIMESTAMP,@transactionTimestamp); 
        END 
    END 
    ELSE 
    BEGIN 
		INSERT INTO CommonAuditLog (Id,TableName,OldRowData,NewRowData,DmlType,DmlTimestamp,TrxTimestamp)
		VALUES((SELECT EmployeeId FROM Deleted),'Employee',(SELECT * FROM Deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
		null,'DELETE',CURRENT_TIMESTAMP,@transactionTimestamp);
END 

GO
---------------------------------------------------------------------------------

INSERT INTO Book (Author,PriceInCents,Publisher,Title) VALUES 
('Vlad Mihalcea',3990,'Amazon','High-Performance Java Persistence 1st edition')
GO
INSERT INTO Book (Author,PriceInCents,Publisher,Title) VALUES 
('Author2',3990,'Amazon','Book2')
GO
UPDATE Book SET PriceInCents = 4499 WHERE Title = 'High-Performance Java Persistence 1st edition'
GO
DELETE FROM Book WHERE Title = 'High-Performance Java Persistence 1st edition'
GO

INSERT INTO Employee([Name],DepartmentId) VALUES 
('Vlad Mihalcea',1)
GO
UPDATE Employee SET DepartmentId = 2 WHERE [Name] = 'Vlad Mihalcea'
GO
DELETE FROM Employee WHERE [Name] = 'Vlad Mihalcea'
GO

----------------------------------------------------------------------------------
Select * from Book
Select * from Employee
Select * from CommonAuditLog
Select * from CommonAuditLog Where Id = 1 and TableName = 'Book'
order by TrxTimestamp desc
