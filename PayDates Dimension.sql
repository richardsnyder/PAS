SELECT DISTINCT 'AllPayDates' [AllPayDates] 
	, CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) 'PayDate' 
	, CONVERT(VARCHAR(12), p.RetailWeekEnd, 113) 'DisplayDate' 
	, p.RetailPeriod 'RetailPeriodValue' 
	, FORMAT(p.RetailWeek,'WK00') RetailWeek 
	, p.RetailWeek 'RetailWeekValue' 
	, p.RetailYear 'RetailYear' 
	, DATEDIFF(dd,'19000101',CONVERT(VARCHAR(12), RetailWeekEnd, 112)) +2 [XLDate] 
	, CASE 
		WHEN p.RetailWeek % 2 = 0 THEN 'RE/BA/YT' 
		ELSE 'ME' 
	END PayType 
	, CONVERT(VARCHAR(12),DATEADD(DAY, -14, p.RetailWeekEnd), 112) 'Prior PayDate' 
	, CASE 
		WHEN p.RetailPeriod = 1 THEN 'Forecast_000' 
		WHEN p.RetailPeriod = 2 THEN 'Forecast_Jul' 
		WHEN p.RetailPeriod = 3 THEN 'Forecast_Aug' 
		WHEN p.RetailPeriod = 4 THEN 'Forecast_Sep' 
		WHEN p.RetailPeriod = 5 THEN 'Forecast_Oct' 
		WHEN p.RetailPeriod = 6 THEN 'Forecast_Nov' 
		WHEN p.RetailPeriod = 7 THEN 'Forecast_Dec' 
		WHEN p.RetailPeriod = 8 THEN 'Forecast_Jan' 
		WHEN p.RetailPeriod = 9 THEN 'Forecast_Feb' 
		WHEN p.RetailPeriod = 10 THEN 'Forecast_Mar' 
		WHEN p.RetailPeriod = 11 THEN 'Forecast_Apr' 
		WHEN p.RetailPeriod = 12 THEN 'Forecast_May'
	END 'Retail Forecast Version'
	, CASE 
		WHEN p.RetailWeek % 2 = 0 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q' + CONVERT(VARCHAR(2), p.FinancialQuarter) +'TD'
		ELSE CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' QTD'
	END QTD	
	, CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' YTD' YTD
FROM dbo.DimDate p 
WHERE calendardate > '24-Jun-2018' 
ORDER BY 2