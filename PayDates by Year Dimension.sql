SELECT DISTINCT 'PayDates by Year' Parent
, p.RetailYear
, CASE WHEN p.RetailPeriod < 5 THEN  CAST(p.RetailYear AS VARCHAR(4))+ '_Q1'
       WHEN p.RetailPeriod > 4 AND p.RetailPeriod < 7 THEN  CAST(p.RetailYear AS VARCHAR(4))+ '_Q2'
       WHEN p.RetailPeriod > 6 AND p.RetailPeriod < 10 THEN  CAST(p.RetailYear AS VARCHAR(4))+ '_Q3' 
       WHEN p.RetailPeriod > 9 THEN  CAST(p.RetailYear AS VARCHAR(4))+ '_Q4'
  END YrQtr
, CAST(p.RetailYear AS VARCHAR(4))+ '_' + CAST(FORMAT(p.RetailPeriod,'\P00') AS VARCHAR(3)) YrQtrPd
, CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) 'PayDate'
FROM dbo.DimDate p 
WHERE calendardate > '24-Jun-2018' 
ORDER BY 2