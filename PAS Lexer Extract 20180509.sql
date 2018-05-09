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
    ,FactRetailSales.WarehouseDispatchTypeId
  FROM FactRetailSales
  WHERE 1 = 1
AND FactRetailSales.SaleDate = DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) --Yesterday
  GROUP BY FactRetailSales.HeaderSourceKey
    ,FactRetailSales.TransactionNumber
    ,FactRetailSales.SaleDate
    ,FactRetailSales.RetailCustomerId
    ,FactRetailSales.WarehouseId
    ,FactRetailSales.ProductId
    ,FactRetailSales.WarehouseDispatchTypeId
  )
SELECT RetailSales.RetailCustomerId AS [customer_id]
  ,RetailCustomers.[Email Address] AS [email]
  ,RetailCustomers.[Mobile Phone Number] AS [mobile]
  ,RetailCustomers.[First Name] AS [first_name]
  ,RetailCustomers.[Last Name] AS [last_name]
  ,RetailCustomers.Gender AS [gender]
  ,CAST(FORMAT(RetailCustomers.[Date of Birth], 'dd/MM/yyyy') AS VARCHAR(20)) AS [dob]
  ,RetailCustomers.[Address Line 1] AS [address_1]
  ,RetailCustomers.[Address Line 2] AS [address_2]
  ,RetailCustomers.[Address City] AS [suburb]
  ,RetailCustomers.[Address State] AS [state]
  ,RetailCustomers.[Address Postcode] AS [postcode]
  ,RetailCustomers.[Address Country] AS [country]
  ,RetailSales.HeaderSourceKey AS order_id --or transaction number, HeaderSourceKey is meaningless to users.
  ,'' AS [business]
  ,'' AS [label]
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
  ,MatProduct.BusinessDivisionName AS [category_1]
  ,MatProduct.BusinessDivisionName AS [category_1A]
  ,CASE 
    WHEN MatProduct.BusinessDivisionCode = 18
      THEN ''
    ELSE MatProduct.DepartmentCode
    END AS [category_2]
   ,MatProduct.DepartmentName AS [category_2A]
  ,MatProduct.CategoryCode AS [category_3]
  ,MatProduct.CategoryName AS [category_3A]
  ,MatProduct.SubCategoryCode AS [category_4]
  ,Matproduct.SubCategoryName AS [category_4A]
  ,MatProduct.SizeCode AS [size]
  ,MatProduct.ColourName AS [colour]
  ,CASE 
    WHEN DimProfitCentre.ProfitCentreType = 'EC'
      OR RetailSales.WarehouseDispatchTypeId IN (1,2,3)
      THEN 'Web'
    ELSE MatWarehouse.LocationTypeName --'In-store'
    END AS [channel]
  ,MatWarehouse.ProfitCentreCode AS [store_code]
  ,MatWarehouse.WarehouseName AS [store_name]
  ,CASE 
    WHEN RetailCustomers.[Signup Date] IS NOT NULL
      THEN 'TRUE'
    ELSE 'FALSE'
    END AS [loyalty_member_flag]
  ,RetailCustomers.[Business Division Name] AS [loyalty_brand]
  ,NULL AS [loyanty_tier]
  ,CAST(FORMAT(RetailCustomers.[Signup Date], 'dd/MM/yyyy') AS VARCHAR(20)) AS [loyalty_join_date]
  ,RetailCustomers.[Loyalty Card Number] AS [loyalty_member_id]
  ,NULL AS [nps_score]
  ,NULL AS [nps_date]
  ,LoyaltyPerson.amount_remaining AS [loyalty_reward_balance]
  ,LoyaltyPerson.expiry_date AS [loyalty_reward_expiry]
FROM RetailSales
LEFT OUTER JOIN DataWarehouseUserView.dbo.[Retail Customers] RetailCustomers ON RetailCustomers.[Person Id] = RetailSales.RetailCustomerId
LEFT OUTER JOIN (
  SELECT DimPerson.ID
    ,ALS_REVIEW_REWARDS.amount_remaining
    ,CAST(FORMAT(ALS_REVIEW_REWARDS.expiry_date, 'dd/MM/yyyy') AS VARCHAR(20)) AS expiry_date
  FROM DimPerson
  INNER JOIN DataWarehouseRawData.dbo.Als_Review_Rewards ON Als_Review_Rewards.person_id = DimPerson.SourceKey
  ) AS LoyaltyPerson ON LoyaltyPerson.Id = RetailSales.RetailCustomerId
INNER JOIN MatProduct ON MatProduct.ProductId = RetailSales.ProductId
INNER JOIN MatWarehouse ON MatWarehouse.WarehouseId = RetailSales.WarehouseId
INNER JOIN DimProfitCentre ON DimProfitCentre.Id = MatWarehouse.ProfitCentreId
WHERE MatProduct.IsReported = 1