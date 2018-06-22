select DimPerson.Code
,sum(SalesExcludingTaxForeign) SalesEx 
,sum(SalesIncludingTaxForeign) SalesInc
,count(distinct docketnumber) Trans
,SUM(CASE WHEN RetailLineTypeId = 1 THEN Quantity ELSE 0 END) UNITS
from factretailsales
inner join DimPerson on DimPerson.Id = FactRetailSales.RetailCustomerId
where retailcustomerid = 803118
and SaleDate between '21-May-2017' and '21-May-2018'
group by DimPerson.Code

select DimPerson.Code
,sum(SalesExcludingTaxForeign) SalesEx 
,sum(SalesIncludingTaxForeign) SalesInc
,count(distinct docketnumber) Trans
,SUM(CASE WHEN RetailLineTypeId = 1 THEN Quantity ELSE 0 END) UNITS
from factretailsales
inner join DimPerson on DimPerson.Id = FactRetailSales.RetailCustomerId
where retailcustomerid = 66210
and SaleDate between '21-May-2017' and '21-May-2018'
group by DimPerson.Code
