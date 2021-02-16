Go
--***************************************
-- Insert table
--*************************************** 
Use BMSDB
Insert into Bank.Branch values   ('Halishahar','Chattagram'),
								('Kalapur','Dhaka'),
								('Coxbazar','Chattagram'),
								('Hobgoang','Syhlet'),
								('Natore','Rajshahi')

Go
Use BMSDB
insert into Bank.Accounts_Holder values ('Arif','Chittagong','01826 122 156',2,5),
									('Faiza','Dhaka','01826 122 156',2,3),
									('Kabir','Rajshahi','01826 122 156',3,1),
									('Nulufa','Syhlet','01826 122 156',4,1),
									('Titu','Chittagong','01826 122 156',5,5)

Go
Use BMSDB
insert into Bank.AccountsDetails values (1,'Savings',10000.00,2),
										(2,'FDR',10000.00,2),
										(3,'Savings',10000.00,3),
										(4,'Current',10000.00,4),
										(5,'Saving',10000.00,5)

Go
Use BMSDB
insert into Bank.Loan values  (4,4,100000,1),
							(5,5,50000,5),
							(3,3,20000,1),
							(1,2,50000,5),
							(2,2,100000,3)

Go
Use BMSDB
insert into Bank.Employee Values ('Nazmul','Cash','Cumilla','01883 811 567','19931565'),
								('Mesbha','ARO','Chittagong','01883 255 567','19931555'),
								('Srekantho','Ro','Coxbazar','01719 811 567','19931585'),
								('Mizan','SO','Chittagong','01552 811 567','19931598'),
								('Meghna','officer','Rahshahi','01925 811 567','19931525')
						
Go
--***************************************
-- Select Query
--***************************************
Go

Select Trans_ID,Trans_Type,Balance
from Bank.TransactionHistory

Go
--***************************************
-- Update Query
--***************************************
Update Bank.Accounts_Holder
Set Acc_HolderName='Ahmed Kabir'
Where  AccountNo=3

Go
--***************************************
-- Delete Query
--***************************************
Delete from Bank.Accounts_Holder
Where AccountNo=5

Go
--***************************************
-- Truncate Table
--***************************************
Truncate table TransactionHistory

Go
--***************************************
-- Six Cluse 
--***************************************
Select Balance,count(AccountNo) 
From Bank.AccountsDetails  
Where AccountType='Savings'
Group by Balance 
Having Count(AccountNo)>2000
Order by Balance Desc

--***************************************************
--SubQuery , Co-Related Subquery, Aggregate Function 
--****************************************************
Use BMSDB
Select Acc_HolderName
From Bank.Accounts_Holder  
Where Acc_HolderName in ( Select Min(Acc_HolderName) From Bank.Accounts_Holder )

Go
-- Co-Related Subquery
Use BMSDB
Select Acc_HolderName
From Bank.Accounts_Holder  a
join Bank.AccountsDetails  b
On a.AccountNo=b.AccountNo
Where AccountType in ( Select Max(Acc_HolderName) From Bank.Accounts_Holder  Where AccountType='Savings' Group by Balance  )

--*************************************************
--Average , Distinct, AND, OR,,NOT,BETWEEN,ALL,Any
--*************************************************
Go
SELECT AVG(DISTINCT Balance)  
FROM Bank.AccountsDetails 

Go
SELECT *   
FROM Bank.AccountsDetails   
WHERE AccountNo=1
OR AccountNo=2   
AND Balance > 1000
ORDER BY AccountNo DESC ;

Go

SELECT AccountNo,Balance   
FROM Bank.AccountsDetails    
WHERE AccountNo = ANY (SELECT AccountNo FROM Bank.AccountsDetails  WHERE Balance >= 10000 )
ORDER BY AccountType;

SELECT AccountNo,Balance
FROM Bank.AccountsDetails   
WHERE Balance > ALL (SELECT AVG (Balance)  FROM Bank.AccountsDetails  Group BY AccountNo )
ORDER BY Balance ;
 

Go

Select Trans_ID,AccountNo,Trans_Type
From Bank.TransactionHistory
Where Balance BETWEEN  10000 AND 70000
Order By Balance 

Go

Select Trans_ID,AccountNo,Trans_Type
From Bank.TransactionHistory
Where Balance NOT BETWEEN  10000 AND 70000
Order By Balance 


Go
--***************************************
-- All Join 	
--***************************************

-- Inner Join & Multi join 
Select a.BranchID,a.BranchName,a.City,b.Acc_HolderName,b.AccountNo, b.Address
From Bank.Branch	a
inner join Bank.Accounts_Holder  b
On a.BranchID=b.BranchID
join Bank.AccountsDetails c
On a.BranchID=b.BranchID	

GO
--Left Join 
Select a.BranchID,a.BranchID,b.AccountNo,b.AccountNo,b.EmployeeID
from Bank.Branch  a
left join Bank.Accounts_Holder  b
ON 	a.BranchID=b.BranchID

GO
--Right Join 
Select a.AccountNo,a.Acc_HolderName,a.EmployeeID,b.BranchID,b.BranchName
from Bank.Accounts_Holder  a
left join Bank.Branch b
ON 	a.BranchID=b.BranchID

GO
--Full Join 
Select a.BranchID,a.BranchID,b.AccountNo,b.AccountNo,b.EmployeeID
from Bank.Branch  a
Full join Bank.Accounts_Holder  b
ON 	a.BranchID=b.BranchID

GO
--Cross Join 
Select a.BranchID,a.BranchID,b.AccountNo,b.AccountNo,b.EmployeeID
from Bank.Branch a
Cross join Bank.Accounts_Holder b


Go
-- Self Join 

Select x.BranchName,y.City
From Bank.Branch as x ,Bank.Branch  as y
Where y.BranchID<>x.BranchID


-- Union operator
Select BranchID from Bank.Branch
Union 
Select BranchID from Bank.Accounts_Holder

-- Union all operator 
Select BranchID from Bank.Branch
Union 
Select BranchID from Bank.Accounts_Holder


Go
--***************************************
-- Cast & Convert 
--***************************************
Select [ date ] = Cast('1-June - 2019 10:00 AM' as Date )
Select [ Timedate ] = Convert(Time ,'1-June - 2019 10:00 AM'   )

Go
--***************************************
-- With Loop, If, Else and While
--***************************************
Declare @i int=0;
While @i <12
Begin
	If @i%2=0
		Begin
			Print @i
		End
	Else
		Begin
			Print Cast(@i as varchar) + 'Skip'
		End
	Set @i=@i+1-1*2/2
End


Go
--***************************************
-- Wild Card
--***************************************
Create View vw_employee
AS
Select EmployeeID,Emp_Name,MobileNo
From Bank.Employee
Where MobileNo Like '017%'
Or MobileNo like '018__ 5%'
With Check Option

Go
--***************************************
-- Floor, Round , Celling
--***************************************
Declare @Value decimal (10,2)
Set @Value =11.05
Select Round(@value,0)
Select Ceiling (@value)
Select Floor (@value)

-- Date Format
Select Getdate()
Select DATEDIFF ( YY,cast('06/06/1993' as datetime),GETDATE()) as Years,
       DATEDIFF ( MM,cast('06/06/1993' as datetime),GETDATE()) %12 As Months,
	   DATEDIFF ( DD,cast('06/06/1993' as datetime),GETDATE()) %30 as Days

Go
--***************************************
--CUBE,ROLLUP,Grouping BY
--***************************************

Select 'A' [Class],1[roll no],'a'[section],80 [marks] , 'Monju' [stuName]
into #tempTable
Union 
Select 'A',2,'a',70,'A Salam'
Union 
Select 'A',3,'a',80,'Noman'
Union 
Select 'A',4,'b',90,'Belal'
Union 
Select 'A',5,'b',90,'Faisal'
Union 
Select 'A',6,'b',50,'Mamun'
Union 
Select 'B',1,'a',60,'Naznin'
Union 
Select 'B',2,'a',50,'Nasir'
Union 
Select 'B',3,'a',80,'Kaium'
Union 
Select 'B',4,'b',90,'Mahmud'
Union 
Select 'B',5,'b',50,'Azim'
Union 
Select 'B',6,'b',70,'Mehedi'

Select * 
From #tempTable

-- RollUp

Select Class ,section,[roll no], sum(marks) as [Sum] 
From #tempTable
Group by Class,section , [roll no] with Rollup

-- With Cube
Select Class ,section,sum(marks) as [Sum] 
From #tempTable
Group by Class,section with Cube

-- Grouping set
Select Class ,section, [roll no], sum(marks) as [Sum] 
From #tempTable
Group by Grouping sets 
(
(Class,section ,[roll no])
,(class)
)

Go
--********************************************
--Transaction (Commit,Rollback,Save Point)
--********************************************

Begin Tran
Delete From Bank.Branch
Where BranchID=2

Go

Commit Tran

Go

RollBack Tran ;
Go

Begin tran 
Save Tran SP10
insert into Bank.Branch Values  ( 'Khatungoanj','Chittagong')

Go 

Begin Tran
Save Tran SP11
Update Bank.Branch 
set BranchName = 'Andorkilla ' Where BranchID =6

Go

Begin Tran
Save Tran SP12
Delete From Bank.Branch
Where BranchID=6


Rollback Tran SP10

Go

--***************************************
-- Sequence for Table
--***************************************
Use BMSDB
Create Sequence sq_Serial
	As Bigint
	Start With 1
	Increment By 1
	Minvalue 1
	Maxvalue 99999
	No Cycle
	Cache 10;
	GO

Select Next value for sq_Serial;
GO

--***************************************
-- CTE
--*************************************** 
With Branch_CTE (BranchID , BranchName,City)
As
(
Select BranchID, BranchName,City
From Bank.Branch 
Where BranchID is not null
)

Select *
From Branch_CTE



--***************************************************
-- Merge 
--***************************************************
Go
Create TABLE Bank.Category 
(
Category_id INT PRIMARY KEY,
Category_name VARCHAR(255) NOT NULL,
Amount DECIMAL(10 , 2 )
);

Go 
INSERT INTO Bank.Category  VALUES(1,'Children Bicycles',15000),
							(2,'Comfort Bicycles',25000),
							(3,'Cruisers Bicycles',13000),
							(4,'Cyclocross Bicycles',10000);
 
 Go
Create TABLE Bank.Category_staging 
(
Category_id INT PRIMARY KEY,
Category_name VARCHAR(255) NOT NULL,
Amount DECIMAL(10 , 2 )
);
 
 Go
INSERT INTO Bank.Category_staging VALUES(1,'Children Bicycles',15000),
									(3,'Cruisers Bicycles',13000),
									(4,'Cyclocross Bicycles',20000),
									(5,'Electric Bikes',10000),
									(6,'Mountain Bikes',10000);

MERGE Bank.Category t 
USING Bank.Category_staging s
ON (s.Category_id = t.Category_id)
WHEN MATCHED
    THEN UPDATE SET 
        t.Category_name = s.Category_name,
        t.Amount = s.Amount
WHEN NOT MATCHED BY TARGET 
    THEN INSERT (Category_id, Category_name, Amount)
         VALUES (s.Category_id, s.Category_name, s.Amount)
WHEN NOT MATCHED BY SOURCE 
    THEN DELETE;


--*************************************
-- CURSOR ,FETCH
--*************************************
Use BMSDB
CREATE TABLE Employee
(
EmployeeID int primary key identity,
EmployeeName varchar(30),
CellPhoneNo varchar(15)
);
GO


INSERT INTO Employee(EmployeeName,CellPhoneNo) VALUES('Asif','74747474'),
													 ('Nazrul','85858585'),
													 ('Noman','969696969'),
													 ('Nasir','41414141'),
													 ('Belal','52525252')
GO



Select * From Employee
GO

use MyCursorDB
SET NOCOUNT ON;
DECLARE @employeeid int, @employeename varchar(20), @cellphoneno varchar(15), @message varchar(max);
PRINT '-------- EMPLOYEE DETAILS --------';
DECLARE employeecursor CURSOR FOR
	SELECT EmployeeID,EmployeeName,CellPhoneNo
	FROM Employee
	order by EmployeeID;
OPEN employeecursor
	FETCH NEXT FROM employeecursor
	INTO @employeeid,@employeename,@cellphoneno
	print 'EmployeeID  EmployeeName  CellPhoneNo'
	WHILE @@FETCH_STATUS = 0
		BEGIN
			print '    ' + CAST(@employeeid as varchar(10)) +'          '+ cast(@employeename as varchar(30))+ '         '+cast(@cellphoneno as varchar(15))
			FETCH NEXT FROM employeecursor
			INTO @employeeid,@employeename,@cellphoneno
		END


CLOSE employeecursor;
DEALLOCATE employeecursor;
GO


--*************************************
-- All Operator 
--*************************************
Select 12+5 as [Sum]
Go
Select 15-7 as [Substraction]
Go
Select 7*7 as [Multiplication]
Go
Select 21/3 as [Divide]
Go
Select 10%3 as [Remainder]



--******************************************
--Case Function
--*******************************************
Go
Select BranchID, BranchName,
Case BranchID
	When 1 then 'Halishahar'
	When 2 then 'Kamlapur'
	When 3 then 'Coxbazar'
Else 'Not In Branch'
End	 
From Bank.Bannch
Go
