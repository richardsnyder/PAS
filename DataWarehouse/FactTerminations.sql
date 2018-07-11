TRUNCATE TABLE FactTermination

INSERT INTO FactTermination (EmployeeId
, Employee_Number
, TER_DATE
, PayDateId
, TER_REAS_CD
, TER_BUSINESS
, TER_LST_DUTY
, TER_NORM_SAL
, TER_ETP_DATE
, TER_PAY_FLG
, TER_PST_ER21
, TER_PST_SEEK
)

SELECT DimEmployee.Id EmployeeId
 ,Staging_EMTER.DET_NUMBER Employee_Number
      ,CAST(Staging_EMTER.TER_DATE AS DATE) TER_DATE
      ,CASE 
         WHEN FactPositionMe.POS_L2_CD = 'ME'
          THEN DimPayDateMe.PayDateId
         WHEN FactPositionRe.POS_L2_CD <> 'ME' OR FactPositionRe.POS_L2_CD IS NULL
          THEN DimPayDateRe.PayDateId
       END PayDateId
      ,Staging_EMTER.TER_REAS_CD
      ,Staging_EMTER.TER_BUSINESS
      ,Staging_EMTER.TER_LST_DUTY
      ,Staging_EMTER.TER_NORM_SAL
      ,Staging_EMTER.TER_ETP_DATE
      ,Staging_EMTER.TER_PAY_FLG
      ,Staging_EMTER.TER_PST_ER21
      ,Staging_EMTER.TER_PST_SEEK
  FROM DataWarehouseChris21RawData.dbo.Staging_EMTER
  INNER JOIN dbo.DimEmployee
  ON DimEmployee.DET_NUMBER = Staging_EMTER.DET_NUMBER

  LEFT JOIN DimPayDate DimPayDateRe
  ON DimPayDateRe.CalendarDate = Staging_EMTER.TER_DATE
  AND DimPayDateRe.PayType = 'RE'

  LEFT JOIN DimPayDate DimPayDateMe
  ON DimPayDateMe.CalendarDate = Staging_EMTER.TER_DATE
  AND DimPayDateMe.PayType = 'ME'

  LEFT JOIN FactPosition FactPositionRe
  ON FactPositionRe.Employee_Number = Staging_EMTER.DET_NUMBER
  AND FactPositionRe.PostionDate = Staging_EMTER.TER_DATE
  AND FactPositionRe.POS_L2_CD <> 'ME'

  LEFT JOIN FactPosition FactPositionMe
  ON FactPositionMe.Employee_Number = Staging_EMTER.DET_NUMBER
  AND FactPositionMe.PostionDate = Staging_EMTER.TER_DATE
  AND FactPositionMe.POS_L2_CD = 'ME'
