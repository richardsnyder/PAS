TRUNCATE TABLE dbo.DimAreaManager

INSERT INTO DimAreaManager (RegionalManagerId, RegionalManagerCode, RegionalManagerName, AreaManagerId, AreaManagerCode, AreaManagerName, RegionalManagerIsActive, AreaManagerIsActive)

SELECT DimRegionalManager.Id RegionalManagerId
,DimRegionalManager.Code AS RegionalManagerCode
,DimRegionalManager.Name AS RegionalManagerName
,DimAreaManager.Id AreaManagerId
,DimAreaManager.Code AS AreaManagerCode
,DimAreaManager.Name AS AreaManagerName
,DimRegionalManager.IsActive RegionalManagerIsActive
,DimAreaManager.IsActive AreaManagerIsActive
FROM DataWarehouseChris21RawData.dbo.Staging_DimAreaManager DimAreaManager
LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_DimRegionalManager DimRegionalManager
ON DimRegionalManager.Id = DimAreaManager.RegionalManagerId
WHERE 1=1
AND DimAreaManager.IsActive = 1
ORDER BY DimRegionalManager.Id, DimAreaManager.Id