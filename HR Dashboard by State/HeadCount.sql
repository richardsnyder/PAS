IF OBJECT_ID('tempdb..#FinPeriods') IS NOT NULL DROP TABLE #FinPeriods

SELECT DISTINCT DimDate.FinancialMonthId
, CAST(FinancialYear AS VARCHAR(4)) + ' - '+FinancialMonthName DisplayName
INTO #FinPeriods
FROM DimDate
WHERE DimDate.CalendarDate Between DATEADD(YEAR, -3, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, 1, CAST(GETDATE() AS DATE))

SELECT FactHeadCount.FinancialMonthId
 ,FinPeriods.DisplayName
 ,FactHeadCount.Chris21ProfitCentre + FactHeadCount.Chris21DivisionCode ProfitCentreSourceKey
 ,FactHeadCount.Chris21DivisionCode BusinessDivisionCode
 ,FactHeadCount.Chris21ProfitCentre ProfitCentreCode
 ,DimProfitCentre.Chris21_ProfitCentreName
 ,DimEmployee.DET_NUMBER EmployeeNumber
 ,DimEmployee.FirstName
 ,DimEmployee.Surname
 ,FactHeadCount.PositionTitle FullPositionTitle
 ,LTRIM(RTRIM(REPLACE(FactHeadCount.PositionTitle,FactHeadCount.Chris21ProfitCentre + ' ' + DimProfitCentre.Chris21_ProfitCentreName,'' ))) ShortPositionTitle
 ,DimAreaManager.AreaManagerId
 ,DimAreaManager.AreaManagerName
 ,DimProfitCentre.DataWarehouse_ProfitCentreName
 ,DimProfitCentre.DataWarehouse_State State
 ,DimProfitCentre.DataWarehouse_Country Country
 ,DimProfitCentre.DataWarehouse_ProfitCentreType
 ,SUM(HeadCount) HeadCount
FROM FactHeadCount
INNER JOIN DimEmployee
ON DimEmployee.Id = FactHeadCount.EmployeeId
LEFT JOIN DimProfitCentre 
ON DimProfitCentre.Chris21_SourceCode = FactHeadCount.Chris21ProfitCentre
AND DimProfitCentre.Chris21_BusinessDivisionCode = FactHeadCount.Chris21DivisionCode
INNER JOIN #FinPeriods FinPeriods
ON FinPeriods.FinancialMonthId = FactHeadCount.FinancialMonthId
LEFT JOIN DimAreaManager
ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
GROUP BY FactHeadCount.FinancialMonthId
         ,FinPeriods.DisplayName
        ,Chris21DivisionCode
        ,FactHeadCount.Chris21ProfitCentre
        ,DimAreaManager.AreaManagerId
        ,DimAreaManager.AreaManagerName
        ,DimProfitCentre.Chris21_ProfitCentreName
         ,DimEmployee.DET_NUMBER 
 ,DimEmployee.FirstName
 ,DimEmployee.Surname
        ,FactHeadCount.PositionTitle
        ,DimProfitCentre.DataWarehouse_ProfitCentreName
        ,DimProfitCentre.DataWarehouse_State
        ,DimProfitCentre.DataWarehouse_Country
        ,DimProfitCentre.DataWarehouse_ProfitCentreType
ORDER BY FinancialMonthId, BusinessDivisionCode, ProfitCentreCode

DROP TABLE #FinPeriods

--SELECT * FROM FactHeadCount fhc WHERE FinancialMonthId = 90 AND Chris21ProfitCentre = 1100
--SELECT * FROM FactFte ff WHERE FinancialMonthId = 90 AND EmployeeNumber IN ('00817','01085','01413','02824')

-- SELECT financialmonthid FROM dimdate WHERE CalendarDate = '30-jun-2017' -- 90