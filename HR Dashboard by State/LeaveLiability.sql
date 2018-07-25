IF OBJECT_ID('tempdb..#HeadCount') IS NOT NULL DROP TABLE #HeadCount
IF OBJECT_ID('tempdb..#FinPeriods') IS NOT NULL DROP TABLE #FinPeriods

SELECT DISTINCT DimDate.FinancialMonthId
, CAST(FinancialYear AS VARCHAR(4)) + ' - '+FinancialMonthName DisplayName
INTO #FinPeriods
FROM DimDate
WHERE DimDate.CalendarDate BETWEEN DATEADD(YEAR, -3, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, 1, CAST(GETDATE() AS DATE))
;
--SELECT * FROM #FinPeriods

SELECT
  FactHeadCount.FinancialMonthId
 ,FactHeadCount.Chris21DivisionCode
 ,SUM(FactHeadCount.HeadCount) HeadCount 
INTO #HeadCount
FROM FactHeadCount
INNER JOIN #FinPeriods FinPeriods
ON FinPeriods.FinancialMonthId = FactHeadCount.FinancialMonthId
GROUP BY FactHeadCount.FinancialMonthId
        ,Chris21DivisionCode
;
--SELECT * FROM #HeadCount ORDER BY 1

WITH LeaveLiability
AS 
(
SELECT
  DimDate.FinancialMonthId
 ,FactPosition.PositionDate
 ,FactPosition.POS_L1_CD
 ,FactPosition.POS_L2_CD
 ,FactPosition.POS_L4_CD
 ,FactPosition.POS_L5_CD
 ,FactPosition.POS_TITLE
 ,LTRIM(RTRIM(REPLACE(FactPosition.POS_TITLE,FactPosition.POS_L5_CD + ' ' + DimProfitCentre.Chris21_ProfitCentreName,'' ))) ShortPositionTitle
 ,DimAreaManager.AreaManagerName
 ,FactLeaveAccrual.LeaveAccrualChangeDate
 ,FactLeaveAccrual.EmployeeId
 ,FactLeaveAccrual.Employee_Number
 ,FactLeaveAccrual.LAC_CUR_AC_H
 ,FactLeaveAccrual.LAC_CUR_EN_H
 ,FactLeaveAccrual.LAC_LVE_TYPE
 ,HeadCount.HeadCount
FROM DataWarehouseChris21.dbo.FactLeaveAccrual
INNER JOIN dbo.DimDate
  ON DimDate.CalendarDate = FactLeaveAccrual.LeaveAccrualChangeDate
LEFT JOIN dbo.FactPosition
  ON FactPosition.PositionDate = FactLeaveAccrual.LeaveAccrualChangeDate
    AND FactPosition.EmployeeId = FactLeaveAccrual.EmployeeId
LEFT JOIN #HeadCount HeadCount
ON HeadCount.FinancialMonthId = DimDate.FinancialMonthId
AND HeadCount.Chris21DivisionCode = FactPosition.POS_L2_CD
LEFT JOIN DimProfitCentre
ON DimProfitCentre.Chris21_ProfitCentreCode = FactPosition.POS_L5_CD
AND DimProfitCentre.Chris21_BusinessDivisionCode = FactPosition.POS_L2_CD
LEFT JOIN DimAreaManager
ON DimAreaManager.Chris21ProfitCentre =  FactPosition.POS_L5_CD
WHERE FactLeaveAccrual.LAC_LVE_TYPE = 'ann'
--AND FactLeaveAccrual.Employee_Number = '02401'
AND FactPosition.PositionDate IS NOT NULL
)

SELECT * FROM LeaveLiability
ORDER BY POS_L5_CD


SELECT * FROM DimAreaManager ORDER BY 1

SELECT * FROM DataWarehouseChris21RawData.dbo.Staging_UPZAM

SELECT * FROM FactPosition WHERE POS_NUMBER = '001533' AND POS_END IS null
SELECT * FROM DimEmployee de WHERE DET_NUMBER = '03551'

--SELECT FinancialMonthId
--, Division
--, HeadCount
--,SUM(LeaveLiabilityEmployees) LeaveLiability
--FROM (
--  SELECT LeaveLiability.FinancialMonthId
--  ,LeaveLiability.POS_L2_CD AS Division
--  ,LeaveLiability.EmployeeId
--  ,HeadCount
--  ,CASE WHEN SUM(LeaveLiability.LAC_CUR_AC_H + LeaveLiability.LAC_CUR_EN_H) >= 152 THEN 1 ELSE 0 END  LeaveLiabilityEmployees
--  --,SUM(LeaveLiability.LAC_CUR_AC_H + LeaveLiability.LAC_CUR_EN_H) AS Liability
--  FROM LeaveLiability
--  WHERE POS_L1_CD ='PASL'
--  AND FinancialMonthId = 103
--  GROUP BY FinancialMonthId
--  ,LeaveLiability.EmployeeId
--  ,POS_L1_CD
--  ,POS_L2_CD
--  ,HeadCount
--  HAVING SUM(LeaveLiability.LAC_CUR_AC_H + LeaveLiability.LAC_CUR_EN_H) >= 152
--) LeaveLiability
--GROUP BY FinancialMonthId, Division, HeadCount
--ORDER BY 2, 1
--DROP TABLE #HeadCount
  