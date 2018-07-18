TRUNCATE TABLE dbo.FactFte;

USE DataWarehouseChris21
GO

INSERT INTO dbo.FactFte (EmployeeId
, EmployeeNumber
, FinancialMonthId
, PayRun
, PayDate
, PayType
, ContractHours
, WorkedHours
, FTE)

  SELECT
    FactPayRunSummary.EmployeeId
   ,FactPayRunSummary.EmployeeNumber
   ,DimDate.FinancialMonthId
   ,FactPayRunSummary.PHQ_RUN_NUMB AS PayRun
   ,FactPayRunSummary.PHQ_PAY_DATE AS PayDate
   ,DimEmployee.Pay_PayType AS PayType
   ,FactPosition.POS_AV_HR_WK AS ContractHours
   ,SUM(FactPayRunSummary.PHQ_BASE_HRS) AS WorkedHours
   ,CAST(
    SUM(
    CASE
      WHEN DimEmployee.Pay_PayType IN (30, 31, 33, 34, 35, 36, 50, 52, 53, 54, 55, 56, 57) THEN FactPayRunSummary.PHQ_BASE_HRS / DimDate.MonthlyFullTimeHours38Hrs --1
      WHEN DimEmployee.Pay_PayType IN (32, 51) THEN FactPayRunSummary.PHQ_BASE_HRS / DimDate.HrDashboardFortNightHours --2
      WHEN DimEmployee.Pay_PayType IN (70, 71, 72, 73, 74, 75, 76, 77) THEN FactPayRunSummary.PHQ_BASE_HRS / DimDate.RetailMonFri38Hrs --3
      WHEN DimEmployee.Pay_PayType IN (72) AND FactPosition.POS_AV_HR_WK = 37.5 THEN FactPayRunSummary.PHQ_BASE_HRS / DimDate.RetailMonFri375Hrs --4
      WHEN DimEmployee.Pay_PayType IN (50) AND FactPosition.POS_AV_HR_WK = 37.5 THEN FactPayRunSummary.PHQ_BASE_HRS / DimDate.MonthlyFullTimeHours375Hrs --5
      ELSE FactPayRunSummary.PHQ_BASE_HRS / DimDate.HrDashboardFortNightHours -- Default FTE value when the Paytype is not matched
    END)
    AS NUMERIC(18, 2)) AS FTE
  FROM dbo.FactPayRunSummary
  INNER JOIN dbo.DimDate
    ON DimDate.CalendarDate = FactPayRunSummary.PHQ_PAY_DATE
  INNER JOIN dbo.FactPosition
    ON FactPosition.PositionDate = FactPayRunSummary.PHQ_PAY_DATE --DimDate.CalendarDate
      AND FactPosition.EmployeeId = FactPayRunSummary.EmployeeId
  INNER JOIN dbo.DimEmployee
    ON DimEmployee.Id = FactPayRunSummary.EmployeeId
  WHERE 1 = 1
  AND DimEmployee.Pay_PayType != 'D'
  --  AND EmployeeNumber = '00971'
  --  AND PHQ_PAY_DATE BETWEEN '25-May-2017' AND '30-Jun-2017' 
  GROUP BY FactPayRunSummary.EmployeeId
          ,FactPayRunSummary.EmployeeNumber
          ,DimDate.FinancialMonthId
          ,FactPayRunSummary.PHQ_RUN_NUMB
          ,FactPayRunSummary.PHQ_PAY_DATE
          ,FactPosition.POS_AV_HR_WK
          ,DimEmployee.Pay_PayType
  ORDER BY 3, 1, 4 DESC

  --SELECT MIN(PIT_RUN_DATE), MAX(PIT_RUN_DATE)
  --FROM DataWarehouseChris21.dbo.FactPayRunDetails
  --WHERE EmployeeNumber = '03808'

--SELECT DISTINCT pay_paytype FROM DimEmployee ORDER BY 1

--SELECT TOP 100 * FROM dimdate


--SELECT * FROM Dimdate where calendardate = '15-Jun-2017' = 90
--SET DATEFIRST 1
--SELECT COUNT(*) from  dimdate WHERE financialmonthid = 90 AND DATEPART(dw,calendardate) BETWEEN 1 AND 5


--SELECT distinct PayPositionType FROM FactPosition WHERE /*PositionDate = '15-May-2017' AND*/ EmployeeId = 104

--SELECT DISTINCT DimEmployee.Pay_PayType FROM DimEmployee ORDER BY 1