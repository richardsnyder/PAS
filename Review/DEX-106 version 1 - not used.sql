DROP TABLE #concession

SELECT RetailCustomerId
, RetailCustomers.[Person Id]
, RetailCustomers.[First Name]
, RetailCustomers.[Last Name]
,RetailCustomers.[Email Address]
, COUNT(*) NumberOFShops
INTO #Concession
FROM FactRetailSales
LEFT JOIN DimPerson
ON DimPerson.Id = FactRetailSales.RetailCustomerId
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
ON RetailCustomers.[Person Id] = DimPerson.Id
INNER JOIN MatWarehouse
ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId
INNER JOIN DimDate 
ON DimDate.CalendarDate = FactRetailSales.SaleDate
WHERE DimPerson.Id IS NOT NULL
AND DimPerson.Code != 'RE_GUEST'
AND  MatWarehouse.LocationTypeCode ='RECONCESSIONMY'
--AND MatWarehouse.LocationTypeCode NOT IN ('RECONCESSIONDJ','REOFFICE','REOUTLET','RESTANDALONE','REWH')
--AND MatWarehouse.WarehouseCode NOT IN ('REEDUMMSG','REEECOMMSTORE','REEEDJDR','REEICONIC','REETMALL')
AND MatWarehouse.BusinessDivisionCode = 18
AND DimDate.RetailYear IN (2018)
AND RetailCustomers.[Privacy Requested] = 'N'
AND RetailCustomers.[Email Address] IS NOT NULL
GROUP BY RetailCustomerId
, RetailCustomers.[Person Id]
,RetailCustomers.[Email Address]
, RetailCustomers.[First Name]
, RetailCustomers.[Last Name]
ORDER BY 1

DROP TABLE #Customers

SELECT * FROM #Concession

SELECT FactRetailSales.RetailCustomerId
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'RECONCESSIONDJ' THEN 'DJ' ELSE NULL END) AS DJConcession
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'RECONCESSIONMY' THEN 'Myer'  ELSE NULL  END) AS MyerConcession
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'REECOMM' THEN 'ecomm'  ELSE NULL  END) AS Ecomm
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'REOFFICE' THEN 'office' ELSE NULL  END) AS Office
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'REOUTLET' THEN 'outlet' ELSE NULL  END) AS Outlet
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'RESTANDALONE' OR MatWarehouse.LocationTypeCode = 'RZSTANDALONE' THEN 'Boutique'  ELSE NULL  END) Boutique
, MAX(CASE WHEN MatWarehouse.LocationTypeCode = 'REWH' THEN 'Warehouse'  ELSE NULL  END) Warehouse
INTO #Customers
FROM FactRetailSales
INNER JOIN #Concession Concession
ON Concession.RetailCustomerId = FactRetailSales.RetailCustomerId
INNER JOIN dimdate 
ON dimdate.CalendarDate = FactRetailSales.SaleDate
INNER JOIN MatWarehouse
ON matwarehouse.WarehouseId = FactRetailSales.WarehouseId
WHERE dimdate.RetailYear = 2018
GROUP BY FactRetailSales.RetailCustomerId

DROP TABLE #Myer

SELECT DISTINCT * 
INTO #Myer
FROM #Customers
WHERE (DJConcession IS NULL
AND Ecomm IS NULL
AND office IS NULL
AND outlet IS NULL
AND Boutique IS NULL
AND Warehouse IS NULL)
AND MyerConcession IS NOT NULL
ORDER BY 1

SELECT DISTINCT retailCustomerId
,RetailCustomers.[Email Address] Email
,RetailCustomers.[First Name] FirstName
,RetailCustomers.[Last Name] LastName
INTO PlayPen.dbo.MyerExtract
FROM #Myer Myer
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
ON RetailCustomers.[Person Id] = Myer.RetailCustomerId
WHERE RetailCustomers.[Email Address] IS NOT NULL
AND retailCustomers.[Privacy Requested] = 'N'

SELECT * FROM #Customers WHERE RetailCustomerId = 1254437

SELECT DISTINCT retailcustomerid, saledate, warehousename,LocationTypeCode RetailCustomerId FROM FactRetailSales
INNER JOIN dimdate ON dimdate.CalendarDate = FactRetailSales.SaleDate
INNER JOIN MatWarehouse ON MatWarehouse.WarehouseId = factretailsales.WarehouseId
WHERE dimdate.RetailYear = 2018
AND RetailCustomerId = 21 -- IN (SELECT DISTINCT RetailCustomerId FROM #Myer)
ORDER BY 4

-- REEEMYERDR Myer Dropship
-- RECONCESSIONMY Myer Concession

/* NOT LocationType
RECONCESSIONDJ
REOFFICE
REOUTLET
RESTANDALONE
REWH

NOT WarehouseCodes
REEDUMMSG
REEECOMMSTORE
REEEDJDR
REEICONIC
REETMALL
*/

SELECT DISTINCT locationtypecode FROM MatWarehouse WHERE BusinessDivisionCode = 18