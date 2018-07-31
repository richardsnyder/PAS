IF OBJECT_ID('tempdb..#HeadCount') IS NOT NULL
  DROP TABLE #HeadCount
IF OBJECT_ID('tempdb..#FinPeriods') IS NOT NULL
  DROP TABLE #FinPeriods

SELECT DISTINCT
  DimDate.FinancialMonthId
 ,CAST(FinancialYear AS VARCHAR(4)) + ' - ' + FinancialMonthName DisplayName INTO #FinPeriods
FROM DimDate
WHERE DimDate.CalendarDate BETWEEN DATEADD(YEAR, -3, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, 1, CAST(GETDATE() AS DATE))
;
--SELECT * FROM #FinPeriods

SELECT
  FactHeadCount.FinancialMonthId
 ,FactHeadCount.Chris21ProfitCentre + FactHeadCount.Chris21DivisionCode ProfitCentreSourceKey
 ,FactHeadCount.Chris21DivisionCode BusinessDivisionCode
 ,FactHeadCount.Chris21ProfitCentre ProfitCentreCode
 ,SUM(HeadCount) HeadCount
INTO #HeadCount
FROM FactHeadCount
LEFT JOIN DimProfitCentre
  ON DimProfitCentre.Chris21_SourceCode = FactHeadCount.Chris21ProfitCentre
    AND DimProfitCentre.Chris21_BusinessDivisionCode = FactHeadCount.Chris21DivisionCode
INNER JOIN #FinPeriods FinPeriods
  ON FinPeriods.FinancialMonthId = FactHeadCount.FinancialMonthId
GROUP BY FactHeadCount.FinancialMonthId
 ,FactHeadCount.Chris21ProfitCentre
 ,FactHeadCount.Chris21DivisionCode 
;

WITH LeaveLiability
AS
(SELECT
    FactPosition.PositionDate
   ,DimDate.FinancialMonthId
   ,CAST(DimDate.FinancialYear AS VARCHAR(4)) + ' - ' + DimDate.FinancialMonthName DisplayName
   ,DimProfitCentre.Chris21_ProfitCentreCode + DimProfitCentre.Chris21_BusinessDivisionCode ProfitCentreSourceKey
   ,FactPosition.POS_L2_CD Chris21BusinessDivisionCode
   ,FactPosition.POS_L5_CD Chris21ProfitCentre
   ,DimProfitCentre.Chris21_ProfitCentreName
   ,FactPosition.POS_L1_CD Chris21Companycode
   ,FactPosition.POS_L4_CD Chris21PositionType
   ,FactPosition.POS_TITLE FullPositionTitle
   ,LTRIM(RTRIM(REPLACE(FactPosition.POS_TITLE, FactPosition.POS_L5_CD + ' ' + DimProfitCentre.Chris21_ProfitCentreName, ''))) ShortPositionTitle
   ,DimAreaManager.AreaManagerId
   ,DimAreaManager.AreaManagerName
   ,DimProfitCentre.DataWarehouse_ProfitCentreName
   ,DimProfitCentre.DataWarehouse_State State
   ,DimProfitCentre.DataWarehouse_Country Country
   ,DimProfitCentre.DataWarehouse_ProfitCentreType
   ,FactLeaveAccrual.LeaveAccrualChangeDate
   ,FactLeaveAccrual.EmployeeId
   ,FactLeaveAccrual.Employee_Number
   ,FactLeaveAccrual.LAC_CUR_AC_H
   ,FactLeaveAccrual.LAC_CUR_EN_H
   ,FactLeaveAccrual.LAC_LVE_TYPE
   ,CASE
    WHEN SUM(FactLeaveAccrual.LAC_CUR_AC_H + FactLeaveAccrual.LAC_CUR_EN_H) >= 152 THEN 1
    ELSE 0
   END LeaveLiabilityEmployees
   ,SUM(FactLeaveAccrual.LAC_CUR_AC_H + FactLeaveAccrual.LAC_CUR_EN_H) LiabilityHours
  FROM DataWarehouseChris21.dbo.FactLeaveAccrual
  INNER JOIN dbo.DimDate
    ON DimDate.CalendarDate = FactLeaveAccrual.LeaveAccrualChangeDate
  LEFT JOIN dbo.FactPosition
    ON FactPosition.PositionDate = FactLeaveAccrual.LeaveAccrualChangeDate
    AND FactPosition.EmployeeId = FactLeaveAccrual.EmployeeId
  LEFT JOIN DimProfitCentre
    ON DimProfitCentre.Chris21_ProfitCentreCode = FactPosition.POS_L5_CD
    AND DimProfitCentre.Chris21_BusinessDivisionCode = FactPosition.POS_L2_CD
  LEFT JOIN DimAreaManager
    ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
  WHERE FactLeaveAccrual.LAC_LVE_TYPE = 'ANN'
  AND FactPosition.PositionDate IS NOT NULL
  GROUP BY     FactPosition.PositionDate
   ,DimDate.FinancialMonthId
   ,CAST(DimDate.FinancialYear AS VARCHAR(4)) + ' - ' + DimDate.FinancialMonthName 
   ,DimProfitCentre.Chris21_ProfitCentreCode + DimProfitCentre.Chris21_BusinessDivisionCode
   ,FactPosition.POS_L2_CD
   ,FactPosition.POS_L5_CD
   ,DimProfitCentre.Chris21_ProfitCentreName
   ,FactPosition.POS_L1_CD
   ,FactPosition.POS_L4_CD
   ,FactPosition.POS_TITLE
   ,LTRIM(RTRIM(REPLACE(FactPosition.POS_TITLE, FactPosition.POS_L5_CD + ' ' + DimProfitCentre.Chris21_ProfitCentreName, '')))
   ,DimAreaManager.AreaManagerId
   ,DimAreaManager.AreaManagerName
   ,DimProfitCentre.DataWarehouse_ProfitCentreName
   ,DimProfitCentre.DataWarehouse_State 
   ,DimProfitCentre.DataWarehouse_Country 
   ,DimProfitCentre.DataWarehouse_ProfitCentreType
   ,FactLeaveAccrual.LeaveAccrualChangeDate
   ,FactLeaveAccrual.EmployeeId
   ,FactLeaveAccrual.Employee_Number
   ,FactLeaveAccrual.LAC_CUR_AC_H
   ,FactLeaveAccrual.LAC_CUR_EN_H
   ,FactLeaveAccrual.LAC_LVE_TYPE
  )

SELECT
  LeaveLiability.FinancialMonthId
 ,LeaveLiability.DisplayName
 ,LeaveLiability.ProfitCentreSourceKey
 ,LeaveLiability.Chris21BusinessDivisionCode
 ,LeaveLiability.Chris21ProfitCentre
 ,LeaveLiability.Chris21_ProfitCentreName
 ,LeaveLiability.AreaManagerId
 ,LeaveLiability.AreaManagerName
 ,LeaveLiability.DataWarehouse_ProfitCentreName
 ,LeaveLiability.State
 ,LeaveLiability.Country
 ,LeaveLiability.DataWarehouse_ProfitCentreType
 ,HeadCount.HeadCount
,COUNT(LeaveLiability.EmployeeId) LiabilityEmployees
,SUM(LeaveLiability.LiabilityHours) LiabilityHours
FROM LeaveLiability
INNER JOIN #HeadCount HeadCount
  ON HeadCount.ProfitCentreSourceKey = LeaveLiability.ProfitCentreSourceKey
    AND HeadCount.FinancialMonthId = LeaveLiability.FinancialMonthId
WHERE 1 = 1
AND LeaveLiability.LiabilityHours > 152
GROUP BY LeaveLiability.FinancialMonthId
        ,LeaveLiability.DisplayName
        ,LeaveLiability.ProfitCentreSourceKey
        ,LeaveLiability.Chris21BusinessDivisionCode
        ,LeaveLiability.Chris21ProfitCentre
        ,LeaveLiability.Chris21_ProfitCentreName
        ,LeaveLiability.AreaManagerId
        ,LeaveLiability.AreaManagerName
        ,LeaveLiability.DataWarehouse_ProfitCentreName
        ,LeaveLiability.State
        ,LeaveLiability.Country
        ,LeaveLiability.DataWarehouse_ProfitCentreType
        ,HeadCount.HeadCount
ORDER BY 1, 3
DROP TABLE #HeadCount,#FinPeriods


