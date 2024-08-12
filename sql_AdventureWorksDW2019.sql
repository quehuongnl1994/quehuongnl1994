/*Task 1:
From dbo.FactInternetSales and dbo.FactInternetSalesReason tables,
Write a query displaying the SalesOrderNumber, SalesOrderLineNumber where the SalesReasonKey equal to 2 or 5
*/
SELECT a.SalesOrderNumber, a.SalesOrderLineNumber, b.SalesReasonKey
FROM [dbo].[FactInternetSales] AS a
JOIN [dbo].[FactInternetSalesReason] AS b
	ON a.SalesOrderNumber = b.SalesOrderNumber
	AND a.SalesOrderLineNumber = b.SalesOrderLineNumber
WHERE SalesReasonKey IN (2,5)
ORDER BY a.SalesOrderNumber;

/* Task 2:
From dbo.FactInternetSales, dbo.FactInternetSalesReason, DimSalesReason, DimProduct, DimProductCategory.
Write a query displaying the SalesOrderNumber, SalesOrderLineNumber, ProductKey, Quantity, EnglishProductName,
Color, EnglishProductCategoryName
where SalesReasonReasonType is 'Marketing' and EnglishProductSubcategoryName contains 'Bikes' 
*/
SELECT
	a.SalesOrderNumber, 
	a.SalesOrderLineNumber,
	a.ProductKey,
	a.OrderQuantity AS Quantity,
	d.EnglishProductName,
	d.Color,
	f.EnglishProductCategoryName
FROM [dbo].[FactInternetSales] AS a
JOIN [dbo].[FactInternetSalesReason] AS b
	ON a.SalesOrderNumber = b.SalesOrderNumber
		AND a.SalesOrderLineNumber = b.SalesOrderLineNumber
JOIN [dbo].[DimSalesReason] AS c
	ON b.SalesReasonKey = c.SalesReasonKey
JOIN [dbo].[DimProduct] AS d
	ON a.ProductKey = d.ProductKey
JOIN [dbo].[DimProductSubcategory] AS e
	ON d.ProductSubcategoryKey = e.ProductSubcategoryKey
JOIN [dbo].[DimProductCategory] AS f
	ON e.ProductCategoryKey = f.ProductCategoryKey
WHERE c.SalesReasonReasonType = 'Marketing'
	AND e.EnglishProductSubcategoryName LIKE '%Bikes%';

/* Task 3:
From DimDepartmentGroup, Write a query display DepartmentGroupName and their parent DepartmentGroupName
*/
SELECT a.DepartmentGroupName, 
	b.DepartmentGroupName AS ParentDepartmentGroupName
FROM [dbo].[DimDepartmentGroup] AS a
JOIN [dbo].[DimDepartmentGroup] AS b
	ON a.ParentDepartmentGroupKey = b.DepartmentGroupKey;

/* Task 4:
From FactInternetSales, DimProduct. 
Display ProductKey, EnglishProductName of products which never have been ordered and ProductCategory is 'Bikes'
*/
SELECT d.ProductKey, d.EnglishProductName
FROM [dbo].[DimProduct] AS d
JOIN [dbo].[DimProductSubcategory] AS e
	ON d.ProductSubcategoryKey = e.ProductSubcategoryKey
JOIN [dbo].[DimProductCategory] AS f
	ON e.ProductCategoryKey = f.ProductCategoryKey
LEFT JOIN [dbo].[FactInternetSales] AS a
	ON a.ProductKey = d.ProductKey
WHERE a.OrderDateKey is NULL
	AND f.EnglishProductCategoryName = 'Bikes';

/* Task 5:
From FactFinance, DimOrganization, DimScenario. 
Write a query display OrganizationKey, OrganizationName, Parent OrganizationKey, Parent OrganizationName, Amount 
where ScenarioName is 'Actual'
*/
SELECT a.OrganizationKey,
	b.OrganizationName,
	b.ParentOrganizationKey, 
	c.OrganizationName AS ParentOrganizationName, 
	a.Amount
FROM [dbo].[FactFinance] AS a
JOIN [dbo].[DimOrganization] AS b
	ON a.OrganizationKey = b.OrganizationKey
JOIN [dbo].[DimOrganization] AS c
	ON b.ParentOrganizationKey = c.OrganizationKey
JOIN [dbo].[DimScenario] AS d
	ON a.ScenarioKey = d.ScenarioKey
WHERE d.ScenarioName = 'Actual';

