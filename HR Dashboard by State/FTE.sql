IF OBJECT_ID('tempdb..#FinPeriods') IS NOT NULL
  DROP TABLE #FinPeriods

SELECT DISTINCT
  DimDate.FinancialMonthId
 ,CAST(FinancialYear AS VARCHAR(4)) + ' - ' + FinancialMonthName DisplayName INTO #FinPeriods
FROM DimDate
WHERE DimDate.CalendarDate >= DATEADD(YEAR, -3, CAST(GETDATE() AS DATE))

SELECT
  FactFte.FinancialMonthId
 ,FinPeriods.DisplayName
 ,FactFte.Chris21ProfitCentre + FactFte.Chris21DivisionCode ProfitCentreSourceKey
 ,FactFte.Chris21DivisionCode BusinessDivisionCode
 ,FactFte.Chris21ProfitCentre ProfitCentreCode
 ,DimProfitCentre.Chris21_ProfitCentreName
 ,FactFte.PositionTitle FullPositionTitle

 ,Case when CHARINDEX(DimProfitCentre.Chris21_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName,FactFte.PositionTitle) = 0 
     Then DimProfitCentre.Chris21_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_BusinessDivisionCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName + ' ' + FactFte.PositionTitle
     ELSE FactFte.PositionTitle
  END AS FullPositionTitle2

 ,LTRIM(RTRIM(REPLACE(FactFte.PositionTitle, FactFte.Chris21ProfitCentre + ' ' + DimProfitCentre.Chris21_ProfitCentreName, ''))) ShortPositionTitle
 ,DimAreaManager.AreaManagerId
 ,DimAreaManager.AreaManagerName
 ,DimEmployee.Id EmployeeId
 ,DimEmployee.DET_NUMBER
 ,DimEmployee.FirstName
 ,DimEmployee.Surname
 ,DimProfitCentre.DataWarehouse_ProfitCentreName
 ,DimProfitCentre.DataWarehouse_State State
 ,DimProfitCentre.DataWarehouse_Country Country
 ,DimProfitCentre.DataWarehouse_ProfitCentreType
 ,SUM(FTE) FTE
FROM FactFte
LEFT JOIN DimProfitCentre
  ON DimProfitCentre.Chris21_SourceCode = FactFte.Chris21ProfitCentre
    AND DimProfitCentre.Chris21_BusinessDivisionCode = FactFte.Chris21DivisionCode
INNER JOIN #FinPeriods FinPeriods
  ON FinPeriods.FinancialMonthId = FactFte.FinancialMonthId
LEFT JOIN DimAreaManager
  ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
INNER JOIN DimEmployee
  ON DimEmployee.Id = FactFte.EmployeeId
GROUP BY FactFte.FinancialMonthId
        ,FinPeriods.DisplayName
        ,FactFte.Chris21DivisionCode
        ,FactFte.Chris21ProfitCentre
        ,DimProfitCentre.Chris21_ProfitCentreCode
        ,DimProfitCentre.Chris21_BusinessDivisionCode
        ,DimAreaManager.AreaManagerId
        ,DimAreaManager.AreaManagerName
        ,DimEmployee.Id
        ,DimEmployee.DET_NUMBER
        ,DimEmployee.FirstName
        ,DimEmployee.Surname
        ,DimProfitCentre.Chris21_ProfitCentreName
        ,FactFte.PositionTitle
        ,DimProfitCentre.DataWarehouse_ProfitCentreName
        ,DimProfitCentre.DataWarehouse_State
        ,DimProfitCentre.DataWarehouse_Country
        ,DimProfitCentre.DataWarehouse_ProfitCentreType
ORDER BY FinancialMonthId, BusinessDivisionCode, ProfitCentreCode

DROP TABLE #FinPeriods

-- SELECT * FROM FactFte fhc WHERE FinancialMonthId = 102 AND Chris21ProfitCentre = 1440
--SELECT * FROM FactFte ff WHERE FinancialMonthId = 90 AND EmployeeNumber IN ('00817','01085','01413','02824')

-- SELECT financialmonthid FROM dimdate WHERE CalendarDate = '30-jun-2017' -- 90

--SELECT employeeid, SUM(phq_base_hrs) phq_base_hrs 
--FROM FactPayRunSummary 
--WHERE EmployeeId IN (3824)
--AND PayDateId IN (209,211)
--GROUP BY EmployeeId

--SELECT id,Pay_PayType FROM DimEmployee WHERE Id = 3824

--SELECT MonthlyFullTimeHours38Hrs FROM DimDate
--WHERE calendardate = '30-Jun-2018'
