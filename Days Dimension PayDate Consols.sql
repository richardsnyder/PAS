IF OBJECT_ID('tempdb..#Dates') IS NOT NULL DROP TABLE #Dates
IF OBJECT_ID('tempdb..#PayDates') IS NOT NULL DROP TABLE #PayDates
GO

DECLARE @PayDateCursor CURSOR
DECLARE @LEVEL1 VARCHAR(30), @LEVEL2 VARCHAR(20), @LEVEL3 VARCHAR(15), @PayDate VARCHAR(12), @Day VARCHAR(12)
DECLARE @Results TABLE (LEVEL1 VARCHAR(30), LEVEL2 VARCHAR(20), LEVEL3 VARCHAR(15) ,PayDate VARCHAR(12) ,Days VARCHAR(12))


SELECT DISTINCT p.RetailWeek, p.RetailWeekEnd, p.CalendarDate
INTO #PayDates
FROM dbo.DimDate p 
WHERE p.RetailWeekEnd > '17-Jun-2018'
order by 2

BEGIN
  SET @PayDateCursor = CURSOR
  FOR
    SELECT DISTINCT RetailWeekend
    FROM #PayDates
    OPEN @PayDateCursor
    FETCH NEXT FROM @PayDateCursor INTO @PayDate
    WHILE @@FETCH_STATUS = 0 

    BEGIN
      INSERT INTO @Results
      select 'Pay Period Consolidations'
      ,''
	  ,''
      ,@PayDate 
      ,CalendarDate 
      from #PayDates PayDates
      where paydates.CalendarDate BETWEEN DATEADD(DAY, -13, @PayDate) AND @PayDate
      ORDER BY 4,5
      FETCH NEXT FROM @PayDateCursor INTO @PayDate
    END
    CLOSE @PayDateCursor
    DEALLOCATE @PayDateCursor
END

UPDATE Results
SET LEVEL2 = CASE 
    WHEN RetailWeek % 2 = 0 
    THEN 'RE Consolidations' 
    ELSE 'ME Consolidations' 
  END
, LEVEL3 = CASE 
    WHEN RetailWeek % 2 = 0 
    THEN CONVERT(VARCHAR(12), CONVERT(DATE,PayDate), 112) + 'RE' 
    ELSE CONVERT(VARCHAR(12), CONVERT(DATE,PayDate), 112) + 'ME' 
  END
FROM @Results Results
INNER JOIN DimDate 
ON DimDate.RetailWeekEnd = Results.PayDate

select LEVEL1, LEVEL2, LEVEL3,CONVERT(VARCHAR(12), CONVERT(DATE,Days), 112) LEVLE4
from @Results
order by 2,3,4
