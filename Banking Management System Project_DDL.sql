--***************************************
-- Create Database 
--***************************************

Use Master
create Database BMSDB
GO

ALTER DATABASE BMSDB MODIFY FILE 
(Name=N'BMSDB', Size=25MB, MaxSize=100MB, FileGrowth=5% )
GO
ALTER DATABASE BMSDB MODIFY FILE 
( Name=N'BMSDB', Size = 5MB, MaxSize = 10MB, FileGrowth = 1MB)


Go
--***************************************
--TO DELETE DATABASE 
--***************************************
USE Master
Drop Database BMSDB

Go
--***************************************
-- Create Schema
--***************************************

Use BMSDB
GO
Create Schema Bank

GO
--***************************************
-- To Create Table 
--***************************************
Use BMSDB
Create Table Bank.Branch
(
BranchID int Primary Key Identity,
BranchName varchar (15) Not Null,
City Varchar(15) Null
)

Go
--***********************************************************************
--Create table With Constraint ,Default, Check , Like ,Computed Column 
--***********************************************************************
Create Table Bank.Accounts_Holder 
(
AccountNo int primary key Identity,
Acc_HolderName varchar(15) Not Null,
Address Varchar(25) Null Constraint CN_Defaultaddress Default ('UNKNOWN'),
MobileNo nvarchar(15) Null Check ((MobileNo Like '[0][1][1-9][0-9] [0-9] [0-9] [0-9] [0-9] [0-9] [0-9]' )),
NID As ('NID'+ Right ('000'+ CAST (AccountNo As Varchar(10)),10)),
BranchID int Foreign key references Bank.Branch(BranchID),
EmployeeID int Foreign key references Bank.Employee(EmployeeID)
)

Go
--*****************************************
--Table Create With Cascade update,Delete 
--*****************************************
Create table Bank.AccountsDetails 
(
AccountNo int Foreign key References Bank.Accounts_Holder(AccountNo) ON Update Cascade ,
BranchID int Foreign key references Bank.Branch(BranchID) ON Update Cascade,
AccountType  varchar(15) Null,
Balance Decimal (10,2) Not Null
)

Go
Create table Bank.Loan
(
LoanID int primary key Identity,
AccountNo int Foreign key References Bank.Accounts_Holder(AccountNo) ,
BranchID int Foreign key references Bank.Branch(BranchID),
EmployeeID int Foreign key references  Bank.Employee(EmployeeID),
Amount decimal(10,2) null
)

Go
--******************************
--Create Table With Sparse
--*******************************

Create Table Bank.Employee
(
EmployeeID int Primary Key Identity,
Emp_Name Varchar(15) Not Null,
Designation varchar(15) SPARSE null,
Address Varchar(20) SPARSE Null,
MobileNo nvarchar(15)SPARSE Null,
NID char(17) Not Null
)

Go

Create table Bank.TransactionHistory
(
Trans_ID int Identity ,
AccountNo int Foreign key References Bank.Accounts_Holder(AccountNo) ,
EmployeeID int Foreign key references Bank.Employee(EmployeeID),
Trans_Type varchar(20) Not Null,
Debit decimal(10,2) Null,
Credit decimal(10,2) Null,
Balance decimal(10,2) Not Null   
)

Go


--***************************
--Local and Global Table 
--***************************

Create Table #AgentBanking
(
AgentID int primary Key Identity(1,3),
AgentName Varchar(30),
Address varchar(30),
Phone nvarchar (15)
)

Go
Create Table ##Remittance 
(
RemittanceID int primary Key ,
sendername varchar(20),
Receivername varchar(20),
AcNo Int 
)

--***************************************
--Alter table 
--***************************************
alter table Bank.TransactionHistory
add Date date Null

Go
--***************************************
-- Drop column
--***************************************
alter table Bank.TransactionHistory
drop column date 

Go
--***************************************
-- To Delete Table 
--***************************************
Drop table Bank.Employee

Go

--***************************************
-- Create Scaler Function
--***************************************

Create Function fn_AccountsDetails
(@branchid int)
returns int
As
Begin 
Return
	(
	Select Sum(Balance) as [Total Balance]
	from Bank.AccountsDetails 
	Where BranchID=@branchid
	)
End
Go
Print fn_AccountsDetails('10')

Go
--***************************************
--Create Tabular Function 
--***************************************

Create Function   Bank.fn_AccountsHolder
(@address varchar (20))
Returns table 
As
Return
	(
	Select Acc_HolderName,NID,BranchID
	From Accounts_Holder
	Where Address=@address
	)

Go
Select * from  Bank.fn_AccountsHolder ('Dhaka')

Go
--***************************************
--Create View 
--***************************************
Create view vw_transactionhistory
As
Select *
From Bank.TransactionHistory

Go
Select * from vw_transactionhistory


Go
--***************************************
--Create View with Schmabinding
--***************************************
Create View vw_Schemabinding
With Schemabinding
As
Select b.BranchID,b.BranchName,a.Acc_HolderName,a.AccountNo,a.Address,a.EmployeeID
From Bank.Branch b
join Bank.Accounts_Holder a
On b.BranchID=a.BranchID

Go
Select * from vw_Schemabinding

Go
--***************************************
--Create View with Encryption
--***************************************

Create View vw_encryption
With Encryption
As
Select b.BranchID,b.BranchName,a.Acc_HolderName,a.AccountNo,a.Address,a.EmployeeID
From Bank.Branch b
join Bank.Accounts_Holder a
On b.BranchID=a.BranchID

Go
--***************************************
-- Create Clustered & NonClustered Index
--***************************************

--Create Clustered 

Create Clustered index CIndex on Bank.TransactionHistory(Trans_ID)

--Create NonClustered
Create NonClustered index Ncindex on Bank.Branch(BranchName)

Go
--***************************************
 -- Create After trigger
--***************************************
Create trigger trg_Employee on Bank.Employee
For insert 
As 
declare @employeeid int ,@emp_name varchar(15),@designation varchar(15),@address varchar(20),@mobileno nvarchar(15),@nid char(17),@audit_action varchar (100);
Select @employeeid=i.EmployeeID from inserted i;
Select @emp_name=i.Emp_Name from inserted i;
Select @designation=i.Designation from inserted i;
Select @address=i.Address from inserted i;
Select @mobileno=i.MobileNo from inserted i;
Select @nid=i.NID from inserted i;
Set @audit_action='Inserted Record--After Insert Trigger.';
insert into Employee ( EmployeeID,Emp_Name,Designation , Address,MobileNo,NID,Audit_Action,Audit_Timestamp)
values ( @employeeid  ,@emp_name,@designation ,@address ,@mobileno ,@nid ,@audit_action,GETDATE());
PRINT 'AFTER INSERT trigger fired.'

--insert Trigger for table : Employee
insert into  Bank.Employee values ('Imtiaz','Cash','Dhaka','01819 312 909','1993151055')


Go
--***************************************
-- Instead Of Trigger 
--***************************************
Create Trigger trg_branch ON Bank.Branch
Instead of Update ,delete
AS
Begin
	Declare @rowcount int
	Set @rowcount=@@ROWCOUNT
		IF(@rowcount>1)
			Begin 
				Raiserror (' It is Not Possible To Update or Delete More Than 1 ',16,1)
			End
		Else
		Print'Successfully '
End


Go
--***************************************
-- Store Procedure Separately
--***************************************
Create Proc sp_branch
@branchid int ,
@branchname varchar(15),
@city varchar(15) ,
@message varchar (50) output 
As
Begin
	Begin try
		begin transaction
			insert into Bank.Branch(BranchID,BranchName,City)
			Values (@branchid, @branchname,@city)
			Set @message='Data inserted Successfully' 
			Print @message
		Commit transaction
	ENd try

	Begin Catch
		Rollback transaction
		Print 'Something is wrong'
	End Catch
End


Go
Declare @mess varchar(50)
exec sp_branch 3,'Bahaddarhat','Chittagong',@mess output
Go
select * from Bank.Branch

Go
--Update by store Procedure
Create Proc sp_branch_update
@branchid int ,
@branchname varchar(15),
@city varchar(15) ,
@message varchar (50) output 
As
Begin
	Begin try
		begin transaction
			Update Bank.Branch
			Set BranchName=@branchname,City=@city
			Where BranchID=@branchid
			Set @message='Data Updated Successfully' 
			Print @message
		Commit transaction
	ENd try

	Begin Catch
		Rollback transaction
		Print 'Something is wrong'
	End Catch
End


Go
Declare @mess varchar(50)
exec sp_branch_update 2,'Muradpur','Chittagong',@mess output

Go
--Delete by store Procedure
Create Proc sp_branch_delete
@branchid int ,
@message varchar (50) output 
As
Begin
	Begin try
		begin transaction
			Delete Bank.Branch
			Where BranchID=@branchid
			Set @message='Data Delete Successfully' 
			Print @message
		Commit transaction
	ENd try

	Begin Catch
		Rollback transaction
		Print 'Something is wrong'
	End Catch
End


Go
Declare @mess varchar(50)
exec sp_branch_delete 3,@mess output
Select @mess

use BMSDB
Select * from Bank.Branch

Go
--***************************************
--Store Procedure 
--***************************************
Create Proc sp_Branch_AccountsDetails
@brsnchid int ,
@branchname varchar (15),
@city varchar (15),
@accountno int  ,
@accountType  varchar(15),
@balance Decimal (10,2)  ,
@tablename varchar (25),
@operationname varchar (25)
AS
Begin
	If(@tablename='Branch' and @operationname='Insert')
		Begin
			insert into Bank.Branch values (@brsnchid, @branchname,@city )
		End 
	If(@tablename='Branch' and @operationname='Update')
		Begin
			Update Bank.Branch Set BranchName=@branchname where BranchID=@brsnchid
		End 
	If(@tablename='Branch' and @operationname='Delete')
		Begin
			Delete Bank.Branch where BranchID=@brsnchid
		End 
	If(@tablename='Branch' and @operationname='Select')
		Begin
			Select * from Bank.Branch
		End 


	If(@tablename='AccountsDetails' and @operationname='Insert')
		Begin
			insert into Bank.AccountsDetails values (@accountno,@accountType,@balance )
		End 
	If(@tablename='AccountsDetails' and @operationname='Update')
		Begin
			Update Bank.AccountsDetails Set AccountType=@accountType where AccountNo=@accountno
		End 
	If(@tablename='AccountsDetails' and @operationname='Delete')
		Begin
			Delete Bank.AccountsDetails where AccountNo=@accountno
		End 
	If(@tablename='AccountsDetails' and @operationname='Select')
		Begin
			Select * from Bank.AccountsDetails
		End 

End 

Exec sp_Branch_AccountsDetails 6,'Battali','Chittagong',6,'FDR',50000.00,'Branch','insert'  


--**********************************************
--Trim (Left /Right)
--**********************************************

SELECT LEFT('SQL Server',3) Result_string;


SELECT Right('SQL Server',6) Result_string;

