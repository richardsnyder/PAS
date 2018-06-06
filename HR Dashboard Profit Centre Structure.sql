SELECT mw.BusinessDivisionId
      ,mw.BusinessDivisionCode
      ,mw.BusinessDivisionName
      ,dpc.State
      ,mw.LocationTypeCode
      ,dpc.Id
      ,dpc.ProfitCentreType
      ,CASE
         WHEN dpc.ProfitCentreType = 'EC' THEN 'E-Commerce'
         WHEN dpc.ProfitCentreType = 'RT' THEN 'Boutique'
         WHEN dpc.ProfitCentreType = 'OU' THEN 'Outlet'
         WHEN dpc.ProfitCentreType = 'CO' THEN 'Concesison'
       END AS 'Channel'
      ,mw.ProfitCentreCode
      ,mw.ProfitCentreName
FROM MatWarehouse AS mw
     INNER JOIN DimProfitCentre AS dpc ON dpc.Id = mw.ProfitCentreId
WHERE mw.ProfitCentreCode < 5000
ORDER BY mw.BusinessDivisionId
        ,mw.ProfitCentreCode