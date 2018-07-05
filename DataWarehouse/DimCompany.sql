DECLARE @StagedData TABLE (
  Chris21_SourceLevel VARCHAR(1)
 ,Chris21_SourceCode VARCHAR(10)
 ,Chris21_Code VARCHAR(20)
 ,Chris21_Name VARCHAR(30)
 ,DataWarehouseCompany_Id INT
 ,DataWarehouseCompany_SourceKey INT
 ,DataWarehouseCompany_Code VARCHAR(15)
 ,DataWarehouseCompany_Name VARCHAR(40)
 ,DataWarehouseCompany_IsActive BIT
)
INSERT INTO @StagedData (Chris21_SourceLevel
, Chris21_SourceCode
, Chris21_Code
, Chris21_Name
, DataWarehouseCompany_Id
, DataWarehouseCompany_SourceKey
, DataWarehouseCompany_Code
, DataWarehouseCompany_Name
, DataWarehouseCompany_IsActive)
  /* Company */
  SELECT DISTINCT
    coorg.SYSOR_CODE Chris21_SourceLevel
   ,coorg.GNA_ORG_CODE Chris21_SourceCode
   ,coorg.GNA_ACCOUNT Chris21_Code
   ,coorg.GNA_ORG_NAME Chris21_Name
   ,Staging_DimLegalEntity.Id DataWarehouseCompany_Id
   ,Staging_DimLegalEntity.SourceKey DataWarehouseCompany_SourceKey
   ,Staging_DimLegalEntity.Code DataWarehouseCompany_Code
   ,Staging_DimLegalEntity.Name DataWarehouseCompany_Name
   ,Staging_DimLegalEntity.IsActive DataWarehouseCompany_IsActive
  FROM DataWarehouseChris21RawData.dbo.Staging_EMPOS pos
  LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_ORGNA coorg
    ON pos.POS_L1_CD = coorg.GNA_ORG_CODE
      AND coorg.SYSOR_CODE = 1
  LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_DimLegalEntity
    ON Staging_DimLegalEntity.Code = coorg.GNA_ACCOUNT
  WHERE NULLIF(pos.POS_END, '0001-01-02') IS NULL
  ORDER BY coorg.GNA_ACCOUNT

MERGE DimCompany AS Destination USING @StagedData AS Source
ON Source.Chris21_Code = Destination.Chris21_Code
  AND Source.DataWarehouseCompany_Id = Destination.DataWarehouseCompany_Id

WHEN NOT MATCHED BY TARGET
  THEN INSERT (Chris21_SourceLevel
    , Chris21_SourceCode
    , Chris21_Code
    , Chris21_Name
    , DataWarehouseCompany_Id
    , DataWarehouseCompany_SourceKey
    , DataWarehouseCompany_Code
    , DataWarehouseCompany_Name
    , DataWarehouseCompany_IsActive
    , UpdateDate
    , UpdateUser
    , CreateDate
    , CreateUser)
      VALUES (Source.Chris21_SourceLevel
      , Source.Chris21_SourceCode
      , Source.Chris21_Code
      , Source.Chris21_Name
      , Source.DataWarehouseCompany_Id
      , Source.DataWarehouseCompany_SourceKey
      , Source.DataWarehouseCompany_Code
      , Source.DataWarehouseCompany_Name
      , Source.DataWarehouseCompany_IsActive
      , NULL
      , NULL
      , CURRENT_TIMESTAMP
      , system_user)

WHEN MATCHED
  AND ISNULL(Source.Chris21_SourceLevel, '') != ISNULL(Destination.Chris21_SourceLevel, '')
  OR ISNULL(Source.Chris21_SourceCode, '') != ISNULL(Destination.Chris21_SourceCode, '')
  OR ISNULL(Source.Chris21_Code, '') != ISNULL(Destination.Chris21_Code, '')
  OR ISNULL(Source.Chris21_Name, '') != ISNULL(Destination.Chris21_Name, '')
  OR ISNULL(Source.DataWarehouseCompany_Id, '') != ISNULL(Destination.DataWarehouseCompany_Id, '')
  OR ISNULL(Source.DataWarehouseCompany_SourceKey, '') != ISNULL(Destination.DataWarehouseCompany_SourceKey, '')
  OR ISNULL(Source.DataWarehouseCompany_Code, '') != ISNULL(Destination.DataWarehouseCompany_Code, '')
  OR ISNULL(Source.DataWarehouseCompany_Name, '') != ISNULL(Destination.DataWarehouseCompany_Name, '')
  OR ISNULL(Source.DataWarehouseCompany_IsActive, '') != ISNULL(Destination.DataWarehouseCompany_IsActive, '')

  THEN UPDATE
    SET Destination.Chris21_SourceLevel = Source.Chris21_SourceLevel 
       ,Destination.Chris21_SourceCode = Source.Chris21_SourceCode
       ,Destination.Chris21_Code = Source.Chris21_Code
       ,Destination.Chris21_Name = Source.Chris21_Name
       ,Destination.DataWarehouseCompany_Id = Source.DataWarehouseCompany_Id
       ,Destination.DataWarehouseCompany_SourceKey = Source.DataWarehouseCompany_SourceKey
       ,Destination.DataWarehouseCompany_Code = Source.DataWarehouseCompany_Code
       ,Destination.DataWarehouseCompany_Name = Source.DataWarehouseCompany_Name
       ,Destination.DataWarehouseCompany_IsActive = Source.DataWarehouseCompany_IsActive
       ,Destination.UpdateDate = current_timestamp
       ,Destination.UpdateUser = system_user
;