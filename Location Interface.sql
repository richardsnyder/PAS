SELECT
  'TOTAL' AS TotalID,
  'Total' AS TotalDesc,
  CAST(BusinessDivisionTranslation.ToCode AS VARCHAR(50)) AS Level2ID,
  CAST(BusinessDivisionTranslation.ToCode + ' - ' + BusinessDivisionTranslation.toName AS VARCHAR(255)) AS Level2Desc,
  CAST(BusinessDivisionTranslation.ToCode +'.R' AS VARCHAR(50)) AS Level3ID, --default to Retail, in case they ever want to add wholesale to this.
  CAST(BusinessDivisionTranslation.ToCode +'.R' + ' - ' + 'Retail' AS VARCHAR(255)) AS Level3Desc,
  CAST(BusinessDivisionTranslation.ToCode +'.R.' + COALESCE(CostingZoneTranslation.ToCode, MatWarehouse.CostingZoneCode) AS VARCHAR(50)) AS Level4ID,
  CAST(BusinessDivisionTranslation.ToCode +'.R.' + COALESCE(CostingZoneTranslation.ToCode, MatWarehouse.CostingZoneCode) + ' - ' + COALESCE(CostingZoneTranslation.ToName, MatWarehouse.CostingZoneName) AS VARCHAR(255)) AS Level4Desc,
  CAST(BusinessDivisionTranslation.ToCode +'.R.' + COALESCE(CostingZoneTranslation.ToCode, MatWarehouse.CostingZoneCode) + '.' + SubLocationGroup.ToCode AS VARCHAR(50)) AS Level5ID, 
  CAST(BusinessDivisionTranslation.ToCode +'.R.' + COALESCE(CostingZoneTranslation.ToCode, MatWarehouse.CostingZoneCode) + '.' + SubLocationGroup.ToCode + ' - ' + SubLocationGroup.ToName AS VARCHAR(255)) AS Level5Desc,
  CAST(BusinessDivisionTranslation.ToCode +'.R.' + COALESCE(CostingZoneTranslation.ToCode, MatWarehouse.CostingZoneCode) + '.' + SubLocationGroup.ToCode + '.' + COALESCE(SubLocation.ToCode, MatWarehouse.LocationTypeCode) AS VARCHAR(50)) AS Level6ID,
  CAST(BusinessDivisionTranslation.ToCode +'.R.' + COALESCE(CostingZoneTranslation.ToCode, MatWarehouse.CostingZoneCode) + '.' + SubLocationGroup.ToCode + '.' + COALESCE(SubLocation.ToCode, MatWarehouse.LocationTypeCode) + ' - ' + COALESCE(SubLocation.ToName, MatWarehouse.LocationTypeName) AS VARCHAR(255)) AS Level6Desc,
  CAST(LEFT(MatWarehouse.WarehouseCode, 50) AS VARCHAR(50)) AS locationID,
  CAST(MatWarehouse.WarehouseCode + ' - ' + MatWarehouse.WarehouseName AS VARCHAR(255)) AS LocationDesc,
  DimProfitCentre.AreaInSquareMeters AS SQM,
  CAST(MatWarehouse.TerritoryName AS VARCHAR(50)) AS DimAtt1, --Territory
  CAST(MatWarehouse.RegionName AS VARCHAR(50)) AS DimAtt2, --Region
  CAST(MatWarehouse.ClimateName AS VARCHAR(50)) AS DimAtt3 --Climate
FROM
  dbo.MatWarehouse
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS BusinessDivisionTranslation ON
  BusinessDivisionTranslation.FromValue = MatWarehouse.BusinessDivisionCode
  AND BusinessDivisionTranslation.FromColumn = 'BusDiv'
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS CostingZoneTranslation ON
  CostingZoneTranslation.FromValue = MatWarehouse.CostingZoneCode
  AND CostingZoneTranslation.FromColumn = 'ZoneCode'
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS SubLocationGroup ON
  SubLocationGroup.FromValue = MatWarehouse.LocationTypeCode
  AND SubLocationGroup.FromColumn = 'SubLocGrpCode'
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS SubLocation ON
  SubLocation.FromValue = MatWarehouse.LocationTypeCode
  AND SubLocation.FromColumn = 'SubLocationCode'
INNER JOIN
  dbo.DimProfitCentre ON
  DimProfitCentre.Id = MatWarehouse.ProfitCentreId
WHERE
  MatWarehouse.BusinessDivisionCode IN ('18','25','26','31')
  AND MatWarehouse.IsPlanningWarehouse = 1
  
UNION ALL

SELECT 'TOTAL' AS TotalID
  , 'Total' AS TotalDesc
  , 'DW' AS Level2ID 
  , 'Designworks' AS Level2Desc 
  , 'DesignworksLevel3' AS Level3ID 
  , 'Designworks Level 3' AS Level3Desc 
  , 'DesignworksLevel4' AS Level4ID 
  , 'Designworks Level 4' AS Level4Desc 
  , 'Wholesale' AS Level5ID 
  , 'Wholesale' AS Level5Desc 
  , 'AU' AS Level6ID 
  , 'Australia' AS Level6Desc 
  , 'RebelAU' AS locationID
  , 'Rebel AU' AS LocationDesc 
  , NULL AS SQM
  , NULL AS DimAtt1 --Territory
  , NULL AS DimAtt2 --Region
  , NULL AS DimAtt3 --Climate  
UNION ALL
SELECT 'TOTAL' AS TotalID 
  , 'Total' AS TotalDesc
  , 'DW' AS Level2ID 
  , 'Designworks' AS Level2Desc 
  , 'DesignworksLevel3' AS Level3ID 
  , 'Designworks Level 3' AS Level3Desc 
  , 'DesignworksLevel4' AS Level4ID 
  , 'Designworks Level 4' AS Level4Desc 
  , 'Wholesale' AS Level5ID 
  , 'Wholesale' AS Level5Desc 
  , 'NZ' AS Level6ID 
  , 'New Zealand' AS Level6Desc 
  , 'RebelNZ' AS locationID
  , 'Rebel NZ' AS LocationDesc 
  , NULL AS SQM
  , NULL AS DimAtt1 --Territory
  , NULL AS DimAtt2 --Region
  , NULL AS DimAtt3 --Climate   
UNION ALL  
SELECT 'TOTAL' AS TotalID 
  , 'Total' AS TotalDesc
  , 'DW' AS Level2ID 
  , 'Designworks' AS Level2Desc 
  , 'DesignworksLevel3' AS Level3ID 
  , 'Designworks Level 3' AS Level3Desc 
  , 'DesignworksLevel4' AS Level4ID 
  , 'Designworks Level 4' AS Level4Desc 
  , 'Wholesale' AS Level5ID 
  , 'Wholesale' AS Level5Desc 
  , 'AU' AS Level6ID 
  , 'Australia' AS Level6Desc 
  , 'IndependentAU' AS locationID
  , 'Independent AU' AS LocationDesc 
  , NULL AS SQM
  , NULL AS DimAtt1 --Territory
  , NULL AS DimAtt2 --Region
  , NULL AS DimAtt3 --Climate  
UNION ALL
SELECT 'TOTAL' AS TotalID 
  , 'Total' AS TotalDesc
  , 'DW' AS Level2ID 
  , 'Designworks' AS Level2Desc 
  , 'DesignworksLevel3' AS Level3ID 
  , 'Designworks Level 3' AS Level3Desc 
  , 'DesignworksLevel4' AS Level4ID 
  , 'Designworks Level 4' AS Level4Desc 
  , 'Wholesale' AS Level5ID 
  , 'Wholesale' AS Level5Desc 
  , 'NZ' AS Level6ID 
  , 'New Zealand' AS Level6Desc 
  , 'IndependentNZ' AS locationID
  , 'Independent NZ' AS LocationDesc

  , NULL AS SQM
  , NULL AS DimAtt1 --Territory
  , NULL AS DimAtt2 --Region
  , NULL AS DimAtt3 --Climate      
UNION ALL  
SELECT 'TOTAL' AS TotalID 
  , 'Total' AS TotalDesc
  , 'DW' AS Level2ID 
  , 'Designworks' AS Level2Desc  
  , 'DesignworksLevel3' AS Level3ID 
  , 'Designworks Level 3' AS Level3Desc 
  , 'DesignworksLevel4' AS Level4ID 
  , 'Designworks Level 4' AS Level4Desc 
  , 'Wholesale' AS Level5ID  
  , 'Wholesale' AS Level5Desc 
  , 'AU' AS Level6ID 
  , 'Australia' AS Level6Desc 
  , 'OnlineAU' AS locationID
  , 'Online AU' AS LocationDesc   
  , NULL AS SQM
  , NULL AS DimAtt1 --Territory
  , NULL AS DimAtt2 --Region
  , NULL AS DimAtt3 --Climate  
UNION ALL
SELECT 'TOTAL' AS TotalID
  , 'Total' AS TotalDesc 
  , 'DW' AS Level2ID 
  , 'Designworks' AS Level2Desc  
  , 'DesignworksLevel3' AS Level3ID 
  , 'Designworks Level 3' AS Level3Desc 
  , 'DesignworksLevel4' AS Level4ID 
  , 'Designworks Level 4' AS Level4Desc 
  , 'Wholesale' AS Level5ID 
  , 'Wholesale' AS Level5Desc 
  , 'NZ' AS Level6ID 
  , 'New Zealand' AS Level6Desc 
  , 'OnlineNZ' AS locationID
  , 'Online NZ' AS LocationDesc  
  , NULL AS SQM
  , NULL AS DimAtt1 --Territory
  , NULL AS DimAtt2 --Region
  , NULL AS DimAtt3 --Climate