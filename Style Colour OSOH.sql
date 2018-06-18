SELECT CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourId 
  ,CAST(
    CASE
      WHEN MatWarehouse.WarehouseCode = 'DWMain' THEN 'WarehouseAU'
      WHEN MatWarehouse.WarehouseCode = 'DWNZ' THEN 'WarehouseNZ'
    END
   AS NVARCHAR(50)) AS LocationID 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID 
  ,CAST(SUM(FactStock.OnHandQuantity) AS INT) AS OSOH_U
  --  ,COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0) , BackupWholesaleAudPrice.CurrentPrice) AS Price
  , SUM(CAST((FactStock.OnHandQuantity) * (dbo.FuncGetTaxExclusiveAmount(COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0) 
  , BackupWholesaleAudPrice.CurrentPrice) 
  , COALESCE (NULLIF (WholesaleAudPriceScheme.TaxRate, 0) , BackupWholesaleAudPriceScheme.TaxRate))) AS DECIMAL(18 
  ,4))) AS OSOH_D 
  , SUM(CAST((FactStock.OnHandQuantity * FactProductCost.Cost) / 
  CASE 
    WHEN MatWarehouse.CostingCurrencyId = AustralianDollarsCurrency.Id 
    THEN 1 
    ELSE CostingExchangeRate.ExchangeRate 
  END AS DECIMAL(18 
  ,4))) AS OSOH_C 
FROM FactStock 
    INNER JOIN MatWarehouse 
    ON MatWarehouse.WarehouseId = FactStock.WarehouseId 
    INNER JOIN MatProduct 
    ON MatProduct.ProductId = FactStock.ProductId 
    INNER JOIN dbo.DimDate 
    ON DATEADD(DAY, -1, DimDate.CalendarDate) = FactStock.StockDate -- -1 day as we want to show the stock on hand for the following retail week
    INNER JOIN dbo.DimDate StockDate 
    ON StockDate.CalendarDate = FactStock.StockDate 
    INNER JOIN dbo.DimDate CurrentDate 
    ON CurrentDate.CalendarDate = CAST(GETDATE() AS DATE) 
    LEFT OUTER JOIN dbo.MatCustomer 
    ON MatCustomer.CustomerId = MatWarehouse.CustomerId 
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
    INNER JOIN DimCurrency AS AustralianDollarsCurrency 
    ON AustralianDollarsCurrency.Code = 'AUD' 
    LEFT OUTER JOIN FactExchangeRate AS CostingExchangeRate 
    ON CostingExchangeRate.FromCurrencyId = MatWarehouse.CostingCurrencyId 
    AND CostingExchangeRate.ToCurrencyId = AustralianDollarsCurrency.Id 
    AND CostingExchangeRate.RateDate = FactStock.StockDate 
    LEFT OUTER JOIN FactProductCost 
    ON FactProductCost.CostDate = ( SELECT MAX(CostDate) AS Expr1 
                                    FROM FactProductCost) 
    AND FactProductCost.ProductId = FactStock.ProductId 
    AND FactProductCost.CostingZoneId = MatWarehouse.CostingZoneId
    
WHERE (MatWarehouse.WarehouseType = 'W') 
  AND MatProduct.PatternMakerId = 17 -- DWPlanned
  AND MatProduct.BusinessDivisionCode = 16 
  AND MatProduct.ComponentGroupCode = 'FG' 
  AND MatProduct.IsActive = 1 
  AND MatProduct.TunId IS NULL 
  AND MatProduct.ColourId != 1 
  AND StockDate.RetailWeekId >= CurrentDate.RetailWeekId - CAST(dbo.GetConfiguration('MapleLakeWeeksToActualise') AS INT) -1
  AND StockDate.RetailWeekId < CurrentDate.RetailWeekId -1
  AND StockDate.DayOfWeekId = 7 --Sundays stock only
GROUP BY CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50))
  ,MatWarehouse.WarehouseCode
ORDER BY 3