SELECT CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourId 
  ,CAST('WHOLESALE' AS NVARCHAR(50)) AS LocationID 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID 
  ,SUM(FactPurchaseOrders.PurchaseOrderQuantity) AS PURCHASES_U 
  , SUM(CAST((FactPurchaseOrders.PurchaseOrderQuantity) * (dbo.FuncGetTaxExclusiveAmount(COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0) 
  , BackupWholesaleAudPrice.CurrentPrice) 
  , COALESCE (NULLIF (WholesaleAudPriceScheme.TaxRate, 0) , BackupWholesaleAudPriceScheme.TaxRate))) AS DECIMAL(18 
  ,4))) AS PURCHASES_D 
  , SUM(CAST((FactPurchaseOrders.PurchaseOrderQuantity * FactProductCost.Cost) / 
  CASE 
    WHEN MatWarehouse.CostingCurrencyId = AustralianDollarsCurrency.Id 
    THEN 1 
    ELSE CostingExchangeRate.ExchangeRate 
  END AS DECIMAL(18 
  ,4))) AS PURCHASES_C 
FROM dbo.FactPurchaseOrders 
    INNER JOIN MatWarehouse 
    ON FactPurchaseOrders.WarehouseId = MatWarehouse.WarehouseId 
    INNER JOIN dbo.DimDate 
    ON DimDate.CalendarDate = FactPurchaseOrders.DueDate 
    INNER JOIN dbo.DimDate CurrentDate 
    ON CurrentDate.CalendarDate = CAST(GETDATE() AS DATE) 
    INNER JOIN dbo.MatProduct 
    ON MatProduct.ProductId = FactPurchaseOrders.ProductId 
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
    AND CostingExchangeRate.RateDate = FactPurchaseOrders.DueDate 
    LEFT OUTER JOIN FactProductCost 
    ON FactProductCost.CostDate = ( SELECT MAX(CostDate) AS Expr1 
                                    FROM FactProductCost) 
    AND FactProductCost.ProductId = FactPurchaseOrders.ProductId 
    AND FactProductCost.CostingZoneId = MatWarehouse.CostingZoneId 
WHERE (COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0), BackupWholesaleAudPrice.CurrentPrice) IS NOT NULL) 
  AND MatWarehouse.BusinessDivisionCode = 16 
  AND MatProduct.PatternMakerId = 17 -- DWPlanned
  AND MatProduct.ComponentGroupCode = 'FG' 
  AND MatProduct.IsActive = 1 
  AND MatProduct.TunId IS NULL 
  AND MatProduct.ColourId != 1 
  AND DimDate.RetailWeekId >= CurrentDate.RetailWeekId -CAST(dbo.GetConfiguration('MapleLakeWeeksToActualise') AS INT) 
  AND DimDate.RetailWeekId <= CurrentDate.RetailWeekId 
GROUP BY CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50))