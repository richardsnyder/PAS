SELECT
  MatProduct.StyleColourCode AS StyleColourID
  ,CAST('TOTAL' AS NVARCHAR(50)) AS LocationID
  ,CAST(CAST(DimDate.RetailYear AS NVARCHAR(4)) + CAST(FORMAT(DimDate.RetailWeek,'00') AS NVARCHAR(4)) AS NVARCHAR(50)) AS TimeID
  ,CAST(MatProduct.StyleSeasonCode AS NVARCHAR(50)) AS SeasonID  

  ,FactMerchandisePlanAdditionsToStock.ReceiptRetailValueForeign AS Receipts_D
  ,FactMerchandisePlanAdditionsToStock.ReceiptCostValueForeign AS Receipts_Cost_D
  ,FactMerchandisePlanAdditionsToStock.ReceiptQuantity AS Receipts_U

  ,FactMerchandisePlanAdditionsToStock.AdjustmentRetailValueForeign AS Adjustments_D
  ,FactMerchandisePlanAdditionsToStock.AdjustmentCostValueForeign AS Adjustments_Cost_D
  ,FactMerchandisePlanAdditionsToStock.AdjustmentQuantity AS Adjustments_U

FROM
  dbo.FactMerchandisePlanAdditionsToStock
INNER JOIN
  dbo.DimDate ON
  DimDate.CalendarDate = FactMerchandisePlanAdditionsToStock.MerchandiseDate
INNER JOIN
  dbo.DimDate CurrentDate ON
  CurrentDate.CalendarDate = CAST(GETDATE() AS DATE)
INNER JOIN
  dbo.MatProduct ON
  MatProduct.ProductId = FactMerchandisePlanAdditionsToStock.ProductId
INNER JOIN
  dbo.MatWarehouse ON
  MatWarehouse.WarehouseId = FactMerchandisePlanAdditionsToStock.WarehouseId
WHERE
  MatWarehouse.BusinessDivisionCode = 16
--  AND MatProduct.PatternMakerId = 17 -- DWPlanned
  AND MatProduct.ComponentGroupCode = 'FG'
  AND MatProduct.IsActive = 1
  AND MatProduct.TunId IS NULL
  AND MatProduct.ColourId != 1
  AND DimDate.RetailWeekId >= CurrentDate.RetailWeekId -CAST(dbo.GetConfiguration('MapleLakeWeeksToActualise') AS INT)
  AND DimDate.RetailWeekId <= CurrentDate.RetailWeekId