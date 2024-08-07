--*************************************************************************--
-- Title: Assignment06
-- Author: ABurger
-- Desc: This file demonstrates how to use Views
-- Change Log: 8/4/2024,ABurger,Added code responses to questions 1 through 10.
-- 2017-01-01,ABurger,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ABurger')
	 Begin 
	  Alter Database [Assignment06DB_ABurger] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ABurger;
	 End
	Create Database Assignment06DB_ABurger;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ABurger;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Use Assignment06DB_ABurger;
Go

--Select * From Categories (Checking column names in categories table)
Create 
View vCategories
WITH SCHEMABINDING
As
	Select CategoryID, CategoryName
		From dbo.Categories;
Go

--Select * From Products

Create 
View vProducts
WITH SCHEMABINDING
As
	Select ProductID, ProductName, CategoryID, UnitPrice
		From dbo.Products;
Go

--Select * From Employees --Checking employees table columns

Create 
View vEmployees
WITH SCHEMABINDING
As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
		From dbo.Employees;
Go

--Select * From Inventories --checking inventories table columns

Create 
View vInventories
WITH SCHEMABINDING
AS
	Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
		From dbo.Inventories;
Go


--Select * From vCategories --Checking result
--Select * From vProducts --Checking result
--Select * From vEmployees --Checking result
--Select * From vInventories --Checking result

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories To Public
Deny Select On dbo.Products To Public
Deny Select On dbo.Employees To Public
Deny Select On dbo.Inventories To Public;

Go

Grant Select On vCategories To Public
Grant Select On vProducts To Public
Grant Select On vEmployees To Public
Grant Select On vInventories To Public;

Go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
--Select * From vCategories
--Select * From vProducts
--Drop View vProductsByCategories --Missed assignment instruction to use views, dropped view to try again.

Create
View vProductsByCategories
As
	Select TOP 1000000000 --Top needed for Order By to work
	CategoryName,
	ProductName,
	UnitPrice
		From dbo.vCategories As C
		Join dbo.vProducts As P
			On C.CategoryID = P.CategoryID
		Order By C.CategoryName, P.ProductName; --Note, not best practice here.
Go


--Select * From dbo.vProductsByCategories --checking result


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Select * From vProducts
--Select * From vInventories

Create
View vInventoriesByProductsByDates
As
	Select TOP 1000000000 --Top needed for Order By to work
	ProductName,
	Count,
	InventoryDate
		From dbo.vProducts As P
		Join dbo.vInventories As I
			On P.ProductID = I.ProductID
		Order By P.ProductName, I.Count, I.InventoryDate; --Note, not best practice here.
Go

--Select * From vInventoriesByProductsByDates

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Select * From vInventories
--Select * From vEmployees

Create
View vInventoriesByEmployeesByDates
As
	Select DISTINCT TOP 1000000000 --Top needed for Order By to work
	InventoryDate,
	EmployeeFirstName + ' ' + EmployeeLastName As [EmployeeName]
		From dbo.vInventories As I
		Join dbo.vEmployees As E
			On I.EmployeeID = E.EmployeeID
		Order By I.InventoryDate; --Note, not best practice here.
Go

--Select * From vInventoriesByEmployeesByDates

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Select * From vCategories
--Select * From vProducts
--Select * From vInventories


Create
View vInventoriesByProductsByCategories
As
	Select TOP 1000000000 --Top needed for Order By to work
	CategoryName,
	ProductName,
	InventoryDate,
	Count
		From dbo.vProducts As P
		Join dbo.vCategories As C
			On P.CategoryID = C.CategoryID
		Join dbo.vInventories As I
			On P.ProductID = I.ProductID
		Order By C.CategoryName, P.ProductName, I.InventoryDate, I.Count; --Note, not best practice here.
Go

--Select * From vInventoriesByProductsByCategories

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!


Create
View vInventoriesByProductsByEmployees
As
	Select TOP 1000000000 --Top needed for Order By to work
	CategoryName,
	ProductName,
	InventoryDate,
	Count,
	EmployeeFirstName + ' ' + EmployeeLastName As [EmployeeName]
		From dbo.vProducts As P
		Join dbo.vCategories As C
			On P.CategoryID = C.CategoryID
		Join dbo.vInventories As I
			On P.ProductID = I.ProductID
		Join dbo.vEmployees As E
			On I.EmployeeID = E.EmployeeID
		Order By I.InventoryDate, C.CategoryName, P.ProductName, [EmployeeName]; --Note, not best practice here.
Go

--Select * From vInventoriesByProductsByEmployees

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Drop View vInventoriesForChaiAndChangByEmployees

Create
View vInventoriesForChaiAndChangByEmployees
As
	Select TOP 1000000000 --Top needed for Order By to work
	CategoryName,
	ProductName,
	InventoryDate,
	Count,
	EmployeeFirstName + ' ' + EmployeeLastName As [EmployeeName]
		From dbo.vProducts As P
		Join dbo.vCategories As C
			On P.CategoryID = C.CategoryID
		Join dbo.vInventories As I
			On P.ProductID = I.ProductID
		Join dbo.vEmployees As E
			On I.EmployeeID = E.EmployeeID
				Where P.ProductID IN (Select ProductID From vProducts Where ProductName ='Chai' Or ProductName = 'Chang')
		Order By I.InventoryDate, P.ProductName --Not in directions, but needed to match assignment result.
Go

--Select * From vInventoriesForChaiAndChangByEmployees

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create
View vEmployeesByManager
As
	Select TOP 1000000000 --Top needed for Order By to work
	Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName As [Manager], 
	Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As [Employee]
	 From vEmployees As Emp 
	 INNER JOIN vEmployees Mgr
		 On Emp.ManagerID = Mgr.EmployeeID
	Order By Manager;  --Note, not best practice

 Go

 --Select * From vEmployeesByManager


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--Select * From vEmployees
--Select * From vInventories
--Select * From vProducts
--Select * From vCategories


Create
View vInventoriesByProductsByCategoriesByEmployees
As
	Select TOP 1000000000 --Top needed for Order By to work
	C.CategoryID,
	C.CategoryName,
	P.ProductID,
	P.ProductName,
	P.UnitPrice,
	I.InventoryID,
	I.InventoryDate,
	I.Count,
	Emp.EmployeeID,
	Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As [Employee],
	Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName As [Manager]
		From dbo.vEmployees As Emp 
		Join dbo.vEmployees Mgr
			On Emp.ManagerID = Mgr.EmployeeID
		Join vInventories As I
			On Emp.EmployeeID = I.EmployeeID
		Join dbo.vProducts As P
			On P.ProductID = I.ProductID
		Join dbo.vCategories As C
			On P.CategoryID = C.CategoryID
		Order By CategoryName, ProductName, InventoryID, Employee;
Go
		
--Select * From vInventoriesByProductsByCategoriesByEmployees		
		 
	


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/