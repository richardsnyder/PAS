SELECT DISTINCT CAST(MatProduct.StyleColourCode AS NVARCHAR(50)) AS StyleColourId 
  ,CAST('WHOLESALE' AS NVARCHAR(50)) AS LocationID 
  ,CAST(FORMAT(DimDate.RetailYear,'0000') + FORMAT(DimDate.RetailWeek,'00')  AS NVARCHAR(50)) AS TimeID 
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID 
  ,MAX(CAST(COALESCE(dbo.FuncGetTaxExclusiveAmount(COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0)
  ,BackupWholesaleAudPrice.CurrentPrice) ,COALESCE (NULLIF (WholesaleAudPriceScheme.TaxRate, 0) , BackupWholesaleAudPriceScheme.TaxRate)),0)AS DECIMAL(18 ,4))) AS Wholesale_Price 
  
  ,MAX(CAST(COALESCE(FactProductCost.Cost / 
      CASE 
        WHEN MatWarehouse.CostingCurrencyId = AustralianDollarsCurrency.Id 
        THEN 1 
        ELSE CostingExchangeRate.ExchangeRate 
      END,0) AS DECIMAL(18,4))) AS Cost_Price 

        , MAX(CAST(COALESCE(dbo.FuncGetTaxExclusiveAmount(COALESCE (NULLIF (RRPAudPrice.CurrentPrice, 0)
  , BackupRRPAudPrice.CurrentPrice) ,COALESCE (NULLIF (RRPAudPriceScheme.TaxRate, 0) , BackupRRPAudPriceScheme.TaxRate)),0) AS DECIMAL(18 ,4))) AS RRP_Price 
      
      
FROM dbo.MatProduct 
    CROSS JOIN dbo.MatWarehouse 
    CROSS JOIN dbo.DimDate 

    LEFT OUTER JOIN DimSalesPriceScheme AS WholesaleAudPriceScheme 
    ON WholesaleAudPriceScheme.Code = 'WholesaleAUD' 

    LEFT OUTER JOIN DimSalesPriceScheme AS BackupWholesaleAudPriceScheme 
    ON WholesaleAudPriceScheme.Id = WholesaleAudPriceScheme.BackupSalesPriceSchemeId 

    LEFT OUTER JOIN FactProductPrice AS WholesaleAudPrice 
    ON WholesaleAudPrice.ProductId = MatProduct.ProductId 
    AND WholesaleAudPrice.SalesPriceSchemeId = WholesaleAudPriceScheme.Id 
    AND WholesaleAudPrice.PriceDate = DimDate.CalendarDate

    LEFT OUTER JOIN FactProductPrice AS BackupWholesaleAudPrice 
    ON BackupWholesaleAudPrice.ProductId = MatProduct.ProductId 
    AND BackupWholesaleAudPrice.SalesPriceSchemeId = BackupWholesaleAudPriceScheme.Id 
    AND BackupWholesaleAudPrice.PriceDate = DimDate.CalendarDate
                                              

    LEFT OUTER JOIN DimSalesPriceScheme AS RRPAudPriceScheme 
    ON RRPAudPriceScheme.Code = 'RRP AUD' 
    LEFT OUTER JOIN DimSalesPriceScheme AS BackupRRPAudPriceScheme
    ON RRPAudPriceScheme.Id = RRPAudPriceScheme.BackupSalesPriceSchemeId 
    LEFT OUTER JOIN FactProductPrice AS RRPAudPrice 
    ON RRPAudPrice.ProductId = MatProduct.ProductId 
    AND RRPAudPrice.SalesPriceSchemeId = RRPAudPriceScheme.Id 
    AND RRPAudPrice.PriceDate = DimDate.CalendarDate
    LEFT OUTER JOIN FactProductPrice AS BackupRRPAudPrice
    ON BackupRRPAudPrice.ProductId = MatProduct.ProductId 
    AND BackupRRPAudPrice.SalesPriceSchemeId = BackupRRPAudPriceScheme.Id 
    AND BackupRRPAudPrice.PriceDate = DimDate.CalendarDate
 
    INNER JOIN DimCurrency AS AustralianDollarsCurrency 
    ON AustralianDollarsCurrency.Code = 'AUD' 
    LEFT OUTER JOIN FactExchangeRate AS CostingExchangeRate 
    ON CostingExchangeRate.FromCurrencyId = MatWarehouse.CostingCurrencyId 
    AND CostingExchangeRate.ToCurrencyId = AustralianDollarsCurrency.Id 
    AND CostingExchangeRate.RateDate = DimDate.CalendarDate 
    LEFT OUTER JOIN FactProductCost 
    ON FactProductCost.CostDate = DimDate.CalendarDate
    AND FactProductCost.ProductId = MatProduct.ProductId 
    AND FactProductCost.CostingZoneId = MatWarehouse.CostingZoneId 
WHERE 1=1 
--  AND (COALESCE (NULLIF (WholesaleAudPrice.CurrentPrice, 0), NULLIF(BackupWholesaleAudPrice.CurrentPrice,0)) IS NOT NULL)
--  AND (COALESCE (NULLIF (RRPAudPrice.CurrentPrice, 0), BackupRRPAudPrice.CurrentPrice) IS NOT NULL)    
 AND MatWarehouse.WarehouseCode = 'DWMAIN' 
  AND MatProduct.PatternMakerId = 17 -- DWPlanned
  AND MatProduct.TunId IS NULL
  AND ComponentGroupCode = 'FG'
  AND MatProduct.IsActive = 1
  AND MatProduct.ColourId != 1
  AND DimDate.CalendarDate = (select max(PriceDate) from FactProductPrice)
--  AND DimDate.DayOfWeekId = 7 --sunday
GROUP BY CAST(MatProduct.StyleColourCode AS NVARCHAR(50))
  ,CAST(FORMAT(DimDate.RetailYear,'0000') + FORMAT(DimDate.RetailWeek,'00')  AS NVARCHAR(50))
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50))

--  
  
---select * from matproduct where StyleColourCode = 'DWEQ141058.DWGRY'
--
--select  * from factProductPrice2018 where productid in (679949)
--
--select top 100 * from DimSalesPriceScheme
--
--select count(*) from matproduct where  MatProduct.PatternMakerId = 17