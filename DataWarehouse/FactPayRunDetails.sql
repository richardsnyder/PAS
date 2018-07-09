DELETE FactPayRunDetails
	FROM FactPayRunDetails
	INNER JOIN DataWarehouseChris21RawData.dbo.staging_EMPIT
		ON FactPayRunDetails.pit_run_no = staging_EMPIT.pit_run_no
		AND FactPayRunDetails.EmployeeNumber = staging_EMPIT.det_number

print 'Deleted ' + convert(varchar(10),@@ROWCOUNT) + ' existing rows from FactPayRunDetails table due to new data for same pay run / employee combinations.'

INSERT INTO dbo.FactPayRunDetails
(EmployeeId
,EmployeeNumber
,PIT_RUN_NO
,PIT_RUN_DATE
,PIT_DED_ALW
,PIT_CODE
,PIT_SEQ
,PIT_DETNUM
,PIT_COMPANY
,PIT_CATEGORY
,PIT_COS_CENT
,PIT_ANAL_GRP
,PIT_COST_GRP
,FILLER_01
,PIT_CRED_DEB
,PIT_AMOUNT
,PIT_ACC_TYPE
,PIT_SURNAME
,FILLER_02
,PIT_CURRENCY
,PIT_HOURS
,PIT_JOB_NUM
,PIT_ACCR_REV
,PIT_BROKEN_I
,PIT_RATE
,FILLER_03
,PIT_SAL_CLSS
,FILLER_04
,PIT_K3_COM_T
,PIT_K3_COM_C
,PIT_K3_EMPNO
,PIT_K3_PAYRN
,PIT_ACC_NUM
,PIT_ORGANI00
,PIT_ORGANI01
,PIT_ORGANI02
,PIT_ORGANI03
,PIT_ORGANI04
,PIT_ORGANI05
,PIT_ORGANI06
,PIT_ORGANI07
,PIT_ORGANI08
,PIT_ORGANI09
,FILLER_05)

SELECT DimEmployee.Id
,Staging_EMPIT.DET_NUMBER
,PIT_RUN_NO
,PIT_RUN_DATE
,PIT_DED_ALW
,PIT_CODE
,PIT_SEQ
,PIT_DETNUM
,PIT_COMPANY
,PIT_CATEGORY
,PIT_COS_CENT
,PIT_ANAL_GRP
,PIT_COST_GRP
,FILLER_01
,PIT_CRED_DEB
,PIT_AMOUNT
,PIT_ACC_TYPE
,PIT_SURNAME
,FILLER_02
,PIT_CURRENCY
,PIT_HOURS
,PIT_JOB_NUM
,PIT_ACCR_REV
,PIT_BROKEN_I
,PIT_RATE
,FILLER_03
,PIT_SAL_CLSS
,FILLER_04
,PIT_K3_COM_T
,PIT_K3_COM_C
,PIT_K3_EMPNO
,PIT_K3_PAYRN
,PIT_ACC_NUM
,PIT_ORGANI00
,PIT_ORGANI01
,PIT_ORGANI02
,PIT_ORGANI03
,PIT_ORGANI04
,PIT_ORGANI05
,PIT_ORGANI06
,PIT_ORGANI07
,PIT_ORGANI08
,PIT_ORGANI09
,FILLER_05
FROM DataWarehouseChris21RawData.dbo.Staging_EMPIT
INNER JOIN DataWarehouseChris21.dbo.DimEmployee 
ON DimEmployee.DET_NUMBER = Staging_EMPIT.DET_NUMBER
print 'Inserted ' + convert(varchar(10),@@ROWCOUNT) + ' new rows into FactPayRunDetails table.'