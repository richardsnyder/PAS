IF OBJECT_ID('tempdb..#EmpDivPos') IS NOT NULL
DROP TABLE #EmpDivPos

DECLARE @ReportDate INT
DECLARE @BusinessDivision Varchar(12)
SET @ReportDate = 101
SET @BusinessDivision = 'BB'

DECLARE @ReportingPeriodId INT
DECLARE @FinancialMonthStart Date
DECLARE @FinancialMonthEnd Date
DECLARE @FortnightlyPayHours FLOAT
DECLARE @MonthlyPayHours  FLOAT

SET @ReportingPeriodId = @ReportDate

SET @FinancialMonthStart = (SELECT DISTINCT
		FinancialMonthStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @FinancialMonthEnd = (SELECT DISTINCT
		FinancialMonthEnd
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @FortnightlyPayHours = (	select ((count(DOW)/2)*10)*7.6 AS FortnightHours
                            	from (
                            	select calendardate
                            	,datepart(dw, calendardate) DOW
                            	from DataWarehouse.dbo.DimDate
                            	where financialmonthid = @ReportingPeriodId)x
                            	where DOW = 5)

SET @MonthlyPayHours = (SELECT DISTINCT
		(COUNT(calendardate) * 7.6) AS CycleThreeHours
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId
	AND DayOfWeekId BETWEEN 1 AND 5)

PRINT @MonthlyPayHours

SELECT DISTINCT
	Staging_EMPOS.DET_NUMBER AS 'Employee'
   ,Staging_EMPOS.POS_L1_CD AS Division
   ,Staging_ORGNA.GNA_ORG_NAME AS DivisionName
   ,Staging_EMPOS.POS_L4_CD AS 'Position' 
   INTO #EmpDivPos
FROM Staging_EMPOS
INNER JOIN Staging_ORGNA
	ON Staging_ORGNA.GNA_ORG_CODE = Staging_EMPOS.POS_L1_CD
WHERE 1 = 1
AND Staging_ORGNA.GNA_SEC_LVL = 1
AND CAST(POS_START AS DATE) <= @FinancialMonthEnd
AND
CASE
	WHEN pos_end = '0001-01-02' THEN '9999-01-01'
	ELSE pos_end
END BETWEEN @FinancialMonthStart AND '9999-01-01'
/*
/* FTE */
SELECT
	'FTE'
   ,Division
   ,0 HeacountRetail
   ,0 HeadCountSupportOffice
   ,0 HeadCountTotal
   ,COALESCE(SUM(CASE
		WHEN PayInterval = 'M' AND
			POSITION <> 'RSTR' THEN ROUND(WorkedHours / @MonthlyPayHours, 2)
	END),0) AS 'SupportOffice'
   ,COALESCE(SUM(CASE
		WHEN PayInterval = 'F' AND
			Position = 'RSTR' THEN CAST(WorkedHours / @FortnightlyPayHours AS DECIMAL(19, 2))
	END),0) AS 'Retail'
   ,COALESCE(SUM(CASE
		WHEN PayInterval = 'M' AND
			POSITION <> 'RSTR' THEN ROUND(WorkedHours / @MonthlyPayHours, 2)
	END),0) +
	COALESCE(SUM(CASE
		WHEN PayInterval = 'F' AND
			Position = 'RSTR' THEN CAST(WorkedHours / @FortnightlyPayHours AS DECIMAL(19, 2))
	END),0) AS 'TotalFTE'
   ,'B' AS SortOrder
FROM (
*/
SELECT
		CAST(EMPIT.DET_NUMBER AS VARCHAR(10)) AS DET_NUMBER
		,se.DET_G1_NAME1
		,se.DET_SURNAME
	   ,Staging_PRRUN.RCN_INTERVAL AS PayInterval
	   ,SUM(EMPIT.PIT_HOURS) AS WorkedHours
	   ,ROUND((SUM(EMPIT.PIT_HOURS) / 174.8), 2) AS FTE_Total
		--	,Staging_PRRUN.RCN_PAY_TYPE01 AS PayType
	   ,EmpDivPos.DivisionName AS Division
	   ,EmpDivPos.Position AS 'Position'
	FROM Chris21_DWH.dbo.EMPIT -- Look at all payruns as you don't know if they are running prior periods
	INNER JOIN Chris21_DWH.dbo.Staging_PRRUN
		ON Staging_PRRUN.RCN_RUN_NO = EMPIT.PIT_RUN_NO
	INNER JOIN DataWarehouse.dbo.DimDate
		ON DimDate.CalendarDate = Staging_PRRUN.RCN_PAY_DATE
	INNER JOIN #EmpDivPos EmpDivPos
		ON EmpDivPos.Employee = EMPIT.DET_NUMBER
	INNER JOIN dbo.Staging_EMDET se ON se.DET_NUMBER = dbo.EMPIT.DET_NUMBER
	WHERE 1 = 1
	AND EMPIT.PIT_RUN_NO != 'STUP'
	AND EMPIT.PIT_CODE IN ('ORD', 'PERS', 'ANN', 'CARE', 'CMP', 'JURY', 'LSL', 'LWOP', 'PAR', 'STC', 'STU', 'TIL', 'UPER', 'UWCM', 'WCM', 'SAL', 'SAL+', 'PHOL')
	AND DimDate.FinancialMonthId = 101
	AND Staging_PRRUN.RCN_PAY_DATE BETWEEN DimDate.FinancialMonthStart AND DimDate.FinancialMonthEnd
--	AND EmpDivPos.Division IN ('BB')
	--AND Staging_PRRUN.RCN_PAY_TYPE01 != '' -- not an anciliary pay
/*	and EMPIT.DET_NUMBER IN (
'04592'
,'04593'
,'04596'
,'04597'
,'04626'
,'04630'
,'04655'
,'04706'
,'04732'
,'04946'
)*/
	GROUP BY EMPIT.DET_NUMBER
			,se.DET_G1_NAME1
		,se.DET_SURNAME
			,Staging_PRRUN.RCN_INTERVAL
			 --			,Staging_PRRUN.RCN_PAY_TYPE01
			,EmpDivPos.DivisionName
			,EmpDivPos.Position
/*			
			) FTE_Hours
GROUP BY Division
*/

-- SELECT * FROM #EmpDivPos edp WHERE edp.Position = 'RETS'