IF OBJECT_ID('tempdb..#HeadCount') IS NOT NULL
  DROP TABLE #HeadCount
IF OBJECT_ID('tempdb..#FinPeriods') IS NOT NULL
  DROP TABLE #FinPeriods
IF OBJECT_ID('tempdb..#Leave') IS NOT NULL
  DROP TABLE #Leave
IF OBJECT_ID('tempdb..#Position') IS NOT NULL
  DROP TABLE #Position

SELECT DISTINCT
  DimDate.FinancialMonthId
 ,CAST(FinancialYear AS VARCHAR(4)) + ' - ' + FinancialMonthName DisplayName INTO #FinPeriods
FROM DimDate
WHERE DimDate.CalendarDate BETWEEN DATEADD(YEAR, -3, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, 1, CAST(GETDATE() AS DATE))

--SELECT * FROM #FinPeriods

SELECT
  DimDate.FinancialMonthId
 ,FactLeaveTaken.Employee_Id
 ,FactLeaveTaken.Employee_Number
 ,FactLeaveTaken.LeaveStartDate
 ,FactLeaveTaken.LeaveEndDate
 ,FactLeaveTaken.LeaveType
 ,SUM(FactLeaveTaken.LeaveHoursTaken) HrsTaken INTO #Leave
FROM dbo.FactLeaveTaken
INNER JOIN dbo.DimDate
  ON DimDate.CalendarDate = FactLeaveTaken.LeaveStartDate
INNER JOIN #FinPeriods FinPeriods
  ON FinPeriods.FinancialMonthId = DimDate.FinancialMonthId
WHERE 1 = 1
--AND (LeaveStartDate >= '01-Jun-2018'
--AND LeaveEndDate <= '30-Jun-2018')
AND LeaveType IN ('PERS', 'UPER', 'CARE')
GROUP BY DimDate.FinancialMonthId
        ,FactLeaveTaken.Employee_Id
        ,FactLeaveTaken.Employee_Number
        ,FactLeaveTaken.LeaveStartDate
        ,FactLeaveTaken.LeaveEndDate
        ,FactLeaveTaken.LeaveType

SELECT
  FactHeadCount.FinancialMonthId
 ,FactHeadCount.Chris21ProfitCentre + FactHeadCount.Chris21DivisionCode ProfitCentreSourceKey
 ,FactHeadCount.Chris21DivisionCode BusinessDivisionCode
 ,FactHeadCount.Chris21ProfitCentre ProfitCentreCode
 ,FactHeadCount.EmployeeId
 ,FactHeadCount.HeadCount INTO #HeadCount
FROM FactHeadCount
LEFT JOIN DimProfitCentre
  ON DimProfitCentre.Chris21_SourceCode = FactHeadCount.Chris21ProfitCentre
    AND DimProfitCentre.Chris21_BusinessDivisionCode = FactHeadCount.Chris21DivisionCode
INNER JOIN #FinPeriods FinPeriods
  ON FinPeriods.FinancialMonthId = FactHeadCount.FinancialMonthId


SELECT
  FinancialMonthId
 ,ProfitCentreSourceKey
 ,EmployeeId
 ,Employee_Number
 ,POS_START
 ,POS_END
 ,DisplayName
 ,Chris21BusinessDivisionCode
 ,Chris21ProfitCentre
 ,Chris21Companycode
 ,Chris21PositionType
 ,FullPositionTitle INTO #Position
FROM (SELECT
    RowNum = ROW_NUMBER() OVER (PARTITION BY FInPeriods.FinancialMonthId, FactPosition.EmployeeId ORDER BY FInPeriods.FinancialMonthId, FactPosition.EmployeeId, FactPosition.POS_START DESC, FactPosition.POS_END ASC)
   ,FInPeriods.FinancialMonthId
   ,FactPosition.EmployeeId
   ,FactPosition.Employee_Number
   ,FactPosition.POS_L5_CD + FactPosition.POS_L2_CD ProfitCentreSourceKey
   ,FactPosition.POS_START
   ,FactPosition.POS_END
   ,FInPeriods.DisplayName
   ,FactPosition.POS_L2_CD Chris21BusinessDivisionCode
   ,FactPosition.POS_L5_CD Chris21ProfitCentre
   ,FactPosition.POS_L1_CD Chris21Companycode
   ,FactPosition.POS_L4_CD Chris21PositionType
   ,FactPosition.POS_TITLE FullPositionTitle
  FROM DataWarehouseChris21.dbo.FactPosition FactPosition
  INNER JOIN DataWarehouse.dbo.DimDate DimDate
    ON DimDate.CalendarDate = FactPosition.PositionDate

  INNER JOIN #FinPeriods FInPeriods
    ON FInPeriods.FinancialMonthId = DimDate.FinancialMonthId

  WHERE 1 = 1) Position
WHERE RowNum = 1

SELECT
  FinPeriods.FinancialMonthId
 ,FinPeriods.DisplayName
 ,SUBSTRING(DimProfitCentre.Chris21_SourceKey, 2, LEN(DimProfitCentre.Chris21_SourceKey)) ProfitCentreSourceKey
 ,DimProfitCentre.Chris21_BusinessDivisionCode Chris21BusinessDivisionCode
 ,DimProfitCentre.Chris21_ProfitCentreCode Chris21ProfitCentre
 ,DimProfitCentre.Chris21_ProfitCentreName
 ,DimAreaManager.AreaManagerId
 ,DimAreaManager.AreaManagerName
 ,DimProfitCentre.DataWarehouse_ProfitCentreName
 ,DimProfitCentre.DataWarehouse_State State
 ,DimProfitCentre.DataWarehouse_Country Country
 ,DimProfitCentre.DataWarehouse_ProfitCentreType
 ,DimEmployee.Id EmployeeId
 ,DimEmployee.DET_NUMBER EmployeeNumber
 ,DimEmployee.FirstName
 ,DimEmployee.Surname
 ,COALESCE(HeadCount.HeadCount, 0) HeadCount
 ,Leave.LeaveType
 ,SUM(Leave.HrsTaken) HoursTaken
FROM #Leave Leave
LEFT JOIN #HeadCount HeadCount
  ON HeadCount.FinancialMonthId = Leave.FinancialMonthId
    AND HeadCount.EmployeeId = Leave.Employee_Id
INNER JOIN DimProfitCentre
  ON SUBSTRING(DimProfitCentre.Chris21_SourceKey, 2, LEN(DimProfitCentre.Chris21_SourceKey)) = HeadCount.ProfitCentreSourceKey
LEFT JOIN DimAreaManager
  ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
INNER JOIN #FinPeriods FinPeriods
  ON FinPeriods.FinancialMonthId = Leave.FinancialMonthId
INNER JOIN DimEmployee
  ON DimEmployee.Id = Leave.Employee_Id
GROUP BY FinPeriods.FinancialMonthId
        ,FinPeriods.DisplayName
        ,SUBSTRING(DimProfitCentre.Chris21_SourceKey, 2, LEN(DimProfitCentre.Chris21_SourceKey))
        ,DimProfitCentre.Chris21_BusinessDivisionCode
        ,DimProfitCentre.Chris21_ProfitCentreCode
        ,DimProfitCentre.Chris21_ProfitCentreName
        ,DimAreaManager.AreaManagerId
        ,DimAreaManager.AreaManagerName
        ,DimProfitCentre.DataWarehouse_ProfitCentreName
        ,DimProfitCentre.DataWarehouse_State
        ,DimProfitCentre.DataWarehouse_Country
        ,DimProfitCentre.DataWarehouse_ProfitCentreType
        ,DimEmployee.Id
        ,DimEmployee.DET_NUMBER
        ,DimEmployee.FirstName
        ,DimEmployee.Surname
        ,HeadCount.HeadCount
        ,Leave.LeaveType
ORDER BY 1

DROP TABLE #HeadCount, #FinPeriods, #Leave, #Position

