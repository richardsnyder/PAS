TRUNCATE TABLE FactTermination

INSERT INTO FactTermination (EmployeeId
, Employee_Number
, TER_DATE
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
  ORDER BY 2

