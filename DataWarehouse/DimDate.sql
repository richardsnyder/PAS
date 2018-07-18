SET DATEFIRST 1
SELECT
  CalendarDate
 ,CalendarDayName
 ,CalendarDateDisplayName
 ,CalendarDateName
 ,CalendarWeek
 ,CalendarWeekName
 ,CalendarWeekStart
 ,CalendarWeekEnd
 ,CalendarMonth
 ,CalendarMonthName
 ,CalendarMonthStart
 ,CalendarMonthEnd
 ,CalendarQuarter
 ,CalendarQuarterName
 ,CalendarQuarterStart
 ,CalendarQuarterEnd
 ,CalendarHalf
 ,CalendarHalfName
 ,CalendarHalfStart
 ,CalendarHalfEnd
 ,CalendarYear
 ,CalendarYearName
 ,CalendarYearStart
 ,CalendarYearEnd
 ,DayOfWeekId
 ,RetailWeekId
 ,RetailWeek
 ,RetailWeekName
 ,RetailWeekStart
 ,RetailWeekEnd
 ,RetailPeriodId
 ,RetailPeriod
 ,RetailPeriodName
 ,RetailPeriodStart
 ,RetailPeriodEnd
 ,RetailHalf
 ,RetailHalfName
 ,RetailHalfStart
 ,RetailHalfEnd
 ,RetailSeason
 ,RetailYearId
 ,RetailYear
 ,RetailYearName
 ,RetailYearStart
 ,RetailYearEnd
 ,SameRetailDayPreviousYear
 ,Staging_DimDate.FinancialMonthId
 ,FinancialMonth
 ,FinancialMonthName
 ,FinancialMonthStart
 ,FinancialMonthEnd
 ,FinancialQuarter
 ,FinancialQuarterName
 ,FinancialQuarterStart
 ,FinancialQuarterEnd
 ,FinancialHalf
 ,FinancialHalfName
 ,FinancialHalfStart
 ,FinancialHalfEnd
 ,FinancialYearId
 ,FinancialYear
 ,FinancialYearName
 ,FinancialYearStart
 ,FinancialYearEnd
 ,RelativeCalendarWeek
 ,RelativeRollingCalendarYear
 ,RelativeRetailYear
 ,RelativeRetailHalf
 ,RelativeRetailPeriod
 ,RelativeRetailWeek
 ,RelativeRetailYearToDate
 ,RelativeRetailYearToDateByWeek
 ,RelativeRetailYearToDateByPeriod
 ,RelativeRetailPeriodToDate
 ,RelativeRetailWeekToDate
 ,RelativeRetailDay
 ,RelativeFinancialYear
 ,RelativeFinancialHalf
 ,RelativeFinancialQuarter
 ,RelativeFinancialMonth
 ,RelativeFinancialYearToGo
 ,RelativeFinancialYearToDate
 ,RelativeFinancialYearToDateByHalf
 ,RelativeFinancialYearToDateByQuarter
 ,RelativeFinancialYearToDateByMonth
 ,RelativeFinancialMonthToGo
 ,RelativeFinancialMonthToDate
 ,RelativeFinancialHalfToGo
 ,RelativeFinancialHalfToDate
 ,RelativeFinancialQuarterToGo
 ,RelativeFinancialQuarterToDate
 ,RelativeFinancialDay
 ,PreviousDay
 ,NextDay
 ,RelativeSeasonToDate
 ,RelativeLast4Weeks
 ,RelativeLast8Weeks
 ,RelativeLast12Weeks
 ,CASE 
    WHEN DATEPART(dw, CalendarDate) = 7 THEN CalendarDate ELSE NULL 
  END PayDate
 ,CASE 
    WHEN RetailWeek % 2 = 0 AND DATEPART(dw, CalendarDate) = 7 THEN 'RE/BA/YT' 
    WHEN RetailWeek % 2 <> 0 AND DATEPART(dw, CalendarDate) = 7 THEN 'ME' 
  END AS PayType
 ,HOURS.NumDays
 ,HOURS.NumWeekDays
 ,HOURS.MonthlyFullTimeHours38Hrs
 ,HOURS.MonthlyFullTimeHours375Hrs
 ,HOURS.RetailMonFri38Hrs
 ,HOURS.RetailMonFri375Hrs
 ,152 HrDashboardFortNightHours
 ,GETDATE() AS UpdateDate
 ,system_user AS UpdateUser
 ,GETDATE() AS CreateDate
 ,system_user AS CreateUser
FROM DataWarehouseChris21RawData.dbo.Staging_DimDate
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
  ON Hours.FinancialMonthId = Staging_DimDate.FinancialMonthId

WHERE Staging_DimDate.CalendarDate >= '23-Jun-2014'