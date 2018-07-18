DELETE FactPayRunSummary
  FROM FactPayRunSummary
  INNER JOIN DataWarehouseChris21RawData.dbo.Staging_EMPHS
    ON FactPayRunSummary.PHQ_RUN_NUMB = Staging_EMPHS.PHQ_RUN_NUMB
    AND FactPayRunSummary.EmployeeNumber = Staging_EMPHS.DET_NUMBER

PRINT 'Deleted ' + CONVERT(VARCHAR(10), @@rowcount) + ' existing rows from FactPayRunDetails table due to new data for same pay run / employee combinations.'

INSERT INTO dbo.FactPayRunSummary (EmployeeId
, EmployeeNumber
, PayDateId
, PHQ_PAY_DATE
, PHQ_RUN_NUMB
, PHQ_PD_UP_TO
, PHQ_BASE_HRS
, PHQ_BASE_AMT
, PHQ_OTME_HRS
, PHQ_OTME_AMT
, PHQ_NET_AMT
, PHQ_GROS_AMT
, PHQ_TAX_PAID
, PHQ_TAXB_SAL
, PHS_NPA_TAXP
, PHS_NPA_TAXB
, PHQ_ALW_BTAX
, PHQ_ALW_ATAX
, PHS_OSB_ALW
, PHQ_DED_ATAX
, PHQ_DED_BTAX
, PHS_OSB_DEDN
, PHQ_LVE_LOAD
, PHQ_EMP_SUP
, PHQ_COY_SUP
, PHS_SUPR_SAL
, PHQ_RBK_DATE
, PHQ_RDW_DATE
, PHQ_STUD_DED
, PHS_ANNO_AMT
, PHS_WCMO_AMT
, PHQ_ESUP_BT
, PHQ_ESUP_AT
, PHQ_L0_CD
, PHQ_L1_CD
, PHQ_L2_CD
, PHQ_L3_CD
, PHQ_L4_CD
, PHQ_L5_CD
, PHQ_L6_CD)

  SELECT
    DimEmployee.Id EmployeeId
   ,Staging_EMPHS.DET_NUMBER
   ,CASE
      WHEN PHQ_L2_CD <> 'ME' THEN DimPayDateRe.PayDateId
      WHEN PHQ_L2_CD = 'ME' THEN DimPayDateMe.PayDateId
    END AS PayDateId
   ,Staging_EMPHS.PHQ_PAY_DATE
   ,Staging_EMPHS.PHQ_RUN_NUMB
   ,Staging_EMPHS.PHQ_PD_UP_TO
   ,Staging_EMPHS.PHQ_BASE_HRS
   ,Staging_EMPHS.PHQ_BASE_AMT
   ,Staging_EMPHS.PHQ_OTME_HRS
   ,Staging_EMPHS.PHQ_OTME_AMT
   ,Staging_EMPHS.PHQ_NET_AMT
   ,Staging_EMPHS.PHQ_GROS_AMT
   ,Staging_EMPHS.PHQ_TAX_PAID
   ,Staging_EMPHS.PHQ_TAXB_SAL
   ,Staging_EMPHS.PHS_NPA_TAXP
   ,Staging_EMPHS.PHS_NPA_TAXB
   ,Staging_EMPHS.PHQ_ALW_BTAX
   ,Staging_EMPHS.PHQ_ALW_ATAX
   ,Staging_EMPHS.PHS_OSB_ALW
   ,Staging_EMPHS.PHQ_DED_ATAX
   ,Staging_EMPHS.PHQ_DED_BTAX
   ,Staging_EMPHS.PHS_OSB_DEDN
   ,Staging_EMPHS.PHQ_LVE_LOAD
   ,Staging_EMPHS.PHQ_EMP_SUP
   ,Staging_EMPHS.PHQ_COY_SUP
   ,Staging_EMPHS.PHS_SUPR_SAL
   ,Staging_EMPHS.PHQ_RBK_DATE
   ,Staging_EMPHS.PHQ_RDW_DATE
   ,Staging_EMPHS.PHQ_STUD_DED
   ,Staging_EMPHS.PHS_ANNO_AMT
   ,Staging_EMPHS.PHS_WCMO_AMT
   ,Staging_EMPHS.PHQ_ESUP_BT
   ,Staging_EMPHS.PHQ_ESUP_AT
   ,Staging_EMPHS.PHQ_L0_CD
   ,Staging_EMPHS.PHQ_L1_CD
   ,Staging_EMPHS.PHQ_L2_CD
   ,Staging_EMPHS.PHQ_L3_CD
   ,Staging_EMPHS.PHQ_L4_CD
   ,Staging_EMPHS.PHQ_L5_CD
   ,Staging_EMPHS.PHQ_L6_CD
  --INTO dbo.FactPayRunSummary
  FROM DataWarehouseChris21RawData.dbo.Staging_EMPHS Staging_EMPHS
  INNER JOIN dbo.DimEmployee
    ON DimEmployee.DET_NUMBER = Staging_EMPHS.DET_NUMBER
  INNER JOIN DataWarehouseChris21RawData.dbo.Staging_EMDET
    ON Staging_EMDET.DET_NUMBER = Staging_EMPHS.DET_NUMBER
  INNER JOIN dbo.DimPayDate DimPayDateRe
    ON DimPayDateRe.CalendarDate = Staging_EMPHS.PHQ_PAY_DATE
      AND DimPayDateRe.PayType = 'RE'
  INNER JOIN dbo.DimPayDate DimPayDateMe
    ON DimPayDateMe.CalendarDate = Staging_EMPHS.PHQ_PAY_DATE
      AND DimPayDateMe.PayType = 'ME'
  ORDER BY 2, 3
print 'Inserted ' + convert(varchar(10),@@ROWCOUNT) + ' new rows into FactPayRunSummary table.'