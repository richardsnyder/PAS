DECLARE @Sales TABLE (
  retailCustomerId INT
 ,SalesAmount NUMERIC(18, 2)
)
INSERT INTO @Sales
  SELECT
    FactRetailSales.retailCustomerId
   ,SUM(FactRetailSales.SalesIncludingTaxLocal) AS SalesAmount
  FROM FactRetailSales
  INNER JOIN MatWarehouse
    ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId
  WHERE MatWarehouse.LocationTypeCode = 'RECONCESSIONMY'
  AND FactRetailSales.SaleDate BETWEEN '2017-06-26' AND '2018-06-24'
  GROUP BY FactRetailSales.retailCustomerId

DECLARE @LocationCount TABLE (
  retailCustomerId INT
 ,LocationTypeCount INT
)
INSERT INTO @LocationCount
  SELECT
    FactRetailSales.retailCustomerId
   ,COUNT(DISTINCT MatWarehouse.LocationTypeCode) AS LocationTypeCount
  FROM FactRetailSales
  INNER JOIN MatWarehouse
    ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId
  WHERE FactRetailSales.SaleDate BETWEEN '2017-06-26' AND '2018-06-24'
  GROUP BY FactRetailSales.retailCustomerId

SELECT
  RetailCustomers.[Person Id]
 ,RetailCustomers.[First Name]
 ,RetailCustomers.[Last Name]
 ,RetailCustomers.[Email Address]
 ,RetailCustomers.[Privacy Requested]
 ,Sales.SalesAmount
FROM @Sales Sales
INNER JOIN @LocationCount LocationCount
  ON LocationCount.retailCustomerId = Sales.retailCustomerId
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
  ON RetailCustomers.[Person Id] = Sales.retailCustomerId
WHERE LocationCount.LocationTypeCount = 1
AND RetailCustomers.[Privacy Requested] = 'N'
AND RetailCustomers.[Email Address] IS NOT NULL 
AND Sales.SalesAmount > 0