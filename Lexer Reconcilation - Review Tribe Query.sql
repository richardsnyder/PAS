SELECT [Business Division Name]
, FORMAT(COUNT(*), '#,##0') CountOfDivision
FROM [Retail Customers] RetailCustomers
WHERE 1=1
--AND  [Total Sales] IS NOT NULL
--AND ([Email Address] IS NOT NULL) -- OR [Mobile Phone Number] IS NOT NULL)
AND [Business Division Code] IN (18,31)
GROUP BY [Business Division Name]



-- no filters 1,101,899
-- with a total sales 926,975
-- with total sales and email 674,292
-- with total sales and email or mobile 680,499
-- with Review business division 489,473
-- with Black Pepper division 177,978


SELECT DISTINCT COUNT([Person Id])
      FROM [Retail Customers] RetailCustomers
      WHERE [Business Division Name] = 'Review'