IF OBJECT_ID('tempdb..#Sales') IS NOT NULL
  DROP TABLE #Sales
GO
SELECT FactRetailSales.RetailCustomerId
, RetailCustomers.[Person Id] PersonId
, RetailCustomers.[Email Address] AS CustomerEmail
, PlayPen.dbo.Email.EMAIL_ADDRESS_ AS SuppliedEmail
, MatWarehouse.WarehouseCode AS StoreCode
, MatWarehouse.WarehouseName AS StoreName
, CASE WHEN DimProfitCentre.ProfitCentreType = 'CO' THEN 'Concession'
       WHEN DimProfitCentre.ProfitCentreType = 'RT' THEN 'Retail Store'
       WHEN DimProfitCentre.ProfitCentreType = 'EC' THEN 'E-commerce'
       WHEN DimProfitCentre.ProfitCentreType = 'OU' THEN 'Outlet'
       ELSE DimProfitCentre.ProfitCentreType
  END AS Channel
, MatWarehouse.TerritoryCode
, CAST(FactRetailSales.SaleDate AS DATE) AS SaleDate
INTO #Sales
FROM FactRetailSales
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
ON RetailCustomers.[Person Id] = FactRetailSales.RetailCustomerId
INNER JOIN PlayPen.dbo.Email
ON Email.Email_Address_ = RetailCustomers.[Email Address]
INNER JOIN MatWarehouse
ON MatWArehouse.WarehouseId = FactRetailSales.WarehouseId
INNER JOIN DimProfitCentre ON DimProfitCentre.Id = MatWarehouse.ProfitCentreId
WHERE SaleDate BETWEEN '24-Jun-2018' AND '25-Jun-2018'

SELECT DISTINCT
  RetailCustomerId
 ,PersonId
 ,CustomerEmail
 ,SuppliedEmail
 ,StoreCode
 ,StoreName
 ,Channel
 ,TerritoryCode
, SaleDate
FROM #Sales s
ORDER BY SaleDate,TerritoryCode,StoreName

DROP TABLE #Sales