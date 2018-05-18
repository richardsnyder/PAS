select count(distinct  retailcustomerid)
from factretailsales
inner join DimPerson
on DimPerson.Id = FactRetailSales.RetailCustomerId
where 1=1
and DimPerson.BusinessDivisionId in (10,22)
and FactRetailSales.SaleDate between '26-Jun-2015' and '07-May-2018'