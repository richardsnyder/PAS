DECLARE @StagedData TABLE (
  Chris21_SourceLevel VARCHAR(1)
 ,Chris21_SourceCode VARCHAR(10)
 ,Chris21_Code VARCHAR(20)
 ,Chris21_Description VARCHAR(30)
 ,Chris21_CompanySourceCode VARCHAR(10)
 ,DataWarehouse_BusinessDivisionId INT
 ,DataWarehouse_SourceKey INT
 ,DataWarehouse_Code VARCHAR(15)
 ,DataWarehouse_Name VARCHAR(40)
 ,DataWarehouse_ABN VARCHAR(35)
 ,DataWarehouse_ACN VARCHAR(35)
 ,DataWarehouse_Logo VARBINARY(MAX)
)

INSERT INTO @StagedData (
  Chris21_SourceLevel
 ,Chris21_SourceCode
 ,Chris21_Code
 ,Chris21_Description
 ,Chris21_CompanySourceCode
 ,DataWarehouse_BusinessDivisionId
 ,DataWarehouse_SourceKey
 ,DataWarehouse_Code
 ,DataWarehouse_Name
 ,DataWarehouse_ABN
 ,DataWarehouse_ACN
 ,DataWarehouse_Logo
)

SELECT DISTINCT
  divorg.SYSOR_CODE Chris21_SourceLevel
 ,divorg.GNA_ORG_CODE Chris21_SourceCode
 ,divorg.GNA_ACCOUNT Chris21_Code
 ,divorg.GNA_ORG_NAME Chris21_Description
 ,pos.POS_L1_CD Chris21_CompanySourceCode
 ,Staging_DimBusinessDivision.Id AS DataWarehouse_BusinessDivisionId
 ,Staging_DimBusinessDivision.SourceKey AS DataWarehouse_SourceKey
 ,Staging_DimBusinessDivision.Code AS DataWarehouse_Code
 ,Staging_DimBusinessDivision.Name AS DataWarehouse_Name
 ,Staging_DimBusinessDivision.ABN AS DataWarehouse_ABN
 ,Staging_DimBusinessDivision.ACN AS DataWarehouse_ACN
 ,Staging_DimBusinessDivision.Logo AS DataWarehouse_Logo
FROM DataWarehouseChris21RawData.dbo.Staging_EMPOS pos
LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_ORGNA divorg
  ON pos.POS_L2_CD = divorg.GNA_ORG_CODE
    AND divorg.SYSOR_CODE = 2
LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_DimBusinessDivision
ON Staging_DimBusinessDivision.Code = divorg.GNA_ACCOUNT
WHERE NULLIF(pos.POS_END, '0001-01-02') IS NULL
ORDER BY divorg.GNA_ACCOUNT

MERGE dbo.DimBusinessDivision AS Destination
USING @StagedData AS Source ON
  Source.Chris21_Code = Destination.Chris21_Code
  AND source.Chris21_SourceLevel = Destination.Chris21_SourceLevel
  AND Source.Chris21_SourceCode = Destination.Chris21_SourceCode

  WHEN NOT MATCHED BY TARGET
  THEN INSERT(Chris21_SourceLevel
           ,Chris21_SourceCode
           ,Chris21_Code
           ,Chris21_Description
           ,Chris21_CompanySourceCode
           ,DataWarehouse_BusinessDivisionId
           ,DataWarehouse_SourceKey
           ,DataWarehouse_Code
           ,DataWarehouse_Name
           ,DataWarehouse_ABN
           ,DataWarehouse_ACN
           ,DataWarehouse_Logo
           ,UpdateDate
           ,UpdateUser
           ,CreateDate
           ,CreateUser)
     VALUES
           (Source.Chris21_SourceLevel
           ,Source.Chris21_SourceCode
           ,Source.Chris21_Code
           ,Source.Chris21_Description
           ,Source.Chris21_CompanySourceCode
           ,Source.DataWarehouse_BusinessDivisionId
           ,Source.DataWarehouse_SourceKey
           ,Source.DataWarehouse_Code
           ,Source.DataWarehouse_Name
           ,Source.DataWarehouse_ABN
           ,Source.DataWarehouse_ACN
           ,Source.DataWarehouse_Logo
           ,NULL
           ,NULL
           ,CURRENT_TIMESTAMP
           ,SYSTEM_USER)

WHEN MATCHED AND 
  ISNULL(Source.Chris21_SourceLevel,'') != ISNULL(Destination.Chris21_SourceLevel,'')
  OR ISNULL(Source.Chris21_SourceCode,'') != ISNULL(Destination.Chris21_SourceCode,'')
  OR ISNULL(Source.Chris21_Code,'') != ISNULL(Destination.Chris21_Code,'')
  OR ISNULL(Source.Chris21_Description,'') != ISNULL(Destination.Chris21_Description,'')
  OR ISNULL(Source.Chris21_CompanySourceCode,'') != ISNULL(Destination.Chris21_CompanySourceCode,'')

THEN UPDATE
SET Destination.Chris21_SourceLevel = Source.Chris21_SourceLevel
           ,Destination.Chris21_SourceCode =Source.Chris21_SourceCode
           ,Destination.Chris21_Code =Source.Chris21_Code
           ,Destination.Chris21_Description = Source.Chris21_Description
           ,Destination.Chris21_CompanySourceCode = Source.Chris21_CompanySourceCode
           ,Destination.DataWarehouse_BusinessDivisionId = Source.DataWarehouse_BusinessDivisionId
           ,Destination.DataWarehouse_SourceKey =Source.DataWarehouse_SourceKey
           ,Destination.DataWarehouse_Code = Source.DataWarehouse_Code
           ,Destination.DataWarehouse_Name = Source.DataWarehouse_Name
           ,Destination.DataWarehouse_ABN = Source.DataWarehouse_ABN
           ,Destination.DataWarehouse_ACN =Source.DataWarehouse_ACN
           ,Destination.DataWarehouse_Logo = Source.DataWarehouse_Logo
           ,Destination.UpdateDate = CURRENT_TIMESTAMP
           ,Destination.UpdateUser = SYSTEM_USER
;

