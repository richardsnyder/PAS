TRUNCATE TABLE DimAreaManager

INSERT INTO dbo.DimAreaManager
           (Chris21ProfitCentre
           ,AreaManager
           ,AreaManagerName
           ,PositionNumber)

SELECT DISTINCT pos_l5_cd Chris21ProfitCentre
, POS_INDUSTRY AreaManager
,Staging_UpZam.ZAM_NAME
,Staging_UpZam.ZAM_POSOTION
FROM FactPosition
INNER JOIN DataWarehouseChris21RawData.dbo.Staging_UPZAM Staging_UpZam
ON Staging_UpZam.ZAM_NUMBER = FactPosition.POS_INDUSTRY
WHERE POS_INDUSTRY <> ''
ORDER BY 1