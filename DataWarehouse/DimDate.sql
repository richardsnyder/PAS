
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
 ,FinancialMonthId
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
    WHEN DATEPART(dw, CalendarDate) = 7 THEN CalendarDate
    ELSE NULL
  END PayDate
 ,CASE
    WHEN RetailWeek % 2 = 0 AND
      DATEPART(dw, CalendarDate) = 7 THEN 'RE/BA/YT'
    WHEN RetailWeek % 2 <> 0 AND
      DATEPART(dw, CalendarDate) = 7 THEN 'ME'
  END AS PayType
 ,GETDATE() AS UpdateDate
 ,SYSTEM_USER AS UpdateUser
 ,GETDATE() AS CreateDate
 ,SYSTEM_USER AS CreateUser
FROM DataWarehouseChris21RawData.dbo.Staging_DimDate
WHERE Staging_DimDate.CalendarDate >= '23-Jun-2014'