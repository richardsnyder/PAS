
WITH RetailSales 
AS (
  SELECT distinct FactRetailSales.RetailCustomerId
  ,CAST(SaleDate AS datetime) + CAST(SaleTime AS datetime) AS SaleDateTime
  from FactRetailSales
  INNER JOIN MatWarehouse 
  ON Matwarehouse.WarehouseId = FactRetailSales.WarehouseId
  INNER JOIN MatProduct 
  ON MatProduct.ProductId = FactRetailSales.ProductId
   where CAST(SaleDate AS datetime) + CAST(SaleTime AS datetime) BETWEEN '22-Jun-2018 16:45:00.000' AND '25-Jun-2018 23:59:00.000'
   AND matwarehouse.BusinessDivisionCode IN (18,31)
)
SELECT DISTINCT RetailSales.RetailCustomerId
, RetailCustomers.[Person Id] PersonId
, RetailCustomers.[First Name]
, RetailCustomers.[Email Address] Email
, RetailCustomers.[Privacy Requested]
, RetailSales.SaleDateTime
FROM RetailSales
LEFT OUTER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
ON RetailCustomers.[Person Id] = RetailSales.RetailCustomerId
WHERE RetailCustomers.[Email Address] IS NOT NULL
ORDER BY RetailSales.SaleDateTime