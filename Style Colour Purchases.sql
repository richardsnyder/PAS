SELECT CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourId
  ,CAST(
    CASE 
     WHEN MatWarehouse.WarehouseCode = 'DWNZ' OR MatWarehouse.WarehouseCode = 'DWChinaNZ' THEN 'WarehouseNZ'
     ELSE 'WarehouseAU'
     END AS NVARCHAR(50)) AS LocationId
  ,CAST('WHOLESALE' AS NVARCHAR(50)) AS LocationID 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID 
  ,SUM(FactPurchaseOrders.PurchaseOrderQuantity) AS PURCHASES_U
  , COALESCE(SUM(CAST((FactPurchaseOrders.PurchaseOrderQuantity) * (dbo.FuncGetTaxExclusiveAmount(COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0) 
  , BackupWholesaleAudPrice.CurrentPrice) 
  , COALESCE (NULLIF (WholesaleAudPriceScheme.TaxRate, 0) , BackupWholesaleAudPriceScheme.TaxRate))) AS DECIMAL(18 
  ,4))),0) AS PURCHASES_D 
  , COALESCE(SUM(CAST((FactPurchaseOrders.PurchaseOrderQuantity * FactProductCost.Cost) / 
  CASE 
    WHEN MatWarehouse.CostingCurrencyId = AustralianDollarsCurrency.Id 
    THEN 1 
    ELSE CostingExchangeRate.ExchangeRate 
  END AS DECIMAL(18 
  ,4))),0) AS PURCHASES_C 
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
WHERE MatWarehouse.BusinessDivisionCode = 16 
  AND MatProduct.PatternMakerId = 17 -- DWPlanned
  AND MatProduct.ComponentGroupCode = 'FG' 
  AND MatProduct.IsActive = 1 
  AND MatProduct.TunId IS NULL 
  AND MatProduct.ColourId != 1
  AND MatWarehouse.WarehouseCode IN ('DWMAIN', 'DWNZ') 
AND FactPurchaseOrders.SnapshotDate = CAST(DATEADD(DAY,-1,GETDATE()) AS DATE)
GROUP BY CAST(MatProduct.StyleColourCode AS NVARCHAR(50))
  ,MatWarehouse.WarehouseCode 
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50))
ORDER BY 3