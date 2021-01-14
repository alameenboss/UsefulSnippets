USE [master]
GO

Drop Database IF EXISTS [FishGraphDB] 
GO

Create Database [FishGraphDB]
GO

USE [FishGraphDB]
GO

DROP TABLE IF EXISTS FishEmployees;
GO
CREATE TABLE FishEmployees (
  EmpID INT IDENTITY PRIMARY KEY,
  FirstName NVARCHAR(50) NOT NULL
) AS NODE;
INSERT INTO FishEmployees (FirstName) VALUES
('Fred'), ('Rita'), ('Filip'), ('Adil'), ('Dora'),
('Mao'), ('Miguel'), ('Nalini'), ('Ben'), ('Barb'),
('Chen'), ('Gus'), ('Ane'), ('Don'), ('Joyce');

GO


DROP TABLE IF EXISTS ReportsTo;
GO
CREATE TABLE ReportsTo AS EDGE;
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 1), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 5));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 2), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 1));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 3), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 1));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 4), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 1));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 6), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 4));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 7), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 4));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 8), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 5));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 9), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 8));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 10), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 8));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 11), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 8));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 6), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 11));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 7), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 11));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 12), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 8));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 13), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 8));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 14), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 11));
INSERT INTO ReportsTo ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 15), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 11));

GO



DROP TABLE IF EXISTS WorksFor;
GO
CREATE TABLE WorksFor AS EDGE;
INSERT INTO WorksFor ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 2), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 9));
INSERT INTO WorksFor ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 12), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 9));
INSERT INTO WorksFor ($from_id, $to_id) VALUES (
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 13), 
  (SELECT $node_id FROM FishEmployees WHERE EmpID = 9));



--Returning employee data
SELECT emp1.FirstName Employee, emp2.FirstName Manager
FROM FishEmployees emp1, ReportsTo, FishEmployees emp2
WHERE MATCH(emp1-(ReportsTo)->emp2)
ORDER BY Employee, Manager;
-------
SELECT emp1.FirstName Employee, emp2.FirstName Manager
FROM FishEmployees emp1, WorksFor, FishEmployees emp2
WHERE MATCH(emp1-(WorksFor)->emp2)
ORDER BY Employee, Manager;
-------
SELECT emp2.EmpID MgrID, emp2.FirstName Manager
FROM FishEmployees emp1, ReportsTo, FishEmployees emp2
WHERE MATCH(emp1-(ReportsTo)->emp2)
  AND emp1.FirstName = 'barb';
-------
WITH rt AS
(
  SELECT $from_id FromID
  FROM ReportsTo
  GROUP BY $from_id
  HAVING COUNT(*) > 1
)
SELECT emp1.FirstName Employee, emp2.FirstName Manager
FROM FishEmployees emp1, ReportsTo, FishEmployees emp2
WHERE MATCH(emp1-(ReportsTo)->emp2)
  AND ReportsTo.$from_id IN (SELECT FromID FROM rt)
ORDER BY Employee, Manager;
-------
SELECT emp1.FirstName Employee, 
  emp2.FirstName ReportsTo, emp3.FirstName WorksFor
FROM FishEmployees emp1, ReportsTo, FishEmployees emp2, 
  WorksFor, FishEmployees emp3
WHERE MATCH(emp2<-(ReportsTo)-emp1-(WorksFor)->emp3)
ORDER BY Employee;
-------
SELECT emp1.EmpID, emp1.FirstName Employee
FROM FishEmployees emp1, WorksFor, FishEmployees emp2
WHERE MATCH(emp1-(WorksFor)->emp2)
  AND emp2.FirstName = 'Ben';
-------

SELECT emp1.EmpID, emp1.FirstName Employee
FROM FishEmployees emp1, ReportsTo, FishEmployees emp2
WHERE MATCH(emp1-(ReportsTo)->emp2)
  AND emp2.FirstName = 'Nalini';
-------
  WITH emp AS
(
  SELECT $node_id NodeID, FirstName Employee, 
    CAST(NULL AS NVARCHAR(50)) Manager
  FROM FishEmployees
  WHERE FirstName = 'Nalini'
  UNION ALL
  SELECT fe.$node_id, fe.FirstName Employee, emp.Employee Manager
  FROM FishEmployees fe INNER JOIN ReportsTo rt
      ON fe.$node_id = rt.$from_id 
   INNER JOIN emp
      ON rt.$to_id = emp.NodeID
)
SELECT Employee, Manager FROM emp
WHERE Manager IS NOT NULL;
-------

WITH emp AS
(
  SELECT $node_id NodeID, FirstName Employee, 
    CAST('N/A' AS NVARCHAR(50)) Manager, 1 AS Tier
  FROM FishEmployees
  WHERE FirstName = 'Dora'
  UNION ALL
  SELECT fe.$node_id, fe.FirstName Employee, emp.Employee Manager, 
    (Tier + 1) AS Tier
  FROM FishEmployees fe INNER JOIN ReportsTo rt
      ON fe.$node_id = rt.$from_id 
    INNER JOIN emp
      ON rt.$to_id = emp.NodeID
)
SELECT Employee, Tier, Manager 
FROM emp
ORDER BY Tier, Manager, Employee;
-------

WITH emp AS
(
  SELECT $node_id NodeID, FirstName Employee, 
    CAST('N/A' AS NVARCHAR(50)) Manager, 1 AS Tier
  FROM FishEmployees
  WHERE FirstName = 'Dora'
  UNION ALL
  SELECT fe.$node_id, fe.FirstName Employee, emp.Employee Manager, 
    (Tier + 1) AS Tier
  FROM FishEmployees fe INNER JOIN ReportsTo rt
      ON fe.$node_id = rt.$from_id 
	INNER JOIN emp
      ON rt.$to_id = emp.NodeID
)
SELECT Employee, Manager 
FROM emp
WHERE Tier = 3
ORDER BY Tier, Manager, Employee;


DROP FUNCTION IF EXISTS GetEmployees;
GO
CREATE FUNCTION GetEmployees (@empid int)  
RETURNS TABLE  
AS  
RETURN   
(  
WITH emp AS
(
  SELECT $node_id NodeID, EmpID, FirstName Employee, 0 AS Tier
  FROM FishEmployees
  WHERE EmpID = @empid
  UNION ALL
  SELECT fe.$node_id, fe.EmpID, fe.FirstName Employee, 
      (Tier + 1) AS Tier
  FROM FishEmployees fe INNER JOIN ReportsTo rt
      ON fe.$node_id = rt.$from_id 
   INNER JOIN emp ON rt.$to_id = emp.NodeID
)
SELECT EmpID, Employee, Tier FROM emp
);  
GO

DELETE ReportsTo
WHERE $from_id = (SELECT $node_id FROM FishEmployees WHERE EmpID = 6)
  AND $to_id = (SELECT $node_id FROM FishEmployees WHERE EmpID = 11);
DELETE ReportsTo
WHERE $from_id = (SELECT $node_id FROM FishEmployees WHERE EmpID = 7)
  AND $to_id = (SELECT $node_id FROM FishEmployees WHERE EmpID = 11);

  DROP TABLE IF EXISTS #temp;
GO
CREATE TABLE #temp(
  MgrID INT,
  MgrName VARCHAR(50),
  EmpID INT,
  EmpName NVARCHAR(50),
  Tier INT);
DECLARE  @mgrid INT = 
  (SELECT MIN(EmpID) FROM FishEmployees);
WHILE @mgrid IS NOT NULL
BEGIN
  DECLARE @mgrname NVARCHAR(50) = 
    (SELECT FirstName FROM FishEmployees WHERE EmpID = @mgrid);
  INSERT INTO #temp
  SELECT DISTINCT @mgrid, @mgrname, EmpID, Employee, Tier 
    FROM GetEmployees(@mgrid);
  SELECT @mgrid = MIN(EmpID) FROM FishEmployees WHERE EmpID > @mgrid;
END;


SELECT STUFF((SELECT '<-' + fe.FirstName
  FROM #temp t1 INNER JOIN #temp t2 ON t2.EmpID = t1.EmpID
    INNER JOIN FishEmployees fe ON fe.EmpID = t2.MgrID
  WHERE t1.MgrID = t.MgrID  
    AND t1.EmpID <> t1.MgrID
    AND t1.EmpID = t.EmpID
  ORDER BY t2.Tier DESC
  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') 
    AS ReportTrail
FROM #temp t
WHERE t.MgrID = 
  (SELECT EmpID FROM FishEmployees 
    WHERE FirstName LIKE 'Dora') 
  AND t.EmpID <> t.MgrID
ORDER BY ReportTrail;


--Select * from FishEmployees
--Select * from ReportsTo
--Select * from WorksFor

--Drop Table WorksFor
--Drop Table ReportsTo
--Drop Table FishEmployees
