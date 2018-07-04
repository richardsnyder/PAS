SELECT DISTINCT
  pcorg.SYSOR_CODE + pcorg.GNA_ORG_CODE + pos.POS_L2_CD SourceKey
 ,pcorg.SYSOR_CODE SourceLevel
 ,pcorg.GNA_ORG_CODE SourceCode
 ,pos.POS_L5_CD Code
 ,pcorg.GNA_ORG_NAME Description
 ,pos.POS_L2_CD BusinessDivisionCode
 ,Staging_DimProfitCentre.CurrentBusinessDivisionId DataWarehouse_BusinessDivisionId
 ,Staging_DimProfitCentre.Id DataWarehouse_ProfitCentreId
 ,Staging_DimProfitCentre.SourceKey DataWarehosue_ProfitCentreSourceKey
 ,Staging_DimProfitCentre.Code DataWarehouse_ProfitCentreCode
 ,Staging_DimProfitCentre.Name DataWarehouse_ProfitCentreName
 ,Staging_DimProfitCentre.ProfitCentreType DataWarehouse_ProfitCentreType
 ,Staging_DimProfitCentre.State DataWarehouse_State
FROM Staging_EMPOS pos
LEFT JOIN Staging_ORGNA pcorg
  ON pos.POS_L5_CD = pcorg.GNA_ORG_CODE
    AND pcorg.SYSOR_CODE = 5
LEFT JOIN Staging_MatWarehouse
  ON Staging_MatWarehouse.ProfitCentreCode = pos.POS_L5_CD
LEFT JOIN Staging_DimProfitCentre
  ON Staging_DimProfitCentre.Code = pos.POS_L5_CD
WHERE NULLIF(pos.POS_END, '0001-01-02') IS NULL
ORDER BY 6, 3