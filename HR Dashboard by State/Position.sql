WITH Positions AS (
SELECT DISTINCT
  FactPosition.POS_L0_CD AS Country
 ,FactPosition.POS_L1_CD AS Division
 ,FactPosition.POS_L2_CD AS ShortDivision
 ,FactPosition.POS_L3_CD AS PositionType
 ,FactPosition.POS_L4_CD AS PositionTypeShort
 ,FactPosition.POS_L5_CD AS ProfitCentre
 ,FactPosition.POS_L5_CD + FactPosition.POS_L2_CD ProfitCentreSourceKey
 ,FactPosition.POS_L6_CD AS State
-- ,FactPosition.POS_TITLE AS FullPositionTitle

  ,Case when CHARINDEX(DimProfitCentre.Chris21_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName,FactPosition.POS_TITLE) = 0 
     Then DimProfitCentre.Chris21_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_BusinessDivisionCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName + ' ' + FactPosition.POS_TITLE
     ELSE FactPosition.POS_TITLE
  END AS FullPositionTitle

 ,LTRIM(RTRIM(REPLACE(FactPosition.POS_Title, DimProfitCentre.DataWarehouse_ProfitCentreCode + ' ' + DimProfitCentre.Chris21_ProfitCentreName, ''))) ShortPositionTitle
 ,RowNum = ROW_NUMBER() OVER (PARTITION BY FactPosition.POS_TITLE ORDER BY FactPosition.POS_TITLE)
FROM DataWarehouseChris21.dbo.FactPosition FactPosition
INNER JOIN DataWarehouseChris21.dbo.DimProfitCentre DimProfitCentre
ON RIGHT(DimProfitCentre.Chris21_SourceKey,LEN(DimProfitCentre.Chris21_SourceKey) -1) = FactPosition.POS_L5_CD + FactPosition.POS_L2_CD
)
SELECT Country, Division,ShortDivision,PositionType, PositionTYpeShort, ProfitCentre, ProfitCentreSourceKey, FullPositionTitle ,ShortPositionTitle
FROM Positions
WHERE RowNum = 1
