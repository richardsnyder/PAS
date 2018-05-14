SELECT DISTINCT 'AllRetailYears' LEVLE1
  , CAST(DimDate.RetailYear AS VARCHAR(4))+'R' LEVEL2
  , CAST(DimDate.RetailYear AS VARCHAR(4))+ '_H' +CAST(DimDate.RetailHalf AS VARCHAR(4)) +'R'  LEVEL3
  , CAST(DimDate.RetailYear AS VARCHAR(4)) +'_' + CAST(FORMAT(DimDate.RetailPeriod,'\P00') AS VARCHAR(3))  + 'R' LEVEL4
  , CONVERT(VARCHAR(12),DimDate.CalendarDate, 112) LEVEL5
FROM dbo.DimDate 
WHERE calendardate > '30-Jun-2019' 
ORDER BY 5