/*
DBMS PRACTICAL CRASH FILE
Dialect: Microsoft SQL Server (T-SQL), except explicitly marked MySQL / MongoDB.
Run one practical section at a time. GO separates SQL Server batches.
*/

-- =========================================================
-- PRACTICAL 1: ER MODEL - LIBRARY MANAGEMENT SYSTEM
-- Q1: ER model (textual mapping)
-- MEMBER 1:M ISSUE; BOOK 1:M ISSUE; PUBLISHER 1:M BOOK;
-- BOOK M:N AUTHOR through BOOK_AUTHOR.
-- =========================================================

-- Q2: Create relational tables
CREATE TABLE Publisher (
    PublisherID INT PRIMARY KEY,
    PublisherName VARCHAR(80) NOT NULL
);
CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    Name VARCHAR(80) NOT NULL,
    Phone VARCHAR(15),
    Address VARCHAR(150)
);
CREATE TABLE Book (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    ISBN VARCHAR(20) UNIQUE,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    PublisherID INT NOT NULL REFERENCES Publisher(PublisherID)
);
CREATE TABLE Author (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(80) NOT NULL
);
CREATE TABLE Book_Author (
    BookID INT REFERENCES Book(BookID),
    AuthorID INT REFERENCES Author(AuthorID),
    PRIMARY KEY (BookID, AuthorID)
);
CREATE TABLE Issue (
    IssueID INT PRIMARY KEY,
    MemberID INT REFERENCES Member(MemberID),
    BookID INT REFERENCES Book(BookID),
    IssueDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL
);
GO

-- Q3: Insert sample data and display member, book and issue dates
INSERT INTO Publisher VALUES (1,'Pearson'),(2,'OReilly');
INSERT INTO Member VALUES (1,'Rahul','9876543210','Pune'),(2,'Priya','9876500000','Mumbai');
INSERT INTO Book VALUES
(101,'DBMS','ISBN101',500,1),(102,'Python','ISBN102',600,2);
INSERT INTO Author VALUES (1,'Navathe'),(2,'Guido');
INSERT INTO Book_Author VALUES (101,1),(102,2);
INSERT INTO Issue VALUES
(1,1,101,'2026-11-01','2026-11-15',NULL),
(2,2,102,'2026-11-02','2026-11-16','2026-11-10');

SELECT m.Name, b.Title, i.IssueDate, i.DueDate, i.ReturnDate
FROM Issue i
JOIN Member m ON i.MemberID=m.MemberID
JOIN Book b ON i.BookID=b.BookID;
GO

-- Q4: Every book with its authors
SELECT b.Title, a.AuthorName
FROM Book b
JOIN Book_Author ba ON b.BookID=ba.BookID
JOIN Author a ON ba.AuthorID=a.AuthorID;
GO

-- Q5: Books issued but not returned
SELECT b.Title, m.Name, i.DueDate
FROM Issue i
JOIN Book b ON i.BookID=b.BookID
JOIN Member m ON i.MemberID=m.MemberID
WHERE i.ReturnDate IS NULL;
GO


-- =========================================================
-- PRACTICAL 2: DDL AND CONSTRAINTS
-- =========================================================
CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL UNIQUE CHECK (DeptName <> ''),
    Location VARCHAR(50)
);
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(80) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Age INT CHECK (Age >= 18),
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    DeptID INT NOT NULL,
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DeptID)
        REFERENCES Department(DeptID)
);
GO
-- Q1: Display table structure (SQL Server)
EXEC sp_help 'Employee';
GO
-- Q2: Insert valid records and display
INSERT INTO Department VALUES (1,'HR','Pune'),(2,'IT','Mumbai');
INSERT INTO Employee VALUES
(1,'Asha','asha@mail.com',20,30000,1),
(2,'Ravi','ravi@mail.com',22,50000,2);
SELECT * FROM Employee;
GO
-- Q3: CHECK constraint violation (expected error)
-- INSERT INTO Employee VALUES (3,'Test','t@mail.com',16,20000,1);
-- Q4: FOREIGN KEY violation (expected error)
-- INSERT INTO Employee VALUES (4,'Test','t2@mail.com',20,20000,99);
-- Q5: UNIQUE violation (expected error)
-- INSERT INTO Employee VALUES (5,'Test','asha@mail.com',20,20000,1);
-- Q6: Add HireDate column
ALTER TABLE Employee ADD HireDate DATE;
EXEC sp_help 'Employee';
GO
-- Extra common DDL
-- ALTER TABLE Employee ADD City VARCHAR(30);
-- ALTER TABLE Employee DROP COLUMN City;
-- DROP TABLE Employee; -- drop child table before Department


-- =========================================================
-- COMMON DATASET FOR PRACTICALS 3 TO 7 AND 9
-- =========================================================
CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(30),
    Location VARCHAR(30)
);
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(60),
    Salary INT,
    DeptID INT NULL,
    HireDate DATE,
    Bonus INT NULL,
    ManagerID INT NULL
);
INSERT INTO Department VALUES
(1,'HR','Pune'),(2,'IT','Mumbai'),(3,'Sales','Delhi'),
(4,'Marketing','Pune'),(5,'Legal','Nagpur');
INSERT INTO Employees VALUES
(101,'Rahul Sharma',35250,1,'2021-05-10',2000,102),
(102,'Priya Mehta',55800,2,'2020-08-15',NULL,105),
(103,'Amit Verma',70500,3,'2019-03-22',5000,105),
(104,'Sneha Reddy',44800,1,'2022-01-12',NULL,103),
(105,'Karan Patel',81200,3,'2018-07-05',7000,NULL),
(106,'Neha Singh',29900,4,'2023-02-18',1500,103),
(107,'Arjun Rao',61000,2,'2021-11-03',NULL,102),
(108,'Pooja Nair',39500,4,'2022-07-21',1000,106),
(109,'Isha Rao',48000,NULL,'2024-01-15',NULL,102);
GO

-- =========================================================
-- PRACTICAL 3: DML AND FILTERING
-- =========================================================
-- Q1: Insert new employee
INSERT INTO Employees(EmpID,EmpName,Salary,DeptID,HireDate,Bonus,ManagerID)
VALUES (110,'Isha Rao',48000,2,'2024-01-15',NULL,102);
SELECT * FROM Employees WHERE EmpID=110;
GO
-- Q2: Increase IT (DeptID 2) salary by 10%
UPDATE Employees SET Salary=Salary*1.10 WHERE DeptID=2;
SELECT * FROM Employees WHERE DeptID=2;
GO
-- Q3: Delete employees earning below 30000
DELETE FROM Employees WHERE Salary<30000;
SELECT * FROM Employees;
GO
-- Q4: Departments 2 and 3, salary > 50000, descending
SELECT * FROM Employees
WHERE DeptID IN (2,3) AND Salary>50000
ORDER BY Salary DESC;
GO
-- Q5: Top 3 highest paid (SQL Server)
SELECT TOP 3 * FROM Employees ORDER BY Salary DESC;
GO
-- Q6: Names starting with A
SELECT * FROM Employees WHERE EmpName LIKE 'A%';
GO
-- Q7: No bonus
SELECT * FROM Employees WHERE Bonus IS NULL;
GO
-- Q8: Hired in date range
SELECT * FROM Employees
WHERE HireDate BETWEEN '2020-01-01' AND '2021-12-31';
GO


-- =========================================================
-- PRACTICAL 4: JOINS
-- =========================================================
-- Q1: INNER JOIN
SELECT e.EmpName,d.DeptName
FROM Employees e INNER JOIN Department d ON e.DeptID=d.DeptID;
GO
-- Q2: LEFT JOIN - all employees
SELECT e.EmpName,d.DeptName
FROM Employees e LEFT JOIN Department d ON e.DeptID=d.DeptID;
GO
-- Q3: RIGHT JOIN - all departments
SELECT e.EmpName,d.DeptName
FROM Employees e RIGHT JOIN Department d ON e.DeptID=d.DeptID;
GO
-- Q4: FULL OUTER JOIN
SELECT e.EmpName,d.DeptName
FROM Employees e FULL OUTER JOIN Department d ON e.DeptID=d.DeptID;
GO
-- Q5: SELF JOIN - employee and manager
SELECT e.EmpName AS Employee,m.EmpName AS Manager
FROM Employees e LEFT JOIN Employees m ON e.ManagerID=m.EmpID;
GO
-- Q6: CROSS JOIN and number of combinations
SELECT COUNT(*) AS TotalCombinations
FROM Employees CROSS JOIN Department;
-- To display combinations:
SELECT e.EmpName,d.DeptName FROM Employees e CROSS JOIN Department d;
GO
-- Q7: Employee count in every department, including zero
SELECT d.DeptName,COUNT(e.EmpID) AS EmployeeCount
FROM Department d LEFT JOIN Employees e ON d.DeptID=e.DeptID
GROUP BY d.DeptID,d.DeptName;
GO


-- =========================================================
-- PRACTICAL 5: AGGREGATES, GROUP BY, HAVING, ROLLUP, CUBE
-- =========================================================
-- Q1: Overall aggregate values
SELECT COUNT(*) AS TotalEmployees, SUM(Salary) AS TotalSalary,
       AVG(Salary) AS AverageSalary, MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary
FROM Employees;
GO
-- Q2: Department-wise count and average salary
SELECT DeptID,COUNT(*) AS EmployeeCount,AVG(Salary) AS AvgSalary
FROM Employees GROUP BY DeptID;
GO
-- Q3: Departments with average salary > 50000
SELECT DeptID,AVG(Salary) AS AvgSalary
FROM Employees GROUP BY DeptID
HAVING AVG(Salary)>50000;
GO
-- Q4: Count employees receiving bonus and total bonus per department
SELECT DeptID,COUNT(Bonus) AS BonusCount,SUM(Bonus) AS TotalBonus
FROM Employees GROUP BY DeptID;
GO
-- Q5: ROLLUP - department totals and grand total
SELECT DeptID,SUM(Salary) AS TotalSalary
FROM Employees GROUP BY ROLLUP(DeptID);
GO
-- Q6: CUBE for DeptID and bonus status, departments 1 and 2
SELECT DeptID,
       CASE WHEN Bonus IS NULL THEN 'No Bonus' ELSE 'Bonus' END AS BonusStatus,
       SUM(Salary) AS TotalSalary
FROM Employees
WHERE DeptID IN (1,2)
GROUP BY CUBE(DeptID,
       CASE WHEN Bonus IS NULL THEN 'No Bonus' ELSE 'Bonus' END);
GO


-- =========================================================
-- PRACTICAL 6: SUBQUERIES AND CTEs
-- =========================================================
-- Q1: Salary greater than overall average (scalar subquery)
SELECT * FROM Employees
WHERE Salary>(SELECT AVG(Salary) FROM Employees);
GO
-- Q2: Salary greater than ALL employees of IT department (DeptID 2)
SELECT * FROM Employees
WHERE Salary>ALL(SELECT Salary FROM Employees WHERE DeptID=2);
GO
-- Q3: Departments having at least one employee (EXISTS)
SELECT d.* FROM Department d
WHERE EXISTS (SELECT 1 FROM Employees e WHERE e.DeptID=d.DeptID);
GO
-- Q4: Departments having no employee (NOT IN)
SELECT * FROM Department
WHERE DeptID NOT IN (SELECT DeptID FROM Employees WHERE DeptID IS NOT NULL);
GO
-- Q5: Employees earning more than their own department average
SELECT e.* FROM Employees e
WHERE Salary>(SELECT AVG(e2.Salary) FROM Employees e2
              WHERE e2.DeptID=e.DeptID);
GO
-- Q6: CTE with department average shown beside each employee
WITH DeptAverage AS (
    SELECT DeptID,AVG(Salary) AS AvgSalary
    FROM Employees GROUP BY DeptID
)
SELECT e.EmpName,e.Salary,e.DeptID,d.AvgSalary
FROM Employees e JOIN DeptAverage d ON e.DeptID=d.DeptID;
GO
-- Q7: Recursive CTE management hierarchy
WITH EmployeeHierarchy AS (
    SELECT EmpID,EmpName,ManagerID,0 AS [Level]
    FROM Employees WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmpID,e.EmpName,e.ManagerID,h.[Level]+1
    FROM Employees e
    JOIN EmployeeHierarchy h ON e.ManagerID=h.EmpID
)
SELECT * FROM EmployeeHierarchy
ORDER BY [Level],EmpID
OPTION (MAXRECURSION 100);
GO


-- =========================================================
-- PRACTICAL 7: WINDOW FUNCTIONS
-- =========================================================
-- Q1: ROW_NUMBER, RANK and DENSE_RANK by department
SELECT EmpName,DeptID,Salary,
 ROW_NUMBER() OVER(PARTITION BY DeptID ORDER BY Salary DESC) AS RowNum,
 RANK() OVER(PARTITION BY DeptID ORDER BY Salary DESC) AS SalaryRank,
 DENSE_RANK() OVER(PARTITION BY DeptID ORDER BY Salary DESC) AS DenseRank
FROM Employees;
GO
-- Q2: Top 2 paid employees in each department
WITH Ranked AS (
 SELECT *,DENSE_RANK() OVER(PARTITION BY DeptID ORDER BY Salary DESC) AS rnk
 FROM Employees
)
SELECT * FROM Ranked WHERE rnk<=2;
GO
-- Q3: Previous salary, next salary and difference from previous
SELECT EmpName,Salary,
 LAG(Salary) OVER(ORDER BY Salary) AS PreviousSalary,
 LEAD(Salary) OVER(ORDER BY Salary) AS NextSalary,
 Salary-LAG(Salary) OVER(ORDER BY Salary) AS DifferenceFromPrevious
FROM Employees;
GO
-- Q4: Running total ordered by hire date
SELECT EmpName,HireDate,Salary,
 SUM(Salary) OVER(ORDER BY HireDate ROWS BETWEEN UNBOUNDED PRECEDING
                  AND CURRENT ROW) AS RunningTotal
FROM Employees;
GO
-- Q5: Department average and difference
SELECT EmpName,Salary,DeptID,
 AVG(Salary) OVER(PARTITION BY DeptID) AS DeptAverage,
 Salary-AVG(Salary) OVER(PARTITION BY DeptID) AS Difference
FROM Employees;
GO
-- Q6: Divide employees into 4 salary groups
SELECT EmpName,Salary,NTILE(4) OVER(ORDER BY Salary DESC) AS SalaryQuartile
FROM Employees;
GO
-- Q7: Highest-paid employee name in each department
SELECT EmpName,DeptID,Salary,
 FIRST_VALUE(EmpName) OVER(PARTITION BY DeptID ORDER BY Salary DESC) AS HighestPaidInDept
FROM Employees;
GO


-- =========================================================
-- PRACTICAL 8: NORMALIZATION
-- =========================================================
-- Q1: Display original denormalized data / redundancy
CREATE TABLE StudentCourse (
 StudentID VARCHAR(5), StudentName VARCHAR(50),
 CourseID VARCHAR(5), CourseName VARCHAR(50),
 InstructorID VARCHAR(5), InstructorName VARCHAR(50),
 Phone VARCHAR(15), Hobby VARCHAR(30)
);
INSERT INTO StudentCourse VALUES
('S1','Rahul Sharma','C1','DBMS','I1','Rukshar','9876543210','Chess'),
('S1','Rahul Sharma','C1','DBMS','I1','Rukshar','9876543210','Music'),
('S1','Rahul Sharma','C2','Python','I2','Meera','9822334455','Chess'),
('S1','Rahul Sharma','C2','Python','I2','Meera','9822334455','Music'),
('S2','Priya Mehta','C1','DBMS','I1','Rukshar','9876543210','Music');
SELECT * FROM StudentCourse;
GO
-- Q2: Demonstrate update anomaly (update only one repeated row)
UPDATE StudentCourse SET Phone='9000000000'
WHERE StudentID='S1' AND CourseID='C1' AND Hobby='Chess';
SELECT InstructorID,InstructorName,Phone FROM StudentCourse WHERE InstructorID='I1';
GO
-- Q3: Decompose into Student, Instructor, Course, Enrolment
CREATE TABLE Student (
 StudentID VARCHAR(5) PRIMARY KEY, StudentName VARCHAR(50)
);
CREATE TABLE Instructor (
 InstructorID VARCHAR(5) PRIMARY KEY, InstructorName VARCHAR(50), Phone VARCHAR(15)
);
CREATE TABLE Course (
 CourseID VARCHAR(5) PRIMARY KEY, CourseName VARCHAR(50),
 InstructorID VARCHAR(5) REFERENCES Instructor(InstructorID)
);
CREATE TABLE Enrolment (
 StudentID VARCHAR(5) REFERENCES Student(StudentID),
 CourseID VARCHAR(5) REFERENCES Course(CourseID),
 PRIMARY KEY(StudentID,CourseID)
);
INSERT INTO Student VALUES ('S1','Rahul Sharma'),('S2','Priya Mehta');
INSERT INTO Instructor VALUES
('I1','Rukshar','9876543210'),('I2','Meera','9822334455');
INSERT INTO Course VALUES ('C1','DBMS','I1'),('C2','Python','I2');
INSERT INTO Enrolment VALUES ('S1','C1'),('S1','C2'),('S2','C1');
SELECT * FROM Student;
SELECT * FROM Instructor;
SELECT * FROM Course;
SELECT * FROM Enrolment;
GO
-- Q4: 4NF table for independent hobbies
CREATE TABLE StudentHobby (
 StudentID VARCHAR(5) REFERENCES Student(StudentID),
 Hobby VARCHAR(30),
 PRIMARY KEY(StudentID,Hobby)
);
INSERT INTO StudentHobby VALUES
('S1','Chess'),('S1','Music'),('S2','Music');
SELECT * FROM StudentHobby;
GO
-- Q5: Rebuild enrolled student-course-instructor relation.
-- Compare against distinct student/course facts; hobbies are independent,
-- so do not join StudentHobby unless intentionally creating combinations.
SELECT s.StudentID,s.StudentName,c.CourseID,c.CourseName,
       i.InstructorID,i.InstructorName,i.Phone,sh.Hobby
FROM Enrolment e
JOIN Student s ON e.StudentID=s.StudentID
JOIN Course c ON e.CourseID=c.CourseID
JOIN Instructor i ON c.InstructorID=i.InstructorID
JOIN StudentHobby sh ON sh.StudentID=s.StudentID;
-- For this sample, this produces the original 5 student-course-hobby combinations.
GO
-- Q6: Update instructor phone once and display courses with instructor
UPDATE Instructor SET Phone='9111111111' WHERE InstructorID='I1';
SELECT c.CourseName,i.InstructorName,i.Phone
FROM Course c JOIN Instructor i ON c.InstructorID=i.InstructorID;
GO


-- =========================================================
-- PRACTICAL 9: VIEWS AND QUERY PERFORMANCE
-- =========================================================
-- Q1: View for IT employees
CREATE VIEW EmpDeptView AS
SELECT e.EmpName,e.Salary,d.DeptName
FROM Employees e JOIN Department d ON e.DeptID=d.DeptID
WHERE d.DeptName='IT';
GO
SELECT * FROM EmpDeptView;
GO
-- Q2: Department summary view
CREATE VIEW DeptSummary AS
SELECT d.DeptID,d.DeptName,COUNT(e.EmpID) AS EmployeeCount,
       COALESCE(SUM(e.Salary),0) AS TotalSalary
FROM Department d LEFT JOIN Employees e ON d.DeptID=e.DeptID
GROUP BY d.DeptID,d.DeptName;
GO
SELECT * FROM DeptSummary;
GO
-- Q3: Departments with total salary > 100000
SELECT * FROM DeptSummary WHERE TotalSalary>100000;
GO
-- Q4: SQL Server equivalent of EXPLAIN before index
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM Employees WHERE EmpName='Rahul Sharma';
-- Also select "Include Actual Execution Plan" in SSMS (Ctrl+M), then execute.
GO
-- Q5: Create index and analyse again
CREATE INDEX IX_Employees_EmpName ON Employees(EmpName);
SELECT * FROM Employees WHERE EmpName='Rahul Sharma';
-- Compare actual execution plan and STATISTICS IO/TIME with the previous query.
GO
-- Q6: Drop view and try query (second statement intentionally errors)
DROP VIEW EmpDeptView;
-- SELECT * FROM EmpDeptView;
GO
-- MySQL alternative for practical manual:
-- EXPLAIN SELECT * FROM Employees WHERE EmpName='Rahul Sharma';
-- CREATE INDEX idx_empname ON Employees(EmpName);
-- EXPLAIN SELECT * FROM Employees WHERE EmpName='Rahul Sharma';


-- =========================================================
-- PRACTICAL 10: TRANSACTIONS, PROCEDURES, FUNCTIONS, TRIGGERS,
-- ROLES AND MONGODB
-- =========================================================
CREATE TABLE Account (
 AccNo INT PRIMARY KEY, CustName VARCHAR(50), Balance DECIMAL(12,2)
);
INSERT INTO Account VALUES (101,'Arun',20000),(102,'Sharvari',50000),(103,'Ganesh',15000);
GO
-- Q1: Transfer 5000 and COMMIT
BEGIN TRANSACTION;
UPDATE Account SET Balance=Balance-5000 WHERE AccNo=101;
UPDATE Account SET Balance=Balance+5000 WHERE AccNo=102;
COMMIT TRANSACTION;
SELECT * FROM Account;
GO
-- Q2: Debit then ROLLBACK
SELECT * FROM Account; -- before
BEGIN TRANSACTION;
UPDATE Account SET Balance=Balance-5000 WHERE AccNo=101;
SELECT * FROM Account; -- inside transaction
ROLLBACK TRANSACTION;
SELECT * FROM Account; -- restored after rollback
GO
-- Q3: SAVEPOINT - undo credit but keep debit
BEGIN TRANSACTION;
UPDATE Account SET Balance=Balance-5000 WHERE AccNo=101;
SAVE TRANSACTION AfterDebit;
UPDATE Account SET Balance=Balance+5000 WHERE AccNo=102;
ROLLBACK TRANSACTION AfterDebit;
COMMIT TRANSACTION;
SELECT * FROM Account;
GO
-- Q4: Stored procedure to deposit and function to return balance
CREATE PROCEDURE proc_deposit
 @AccNo INT, @Amount DECIMAL(12,2)
AS
BEGIN
 UPDATE Account SET Balance=Balance+@Amount WHERE AccNo=@AccNo;
END;
GO
CREATE FUNCTION fn_balance(@AccNo INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
 DECLARE @Bal DECIMAL(12,2);
 SELECT @Bal=Balance FROM Account WHERE AccNo=@AccNo;
 RETURN @Bal;
END;
GO
EXEC proc_deposit @AccNo=101,@Amount=2500;
SELECT dbo.fn_balance(101) AS CurrentBalance;
GO
-- Q5: Audit trigger stores old and new balance on UPDATE
CREATE TABLE Account_Audit (
 AuditID INT IDENTITY(1,1) PRIMARY KEY,
 AccNo INT, OldBalance DECIMAL(12,2), NewBalance DECIMAL(12,2),
 ChangedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO
CREATE TRIGGER trg_Account_Audit
ON Account
AFTER UPDATE
AS
BEGIN
 INSERT INTO Account_Audit(AccNo,OldBalance,NewBalance)
 SELECT d.AccNo,d.Balance,i.Balance
 FROM deleted d JOIN inserted i ON d.AccNo=i.AccNo;
END;
GO
EXEC proc_deposit @AccNo=101,@Amount=2500;
SELECT * FROM Account_Audit;
GO
-- Q6: Roles and privileges (run with suitable admin permission)
CREATE ROLE clerk;
CREATE ROLE manager;
GRANT SELECT,INSERT ON dbo.Account TO clerk;
GRANT SELECT,INSERT,UPDATE,DELETE ON dbo.Account TO manager;
-- Create a database user first if one does not exist:
-- CREATE USER clerk_user WITHOUT LOGIN;
-- ALTER ROLE clerk ADD MEMBER clerk_user;
REVOKE INSERT ON dbo.Account FROM clerk;
-- SQL Server role grants:
SELECT dp.name AS RoleName, perm.permission_name, perm.state_desc
FROM sys.database_permissions perm
JOIN sys.database_principals dp ON perm.grantee_principal_id=dp.principal_id
WHERE dp.name='clerk';
GO

-- Q7 & Q8: MongoDB commands (run in mongosh, NOT SQL Server)
/*
use BankingDB
db.account.insertMany([
 {accNo:101,custName:"Arun",balance:20000,branch:"Pune"},
 {accNo:102,custName:"Sharvari",balance:50000,branch:"Mumbai"},
 {accNo:103,custName:"Ganesh",balance:15000,branch:"Pune"},
 {accNo:104,custName:"Meera",balance:8000,branch:"Mumbai"}
])
// Find balance > 5000
db.account.find({balance:{$gt:5000}})
// Update account 101 balance
db.account.updateOne({accNo:101},{$set:{balance:12000}})
// Delete account 104
db.account.deleteOne({accNo:104})
// Display all
db.account.find()

// Q8: total balance and customer count per branch
db.account.aggregate([
 {$group:{_id:"$branch",
          totalBalance:{$sum:"$balance"},
          customerCount:{$sum:1}}}
])
*/
