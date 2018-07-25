SELECT DISTINCT
DimProfitCentre.Chris21_BusinessDivisionCode BusinessDivisionCode
,DimBusinessDivision.Chris21_Description BusinessDivisionName
,DimProfitCentre.DataWarehouse_ProfitCentreType ProfitCentreType
,CASE 
  WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'RT' THEN 'Boutique'  
  WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'CO' THEN 'Concession'
  WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'OU' THEN 'Outlet'
  WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'SU' THEN 'Support Office'
  WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'WS' THEN 'Wholesale'
END AS ProfitCentreTypeDescription
,CASE 
   WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'RT' OR
       DimProfitCentre.DataWarehouse_ProfitCentreType = 'CO' OR
       DimProfitCentre.DataWarehouse_ProfitCentreType = 'OU' THEN 'Retail'
   WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'SU' THEN 'Support Office'
   WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'WS' THEN 'Wholesale'
 END AS Channel
,CASE
   WHEN DimProfitCentre.DataWarehouse_ProfitCentreType = 'WS' THEN 'VIC'
   WHEN DimProfitCentre.DataWarehouse_State IS NULL THEN 'VIC'
   ELSE DimProfitCentre.DataWarehouse_State 
 END AS [State]
,DimProfitCentre.DataWarehouse_ProfitCentreCode ProfitCentreCode
,DimProfitCentre.DataWarehouse_ProfitCentreName ProfitCentreName
,RIGHT(DimProfitCentre.Chris21_SourceKey,LEN(DimProfitCentre.Chris21_SourceKey)-1) AS ProfitCentreSourceKey
,DimProfitCentre.DataWarehouse_AreaManagerId
,DimAreaManager.AreaManagerCode
,DimAreaManager.AreaManagerName
FROM DimProfitCentre
INNER JOIN DimBusinessDivision
ON DimBusinessDivision.Chris21_SourceCode = DimProfitCentre.Chris21_BusinessDivisionCode
LEFT JOIN DimAreaManager
ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
ORDER BY DimProfitCentre.DataWarehouse_ProfitCentreCode