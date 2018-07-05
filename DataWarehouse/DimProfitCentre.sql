DECLARE @StagedData TABLE (
  Chris21_SourceKey VARCHAR(15)
 ,Chris21_SourceLevel VARCHAR(1)
 ,Chris21_SourceCode VARCHAR(10)
 ,Chris21_ProfitCentreCode VARCHAR(20)
 ,Chris21_ProfitCentreName VARCHAR(30)
 ,Chris21_BusinessDivisionCode VARCHAR(10)
 ,DataWarehouse_BusinessDivisionId INT
 ,DataWarehouse_ProfitCentreId INT
 ,DataWarehosue_ProfitCentreSourceKey INT
 ,DataWarehouse_ProfitCentreCode VARCHAR(15)
 ,DataWarehouse_ProfitCentreName VARCHAR(40)
 ,DataWarehouse_ProfitCentreType VARCHAR(5)
 ,DataWarehouse_State VARCHAR(10)
)

INSERT INTO @StagedData (
  Chris21_SourceKey
 ,Chris21_SourceLevel
 ,Chris21_SourceCode
 ,Chris21_ProfitCentreCode
 ,Chris21_ProfitCentreName
 ,Chris21_BusinessDivisionCode
 ,DataWarehouse_BusinessDivisionId
 ,DataWarehouse_ProfitCentreId
 ,DataWarehosue_ProfitCentreSourceKey
 ,DataWarehouse_ProfitCentreCode
 ,DataWarehouse_ProfitCentreName
 ,DataWarehouse_ProfitCentreType
 ,DataWarehouse_State
)
SELECT DISTINCT
  pcorg.SYSOR_CODE + pcorg.GNA_ORG_CODE + pos.POS_L2_CD Chris21_SourceKey
 ,pcorg.SYSOR_CODE Chris21_SourceLevel
 ,pcorg.GNA_ORG_CODE Chris21_SourceCode
 ,pos.POS_L5_CD Chris21_ProfitCentreCode
 ,pcorg.GNA_ORG_NAME Chris21_ProfitCentreName
 ,pos.POS_L2_CD Chris21_BusinessDivisionCode
 ,Staging_DimProfitCentre.CurrentBusinessDivisionId DataWarehouse_BusinessDivisionId
 ,Staging_DimProfitCentre.Id DataWarehouse_ProfitCentreId
 ,Staging_DimProfitCentre.SourceKey DataWarehosue_ProfitCentreSourceKey
 ,Staging_DimProfitCentre.Code DataWarehouse_ProfitCentreCode
 ,Staging_DimProfitCentre.Name DataWarehouse_ProfitCentreName
 ,Staging_DimProfitCentre.ProfitCentreType DataWarehouse_ProfitCentreType
 ,Staging_DimProfitCentre.State DataWarehouse_State
FROM DataWarehouseChris21RawData.dbo.Staging_EMPOS pos
LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_ORGNA pcorg
  ON pos.POS_L5_CD = pcorg.GNA_ORG_CODE
    AND pcorg.SYSOR_CODE = 5
LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_DimProfitCentre
  ON Staging_DimProfitCentre.Code = pos.POS_L5_CD
WHERE NULLIF(pos.POS_END, '0001-01-02') IS NULL
ORDER BY 6,3

MERGE dbo.DimProfitCentre AS Destination
USING @StagedData AS Source ON
  Source.Chris21_SourceKey = Destination.Chris21_SourceKey
  AND SOURCE.DataWarehouse_ProfitCentreId = Destination.DataWarehouse_ProfitCentreId

WHEN NOT MATCHED BY TARGET THEN INSERT (
 Chris21_SourceKey
 ,Chris21_SourceLevel
 ,Chris21_SourceCode
 ,Chris21_ProfitCentreCode
 ,Chris21_ProfitCentreName
 ,Chris21_BusinessDivisionCode
 ,DataWarehouse_BusinessDivisionId
 ,DataWarehouse_ProfitCentreId
 ,DataWarehosue_ProfitCentreSourceKey
 ,DataWarehouse_ProfitCentreCode
 ,DataWarehouse_ProfitCentreName
 ,DataWarehouse_ProfitCentreType
 ,DataWarehouse_State
 ,UpdateDate
 ,UpdateUser
 ,CreateDate
 ,CreateUser )
 VALUES (
  Source.Chris21_SourceKey
 ,Source.Chris21_SourceLevel
 ,Source.Chris21_SourceCode
 ,Source.Chris21_ProfitCentreCode
 ,Source.Chris21_ProfitCentreName
 ,Source.Chris21_BusinessDivisionCode
 ,Source.DataWarehouse_BusinessDivisionId
 ,Source.DataWarehouse_ProfitCentreId
 ,Source.DataWarehosue_ProfitCentreSourceKey
 ,Source.DataWarehouse_ProfitCentreCode
 ,Source.DataWarehouse_ProfitCentreName
 ,Source.DataWarehouse_ProfitCentreType
 ,Source.DataWarehouse_State
 ,NULL
 ,NULL
 ,CURRENT_TIMESTAMP
 ,SYSTEM_USER)
 
WHEN MATCHED AND
  ISNULL(Source.Chris21_SourceKey,'') != ISNULL(Destination.Chris21_SourceKey,'')
  OR ISNULL(Source.Chris21_SourceLevel,'') != ISNULL(Destination.Chris21_SourceLevel,'')
  OR ISNULL(Source.Chris21_SourceCode,'') != ISNULL(Destination.Chris21_SourceCode,'')
  OR ISNULL(Source.Chris21_ProfitCentreCode,'') != ISNULL(Destination.Chris21_ProfitCentreCode,'')
  OR ISNULL(Source.Chris21_BusinessDivisionCode,'') != ISNULL(Destination.Chris21_BusinessDivisionCode,'')
  OR ISNULL(Source.DataWarehouse_ProfitCentreId,'') != ISNULL(Destination.DataWarehouse_ProfitCentreId,'')
  OR ISNULL(Source.DataWarehosue_ProfitCentreSourceKey,'') != ISNULL(Destination.DataWarehosue_ProfitCentreSourceKey,'')
  OR ISNULL(Source.DataWarehouse_ProfitCentreCode,'') != ISNULL(Destination.DataWarehouse_ProfitCentreCode,'')
  OR ISNULL(Source.DataWarehouse_ProfitCentreName,'') != ISNULL(Destination.DataWarehouse_ProfitCentreName,'')
  OR ISNULL(Source.DataWarehouse_ProfitCentreType,'') != ISNULL(Destination.DataWarehouse_ProfitCentreType,'')
  OR ISNULL(Source.DataWarehouse_State,'') != ISNULL(Destination.DataWarehouse_State,'')

  THEN UPDATE 
  SET
  Destination.Chris21_SourceKey = Source.Chris21_SourceKey
 ,Destination.Chris21_SourceLevel = Source.Chris21_SourceLevel
 ,Destination.Chris21_SourceCode = Source.Chris21_SourceCode
 ,Destination.Chris21_ProfitCentreCode = Source.Chris21_ProfitCentreCode
 ,Destination.Chris21_ProfitCentreName = Source.Chris21_ProfitCentreName
 ,Destination.Chris21_BusinessDivisionCode = Source.Chris21_BusinessDivisionCode
 ,Destination.DataWarehouse_BusinessDivisionId = Source.DataWarehouse_BusinessDivisionId
 ,Destination.DataWarehouse_ProfitCentreId =Source.DataWarehouse_ProfitCentreId
 ,Destination.DataWarehosue_ProfitCentreSourceKey = Source.DataWarehosue_ProfitCentreSourceKey
 ,Destination.DataWarehouse_ProfitCentreCode = Source.DataWarehouse_ProfitCentreCode
 ,Destination.DataWarehouse_ProfitCentreName = Source.DataWarehouse_ProfitCentreName
 ,Destination.DataWarehouse_ProfitCentreType = Source.DataWarehouse_ProfitCentreType
 ,Destination.DataWarehouse_State = Source.DataWarehouse_State
 ,Destination.UpdateDate = CURRENT_TIMESTAMP
 ,Destination.UpdateUser = SYSTEM_USER
 ;
