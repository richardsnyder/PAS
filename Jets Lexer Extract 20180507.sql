WITH RetailSales
AS (
 SELECT FactRetailSales.HeaderSourceKey
  ,FactRetailSales.TransactionNumber
  ,FactRetailSales.SaleDate
  ,FactRetailSales.RetailCustomerId
  ,FactRetailSales.WarehouseId
  ,FactRetailSales.ProductId
  ,MAX(CASE 
    WHEN RetailLineTypeId = 1
     THEN FactRetailSales.CurrentUnitPriceExcludingTaxForeign
    END) AS CurrentUnitPriceExcludingTaxForeign
  ,SUM(CASE 
    WHEN RetailLineTypeId = 1
     THEN FactRetailSales.Quantity
    END) AS Quantity
  ,SUM(CASE 
    WHEN RetailLineTypeId = 1
     THEN FactRetailSales.SalesExcludingTaxLocal
    END) AS SalesExcludingTaxLocal
  ,SUM(CASE 
    WHEN RetailLineTypeId = 2
     THEN FactRetailSales.SalesExcludingTaxLocal
    END) AS DiscountExcludingTaxLocal
  ,SUM(CASE 
    WHEN RetailLineTypeId = 3
     THEN FactRetailSales.SalesExcludingTaxLocal
    END) AS LoyaltyDiscountExcludingTaxLocal
  ,SUM(CASE 
    WHEN RetailLineTypeId = 4
     THEN FactRetailSales.SalesExcludingTaxLocal
    END) AS PriceOverrideExcludingTaxLocal
  ,SUM(CASE 
    WHEN RetailLineTypeId = 1
     THEN FactRetailSales.SalesExcludingTaxForeign
    END) AS SalesExcludingTaxForeign
  ,SUM(CASE 
    WHEN RetailLineTypeId = 2
     THEN FactRetailSales.SalesExcludingTaxForeign
    END) AS DiscountExcludingTaxForeign
  ,SUM(CASE 
    WHEN RetailLineTypeId = 3
     THEN FactRetailSales.SalesExcludingTaxForeign
    END) AS LoyaltyDiscountExcludingTaxForeign
  ,SUM(CASE 
    WHEN RetailLineTypeId = 4
     THEN FactRetailSales.SalesExcludingTaxForeign
    END) AS PriceOverrideExcludingTaxForeign
 FROM JetsDataWarehouse.dbo.FactRetailSales
 WHERE 1=1
   AND FactRetailSales.SaleDate BETWEEN '29-Jul-2015' AND '07-May-2018'
 --AND FactRetailSales.SaleDate = DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) --Yesterday
 GROUP BY FactRetailSales.HeaderSourceKey
  ,FactRetailSales.TransactionNumber
  ,FactRetailSales.SaleDate
  ,FactRetailSales.RetailCustomerId
  ,FactRetailSales.WarehouseId
  ,FactRetailSales.ProductId
 )
SELECT RetailSales.RetailCustomerId AS [customer_id]
 ,DimPerson.EmailAddress AS [email]
 ,DimPerson.MainPhoneNumber AS [mobile]
 ,DimPerson.FirstName AS [first_name]
 ,DimPerson.LastName AS [last_name]
 ,DimPerson.Gender AS [gender]
 ,CAST(FORMAT(DimPerson.DateOfBirth, 'dd/MM/yyyy') AS VARCHAR(20)) AS [dob]
 ,DimAddress.AddressLine1 AS [address_1]
 ,DimAddress.AddressLine2 AS [address_2]
 ,DimAddress.City AS [suburb]
 ,DimAddress.[State] AS [state]
 ,DimAddress.Postcode AS [postcode]
 ,DimAddress.Country AS [country]
 ,RetailSales.HeaderSourceKey AS order_id -- HeaderSourceKey is meaningless to users Not all Jets transactions have transaction number
 ,'' AS [business]
 ,'' [label]
 ,CAST(FORMAT(RetailSales.SaleDate, 'dd/MM/yyyy') AS VARCHAR(20)) AS [order_date]
 ,CASE 
  WHEN COALESCE(ABS(RetailSales.DiscountExcludingTaxLocal), 0) + COALESCE(ABS(RetailSales.LoyaltyDiscountExcludingTaxLocal), 0) + COALESCE(ABS(RetailSales.PriceOverrideExcludingTaxLocal), 0) > 0
   THEN 'TRUE'
  ELSE 'FALSE'
  END AS [discount_flag]
 ,CASE 
  WHEN RetailSales.Quantity < 0
   THEN 'Return'
  ELSE 'Purchase'
  END AS [transaction_type]
 ,MatProduct.StyleName AS [item_name]
 ,MatProduct.StyleColourSizeCode AS [sku]
 ,RetailSales.CurrentUnitPriceExcludingTaxForeign AS [Current_Unit_Price_Excluding_Tax]
 ,'Jets' AS [category_1]
 ,'Jets' AS [category_1A]
 ,MatProduct.CategoryCode [category_2]
 ,MatProduct.CategoryName [category_2A] 
 ,Matproduct.ProductTypeCode [category_3]
 ,Matproduct.ProductTypeName [category_3A]
 ,MatProduct.StoryCode [category_4]
 ,MatProduct.StoryName [category_4A]
 ,MatProduct.SizeCode AS [size]
 ,MatProduct.ColourName AS [colour]
 ,CASE 
  WHEN MapProfitCentre.ProfitCentreType = 'EC'
   THEN 'Online'
  WHEN MapProfitCentre.ProfitCentreType = 'RT'
   THEN 'Boutiques'
  WHEN MapProfitCentre.ProfitCentreType = 'CO'
   THEN 'Concession'
  WHEN MapProfitCentre.ProfitCentreType = 'OU'
   THEN 'Outlets'      
 END AS [channel]
 ,MapProfitCentre.PasProfitCentreCode AS [store_code]
 ,MatWarehouse.WarehouseName AS [store_name]
 ,CASE 
  WHEN DimPerson.SignupDate IS NOT NULL
   THEN 'TRUE'
  ELSE 'FALSE'
  END AS [loyalty_member_flag]
 ,'Jets' AS [loyalty_brand]
 ,NULL AS [loyanty_tier]
 ,CAST(FORMAT(DimPerson.SignupDate, 'dd/MM/yyyy') AS VARCHAR(20)) AS [loyalty_join_date]
 ,RetailSales.RetailCustomerId AS [loyalty_member_id] -- Or can be NULL
 ,NULL AS [nps_score]
 ,NULL AS [nps_date]
 ,NULL AS [loyalty_reward_balance]
 ,NULL AS [loyalty_reward_expiry]
FROM RetailSales
LEFT OUTER JOIN JetsDataWarehouse.dbo.DimPerson ON DimPerson.Id = RetailSales.RetailCustomerId
LEFT OUTER JOIN JetsDataWarehouse.dbo.DimAddress ON DimPerson.AddressId = DimAddress.Id
INNER JOIN JetsDataWarehouse.dbo.MatProduct ON MatProduct.ProductId = RetailSales.ProductId
INNER JOIN JetsDataWarehouse.dbo.MatWarehouse ON MatWarehouse.WarehouseId = RetailSales.WarehouseId
INNER JOIN JetsDataWarehouse.dbo.MapProfitCentre ON MapProfitCentre.JetsWarehouseId = MatWarehouse.WarehouseId
WHERE MatProduct.IsReported = 1
ORDER BY [order_date]