SELECT RetailCustomers.[Person Id] PersonId 
  , RetailCustomers.[First Name] 
  , RetailCustomers.[Last Name] 
  , RetailCustomers.[Email Address] Email
  , Sales.Sales
FROM datawarehouseuserview.dbo.[Retail Customers] RetailCustomers 
    INNER JOIN (SELECT retailcustomerid 
                  , SUM(SalesIncludingTaxForeign) Sales 
                FROM FactRetailSales 
                  INNER JOIN MatProduct 
                  ON matproduct.ProductId = factretailsales.ProductId 
                WHERE matproduct.IsReported =1 
                  AND SaleDate > DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)) 
                  AND matproduct.DepartmentCode = 'BAEQ' 
                GROUP BY RetailCustomerId) AS Sales 
    ON Sales.RetailCustomerId = RetailCustomers.[Person Id] 
WHERE RetailCustomers.[Privacy Requested] = 'N' 
  AND RetailCustomers.[Email Address] IS NOT NULL 
--  AND RetailCustomers.[Business Division Code] IN (25,26)
--  AND Sales.Sales > 0