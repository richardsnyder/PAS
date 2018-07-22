/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [LeaveAccrualChangeDate]
      ,[EmployeeId]
      ,[Employee_Number]
      ,[LAC_CUR_AC_H]
      ,[LAC_CUR_EN_H]
      ,[LAC_LVE_TYPE]
      ,[LAC_CALC_RUN]
      ,[LAC_LAST_ENT]
      ,[LAC_NEXT_ENT]
  FROM [DataWarehouseChris21].[dbo].[FactLeaveAccrual]
  WHERE LAC_LVE_TYPE = 'ann'
  AND Employee_Number = '03370'
  ORDER BY 2,1


  