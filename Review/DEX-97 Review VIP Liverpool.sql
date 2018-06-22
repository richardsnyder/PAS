SELECT RetailCustomers.[Person Id],
    RetailCustomers.[First Name],
    RetailCustomers.[Email Address],
    RetailCustomers.[Privacy Requested],
    SUM(FactRetailSales.SalesIncludingTaxLocal) AS SalesAmount
FROM FactRetailSales
    INNER JOIN MatWarehouse ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId
    INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers ON RetailCustomers.[Person Id] = FactRetailSales.RetailCustomerId
    INNER JOIN DimWarehouseDispatchType ON DimWarehouseDispatchType.Id = FactRetailSales.WarehouseDispatchTypeId
WHERE FactRetailSales.SaleDate >= DATEADD(MONTH, -12, CAST(GETDATE() AS DATE))
    AND DimWarehouseDispatchType.Name <> 'Store to Door'
    AND MatWarehouse.BusinessDivisionCode IN('18', '31')
    AND RetailCustomers.[Privacy Requested] = 'N'
    AND RetailCustomers.[Email Address] IS NOT NULL
    AND dbo.MatWarehouse.WarehouseCode IN('REOLIV')
    AND dbo.FactRetailSales.IsWebSale = 0
GROUP BY RetailCustomers.[Person Id],
         RetailCustomers.[First Name],
         RetailCustomers.[Email Address],
         RetailCustomers.[Privacy Requested]
ORDER BY SUM(FactRetailSales.SalesIncludingTaxLocal) DESC;


--  Myer Highpoint, Myer Chadstone, Myer Doncaster, Myer Melbourne, Myer Northland
/*
SELECT mw.WarehouseId, mw.WarehouseCode, mw.WarehouseName FROM dbo.MatWarehouse mw
WHERE mw.BusinessDivisionCode = 18
AND mw.WarehouseName LIKE '%Liverpool%'
AND mw.TradingStatus = 'Opened'
ORDER BY 3
*/
/*
REOLIV Review Liverpool

*/