SELECT DISTINCT
  'PayDates QTD' LEVEL1
--  ,p.RetailYear
  ,CASE 
    WHEN p.RetailWeek % 2 = 0 
    THEN CONVERT(VARCHAR(4),p.RetailYear) + ' QTD RE/BA/YT' 
  END LEVEL2
  ,CASE 
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) < 4 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q1TD' 
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) >3 AND CONVERT(VARCHAR(2), p.RetailPeriod) <7 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q2TD'
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) >6 AND CONVERT(VARCHAR(2), p.RetailPeriod) <10 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q3TD'
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) >9 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q4TD'    
  END AS LEVEL3 
  ,CONVERT(VARCHAR(12),Date1.PayDate, 112)LEVEL4
FROM dbo.DimDate p 
    INNER JOIN 
    (
      SELECT DISTINCT 
      RetailYear
      ,CONVERT(VARCHAR(12),RetailWeekEnd, 112)PayDate 
      FROM dbo.DimDate 
      WHERE calendardate > '30-Jun-2014' AND
      RetailWeek % 2 = 0 
    ) AS Date1 
    ON Date1.PayDate <= p.RetailWeekEnd 
    AND Date1.Retailyear = p.RetailYear
WHERE calendardate > '30-Jun-2014' AND
  p.RetailWeek % 2 = 0

UNION ALL
SELECT DISTINCT
  'PayDates QTD' LEVEL1
--  ,p.RetailYear
  ,CASE 
    WHEN p.RetailWeek % 2 <> 0 
    THEN CONVERT(VARCHAR(4),p.RetailYear) + ' QTD ME' 
  END LEVEL2
  ,CASE 
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) < 4 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q1TD' 
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) >3 AND CONVERT(VARCHAR(2), p.RetailPeriod) <7 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q2TD'
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) >6 AND CONVERT(VARCHAR(2), p.RetailPeriod) <10 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q3TD'
    WHEN CONVERT(VARCHAR(2), p.RetailPeriod) >9 THEN CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' Q4TD'    
  END AS LEVEL3 
  ,CONVERT(VARCHAR(12),Date1.PayDate, 112)LEVEL4
FROM dbo.DimDate p 
    INNER JOIN 
    (
      SELECT DISTINCT 
      RetailYear
      ,CONVERT(VARCHAR(12),RetailWeekEnd, 112)PayDate 
      FROM dbo.DimDate 
      WHERE calendardate > '30-Jun-2014' AND
      RetailWeek % 2 <> 0 
    ) AS Date1 
    ON Date1.PayDate <= p.RetailWeekEnd 
    AND Date1.Retailyear = p.RetailYear
WHERE calendardate > '30-Jun-2014' AND
  p.RetailWeek % 2 <> 0 
ORDER BY 1,2,3,4