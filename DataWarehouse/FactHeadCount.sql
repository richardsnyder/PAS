TRUNCATE TABLE dbo.FactHeadCount;

WITH Employees
AS
(
  SELECT DISTINCT
    DimEmployee.Id
   ,DimEmployee.DET_NUMBER
   ,DimEmployee.DateJoined
   ,DimEmployee.TerminationDate
   ,CASE
      WHEN DimEmployee.DateJoined <= DimDate.FinancialMonthEnd AND
        (DimEmployee.TerminationDate = '0001-01-02' OR
        DimEmployee.TerminationDate > DimDate.FinancialMonthEnd) THEN 1
      ELSE 0
    END HeadCount
   ,DimDate.FinancialMonthId
   ,DimDate.FinancialMonthStart
   ,DimDate.FinancialMonthEnd
  FROM dbo.DimEmployee DimEmployee
  CROSS JOIN dbo.DimDate
--  WHERE DimDate.FinancialMonthId = 102
),
Positions AS
(
  SELECT DISTINCT
  EmployeeId
  ,Employee_Number
  ,POS_START
  ,POS_END 
  ,POS_TITLE
  ,POS_NUMBER
  ,POS_L2_CD AS Chris21DivisionCode
  ,POS_L4_CD AS Chris21PositionCode
  ,POS_L5_CD AS Chris21ProfitCentre
  ,POS_L5_CD + POS_L4_CD AS Chris21ProfitCentreSourceKey
  ,POS_L6_CD AS Chris21State
  ,RN = ROW_NUMBER()OVER(PARTITION BY EmployeeId ORDER BY EmployeeId)
  FROM dbo.FactPosition
  INNER JOIN dbo.DimDate
  ON DimDate.CalendarDate = FactPosition.PositionDate
--  WHERE DimDate.FinancialMonthId = 102
)

INSERT INTO dbo.FactHeadCount
           (FinancialMonthId
           ,EmployeeId
           ,HeadCount
           ,Chris21DivisionCode
           ,BusinessDivisinId
           ,Chris21ProfitCentre
           ,DET_NUMBER
           ,PositionTitle
           ,PositionNumber
           ,DateJoined
           ,TerminationDate)

SELECT
  Employees.FinancialMonthId
  ,Employees.Id EmployeeId
  ,Employees.HeadCount
  ,Positions.Chris21DivisionCode
  ,DimBusinessDivision.DataWarehouse_BusinessDivisionId BusinessDivisinId
  ,Positions.Chris21ProfitCentre
  ,Employees.DET_NUMBER
  ,Positions.POS_TITLE
  ,Positions.POS_NUMBER
  ,Employees.DateJoined
  ,Employees.TerminationDate
FROM Employees
LEFT JOIN Positions
ON Positions.EmployeeId = Employees.Id
AND Positions.RN = 1
LEFT JOIN DimBusinessDivision
ON DimBusinessDivision.Chris21_SourceCode = Positions.Chris21DivisionCode
WHERE HeadCount <>0
-- AND Employees.FinancialMonthId = 54
-- AND Chris21DivisionCode = 'RE'
-- AND Employees.Id = 1
ORDER BY 1,2

--SELECT * FROM FactHeadCount fhc WHERE Chris21ProfitCentre IS null order by 2,1

--SELECT * FROM DimDate dpd WHERE FinancialMonthId = 60 ORDER BY 1  --186

--SELECT * 
--FROM FactPosition
--INNER JOIN DimDate 
--ON DimDate.CalendarDate = FactPosition.PositionDate
----AND DimDate.FinancialMonthId = 103
--WHERE EmployeeId = 4128

--select * FROM DimEmployee WHERE id in (4131,4132)

--SELECT * FROM DataWarehouseChris21RawData.dbo.Staging_EMDET WHERE DET_NUMBER IN ('04738')

--SELECT * FROM DimBusinessDivision
