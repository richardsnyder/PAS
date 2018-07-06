TRUNCATE TABLE FactLeaveTaken

INSERT INTO FactLeaveTaken (Employee_Id
, Employee_Number
, LeaveStartDate
, LeaveEndDate
, LeaveType
, LeaveHoursTaken
, LeaveDaysTaken
, LeaveDayOfWeek
, LeaveDaysClear
, LeaveHoursPerDay
, LeaveReason
, LeaveApproved
, LeavePayRun
, LeaveEmployee)

  SELECT
    DimEmployee.Id
   ,Staging_EMLVE.DET_NUMBER
   ,CAST(Staging_EMLVE.LVE_START AS DATE) AS LeaveStartDate
   ,CAST(Staging_EMLVE.LVE_END AS DATE) AS LeaveEndDate
   ,Staging_EMLVE.LVE_TYPE_CD
   ,Staging_EMLVE.LVE_HOUR_TKN
   ,Staging_EMLVE.LVE_DAY_TAKE
   ,Staging_EMLVE.LVE_DOW
   ,Staging_EMLVE.LVE_DAYS_CLR
   ,Staging_EMLVE.LVE_HRS_DAY
   ,Staging_EMLVE.LVE_ACT_REAS
   ,Staging_EMLVE.LVE_APPROVED
   ,Staging_EMLVE.LVE_PAY_RUN
   ,Staging_EMLVE.LVE_SEC_EMP
  FROM DataWarehouseChris21RawData.dbo.Staging_EMLVE
  INNER JOIN DataWarehouseChris21.dbo.DimEmployee 
  ON DimEmployee.DET_NUMBER = Staging_EMLVE.DET_NUMBER
