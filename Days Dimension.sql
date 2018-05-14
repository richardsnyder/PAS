SELECT DISTINCT 'AllDays' LEVLE1 
  , CONVERT(VARCHAR(12),DimDate.CalendarDate, 112) LEVEL2 
  , CAST(DimDate.RetailYear AS VARCHAR(4) ) RetailYear 
  , CAST(FORMAT(DimDate.RetailPeriod,'\P00') AS VARCHAR(3)) RetailMonth 
  , DimDate.RetailPeriod RetailMonthValue 
  , CAST(FORMAT(DimDate.RetailWeek, 'WK00') AS VARCHAR(4)) RetailWeek 
  , CONVERT(VARCHAR(12), DimDate.CalendarDate, 113) 'DisplayDate' 
  , DimDate.RetailWeek RetailWeekValue 
  , CONVERT(VARCHAR(12),DimDate.RetailWeekStart, 112) RetailWeekStart
  , CONVERT(VARCHAR(12),DimDate.RetailWeekEnd, 112) RetailWeekEnd
  , DimDate.FinancialYear FinancialYear
  , CAST(FORMAT(DimDate.FinancialMonth,'\P00') AS VARCHAR(3)) FinancialPeriod
  , DimDate.FinancialMonth FinancialPeriodValue
  , LEFT(DATENAME(dw,DimDate.CalendarDate),3) DayOfWeek
  , CONVERT(VARCHAR(12),DimDate.PreviousDay, 112) Previous
  , CONVERT(VARCHAR(12),DimDate.NextDay, 112) Next
  , CONVERT(VARCHAR(12),DimDate.FinancialMonthEnd, 112) [Last Day Of Month]
  , CONVERT(VARCHAR(12),DimDate.CalendarDate, 103) [dd/mm/yyyy]
  , LEFT(DATENAME(M,DimDate.CalendarDate),3) + '-' + CAST(DATEPART(yy,DimDate.CalendarDate) AS VARCHAR(4)) MMMyyyy 
  , CAST(FORMAT(DATEPART(d,DimDate.CalendarDate),'00') AS VARCHAR(2)) + '-' + LEFT(DATENAME(M,DimDate.CalendarDate),3) + '-' + CAST(DATEPART(yy,DimDate.CalendarDate) AS VARCHAR(4)) ddMMMyyyy 
  , 
  CASE 
    WHEN DimDate.RetailPeriod = 1 
    THEN 'Forecast_000' 
    WHEN DimDate.RetailPeriod = 2 
    THEN 'Forecast_Jul' 
    WHEN DimDate.RetailPeriod = 3 
    THEN 'Forecast_Aug' 
    WHEN DimDate.RetailPeriod = 4 
    THEN 'Forecast_Sep' 
    WHEN DimDate.RetailPeriod = 5 
    THEN 'Forecast_Oct' 
    WHEN DimDate.RetailPeriod = 6 
    THEN 'Forecast_Nov' 
    WHEN DimDate.RetailPeriod = 7 
    THEN 'Forecast_Dec' 
    WHEN DimDate.RetailPeriod = 8 
    THEN 'Forecast_Jan' 
    WHEN DimDate.RetailPeriod = 9 
    THEN 'Forecast_Feb' 
    WHEN DimDate.RetailPeriod = 10 
    THEN 'Forecast_Mar' 
    WHEN DimDate.RetailPeriod = 11 
    THEN 'Forecast_Apr' 
    WHEN DimDate.RetailPeriod = 12 
    THEN 'Forecast_May' 
  END [Retail Forecast Version]
  , DATEDIFF(dd,'19000101',CONVERT(VARCHAR(12), CalendarDate, 112)) +2 [XLDate]    
FROM dbo.DimDate 
WHERE calendardate > '30-Jun-2019' 
ORDER BY 2