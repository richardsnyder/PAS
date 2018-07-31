TRUNCATE TABLE dbo.FactFte;

WITH FTE AS
(
  SELECT
    FactPayRunSummary.EmployeeId
   ,FactPayRunSummary.EmployeeNumber
   ,DimDate.FinancialMonthId
   ,DimEmployee.Pay_PayType AS PayType
   ,FactPosition.POS_AV_HR_WK AS ContractHours
   ,SUM(FactPayRunSummary.PHQ_BASE_HRS) AS WorkedHours
   ,CAST(SUM(
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
          --,FactPayRunSummary.PHQ_RUN_NUMB
          --,FactPayRunSummary.PHQ_PAY_DATE
          ,FactPosition.POS_AV_HR_WK
          ,DimEmployee.Pay_PayType
),

Positions AS
(
SELECT RawPositions.EmployeeId
 ,RawPositions.Employee_Number
 ,RawPositions.FinancialMonthId
 ,RawPositions.POS_TITLE
 ,RawPositions.Chris21DivisionCode
 ,RawPositions.Chris21ProfitCentre
 ,RawPositions.POS_NUMBER
 ,RawPositions.RN
FROM 
(
    SELECT DISTINCT
    EmployeeId
    ,Employee_Number
    ,FinancialMonthId
    ,POS_START
    ,POS_END 
    ,POS_TITLE
    ,POS_NUMBER
    ,POS_L2_CD AS Chris21DivisionCode
    ,POS_L4_CD AS Chris21PositionCode
    ,POS_L5_CD AS Chris21ProfitCentre
    ,POS_L5_CD + POS_L4_CD AS Chris21ProfitCentreSourceKey
    ,POS_L6_CD AS Chris21State
    ,RN = ROW_NUMBER()OVER(PARTITION BY FinancialMonthId, EmployeeId, POS_L5_CD ORDER BY FinancialMonthId, EmployeeId,POS_L5_CD)
    FROM dbo.FactPosition
    INNER JOIN dbo.DimDate
    ON DimDate.CalendarDate = FactPosition.PositionDate
    WHERE 1=1
  --  AND DimDate.FinancialMonthId = 102
  --  AND EmployeeId = 2305
) RawPositions
WHERE RN =1
)


INSERT INTO dbo.FactFte
           (FinancialMonthId
           ,EmployeeId
           ,EmployeeNumber
           ,FTE
           ,Chris21DivisionCode
           ,BusinessDivisionId
           ,Chris21ProfitCentre
           ,PositionTitle
           ,PositionNumber)

SELECT
  FTE.FinancialMonthId
  ,FTE.EmployeeId EmployeeId
  ,FTE.EmployeeNumber
  ,FTE.FTE
  ,Positions.Chris21DivisionCode
  ,DimBusinessDivision.DataWarehouse_BusinessDivisionId BusinessDivisinId
  ,Positions.Chris21ProfitCentre
  ,Positions.POS_TITLE
  ,Positions.POS_NUMBER
FROM FTE
LEFT JOIN Positions
ON Positions.EmployeeId = FTE.EmployeeId
AND FTE.FinancialMonthId = Positions.FinancialMonthId
AND Positions.RN = 1
LEFT JOIN DimBusinessDivision
ON DimBusinessDivision.Chris21_SourceCode = Positions.Chris21DivisionCode
WHERE FTE.FTE <>0
--AND FinancialMonthId = 102
--AND Chris21ProfitCentre = 1423
--AND FTE.EmployeeId IN (2305)
ORDER BY 1,2

--SELECT * FROM factfte WHERE FinancialMonthId = 102 AND Chris21ProfitCentre = 1423