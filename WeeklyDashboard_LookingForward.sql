--Drop any temporary tables
IF OBJECT_ID('tempdb..#ReportDatesReportWeek') IS NOT NULL
DROP TABLE #ReportDatesReportWeek

IF OBJECT_ID('tempdb..#ReportDatesNextWeek') IS NOT NULL
DROP TABLE #ReportDatesNextWeek

IF OBJECT_ID('tempdb..#RetailSalesAndStock') IS NOT NULL
DROP TABLE #RetailSalesAndStock

GO                                      --Uncomment when running in SSMS
DECLARE @ReportDate INT                 --Uncomment when running in SSMS
DECLARE @BusinessDivision INT           --Uncomment when running in SSMS
SET @ReportDate = 411 -- WK51           --Uncomment when running in SSMS
SET @BusinessDivision = 3 -- BA         --Uncomment when running in SSMS

DECLARE @ReportDatePlusOne INT  

SET @ReportDatePlusOne = @ReportDate + 1

DECLARE @ReportEffectiveDate DATE = ( SELECT DISTINCT
		RetailWeekEnd
	FROM dbo.DimDate
	WHERE RetailWeekId = @ReportDate)
	
DECLARE @ReportEffectiveDatePlusOne DATE = ( SELECT DISTINCT
		RetailWeekEnd
	FROM dbo.DimDate
	WHERE RetailWeekId = @ReportDatePlusOne)	

--select DATEADD(DAY, -1, GETDATE()) --Date the report will run as of - passed through from SSRS

--Create a table of dates that will drive the date period buckets (Year/Period/Week)
SELECT
	* INTO #ReportDatesReportWeek
FROM dbo.GetRetailReportingDates(@ReportEffectiveDate) AS ReportDatesReportWeek
WHERE ReportDatesReportWeek.PeriodType IN ('Year', 'Season', 'Period', 'Week', 'Day')

SELECT
	* INTO #ReportDatesNextWeek
FROM dbo.GetRetailReportingDates(@ReportEffectiveDatePlusOne) AS ReportDatesNextWeek
WHERE ReportDatesNextWeek.PeriodType IN ('Year', 'Season', 'Period', 'Week', 'Day')

SELECT
	MatWarehouse.LocationTypeCode
	,DimProfitCentre.ProfitCentreType
	,CASE
		WHEN DimProfitCentre.ProfitCentreType = 'RT' OR
			DimProfitCentre.ProfitCentreType = 'EC' OR
			DimProfitCentre.ProfitCentreType = 'CO' THEN 'Retail'
		WHEN DimProfitCentre.ProfitCentreType = 'OU' THEN 'OutLet'
		ELSE 'NA'
	END 'ProfitCentreTypeGroup'
	,COALESCE(SUM(Sales.WeekSalesThisYear), 0) AS WeekSalesThisYear
	,COALESCE(SUM(Sales.WeekSalesLastYear), 0) AS WeekSalesLastYear	
	,COALESCE(SUM(lastyearsales.NextWeekSalesLastYear), 0) AS NextWeekSalesLastYear
	,COALESCE(SUM(Budget.NextWeekBudgetSales), 0) AS NextWeekBudgetSales
	,COALESCE(SUM(Budget.NextWeekBudgetCost), 0) AS NextWeekBudgetCost
	,COALESCE(SUM(Forecast.NextWeekForecastSales), 0) AS NextWeekForecastSales
	,COALESCE(SUM(Forecast.NextWeekForecastCost), 0) AS NextWeekForecastCost
FROM dbo.MatWarehouse
LEFT OUTER JOIN (SELECT
		FactRetailSales.WarehouseId
		,SUM(CASE
			WHEN ReportDatesReportWeek.PeriodType = 'Week' AND
				ReportDatesReportWeek.CurrentOrPreviousPeriod = 'Current' THEN SalesExcludingTaxForeign
		END) AS WeekSalesThisYear
		,SUM(CASE
			WHEN ReportDatesReportWeek.PeriodType = 'Week' AND
				ReportDatesReportWeek.CurrentOrPreviousPeriod = 'Previous' THEN SalesExcludingTaxForeign
		END) AS WeekSalesLastYear		
	FROM dbo.FactRetailSales
	INNER JOIN dbo.MatProduct
		ON MatProduct.ProductId = FactRetailSales.ProductId
	INNER JOIN #ReportDatesReportWeek AS ReportDatesReportWeek
		ON ReportDatesReportWeek.CalendarDate = FactRetailSales.SaleDate
	INNER JOIN dbo.MatWarehouse
		ON Matwarehouse.WarehouseId = FactRetailSales.WarehouseId
	INNER JOIN dbo.FactComp
		ON FactComp.ProfitCentreId = MatWarehouse.ProfitCentreId
		AND FactComp.CompDate = FactRetailSales.SaleDate
	WHERE MatProduct.IsReported = 1
	AND ReportDatesReportWeek.PeriodType IN ('Year', 'Season', 'Period', 'Week')
	AND MatWarehouse.BusinessDivisionId IN (@BusinessDivision)
	GROUP BY FactRetailSales.WarehouseId) AS sales
	ON Sales.WarehouseId = MatWarehouse.WarehouseId
	
LEFT OUTER JOIN (SELECT
		FactRetailSales.WarehouseId
		,SUM(CASE
			WHEN ReportDatesNextWeek.PeriodType = 'Week' AND
				ReportDatesNextWeek.CurrentOrPreviousPeriod = 'Previous' THEN SalesExcludingTaxForeign
		END) AS NextWeekSalesLastYear
	FROM dbo.FactRetailSales
	INNER JOIN dbo.MatProduct
		ON MatProduct.ProductId = FactRetailSales.ProductId
	INNER JOIN #ReportDatesNextWeek AS ReportDatesNextWeek
		ON ReportDatesNextWeek.CalendarDate = FactRetailSales.SaleDate
	INNER JOIN dbo.MatWarehouse
		ON Matwarehouse.WarehouseId = FactRetailSales.WarehouseId
	INNER JOIN dbo.FactComp
		ON FactComp.ProfitCentreId = MatWarehouse.ProfitCentreId
		AND FactComp.CompDate = FactRetailSales.SaleDate
	WHERE MatProduct.IsReported = 1
	AND ReportDatesNextWeek.PeriodType IN ('Year', 'Season', 'Period', 'Week')
	AND MatWarehouse.BusinessDivisionId IN (@BusinessDivision)
	GROUP BY FactRetailSales.WarehouseId) AS lastyearsales
	ON lastyearsales.WarehouseId = MatWarehouse.WarehouseId
	
LEFT OUTER JOIN (SELECT
		FactStoreBudget.WarehouseId
		,SUM(CASE
			WHEN ReportDatesNextWeek.PeriodType = 'Week' AND
				ReportDatesNextWeek.CurrentOrPreviousPeriod = 'Current' THEN FactStoreBudget.BudgetSalesExcludingTaxForeign
		END) AS NextWeekBudgetSales
		,SUM(CASE
			WHEN ReportDatesNextWeek.PeriodType = 'Week' AND
				ReportDatesNextWeek.CurrentOrPreviousPeriod = 'Current' THEN FactStoreBudget.BudgetCostExcludingTaxForeign
		END) AS NextWeekBudgetCost
	FROM dbo.FactStoreBudget
	INNER JOIN #ReportDatesNextWeek AS ReportDatesNextWeek
		ON ReportDatesNextWeek.CalendarDate = FactStoreBudget.BudgetDate
	INNER JOIN MatWarehouse
		ON MatWarehouse.WarehouseId = FactStoreBudget.WarehouseId
	WHERE ReportDatesNextWeek.PeriodType IN ('Year', 'Season', 'Period', 'Week')
	AND MatWarehouse.BusinessDivisionId IN (@BusinessDivision)
	GROUP BY FactStoreBudget.WarehouseId) AS Budget
	ON Budget.WarehouseId = MatWarehouse.WarehouseId

LEFT OUTER JOIN (SELECT
		FactStoreForecast.WarehouseId
		,SUM(CASE
			WHEN ReportDatesNextWeek.PeriodType = 'Week' AND
				ReportDatesNextWeek.CurrentOrPreviousPeriod = 'Current' THEN FactStoreForecast.ForecastSalesExcludingTaxForeign
		END) AS NextWeekForecastSales
		,SUM(CASE
			WHEN ReportDatesNextWeek.PeriodType = 'Week' AND
				ReportDatesNextWeek.CurrentOrPreviousPeriod = 'Current' THEN FactStoreForecast.ForecastCostExcludingTaxForeign
		END) AS NextWeekForecastCost		
	FROM dbo.FactStoreForecast
	INNER JOIN #ReportDatesNextWeek AS ReportDatesNextWeek
		ON ReportDatesNextWeek.CalendarDate = FactStoreForecast.ForecastDate
	INNER JOIN MatWarehouse
		ON MatWarehouse.WarehouseId = FactStoreForecast.WarehouseId
	WHERE ReportDatesNextWeek.PeriodType IN ('Year', 'Season', 'Period', 'Week')
	AND MatWarehouse.BusinessDivisionId IN (@BusinessDivision)
	GROUP BY FactStoreForecast.WarehouseId) AS Forecast
	ON Forecast.WarehouseId = MatWarehouse.WarehouseId

INNER JOIN DimProfitCentre
	ON DimProfitCentre.Id = MatWarehouse.ProfitCentreId
WHERE MatWarehouse.BusinessDivisionId IN (@BusinessDivision)
AND MatWarehouse.State IS NOT NULL
AND DimProfitCentre.ProfitCentreType NOT IN ('RH', 'SU', 'WS')
GROUP BY MatWarehouse.LocationTypeCode
			,DimProfitCentre.ProfitCentreType