SELECT CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourID 
  ,CAST('ONLINE' AS NVARCHAR(50)) AS LocationID
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID
  ,CAST(SUM(FactRetailSales.SalesExcludingTaxForeign) AS NUMERIC(16 ,2)) AS Sales_D
  ,CAST(SUM(FactRetailSales.CostExtendedExcludingTaxForeign) AS NUMERIC(16 ,2)) AS COGS_D
  ,CAST(SUM(CASE WHEN FactRetailSales.RetailLineTypeId = 1 THEN FactRetailSales.Quantity ELSE 0 END) AS NUMERIC(16 ,2)) AS Sales_U     
FROM dbo.FactRetailSales 
    INNER JOIN dbo.MatProduct 
    ON MatProduct.ProductId = FactRetailSales.ProductId 
    INNER JOIN dbo.MatWarehouse 
    ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId 
    INNER JOIN dbo.DimDate 
    ON DimDate.CalendarDate = FactRetailSales.SaleDate 
    INNER JOIN dbo.DimDate CurrentDate 
    ON CurrentDate.CalendarDate = CAST(GETDATE() AS DATE) 
WHERE MatWarehouse.LocationTypeCode = 'DWECOMM' 
  AND MatProduct.BusinessDivisionCode = 16 
  AND MatProduct.PatternMakerId = 17 /* DWPlanned */
  AND MatProduct.ComponentGroupCode = 'FG' 
  AND MatProduct.IsActive = 1 
  AND MatProduct.TunId IS NULL 
  AND MatProduct.ColourId != 1 
  AND DimDate.RetailWeekId BETWEEN CurrentDate.RetailWeekId -CAST(dbo.GetConfiguration('MapleLakeWeeksToActualise') AS INT)  AND CurrentDate.RetailWeekId
group by CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50))