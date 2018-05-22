
SELECT MatProduct.StyleColourCode AS StyleColourID 
  ,CASE 
    WHEN MatCustomer.BillToCustomerCode = 'DWRB' OR MatCustomer.BillToCustomerCode = 'DWRBUSD' THEN 'Rebel AU'
    WHEN MatCustomer.BillToCustomerCode = 'DWRBZ' THEN 'Rebel NZ'
    WHEN MatCustomer.BillToCustomerCode <> 'DWRBZ' AND MatCustomer.TerritoryCode ='NZ' THEN 'Independent NZ'
    WHEN MatCustomer.BillToCustomerCode <> 'DWRB' OR MatCustomer.BillToCustomerCode <> 'DWRBUSD' AND MatCustomer.TerritoryCode <> 'NZ' THEN 'Independent AU'
   END 
  AS LocationID
  ,CAST(DimDate.RetailYear AS VARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS VARCHAR(4)) TimeID
  ,CAST(SUM(FactWholesaleInvoices.NetSalesExcludingTaxForeign) AS NUMERIC(16 ,2)) AS Sales_D 
  ,CAST(SUM(FactWholesaleInvoices.CostExcludingTaxForeign) AS NUMERIC(16 ,2)) AS COGS_D 
  ,CAST(SUM(FactWholesaleInvoices.Quantity) AS NUMERIC(16 ,2)) AS Sales_U
FROM DataWarehouse.dbo.FactWholesaleInvoices 
    INNER JOIN DataWarehouse.dbo.DimDate 
    ON DimDate.CalendarDate = FactWholesaleInvoices.PostedDate 
    INNER JOIN DataWarehouse.dbo.DimDate CurrentDate 
    ON CurrentDate.CalendarDate = CAST(GETDATE() AS DATE)
    LEFT JOIN DataWarehouse.dbo.MatCustomer 
    ON MatCustomer.CustomerId = FactWholesaleInvoices.CustomerId
    INNER JOIN DataWarehouse.dbo.DimBusinessDivision
    ON DimBusinessDivision.Id = MatCustomer.BusinessDivisionId
    LEFT JOIN DataWarehouse.dbo.MatProduct 
    ON MatProduct.ProductId = FactWholesaleInvoices.ProductId
WHERE 1=1
and MatProduct.IsReported = 1
AND MatProduct.BusinessDivisionCode = 16
AND MatProduct.StyleSeasonCode = 'CTL'
AND MatProduct.ComponentGroupCode = 'FG'
AND MatProduct.IsActive = 1
AND DimDate.RetailWeekId >= CurrentDate.RetailWeekId -CAST(dbo.GetConfiguration('MapleLakeWeeksToActualise') AS INT)
AND DimDate.RetailWeekId <= CurrentDate.RetailWeekId
GROUP BY MatProduct.StyleColourCode
  ,MatCustomer.BillToCustomerCode
  ,MatCustomer.TerritoryCode
  ,CAST(DimDate.RetailYear AS VARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS VARCHAR(4)) 
ORDER BY 3,1

