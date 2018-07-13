IF OBJECT_ID('tempdb..#StageData') IS NOT NULL DROP TABLE #StageData

  SELECT
   DimEmployee.Id EmployeeId
   ,Staging_EMPOS.DET_NUMBER Employee_Number
   ,CAST(Staging_EMPOS.POS_START AS DATE) POS_START
   ,CAST(NULLIF(Staging_EMPOS.POS_END, '0001-01-02') AS DATE) POS_END
   ,Staging_EMPOS.POS_LVE_GRP
   ,Staging_EMPOS.POS_HOL_ZONE
   ,Staging_EMPOS.POS_EMP_NOM
   ,Staging_EMPOS.POS_EMP_N_ST
   ,Staging_EMPOS.POS_EMP_OCC
   ,Staging_EMPOS.POS_AV_HR_WK
   ,Staging_EMPOS.POS_OT_PAY
   ,Staging_EMPOS.POS_ANL_GRP
   ,Staging_EMPOS.POS_COST_GRP
   ,Staging_EMPOS.POS_SEC_LVL
   ,Staging_EMPOS.POS_PERC_WKD
   ,Staging_EMPOS.POS_STATUS
   ,Staging_EMPOS.POS_DAYS_WK
   ,Staging_EMPOS.POS_TT_AW_ID
   ,Staging_EMPOS.POS_SHARE
   ,Staging_EMPOS.POS_RT_ZAI
   ,Staging_EMPOS.POS_NUMBER
   ,CAST(Staging_EMPOS.POS_PDT_STRT AS DATE) POS_PDT_STRT
   ,CAST(Staging_EMPOS.POS_PDT_END AS DATE) POS_PDT_END
   ,Staging_EMPOS.POS_CATEG_CD
   ,Staging_EMPOS.POS_CLS_CODE
   ,Staging_EMPOS.POS_PDT_STAT
   ,Staging_EMPOS.POS_PDT_HRS
   ,Staging_EMPOS.POS_PDT_OT
   ,Staging_EMPOS.POS_PDT_ANL
   ,Staging_EMPOS.POS_PDT_COST
   ,Staging_EMPOS.POS_PDT_SEC
   ,Staging_EMPOS.POS_PDT_ZAS
   ,Staging_EMPOS.POS_PDT_ZDR
   ,Staging_EMPOS.POS_INDUSTRY
   ,Staging_EMPOS.POS_L0_CD
   ,Staging_EMPOS.POS_L1_CD
   ,Staging_EMPOS.POS_L2_CD
   ,Staging_EMPOS.POS_L3_CD
   ,Staging_EMPOS.POS_L4_CD
   ,Staging_EMPOS.POS_L5_CD
   ,Staging_EMPOS.POS_L6_CD
   ,Staging_EMPOS.POS_TITLE
   ,Staging_EMPAY.PYD_TYPE 
  INTO #StageData
  FROM DataWarehouseChris21RawData.dbo.Staging_EMPOS
  INNER JOIN DataWarehouseChris21.dbo.DimEmployee
  ON DimEmployee.DET_NUMBER = Staging_EMPOS.DET_NUMBER
  LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_EMPAY Staging_EMPAY
  ON Staging_EMPAY.DET_NUMBER = Staging_EMPOS.DET_NUMBER

/* Add the records that have a POS_END Date
   These will only be added for the calendar dates
   between POS_START and POS_END
*/
INSERT INTO dbo.FactPosition
           (PositionDate
           ,EmployeeId
           ,Employee_Number
           ,POS_START
           ,POS_END
           ,POS_LVE_GRP
           ,POS_HOL_ZONE
           ,POS_EMP_NOM
           ,POS_EMP_N_ST
           ,POS_EMP_OCC
           ,POS_AV_HR_WK
           ,POS_OT_PAY
           ,POS_ANL_GRP
           ,POS_COST_GRP
           ,POS_SEC_LVL
           ,POS_PERC_WKD
           ,POS_STATUS
           ,POS_DAYS_WK
           ,POS_TT_AW_ID
           ,POS_SHARE
           ,POS_RT_ZAI
           ,POS_NUMBER
           ,POS_PDT_STRT
           ,POS_PDT_END
           ,POS_CATEG_CD
           ,POS_CLS_CODE
           ,POS_PDT_STAT
           ,POS_PDT_HRS
           ,POS_PDT_OT
           ,POS_PDT_ANL
           ,POS_PDT_COST
           ,POS_PDT_SEC
           ,POS_PDT_ZAS
           ,POS_PDT_ZDR
           ,POS_INDUSTRY
           ,POS_L0_CD
           ,POS_L1_CD
           ,POS_L2_CD
           ,POS_L3_CD
           ,POS_L4_CD
           ,POS_L5_CD
           ,POS_L6_CD
           ,POS_TITLE
           ,PAYPOSITIONTYPE)
SELECT
 DimDate.CalendarDate
 ,StageData.EmployeeId
 ,StageData.Employee_Number
 ,StageData.POS_START
 ,StageData.POS_END
 ,StageData.POS_LVE_GRP
 ,StageData.POS_HOL_ZONE
 ,StageData.POS_EMP_NOM
 ,StageData.POS_EMP_N_ST
 ,StageData.POS_EMP_OCC
 ,StageData.POS_AV_HR_WK
 ,StageData.POS_OT_PAY
 ,StageData.POS_ANL_GRP
 ,StageData.POS_COST_GRP
 ,StageData.POS_SEC_LVL
 ,StageData.POS_PERC_WKD
 ,StageData.POS_STATUS
 ,StageData.POS_DAYS_WK
 ,StageData.POS_TT_AW_ID
 ,StageData.POS_SHARE
 ,StageData.POS_RT_ZAI
 ,StageData.POS_NUMBER
 ,StageData.POS_PDT_STRT
 ,StageData.POS_PDT_END
 ,StageData.POS_CATEG_CD
 ,StageData.POS_CLS_CODE
 ,StageData.POS_PDT_STAT
 ,StageData.POS_PDT_HRS
 ,StageData.POS_PDT_OT
 ,StageData.POS_PDT_ANL
 ,StageData.POS_PDT_COST
 ,StageData.POS_PDT_SEC
 ,StageData.POS_PDT_ZAS
 ,StageData.POS_PDT_ZDR
 ,StageData.POS_INDUSTRY
 ,StageData.POS_L0_CD
 ,StageData.POS_L1_CD
 ,StageData.POS_L2_CD
 ,StageData.POS_L3_CD
 ,StageData.POS_L4_CD
 ,StageData.POS_L5_CD
 ,StageData.POS_L6_CD
 ,StageData.POS_TITLE
 ,StageData.PYD_TYPE
FROM #StageData StageData
INNER JOIN DimDate 
ON DimDate.CalendarDate BETWEEN StageData.POS_START AND StageData.POS_END
WHERE StageData.POS_END IS NOT NULL
AND NOT EXISTS (SELECT * FROM FactPosition WHERE FactPosition.EmployeeId = StageData.EmployeeId)

/* Add the records that have NO POS_END Date
   These will be added for the calendar dates
   between POS_START until the position ends 
   POS_END is not null
*/
INSERT INTO dbo.FactPosition
           (PositionDate
           ,EmployeeId
           ,Employee_Number
           ,POS_START
           ,POS_END
           ,POS_LVE_GRP
           ,POS_HOL_ZONE
           ,POS_EMP_NOM
           ,POS_EMP_N_ST
           ,POS_EMP_OCC
           ,POS_AV_HR_WK
           ,POS_OT_PAY
           ,POS_ANL_GRP
           ,POS_COST_GRP
           ,POS_SEC_LVL
           ,POS_PERC_WKD
           ,POS_STATUS
           ,POS_DAYS_WK
           ,POS_TT_AW_ID
           ,POS_SHARE
           ,POS_RT_ZAI
           ,POS_NUMBER
           ,POS_PDT_STRT
           ,POS_PDT_END
           ,POS_CATEG_CD
           ,POS_CLS_CODE
           ,POS_PDT_STAT
           ,POS_PDT_HRS
           ,POS_PDT_OT
           ,POS_PDT_ANL
           ,POS_PDT_COST
           ,POS_PDT_SEC
           ,POS_PDT_ZAS
           ,POS_PDT_ZDR
           ,POS_INDUSTRY
           ,POS_L0_CD
           ,POS_L1_CD
           ,POS_L2_CD
           ,POS_L3_CD
           ,POS_L4_CD
           ,POS_L5_CD
           ,POS_L6_CD
           ,POS_TITLE
           ,PAYPOSITIONTYPE)

SELECT
 DimDate.CalendarDate
 ,StageData.EmployeeId
 ,StageData.Employee_Number
 ,StageData.POS_START
 ,StageData.POS_END
 ,StageData.POS_LVE_GRP
 ,StageData.POS_HOL_ZONE
 ,StageData.POS_EMP_NOM
 ,StageData.POS_EMP_N_ST
 ,StageData.POS_EMP_OCC
 ,StageData.POS_AV_HR_WK
 ,StageData.POS_OT_PAY
 ,StageData.POS_ANL_GRP
 ,StageData.POS_COST_GRP
 ,StageData.POS_SEC_LVL
 ,StageData.POS_PERC_WKD
 ,StageData.POS_STATUS
 ,StageData.POS_DAYS_WK
 ,StageData.POS_TT_AW_ID
 ,StageData.POS_SHARE
 ,StageData.POS_RT_ZAI
 ,StageData.POS_NUMBER
 ,StageData.POS_PDT_STRT
 ,StageData.POS_PDT_END
 ,StageData.POS_CATEG_CD
 ,StageData.POS_CLS_CODE
 ,StageData.POS_PDT_STAT
 ,StageData.POS_PDT_HRS
 ,StageData.POS_PDT_OT
 ,StageData.POS_PDT_ANL
 ,StageData.POS_PDT_COST
 ,StageData.POS_PDT_SEC
 ,StageData.POS_PDT_ZAS
 ,StageData.POS_PDT_ZDR
 ,StageData.POS_INDUSTRY
 ,StageData.POS_L0_CD
 ,StageData.POS_L1_CD
 ,StageData.POS_L2_CD
 ,StageData.POS_L3_CD
 ,StageData.POS_L4_CD
 ,StageData.POS_L5_CD
 ,StageData.POS_L6_CD
 ,StageData.POS_TITLE
 ,StageData.PYD_TYPE
FROM #StageData StageData
INNER JOIN DimDate 
ON DimDate.CalendarDate BETWEEN StageData.POS_START AND CAST(GETDATE() AS DATE)
WHERE StageData.POS_END IS NULL
AND NOT EXISTS (SELECT * FROM FactPosition WHERE FactPosition.EmployeeId = StageData.EmployeeId AND FactPosition.PositionDate = DimDate.CalendarDate)

DROP TABLE #StageData

