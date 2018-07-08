/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [DET_NUMBER]
      ,[TER_DATE]
      ,[TER_REAS_CD]
      ,[TER_BUSINESS]
      ,[TER_LST_DUTY]
      ,[TER_NORM_SAL]
      ,[TER_ETP_DATE]
      ,[TER_PAY_FLG]
      ,[TER_PST_ER21]
      ,[TER_PST_SEEK]
  FROM [DataWarehouseChris21RawData].[dbo].[Staging_EMTER]
  ORDER BY 2

