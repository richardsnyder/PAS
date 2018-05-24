SELECT CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourID 
  ,CAST(CASE 
    WHEN MatCustomer.BillToCustomerCode = 'DWRB' OR MatCustomer.BillToCustomerCode = 'DWRBUSD' THEN 'RebelAU'
    WHEN MatCustomer.BillToCustomerCode = 'DWRBZ' THEN 'RebelNZ'
    WHEN MatCustomer.BillToCustomerCode <> 'DWRBZ' AND MatCustomer.TerritoryCode ='NZ' THEN 'IndependentNZ'
    WHEN MatCustomer.BillToCustomerCode <> 'DWRB' OR MatCustomer.BillToCustomerCode <> 'DWRBUSD' AND MatCustomer.TerritoryCode <> 'NZ' THEN 'IndependentAU'
   END AS NVARCHAR(50))
  AS LocationID
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID
  ,CAST(SUM(FactWholesaleOrders.SalesOrderNetSalesExcludingTaxForeign + FactWholesaleOrders.PackedNetSalesExcludingTaxForeign) AS NUMERIC(16 ,2)) AS OnOrder_D 
  ,CAST(SUM(FactWholesaleOrders.SalesOrderCostExcludingTaxForeign + FactWholesaleOrders.PackedCostExcludingTaxForeign) AS NUMERIC(16 ,2)) AS OnOrder_C 
  ,CAST(SUM(FactWholesaleOrders.SalesOrderQuantity + FactWholesaleOrders.PackedQuantity) AS NUMERIC(16 ,2)) AS OnOrder_U
FROM DataWarehouse.dbo.FactWholesaleOrders 
    INNER JOIN DataWarehouse.dbo.DimDate 
    ON DimDate.CalendarDate = FactWholesaleOrders.DueDate 
    LEFT JOIN DataWarehouse.dbo.MatCustomer 
    ON MatCustomer.CustomerId = FactWholesaleOrders.CustomerId
    LEFT JOIN DataWarehouse.dbo.MatProduct 
    ON MatProduct.ProductId = FactWholesaleOrders.ProductId
WHERE 1=1
    AND FactWholesaleOrders.SnapshotDate = DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) -- AND factwholesaleorders.DueDate >= @CurrentFinYearStart
    AND MatProduct.PatternMakerId = 17 -- DWPlanned
    AND MatProduct.BusinessDivisionCode = 16
    AND MatProduct.ComponentGroupCode = 'FG'
    AND MatProduct.IsActive = 1
    AND MatProduct.TunId IS NULL
    AND MatProduct.ColourId != 1
GROUP BY MatProduct.StyleColourCode
,CAST(CASE 
WHEN MatCustomer.BillToCustomerCode = 'DWRB' OR MatCustomer.BillToCustomerCode = 'DWRBUSD' THEN 'RebelAU'
WHEN MatCustomer.BillToCustomerCode = 'DWRBZ' THEN 'RebelNZ'
WHEN MatCustomer.BillToCustomerCode <> 'DWRBZ' AND MatCustomer.TerritoryCode ='NZ' THEN 'IndependentNZ'
WHEN MatCustomer.BillToCustomerCode <> 'DWRB' OR MatCustomer.BillToCustomerCode <> 'DWRBUSD' AND MatCustomer.TerritoryCode <> 'NZ' THEN 'IndependentAU'
END AS NVARCHAR(50))
,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50))
,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) 