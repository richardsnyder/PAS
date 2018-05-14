SELECT DISTINCT 'AllFinancialYears' LEVLE1
  , CAST(DimDate.FinancialYear AS VARCHAR(4)) LEVEL2
  , CAST(DimDate.FinancialYear AS VARCHAR(4)) +'_' + CAST(FORMAT(DimDate.FinancialMonth,'\P00') AS VARCHAR(3)) LEVEL3
  , CONVERT(VARCHAR(12),DimDate.CalendarDate, 112) LEVEL4 
FROM dbo.DimDate 
WHERE calendardate > '30-Jun-2019' 
ORDER BY 2