SELECT DISTINCT 'PayDates by LTM' LEVEL1
, 'PayDates by Period' LEVEL2
, CAST(p.RetailYear AS VARCHAR(4)) + '_LTM' LEVEL34
, CAST(p.RetailYear AS VARCHAR(4)) + '_' + CAST(FORMAT(p.RetailPeriod, '\P00') AS VARCHAR(3)) + '_LTM' LEVEL4
, CAST(p.RetailYear AS VARCHAR(4))+ '_' + CAST(FORMAT(p.RetailPeriod,'\P00') AS VARCHAR(3)) LEVEL5
, CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) LEVEL6
FROM dbo.DimDate p 
WHERE calendardate > '24-Jun-2018' 
ORDER BY 1,2,3,4,5,6