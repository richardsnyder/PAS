
SELECT RetailCustomers.[Person Id] PersonId 
  , RetailCustomers.[First Name] FirstName 
  , RetailCustomers.[Last Name] LastName 
  , RetailCustomers.[Email Address] Email 
--  , RetailCustomers.[Signup Date] SignupDate 
--  , 0 Sales
FROM datawarehouseuserview.dbo.[Retail Customers] RetailCustomers 
WHERE RetailCustomers.[Signup Store Code] = 'BASHERVE' 
  AND RetailCustomers.[Signup Date] >= DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)) 
  AND RetailCustomers.[Privacy Requested] = 'N' 
  AND RetailCustomers.[Email Address] IS NOT NULL 
UNION
SELECT RetailCustomers.[Person Id] PersonId
  , RetailCustomers.[First Name] FirstName  
  , RetailCustomers.[Last Name] LastName 
  , RetailCustomers.[Email Address] Email 
--  , RetailCustomers.[Signup Date] SignupDate 
--  , SUM(SalesIncludingTaxLocal) SalesInc 
FROM FactRetailSales 
    INNER JOIN MatWarehouse 
    ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId 
      INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers 
      ON RetailCustomers.[Person Id] = FactRetailSales.RetailCustomerId 
WHERE FactRetailSales.SaleDate >= DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)) 
  AND MatWarehouse.WarehouseCode = 'BASHERVE' 
  AND RetailCustomers.[Email Address] IS NOT NULL
  AND RetailCustomers.[Privacy Requested] = 'N' 
GROUP BY RetailCustomers.[Person Id] 
  , RetailCustomers.[First Name] 
  , RetailCustomers.[Last Name] 
  , RetailCustomers.[Email Address] 
  , RetailCustomers.[Signup Date]
  
  --select * from MatWarehouse where WarehouseName like '%hervey%' -- ID 303 Code BASHERVE