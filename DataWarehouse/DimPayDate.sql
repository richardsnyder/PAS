SET DATEFIRST 1

DECLARE @MyCursor CURSOR
DECLARE @KeyDate DATE
DECLARE @WeekNumber INT
DECLARE @BaseTable TABLE (
  PayDate DATE
  ,WeekNumber INT
)
DECLARE @Result TABLE (
  CalendarDate DATE
 ,KeyDate DATE
 ,PayPeriodStart DATE
 ,PayPeriodEnd DATE
 ,PayType VARCHAR(10)
 --,RetailYear INT
 --,RetailWeek INT
 --,RetailWeekId INT
 --,FinancialYear INT
 --,FinancialMonth INT
 --,FinancialMonthId INT
)

INSERT INTO @BaseTable
  SELECT
    Staging_DimDate.CalendarDate AS PayDate
    ,Staging_DimDate.RetailWeek AS WeekNumber
  FROM Staging_DimDate
  WHERE Staging_DimDate.CalendarDate >= '24-Jun-2014'
  AND DATEPART(dw, CalendarDate) = 7

BEGIN
  SET @MyCursor = CURSOR
  FOR SELECT
    PayDate
    ,WeekNumber
  FROM @BaseTable
  OPEN @MyCursor
  FETCH NEXT FROM @MyCursor INTO @KeyDate, @WeekNumber
  WHILE @@fetch_status = 0

  BEGIN
  INSERT INTO @Result
    SELECT TOP 14
      CalendarDate
     ,@KeyDate
     ,DATEADD(DAY, -13, @KeyDate) PayPeriodStart
     ,@KeyDate AS PayPeriodEnd
     ,CASE WHEN @WeekNumber % 2 = 0 THEN 'RE' ELSE 'ME' END PayType
    FROM Staging_DimDate
    WHERE CalendarDate <= @KeyDate
    ORDER BY CalendarDate DESC
  FETCH NEXT FROM @MyCursor INTO @KeyDate, @WeekNumber
  END
  CLOSE @MyCursor
  DEALLOCATE @MyCursor
END

SELECT
  DENSE_RANK() OVER (ORDER BY KeyDate ASC) AS PayDateId
 ,CalendarDate
  --,KeyDate AS PayDate
 ,PayPeriodStart
 ,PayPeriodEnd
 ,PayType
INTO DataWarehouseChris21.dbo.DimPayDate
FROM @Result
ORDER BY PayDateId, CalendarDate
