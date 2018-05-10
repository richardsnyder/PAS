select profitcentrecode
, WarehouseName
, LocationTypeName
from MatWarehouse
where businessdivisioncode <> 19
and ProfitCentreCode < 5000