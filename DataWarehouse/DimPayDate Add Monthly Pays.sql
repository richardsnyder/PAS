/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [PayDateId]
      ,[CalendarDate]
      ,[PayPeriodStart]
      ,[PayPeriodEnd]
      ,[FinancialMonthId]
      ,[PayType]
  FROM [DataWarehouseChris21Cube].[dbo].[DimPayDate]

INSERT INTO [dbo].[DimPayDate](
           [CalendarDate]
           ,[PayPeriodStart]
           ,[PayPeriodEnd]
           ,[FinancialMonthId]
           ,[PayType])

  SELECT DISTINCT 
  DimDate.FinancialMonthEnd CalendarDate
  , DimDate.FinancialMonthStart PayPeriodStart
  , DimDate.FinancialMonthEnd PayPeriodEnd
  , DimDate.FinancialMonthId
  , 'M' PayType
  FROM DimDate

  SELECT * FROM DimPayDate dpd WHERE PayType = 'm'
