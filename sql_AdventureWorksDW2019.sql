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

/* Task 6: Write a query joining the DimCustomer, and FactInternetSales tables to return CustomerKey, FullName 
with their number of order */

SELECT a.CustomerKey, b.FullName, a.NumberOfOrder
FROM
	(SELECT CustomerKey, COUNT(SalesOrderNumber) AS NumberOfOrder
	FROM [dbo].[FactInternetSales]
	GROUP BY CustomerKey) AS a
JOIN
	(SELECT CustomerKey, 
		FirstName + ' ' + isnull(MiddleName,'') + ' ' + LastName AS FullName
	FROM [dbo].[DimCustomer]) AS b
	ON a.CustomerKey = b.CustomerKey;

/* Task 7: From FactInternetSale, DimProduct,
Write a query that creates a new Color_group, if the product color is 'Black' or 'Silver' or 'Silver/Black' leave 'Basic', 
else keep Color.
Then Caculate total SalesAmount by new Color_group */

SELECT Color_group, SUM(SalesAmount) AS TotalSalesAmount
FROM [dbo].[FactInternetSales] AS a
JOIN 
	(SELECT ProductKey,
		(CASE
			WHEN Color IN ('Black', 'Silver','Silver/Black') THEN 'Basic'
			ELSE Color
		END) AS Color_group
	FROM [dbo].[DimProduct]) AS b
	ON a.ProductKey = b.ProductKey
GROUP BY Color_group;

/* Task 8: From FactInternetSales, DimProduct
Write a query display SaleOrderNumber, EnglishProductName, OrderQuantity, SalesAmount. 
Then generate a column name 'Order Type' with values (“Under 10” or “10–19” or “20–29” or “30–39” or “40 and over”) from SalesAmount 
*/

SELECT a.SalesOrderNumber, 
	b.EnglishProductName, 
	a.OrderQuantity, 
	a.SalesAmount,
	(CASE
		WHEN a.SalesAmount < 10 THEN 'Under 10'
		WHEN a.SalesAmount >= 10 AND a.SalesAmount < 19 THEN '10-19'
		WHEN a.SalesAmount >= 20 AND a.SalesAmount < 29 THEN '20-29'
		WHEN a.SalesAmount >= 30 AND a.SalesAmount < 39 THEN '30-39'
		ELSE '40 and over'
	END) AS 'Order Type'
FROM [dbo].[FactInternetSales] AS a
JOIN [dbo].[DimProduct] AS b
	ON a.ProductKey = b.ProductKey;

/* Task 9: From the FactInternetsales and Resellersales tables, 
retrieve: saleordernumber, productkey, orderdate, shipdate of orders in October 2011, 
along with sales type ('Resell' or 'Internet')
*/

SELECT a.SalesOrderNumber, a.ProductKey, a.OrderDate, a.ShipDate, a.SalesType
FROM
	(SELECT SalesOrderNumber, ProductKey, OrderDate, ShipDate, 'Internet' AS SalesType
	FROM [dbo].[FactInternetSales]
	UNION ALL
	SELECT SalesOrderNumber, ProductKey, OrderDate, ShipDate, 'Resell' AS SalesType
	FROM [dbo].[FactResellerSales]) AS a
WHERE CONVERT(varchar,a.ShipDate,102) LIKE '2011.10.%';

/* Task 10: From database 
Display ProductKey, EnglishProductName, Total OrderQuantity (caculate from OrderQuantity in Quarter 3 of 2013) of product 
sold in London for each Sales type ('Resell' and 'Internet')
*/
WITH x AS
(SELECT a.ProductKey, a.OrderDate, a.OrderQuantity, 'Internet' AS SalesType, c.City
FROM [dbo].[FactInternetSales] AS a
JOIN [dbo].[DimCustomer] AS b
	ON a.CustomerKey = b.CustomerKey
JOIN [dbo].[DimGeography] AS c
	ON b.GeographyKey = c.GeographyKey
UNION ALL
SELECT d.ProductKey, d.OrderDate, d.OrderQuantity, 'Resell' AS SalesType, f.City
FROM [dbo].[FactResellerSales] AS d
JOIN [dbo].[DimReseller] AS e
	ON d.ResellerKey = e.ResellerKey
JOIN [dbo].[DimGeography] AS f
	ON e.GeographyKey = f.GeographyKey)

SELECT x.ProductKey, y.EnglishProductName, SUM(OrderQuantity) AS TotalOrderQuantity, x.SalesType
FROM x
JOIN [dbo].[DimProduct] AS y
	ON x.ProductKey = y.ProductKey
WHERE City = 'London'
AND (MONTH(OrderDate) IN (7, 8, 9) AND YEAR(OrderDate) = 2013)
GROUP BY x.ProductKey, y.EnglishProductName, x.SalesType;

/*Task 11: From database, retrieve total SalesAmount monthly of internet_sales and reseller_sales.
*/

WITH a AS
(SELECT CONCAT(YEAR(OrderDate), '-', FORMAT(MONTH(OrderDate),'00')) AS Month, SUM(SalesAmount) AS TotalSalesAmount
FROM [dbo].[FactInternetSales]
GROUP BY CONCAT(YEAR(OrderDate), '-', FORMAT(MONTH(OrderDate),'00'))),

b AS
(SELECT CONCAT(YEAR(OrderDate), '-', FORMAT(MONTH(OrderDate),'00')) AS Month, SUM(SalesAmount) AS TotalSalesAmount
FROM [dbo].[FactResellerSales]
GROUP BY CONCAT(YEAR(OrderDate), '-', FORMAT(MONTH(OrderDate),'00')))

SELECT 'InternetSales' AS SalesType, Month, TotalSalesAmount
FROM a
UNION ALL
SELECT 'ResellerSales' AS SalesType, Month, TotalSalesAmount
FROM b
ORDER BY Month, SalesType;

/* Task 12: Write a query joining the DimCustomer, and FactInternetSales tables to return CustomerKey, FullName with their number of order */

WITH cte AS
(
	SELECT
		a.CustomerKey, 
		isnull(Title,'') + ' ' + FirstName + ' ' + isnull(MiddleName,'') + ' ' + LastName + ' ' + ISNULL(Suffix,'') AS FullName,
		SalesOrderNumber
	FROM [dbo].[FactInternetSales] AS a
	JOIN DimCustomer AS b
		ON a.CustomerKey = b.CustomerKey
)

SELECT
	DISTINCT CustomerKey,
	FullName,
	COUNT(SalesOrderNumber) OVER (PARTITION BY CustomerKey) AS NumberOfOrder
FROM cte;

/* Task 13: Write a query that creates a new Color_Group, if product color is 'Black' or 'Silver' or 'Silver/Black' leave 'Basic', else keep Color.
Then Calculate total SalesAmount by new Color_group */

WITH cte AS
(
	SELECT
		CASE
			WHEN Color IN ('Black', 'Silver', 'Silver/Black') THEN 'Basic'
			ELSE Color
		END AS Color_Group,
		SalesAmount
	FROM [dbo].[FactInternetSales] AS a
	JOIN [dbo].[DimProduct] AS b
		ON a.ProductKey = b.ProductKey
)

SELECT
	DISTINCT Color_Group,
	SUM(SalesAmount) OVER (PARTITION BY Color_Group) AS TotalSalesAmount
FROM cte;

/* Task 14: From the FactInternetsales and Resellersales tables, retrieve saleordernumber, productkey, orderdate,
shipdate of orders in October 2011, along with sales type ('Resell' or 'Internet') */

SELECT * FROM
(
	SELECT SalesOrderNumber, ProductKey, OrderDate, ShipDate, 'Internet' AS SalesType
	FROM [dbo].[FactInternetSales]
	UNION ALL
	SELECT SalesOrderNumber, ProductKey, OrderDate, ShipDate, 'Resell' AS SalesType
	FROM [dbo].[FactResellerSales]
) AS a
WHERE YEAR(a.ShipDate) = 2011 AND MONTH(a.ShipDate) = 10;

/* Task 15: Display ProductKey, EnglishProductName, Total OrderQuantity (caculate from OrderQuantity in Quarter 3 of 2013) of product sold in London 
for each Sales type ('Reseller' and 'Internet'). */

WITH a AS
(
	SELECT ProductKey, OrderQuantity, 'Internet' AS SalesType, OrderDate, GeographyKey
	FROM [dbo].[FactInternetSales] AS i
	JOIN [dbo].[DimCustomer] AS cus
		ON i.CustomerKey = cus.CustomerKey
	
	UNION ALL

	SELECT ProductKey, OrderQuantity, 'Resell' AS SalesType, OrderDate, GeographyKey
	FROM [dbo].[FactResellerSales] AS r
	JOIN [dbo].[DimReseller] AS res
		ON r.ResellerKey = res.ResellerKey
),

cte AS
(	
	SELECT
		a.ProductKey,
		EnglishProductName,
		SalesType,
		OrderQuantity
	FROM a
	JOIN [dbo].[DimProduct] AS b
		ON a.ProductKey = b.ProductKey
	JOIN [dbo].[DimGeography] AS c
		ON a.GeographyKey = c.GeographyKey
	WHERE c.City = 'London'
		AND MONTH(OrderDate) IN (7, 8, 9) AND YEAR(OrderDate) = 2013
)

SELECT 
	DISTINCT ProductKey,
	EnglishProductName,
	SalesType,
	SUM(OrderQuantity) OVER (PARTITION BY ProductKey) AS TotalOrderQuantity
FROM cte;

/* Task 16: From database, retrieve total SalesAmount monthly of internet_sales and reseller_sales. */

WITH cte AS
(
	SELECT
		MONTH(OrderDate) AS Month, YEAR(OrderDate) AS Year, SalesAmount, 'Internet' AS SalesType
	FROM [dbo].[FactInternetSales]
	UNION ALL
	SELECT
		MONTH(OrderDate) AS Month, YEAR(OrderDate) AS Year, SalesAmount, 'Reseller' AS SalesType
	FROM [dbo].[FactResellerSales])

SELECT DISTINCT Month, Year,
	SUM(CASE WHEN SalesType = 'Internet' THEN SalesAmount ELSE 0 END) OVER (PARTITION BY Month, Year) AS Internet_SalesAmount,
	SUM(CASE WHEN SalesType = 'Reseller' THEN SalesAmount ELSE 0 END) OVER (PARTITION BY Month, Year) AS Reseller_SalesAmount
FROM cte
ORDER BY Year, Month;

/*Task 17: From FactInternetSales, DimCustomer, DimGeography. Get a list of 5 cities with the highest InternetSalesAmount in each country, each year. */

WITH cte AS
(
	SELECT 
		YEAR(OrderDate) AS Year,
		EnglishCountryRegionName AS Country,
		City, 
		SUM(SalesAmount) AS InternetSalesAmount
	FROM [dbo].[FactInternetSales] AS a
	JOIN [dbo].[DimCustomer] AS b
		ON a.CustomerKey = b.CustomerKey
	JOIN [dbo].[DimGeography] AS c
		ON b.GeographyKey = c.GeographyKey
	GROUP BY YEAR(OrderDate), EnglishCountryRegionName, City
),

cte2 AS
(
	SELECT
		Year,
		Country,
		City,
		InternetSalesAmount, 
		ROW_NUMBER() OVER (PARTITION BY Year, Country ORDER BY InternetSalesAmount DESC) AS SalesAmountRankCountry
	FROM cte
)

SELECT *
FROM cte2
WHERE SalesAmountRankCountry BETWEEN 1 AND 5;

/* Task 18: From DimProduct, DimSalesTerritory, and FactInternetSales,
Calculate the percentage of sales of each product (named PercentofTotaInCountry) in the Total Sales of each country.
The returned result includes the following information:
SalesTerritoryCountry, ProductKey, EnglishProductName, InternetTotalSales, PercentofTotaInCountry (format %)
*/
WITH cte AS
(
	SELECT b.SalesTerritoryCountry, a.ProductKey, c.EnglishProductName, 
		SUM(SalesAmount) AS InternetTotalSales
	FROM FactInternetSales AS a
	JOIN DimSalesTerritory AS b
		ON a.SalesTerritoryKey = b.SalesTerritoryKey
	JOIN DimProduct AS c
		ON a.ProductKey = c.ProductKey
	GROUP BY b.SalesTerritoryCountry, a.ProductKey, c.EnglishProductName
)

SELECT SalesTerritoryCountry, ProductKey, EnglishProductName, InternetTotalSales,
	FORMAT(InternetTotalSales / (SUM(InternetTotalSales) OVER (PARTITION BY SalesTerritoryCountry)), 'P') AS PercentofTotalInCountry
FROM cte;