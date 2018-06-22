DECLARE @ReportingWeek INT
, @ReportingYear INT
, @ReportingWeekId INT

SET @ReportingWeek = (SELECT dbo.GetConfiguration('ReportingRetailWeek'))
SET @ReportingYear = (SELECT dbo.GetConfiguration('ReportingRetailYear'))
SET @ReportingWeekId = (SELECT DISTINCT RetailWeekId FROM dbo.DimDate WHERE RetailWeek = @ReportingWeek AND RetailYear = @ReportingYear)

SELECT MatWarehouse.WarehouseId
, MatWarehouse.TerritoryCode
, MatWarehouse.WarehouseCode
, MatWarehouse.WarehouseName
, SUM(COALESCE(Sales.FpSales,0)) AS FullPriceSales
, SUM(COALESCE(Sales.MdSales,0)) AS MarkdownSales
, SUM(COALESCE(Sales.FpSales,0)) + SUM(COALESCE(Sales.MdSales,0)) AS TotalSales
, IsNUll(SUM(Sales.FpSales) / (SUM(Sales.FpSales) + SUM(Sales.MdSales)),0) AS PerCentFullPriceSales
, IsNUll(SUM(Sales.MdSales) / (SUM(Sales.FpSales) + SUM(Sales.MdSales)),0) AS PerCentFullPriceSales
, SUM(Stock.FPQuantity) FPSoh
, SUM(Stock.MDQuantity) MDSoh

FROM dbo.MatWarehouse
LEFT OUTER JOIN
( SELECT WarehouseId 
  ,SUM(CASE WHEN COALESCE(IsMarkedDown, 0) = 0 THEN SalesExcludingTaxForeign END) AS FpSales
  ,SUM(CASE WHEN COALESCE(IsMarkedDown, 0) = 1 THEN SalesExcludingTaxForeign END) AS MdSales
  FROM dbo.FactRetailSales
  WHERE SaleDate IN (SELECT calendardate FROM dbo.DimDate WHERE RetailWeekId = @ReportingWeekId)
  GROUP BY WarehouseId
) AS Sales
ON Sales.WarehouseId = MatWarehouse.WarehouseId

LEFT OUTER JOIN
(
	SELECT FactStock.WarehouseId
  		,ISNULL(SUM(CASE 
				WHEN dbo.FuncGetIsMarkedDown(FactProductPrice.OriginalPrice, FactProductPrice.CurrentPrice) = 1
					THEN ISNULL(NULLIF(FactStock.OnHandQuantity,NULL),0) + ISNULL(NULLIF(FactStock.InTransitQuantity,NULL),0)
				END),0) AS MDQuantity
		,ISNULL(SUM(CASE 
				WHEN COALESCE(dbo.FuncGetIsMarkedDown(FactProductPrice.OriginalPrice, FactProductPrice.CurrentPrice), 0) = 0
					THEN ISNULL(NULLIF(FactStock.OnHandQuantity,NULL),0) + ISNULL(NULLIF(FactStock.InTransitQuantity,NULL),0)
				END),0) AS FPQuantity  

  FROM FactStock
	INNER JOIN MatWarehouse ON MatWarehouse.WarehouseId = FactStock.WarehouseId
	INNER JOIN MatProduct ON MatProduct.ProductId = FactStock.ProductId
	LEFT OUTER JOIN DimCustomer ON DimCustomer.Id = MatWarehouse.CustomerId
	INNER JOIN DimCurrency AS AustralianDollarsCurrency ON AustralianDollarsCurrency.Code = 'AUD'
	LEFT OUTER JOIN FactExchangeRate AS CostingExchangeRate ON CostingExchangeRate.FromCurrencyId = MatWarehouse.CostingCurrencyId
		AND CostingExchangeRate.ToCurrencyId = AustralianDollarsCurrency.Id
		AND CostingExchangeRate.RateDate = FactStock.StockDate
	LEFT OUTER JOIN FactExchangeRate AS TransactionExchangeRate ON TransactionExchangeRate.FromCurrencyId = MatWarehouse.TransactionCurrencyId
		AND TransactionExchangeRate.ToCurrencyId = AustralianDollarsCurrency.Id
		AND TransactionExchangeRate.RateDate = FactStock.StockDate
	LEFT OUTER JOIN FactProductPrice ON FactProductPrice.PriceDate = FactStock.StockDate
		AND FactProductPrice.ProductId = FactStock.ProductId
		AND FactProductPrice.SalesPriceSchemeId = MatWarehouse.SalesPriceSchemeId
	LEFT OUTER JOIN FactProductPrice AS BackupProductPrice ON BackupProductPrice.PriceDate = FactStock.StockDate
		AND BackupProductPrice.ProductId = FactStock.ProductId
		AND BackupProductPrice.SalesPriceSchemeId = MatWarehouse.BackupSalesPriceSchemeId
	LEFT OUTER JOIN FactProductCost ON FactProductCost.CostDate = FactStock.StockDate
		AND FactProductCost.ProductId = FactStock.ProductId
		AND FactProductCost.CostingZoneId = MatWarehouse.CostingZoneId
	LEFT OUTER JOIN FactSalesTaxRates ON FactSalesTaxRates.TaxTypeSalesId = DimCustomer.TaxTypeSalesId
		AND FactSalesTaxRates.StockTypeId = MatProduct.StockTypeId

		WHERE FactStock.StockDate = (SELECT DISTINCT RetailWeekEnd FROM dbo.DimDate WHERE RetailWeekId = @ReportingWeekId -1)
  	GROUP BY FactStock.WarehouseId
	) AS Stock ON Stock.WarehouseId = MatWarehouse.WarehouseId

WHERE MatWarehouse.BusinessDivisionCode IN (18,31)
AND MatWarehouse.IsPlanningWarehouse = 1
AND MatWarehouse.TradingStatus = 'Opened'
GROUP BY MatWarehouse.WarehouseId
, MatWarehouse.TerritoryCode
, MatWarehouse.WarehouseCode
, MatWarehouse.WarehouseName
