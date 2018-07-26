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
        DimEmployee.TerminationDate >= DimDate.FinancialMonthEnd) THEN 1
      ELSE 0
    END HeadCount
   ,DimDate.FinancialMonthId
   ,DimDate.FinancialMonthStart
   ,DimDate.FinancialMonthEnd
  FROM dbo.DimEmployee DimEmployee
  CROSS JOIN dbo.DimDate
  INNER JOIN FactPosition
  ON FactPosition.EmployeeId = DimEmployee.Id
  AND FactPosition.PositionDate = DimDate.CalendarDate
),
Positions AS
(
SELECT
FinancialMonthId 
,employeeid
, Employee_Number
,POS_START
,POS_END
, POS_TITLE
 ,POS_NUMBER
 ,Chris21DivisionCode
 ,Chris21PositionCode
 ,Chris21ProfitCentre
 ,Chris21ProfitCentreSourceKey
 ,Chris21State
 ,RN = ROW_NUMBER()OVER(PARTITION BY EmployeeId ORDER BY FinancialMonthId,POS_START,POS_END)
FROM 
  (  
    SELECT DISTINCT
    FinancialMonthId
    ,EmployeeId
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
    FROM dbo.FactPosition
    INNER JOIN dbo.DimDate
    ON DimDate.CalendarDate = FactPosition.PositionDate
  ) RawPosition

)

INSERT INTO dbo.FactHeadCount
           (FinancialMonthId
           ,EmployeeId
           ,EmployeeNumber
           ,HeadCount
           ,Chris21DivisionCode
           ,BusinessDivisinId
           ,Chris21ProfitCentre
           ,PositionTitle
           ,PositionNumber
           ,DateJoined
           ,TerminationDate)

SELECT
  Positions.FinancialMonthId
  ,Employees.Id EmployeeId
  ,Employees.DET_NUMBER
  ,Employees.HeadCount
  ,Positions.Chris21DivisionCode
  ,DimBusinessDivision.DataWarehouse_BusinessDivisionId BusinessDivisinId
  ,Positions.Chris21ProfitCentre
  ,Positions.POS_TITLE
  ,Positions.POS_NUMBER
  ,Employees.DateJoined
  ,Employees.TerminationDate
FROM Employees
LEFT JOIN Positions
ON Positions.EmployeeId = Employees.Id
AND Positions.FinancialMonthId = Employees.FinancialMonthId
LEFT JOIN DimBusinessDivision
ON DimBusinessDivision.Chris21_SourceCode = Positions.Chris21DivisionCode
WHERE HeadCount <>0
ORDER BY 1,2
