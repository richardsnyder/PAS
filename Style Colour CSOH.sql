SELECT 
   CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourId
  ,CAST('TOTAL' AS NVARCHAR(50)) AS LocationID
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID  
  ,CAST(SUM(FactStock.OnHandQuantity) AS INT) AS CSOH_U
--  ,COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0) , BackupWholesaleAudPrice.CurrentPrice) AS Price
  , SUM(CAST((FactStock.OnHandQuantity) * (dbo.FuncGetTaxExclusiveAmount(COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0) , BackupWholesaleAudPrice.CurrentPrice), COALESCE (NULLIF (WholesaleAudPriceScheme.TaxRate, 0) , BackupWholesaleAudPriceScheme.TaxRate))) AS DECIMAL(18,4))) AS CSOH_D
  FROM FactStock 
    INNER JOIN MatProduct
    ON MatProduct.ProductId = FactStock.ProductId
    INNER JOIN
    dbo.DimDate CurrentDate ON
    CurrentDate.CalendarDate = CAST(GETDATE() AS DATE)
    INNER JOIN
    dbo.DimDate ON
    DimDate.CalendarDate = FactStock.StockDate
    INNER JOIN MatWarehouse
    ON MatWarehouse.WarehouseId = FactStock.WarehouseId
    LEFT OUTER JOIN DimSalesPriceScheme AS WholesaleAudPriceScheme 
    ON WholesaleAudPriceScheme.Code = 'WholesaleAUD' 
    LEFT OUTER JOIN DimSalesPriceScheme AS BackupWholesaleAudPriceScheme 
    ON WholesaleAudPriceScheme.Id = WholesaleAudPriceScheme.BackupSalesPriceSchemeId 
    LEFT OUTER JOIN FactProductPrice AS WholesaleAudPrice 
    ON WholesaleAudPrice.ProductId = MatProduct.ProductId 
    AND WholesaleAudPrice.SalesPriceSchemeId = WholesaleAudPriceScheme.Id 
    AND WholesaleAudPrice.PriceDate = ( SELECT MAX(PriceDate) AS Expr1 
                                        FROM FactProductPrice) 
    LEFT OUTER JOIN FactProductPrice AS BackupWholesaleAudPrice 
    ON BackupWholesaleAudPrice.ProductId = MatProduct.ProductId 
    AND BackupWholesaleAudPrice.SalesPriceSchemeId = BackupWholesaleAudPriceScheme.Id 
    AND BackupWholesaleAudPrice.PriceDate = ( SELECT MAX(PriceDate) AS Expr1 
                                            FROM FactProductPrice) 
WHERE (COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0), BackupWholesaleAudPrice.CurrentPrice) IS NOT NULL) 
    AND (MatWarehouse.WarehouseType = 'W')
    AND MatProduct.PatternMakerId = 17 -- DWPlanned
    AND MatProduct.BusinessDivisionCode = 16
    AND MatProduct.ComponentGroupCode = 'FG'
    AND MatProduct.IsActive = 1
    AND MatProduct.TunId IS NULL
    AND MatProduct.ColourId != 1
    AND DimDate.RetailWeekId >= CurrentDate.RetailWeekId -CAST(dbo.GetConfiguration('MapleLakeWeeksToActualise') AS INT)
    AND DimDate.RetailWeekId <= CurrentDate.RetailWeekId
    AND DimDate.DayOfWeekId = 7 --Sundays stock only
GROUP BY CAST(MatProduct.StyleColourCode AS NVARCHAR(50))
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50))
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50))

  