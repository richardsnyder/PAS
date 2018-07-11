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
     ,CASE
        WHEN @WeekNumber % 2 = 0 THEN 'RE'
        ELSE 'ME'
      END PayType
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
 ,Result.CalendarDate
  --,KeyDate AS PayDate
 ,PayPeriodStart
 ,PayPeriodEnd
 ,DimDate.FinancialMonthId
 ,Result.PayType
 ,Hours.NumDays
 ,Hours.NumWeekDays
 ,Hours.MonthlyFullTimeHours38Hrs
 ,Hours.MonthlyFullTimeHours375Hrs
 ,Hours.RetailMonFri38Hrs
 ,Hours.RetailMonFri375Hrs
 ,152 HrDashboardFortNightHours
INTO DataWarehouseChris21.dbo.DimPayDate
FROM @Result Result
INNER JOIN DataWarehouseChris21.dbo.DimDate DimDate
  ON DimDate.CalendarDate = Result.PayPeriodEnd
INNER JOIN (SELECT
    FinancialMonthId
   ,SUM(CASE WHEN DATEPART(dw, CalendarDate) BETWEEN 1 AND 7 THEN 1 ELSE 0 END) NumDays
   ,SUM(CASE WHEN DATEPART(dw, CalendarDate) BETWEEN 1 AND 5 THEN 1 ELSE 0 END) NumWeekDays
   ,SUM(CASE WHEN DATEPART(dw, CalendarDate) BETWEEN 1 AND 7 THEN 1 ELSE 0 END) * 7.6 MonthlyFullTimeHours38Hrs
   ,SUM(CASE WHEN DATEPART(dw, CalendarDate) BETWEEN 1 AND 7 THEN 1 ELSE 0 END) * 7.5 MonthlyFullTimeHours375Hrs
   ,SUM(CASE WHEN DATEPART(dw, CalendarDate) BETWEEN 1 AND 5 THEN 1 ELSE 0 END) * 7.6 RetailMonFri38Hrs
   ,SUM(CASE WHEN DATEPART(dw, CalendarDate) BETWEEN 1 AND 5 THEN 1 ELSE 0 END) * 7.5 RetailMonFri375Hrs
  FROM DataWarehouseChris21RawData.dbo.Staging_DimDate
  GROUP BY FinancialMonthId) Hours
  ON Hours.FinancialMonthId = DimDate.FinancialMonthId
ORDER BY PayDateId, Result.CalendarDate
