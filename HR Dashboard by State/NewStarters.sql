SELECT
  DimEmployee.DateJoined
 ,DimDate.FinancialMonthId
 ,CAST(DimDate.FinancialYear AS VARCHAR(4)) + ' - ' + DimDate.FinancialMonthName DisplayName
 ,DimProfitCentre.Chris21_ProfitCentreCode + DimProfitCentre.Chris21_BusinessDivisionCode ProfitCentreSourceKey
 ,FactPosition.POS_L2_CD Chris21BusinessDivisionCode
 ,FactPosition.POS_L5_CD Chris21ProfitCentre
 ,DimProfitCentre.Chris21_ProfitCentreName
 ,FactPosition.POS_L1_CD Chris21Companycode
 ,FactPosition.POS_L4_CD Chris21PositionType
-- ,FactPosition.POS_TITLE FullPositionTitle

  ,Case when CHARINDEX(DimProfitCentre.Chris21_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName,FactPosition.POS_TITLE) = 0 
     Then DimProfitCentre.Chris21_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_BusinessDivisionCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName + ' ' + FactPosition.POS_TITLE
     ELSE FactPosition.POS_TITLE
  END AS FullPositionTitle

 ,LTRIM(RTRIM(REPLACE(FactPosition.POS_TITLE, FactPosition.POS_L5_CD + ' ' + DimProfitCentre.Chris21_ProfitCentreName, ''))) ShortPositionTitle
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
FROM dbo.DimEmployee DimEmployee
INNER JOIN dbo.DimDate DimDate
  ON DimDate.CalendarDate = DimEmployee.DateJoined
INNER JOIN dbo.FactPosition FactPosition
  ON FactPosition.EmployeeId = DimEmployee.Id
    AND FactPosition.PositionDate = DimEmployee.DateJoined
LEFT JOIN DimProfitCentre
  ON DimProfitCentre.Chris21_ProfitCentreCode = FactPosition.POS_L5_CD
    AND DimProfitCentre.Chris21_BusinessDivisionCode = FactPosition.POS_L2_CD
LEFT JOIN DimAreaManager
  ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
WHERE DimDate.CalendarDate BETWEEN DATEADD(YEAR, -3, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, 1, CAST(GETDATE() AS DATE))
ORDER BY DateJoined