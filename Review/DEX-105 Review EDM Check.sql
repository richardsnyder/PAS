IF OBJECT_ID('tempdb..#Customers') IS NOT NULL
  DROP TABLE #Customers

SELECT DISTINCT Email.EMAIL_ADDRESS_ Email, RetailCustomers.[Person Id] PersonId
INTO #Customers
FROM PlayPen.dbo.Email
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
  ON Email.Email_Address_ = RetailCustomers.[Email Address]


SELECT
  FactRetailSales.RetailCustomerId
 ,RetailCustomers.[Person Id] PersonId
 ,RetailCustomers.[Email Address] AS CustomerEmail
 ,MatWarehouse.WarehouseId
 ,MatWarehouse.WarehouseCode AS StoreCode
 ,MatWarehouse.WarehouseName AS StoreName
 ,CASE
    WHEN DimProfitCentre.ProfitCentreType = 'CO' THEN 'Concession'
    WHEN DimProfitCentre.ProfitCentreType = 'RT' THEN 'Boutique'
    WHEN DimProfitCentre.ProfitCentreType = 'EC' THEN 'E-commerce'
    WHEN DimProfitCentre.ProfitCentreType = 'OU' THEN 'Outlet'
    ELSE DimProfitCentre.ProfitCentreType
  END AS Channel
 ,MatWarehouse.TerritoryCode
 ,CAST(FactRetailSales.SaleDate AS DATE) AS SaleDate
 ,SUM(FactRetailSales.SalesIncludingTaxForeign) AS SalesInc
FROM FactRetailSales
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
  ON RetailCustomers.[Person Id] = FactRetailSales.RetailCustomerId
INNER JOIN #Customers Customers
ON Customers.PersonId = FactRetailSales.RetailCustomerId
INNER JOIN MatWarehouse
  ON MatWArehouse.WarehouseId = FactRetailSales.WarehouseId
INNER JOIN DimProfitCentre
  ON DimProfitCentre.id = MatWarehouse.ProfitCentreId
INNER JOIN MatProduct
ON MatProduct.ProductId = FactRetailSales.ProductId
WHERE SaleDate BETWEEN '24-Jun-2018' AND '25-Jun-2018'
AND MatProduct.IsReported = 1
GROUP BY   FactRetailSales.RetailCustomerId
 ,RetailCustomers.[Person Id]
 ,RetailCustomers.[Email Address]
 ,MatWarehouse.WarehouseId
 ,MatWarehouse.WarehouseCode
 ,MatWarehouse.WarehouseName
 ,CASE
    WHEN DimProfitCentre.ProfitCentreType = 'CO' THEN 'Concession'
    WHEN DimProfitCentre.ProfitCentreType = 'RT' THEN 'Boutique'
    WHEN DimProfitCentre.ProfitCentreType = 'EC' THEN 'E-commerce'
    WHEN DimProfitCentre.ProfitCentreType = 'OU' THEN 'Outlet'
    ELSE DimProfitCentre.ProfitCentreType
  END
 ,MatWarehouse.TerritoryCode
 ,CAST(FactRetailSales.SaleDate AS DATE)
ORDER BY SaleDate, TerritoryCode, StoreName, CustomerEmail
