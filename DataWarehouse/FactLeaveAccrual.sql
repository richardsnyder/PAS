IF OBJECT_ID('tempdb..#StageData') IS NOT NULL DROP TABLE #StageData
CREATE TABLE #StageData (
  LeaveAccrualChangeDate DATE
 ,EmployeeId INT
 ,Employee_Number VARCHAR(7)
 ,LAC_LVE_TYPE VARCHAR(4) NULL
 ,LAC_AS_AT_DT DATE NULL
 ,LAC_SRV_STRT DATE NULL
 ,LAC_ENT_DATE DATE NULL
 ,LAC_ACC_DAYS FLOAT NULL
 ,LAC_ACC_HRS FLOAT NULL
 ,LAC_ENT_DAYS FLOAT NULL
 ,LAC_ENT_HRS FLOAT NULL
 ,LAC_CALC_RUN DATE NULL
 ,LAC_CUR_AC_D FLOAT NULL
 ,LAC_CUR_AC_H FLOAT NULL
 ,LAC_TOT_DAYS FLOAT NULL
 ,LAC_TOT_HRS FLOAT NULL
 ,LAC_LVE_DAYS FLOAT NULL
 ,LAC_LVE_HRS FLOAT NULL
 ,LAC_PAST_DAY FLOAT NULL
 ,LAC_PAST_HRS FLOAT NULL
 ,LAC_SRV_YRS INT NULL
 ,LAC_SRV_DAYS INT NULL
 ,LAC_CUR_EN_D FLOAT NULL
 ,LAC_CUR_EN_H FLOAT NULL
 ,LAC_LAST_ENT NVARCHAR(10) NULL
 ,LAC_ADJ_DAYS FLOAT NULL
 ,LAC_ADJ_HRS FLOAT NULL
 ,LAC_NEXT_ENT NVARCHAR(10) NULL
)

INSERT INTO #StageData (LeaveAccrualChangeDate
, EmployeeId
, Employee_Number
, LAC_LVE_TYPE
, LAC_AS_AT_DT
, LAC_SRV_STRT
, LAC_ENT_DATE
, LAC_ACC_DAYS
, LAC_ACC_HRS
, LAC_ENT_DAYS
, LAC_ENT_HRS
, LAC_CALC_RUN
, LAC_CUR_AC_D
, LAC_CUR_AC_H
, LAC_TOT_DAYS
, LAC_TOT_HRS
, LAC_LVE_DAYS
, LAC_LVE_HRS
, LAC_PAST_DAY
, LAC_PAST_HRS
, LAC_SRV_YRS
, LAC_SRV_DAYS
, LAC_CUR_EN_D
, LAC_CUR_EN_H
, LAC_LAST_ENT
, LAC_ADJ_DAYS
, LAC_ADJ_HRS
, LAC_NEXT_ENT)

  SELECT CAST(GETDATE() AS DATE) AS LeaveAccrualChangeDate
   ,DimEmployee.Id 
   ,Staging_EMLAC.DET_NUMBER
   ,Staging_EMLAC.LAC_LVE_TYPE
   ,CAST(Staging_EMLAC.LAC_AS_AT_DT AS DATE) LAC_AS_AT_DT
   ,CAST(Staging_EMLAC.LAC_SRV_STRT AS DATE) LAC_SRV_STRT
   ,CAST(Staging_EMLAC.LAC_ENT_DATE AS DATE) LAC_ENT_DATE
   ,Staging_EMLAC.LAC_ACC_DAYS
   ,Staging_EMLAC.LAC_ACC_HRS
   ,Staging_EMLAC.LAC_ENT_DAYS
   ,Staging_EMLAC.LAC_ENT_HRS
   ,CAST(Staging_EMLAC.LAC_CALC_RUN AS DATE) LAC_CALC_RUN
   ,Staging_EMLAC.LAC_CUR_AC_D
   ,Staging_EMLAC.LAC_CUR_AC_H
   ,Staging_EMLAC.LAC_TOT_DAYS
   ,Staging_EMLAC.LAC_TOT_HRS
   ,Staging_EMLAC.LAC_LVE_DAYS
   ,Staging_EMLAC.LAC_LVE_HRS
   ,Staging_EMLAC.LAC_PAST_DAY
   ,Staging_EMLAC.LAC_PAST_HRS
   ,Staging_EMLAC.LAC_SRV_YRS
   ,Staging_EMLAC.LAC_SRV_DAYS
   ,Staging_EMLAC.LAC_CUR_EN_D
   ,Staging_EMLAC.LAC_CUR_EN_H
   ,Staging_EMLAC.LAC_LAST_ENT
   ,Staging_EMLAC.LAC_ADJ_DAYS
   ,Staging_EMLAC.LAC_ADJ_HRS
   ,Staging_EMLAC.LAC_NEXT_ENT
  FROM DataWarehouseChris21RawData.dbo.Staging_EMLAC
  INNER JOIN DataWarehouseChris21.dbo.DimEmployee
  ON DimEmployee.DET_NUMBER = Staging_EMLAC.DET_NUMBER

MERGE  FactLeaveAccrual AS Destination
USING #StageData AS Source
ON (Destination.EmployeeId = Source.EmployeeId
AND Destination.Employee_Number = Source.Employee_Number
AND Destination.LAC_CALC_RUN = Source.LAC_CALC_RUN
AND Destination.LeaveAccrualChangeDate=Source.LeaveAccrualChangeDate)
WHEN NOT MATCHED BY TARGET
THEN INSERT (
    LeaveAccrualChangeDate 
    , EmployeeId 
    , Employee_Number 
    , LAC_LVE_TYPE 
    , LAC_AS_AT_DT 
    , LAC_SRV_STRT 
    , LAC_ENT_DATE 
    , LAC_ACC_DAYS 
    , LAC_ACC_HRS 
    , LAC_ENT_DAYS 
    , LAC_ENT_HRS 
    , LAC_CALC_RUN 
    , LAC_CUR_AC_D 
    , LAC_CUR_AC_H 
    , LAC_TOT_DAYS 
    , LAC_TOT_HRS 
    , LAC_LVE_DAYS 
    , LAC_LVE_HRS 
    , LAC_PAST_DAY 
    , LAC_PAST_HRS 
    , LAC_SRV_YRS 
    , LAC_SRV_DAYS 
    , LAC_CUR_EN_D 
    , LAC_CUR_EN_H 
    , LAC_LAST_ENT 
    , LAC_ADJ_DAYS 
    , LAC_ADJ_HRS 
    , LAC_NEXT_ENT
  )
  VALUES (Source.LeaveAccrualChangeDate
  ,Source.EmployeeId 
  ,Source.Employee_Number 
  ,Source.LAC_LVE_TYPE 
  ,Source.LAC_AS_AT_DT 
  ,Source.LAC_SRV_STRT 
  ,Source.LAC_ENT_DATE 
  ,Source.LAC_ACC_DAYS 
  ,Source.LAC_ACC_HRS 
  ,Source.LAC_ENT_DAYS 
  ,Source.LAC_ENT_HRS 
  ,Source.LAC_CALC_RUN 
  ,Source.LAC_CUR_AC_D 
  ,Source.LAC_CUR_AC_H 
  ,Source.LAC_TOT_DAYS 
  ,Source.LAC_TOT_HRS 
  ,Source.LAC_LVE_DAYS 
  ,Source.LAC_LVE_HRS 
  ,Source.LAC_PAST_DAY 
  ,Source.LAC_PAST_HRS 
  ,Source.LAC_SRV_YRS 
  ,Source.LAC_SRV_DAYS 
  ,Source.LAC_CUR_EN_D 
  ,Source.LAC_CUR_EN_H 
  ,Source.LAC_LAST_ENT 
  ,Source.LAC_ADJ_DAYS 
  ,Source.LAC_ADJ_HRS 
  ,Source.LAC_NEXT_ENT)
WHEN MATCHED AND
(
  Destination.LeaveAccrualChangeDate=Source.LeaveAccrualChangeDate
    AND Destination.EmployeeId!=Source.EmployeeId
    AND Destination.Employee_Number!=Source.Employee_Number
    AND Destination.LAC_LVE_TYPE!=Source.LAC_LVE_TYPE
    AND Destination.LAC_AS_AT_DT!=Source.LAC_AS_AT_DT
    AND Destination.LAC_SRV_STRT!=Source.LAC_SRV_STRT
    AND Destination.LAC_ENT_DATE!=Source.LAC_ENT_DATE
    AND Destination.LAC_ACC_DAYS!=Source.LAC_ACC_DAYS
    AND Destination.LAC_ACC_HRS!=Source.LAC_ACC_HRS
    AND Destination.LAC_ENT_DAYS!=Source.LAC_ENT_DAYS
    AND Destination.LAC_ENT_HRS!=Source.LAC_ENT_HRS
    AND Destination.LAC_CALC_RUN!=Source.LAC_CALC_RUN
    AND Destination.LAC_CUR_AC_D!=Source.LAC_CUR_AC_D
    AND Destination.LAC_CUR_AC_H!=Source.LAC_CUR_AC_H
    AND Destination.LAC_TOT_DAYS!=Source.LAC_TOT_DAYS
    AND Destination.LAC_TOT_HRS!=Source.LAC_TOT_HRS
    AND Destination.LAC_LVE_DAYS!=Source.LAC_LVE_DAYS
    AND Destination.LAC_LVE_HRS!=Source.LAC_LVE_HRS
    AND Destination.LAC_PAST_DAY!=Source.LAC_PAST_DAY
    AND Destination.LAC_PAST_HRS!=Source.LAC_PAST_HRS
    AND Destination.LAC_SRV_YRS!=Source.LAC_SRV_YRS
    AND Destination.LAC_SRV_DAYS!=Source.LAC_SRV_DAYS
    AND Destination.LAC_CUR_EN_D!=Source.LAC_CUR_EN_D
    AND Destination.LAC_CUR_EN_H!=Source.LAC_CUR_EN_H
    AND Destination.LAC_LAST_ENT!=Source.LAC_LAST_ENT
    AND Destination.LAC_ADJ_DAYS!=Source.LAC_ADJ_DAYS
    AND Destination.LAC_ADJ_HRS!=Source.LAC_ADJ_HRS
    AND Destination.LAC_NEXT_ENT!=Source.LAC_NEXT_ENT
)
  THEN UPDATE
    SET Destination.LeaveAccrualChangeDate=Source.LeaveAccrualChangeDate
    , Destination.EmployeeId=Source.EmployeeId
    , Destination.Employee_Number=Source.Employee_Number
    , Destination.LAC_LVE_TYPE=Source.LAC_LVE_TYPE
    , Destination.LAC_AS_AT_DT=Source.LAC_AS_AT_DT
    , Destination.LAC_SRV_STRT=Source.LAC_SRV_STRT
    , Destination.LAC_ENT_DATE=Source.LAC_ENT_DATE
    , Destination.LAC_ACC_DAYS=Source.LAC_ACC_DAYS
    , Destination.LAC_ACC_HRS=Source.LAC_ACC_HRS
    , Destination.LAC_ENT_DAYS=Source.LAC_ENT_DAYS
    , Destination.LAC_ENT_HRS=Source.LAC_ENT_HRS
    , Destination.LAC_CALC_RUN=Source.LAC_CALC_RUN
    , Destination.LAC_CUR_AC_D=Source.LAC_CUR_AC_D
    , Destination.LAC_CUR_AC_H=Source.LAC_CUR_AC_H
    , Destination.LAC_TOT_DAYS=Source.LAC_TOT_DAYS
    , Destination.LAC_TOT_HRS=Source.LAC_TOT_HRS
    , Destination.LAC_LVE_DAYS=Source.LAC_LVE_DAYS
    , Destination.LAC_LVE_HRS=Source.LAC_LVE_HRS
    , Destination.LAC_PAST_DAY=Source.LAC_PAST_DAY
    , Destination.LAC_PAST_HRS=Source.LAC_PAST_HRS
    , Destination.LAC_SRV_YRS=Source.LAC_SRV_YRS
    , Destination.LAC_SRV_DAYS=Source.LAC_SRV_DAYS
    , Destination.LAC_CUR_EN_D=Source.LAC_CUR_EN_D
    , Destination.LAC_CUR_EN_H=Source.LAC_CUR_EN_H
    , Destination.LAC_LAST_ENT=Source.LAC_LAST_ENT
    , Destination.LAC_ADJ_DAYS=Source.LAC_ADJ_DAYS
    , Destination.LAC_ADJ_HRS=Source.LAC_ADJ_HRS
    , Destination.LAC_NEXT_ENT=Source.LAC_NEXT_ENT
;
DROP TABLE #StageData