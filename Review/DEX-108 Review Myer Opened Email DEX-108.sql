SELECT FactRetailSales.RetailCustomerId FactRetailSalesCustomerId
,RetailCustomers.[Person Id] LoyaltyPersonId
, opened.CUSTOMER_ID_ ResponsysCustomerId
, DimPerson.SourceKey AP21CustomerId
, opened.EMAIL_ADDRESS_ ResponsysEmailAddress
, RetailCustomers.[Email Address] LoyaltyPersonEmailAddress
, MatWarehouse.LocationTypeCode 
, MatWarehouse.WarehouseName
, FactRetailSales.SaleDate
, SUM(SalesIncludingTaxForeign) SalesInc
FROM FactRetailSales
INNER JOIN MatWarehouse
ON FactRetailSales.WarehouseId = MatWarehouse.WarehouseId
INNER JOIN DimPerson 
ON FactRetailSales.RetailCustomerId = DimPerson.Id
INNER JOIN PlayPen.dbo.re_opened_myer opened
ON DimPerson.SourceKey = opened.CUSTOMER_ID_
INNER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
ON RetailCustomers.[Person Id] = DimPerson.Id
WHERE FactRetailSales.SaleDate BETWEEN '06-Jul-2018' AND '08-Jul-2018'
GROUP BY
FactRetailSales.RetailCustomerId
,RetailCustomers.[Person Id]
, opened.CUSTOMER_ID_
, DimPerson.SourceKey
, opened.EMAIL_ADDRESS_
, RetailCustomers.[Email Address]
, MatWarehouse.LocationTypeCode
, MatWarehouse.WarehouseName
, FactRetailSales.SaleDate

UNION ALL
SELECT FactRetailSales.RetailCustomerId FactRetailSalesCustomerId
,RetailCustomers.[Person Id] LoyaltyPersonId
, opened.CUSTOMER_ID_ ResponsysCustomerId
, DimPerson.SourceKey AP21CustomerId
, opened.EMAIL_ADDRESS_ ResponsysEmailAddress
, RetailCustomers.[Email Address] LoyaltyPersonEmailAddress
, MatWarehouse.LocationTypeCode 
, MatWarehouse.WarehouseName
, FactRetailSales.SaleDate
, SUM(SalesIncludingTaxForeign) SalesInc
FROM FactRetailSales 
INNER JOIN MatWarehouse 
ON MatWarehouse.WarehouseId = FactRetailSales.WarehouseId
LEFT OUTER JOIN DimPerson 
ON DimPerson.Id = FactRetailSales.RetailCustomerId
LEFT OUTER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers
ON RetailCustomers.[Person Id] = FactRetailSales.RetailCustomerId
LEFT OUTER JOIN PlayPen.dbo.re_opened_myer opened
ON opened.EMAIL_ADDRESS_ = DimPerson.EmailAddress
WHERE factRetailSales.SaleDate BETWEEN '06-Jul-2018' AND '08-Jul-2018'
AND FactRetailSales.RetailCustomerId IN (
SELECT ID FROM DimPerson dp
WHERE dp.EmailAddress IN (SELECT EMAIL_ADDRESS_ FROM [PlayPen].[dbo].[re_opened_myer] WHERE EMAIL_ADDRESS_ = dp.EmailAddress AND CUSTOMER_ID_ = ''))
GROUP BY 
FactRetailSales.RetailCustomerId
,RetailCustomers.[Person Id]
, opened.CUSTOMER_ID_
, DimPerson.SourceKey
, opened.EMAIL_ADDRESS_
, RetailCustomers.[Email Address]
, MatWarehouse.LocationTypeCode
, MatWarehouse.WarehouseName
, FactRetailSales.SaleDate

ORDER BY SaleDate
,LocationTypeCode
, [Email Address]