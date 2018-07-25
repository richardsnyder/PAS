IF OBJECT_ID('tempdb..#EmpDivPos') IS NOT NULL
DROP TABLE #EmpDivPos

DECLARE @ReportDate INT
DECLARE @BusinessDivision Varchar(12)
SET @ReportDate = 103
SET @BusinessDivision = 'PASL'

DECLARE @ReportingPeriodId INT
DECLARE @FinancialMonthStart Date
DECLARE @FinancialMonthEnd Date
DECLARE @FortnightlyPayHours FLOAT
DECLARE @MonthlyPayHours  FLOAT

SET @ReportingPeriodId = 103

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

SELECT
	'LeaveLiability' AS Measure
   ,LeaveLiability.Division
   ,CAST(COALESCE(LeaveLiability.HeadCountSupportOffice, 0) AS DECIMAL(18, 4)) 'HeadCountSupportOffice'
   ,CAST(COALESCE(LeaveLiability.HeadCountRetail, 0) AS DECIMAL(18, 4)) AS 'HeadCountRetail'
   ,CAST(COALESCE(HeadCountRetail + HeadCountSupportOffice, 0) AS DECIMAL(18, 4)) AS 'HeadCountTotal'
   ,CAST(LeaveLiability.SupportOffice AS DECIMAL(18, 4)) AS 'SupportOffice'
   ,CAST(LeaveLiability.Retail AS DECIMAL(18, 4)) AS 'Retail'
   ,CAST(LeaveLiability.TotalLeaveLiability AS DECIMAL(18, 4)) AS 'TotalLeaveLiability'
   ,LeaveLiability.SortOrder
FROM (SELECT
		'LeaveLiability' AS Measure
	   ,LeaveLiability.Division
	   ,COUNT(CASE
			WHEN LeaveLiability.Position <> 'Retail' THEN LeaveLiability.employee
		END) AS 'SupportOffice'
	   ,COUNT(CASE
			WHEN LeaveLiability.Position = 'Retail' THEN LeaveLiability.employee
		END) AS 'Retail'
	   ,HeadCount.Retail HeadCountRetail
	   ,HeadCount.SupportOffice HeadCountSupportOffice
	   ,COUNT(LeaveLiability.employee) AS 'TotalLeaveLiability'
	   ,'C' AS SortOrder
	FROM (SELECT
			Staging_EMLAC.DET_NUMBER AS 'Employee'
		   ,EmpDivPos.DivisionName AS 'Division'
		   ,CASE
				WHEN EmpDivPos.Position <> 'RSTR' THEN 'SupportOffice'
				WHEN EmpDivPos.Position = 'RSTR' THEN 'Retail'
			END AS 'Position'
		   ,SUM(Staging_EMLAC.LAC_CUR_AC_H + Staging_EMLAC.LAC_CUR_EN_H) AS 'Liability'
		FROM Chris21_DWH.dbo.Staging_EMLAC
		INNER JOIN Staging_EMDET
			ON Staging_EMDET.DET_NUMBER = Staging_EMLAC.DET_NUMBER
		INNER JOIN #EmpDivPos EmpDivPos
			ON EmpDivPos.Employee = Staging_EMLAC.DET_NUMBER
		WHERE 1 = 1
		AND Staging_EMLAC.LAC_LVE_TYPE = 'ANN'
		AND Staging_EMLAC.DET_NUMBER <> '9999'
		AND Staging_EMDET.DET_TER_DATE = '0001-01-02'
		AND EmpDivPos.Division IN (@BusinessDivision)
		GROUP BY Staging_EMLAC.DET_NUMBER
				,EmpDivPos.DivisionName
				,EmpDivPos.Position
				,Staging_EMLAC.LAC_CUR_AC_H
				,Staging_EMLAC.LAC_CUR_EN_H
		HAVING SUM(Staging_EMLAC.LAC_CUR_AC_H + Staging_EMLAC.LAC_CUR_EN_H) >= 152) LeaveLiability
	INNER JOIN (SELECT
			'HeadCount' AS Measure
		   ,HeadCount.Division
		   ,COUNT(DISTINCT CASE
				WHEN HeadCount.Position <> 'RSTR' AND
					HeadCount.JoinedDate <= @FinancialMonthEnd AND
					(HeadCount.TerminationDate = '0001-01-02' OR
					HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
			END) AS 'SupportOffice'
		   ,COUNT(DISTINCT CASE
				WHEN HeadCount.Position = 'RSTR' AND
					HeadCount.JoinedDate <= @FinancialMonthEnd AND
					(HeadCount.TerminationDate = '0001-01-02' OR
					HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
			END) AS 'Retail'
		FROM (SELECT DISTINCT
				Staging_EMDET.DET_NUMBER AS 'Employee'
			   ,Staging_ORGNA.GNA_ORG_NAME AS Division
			   ,Staging_EMPOS.POS_L4_CD AS 'Position'
			   ,CAST(Staging_EMDET.DET_DATE_JND AS DATE) AS 'JoinedDate'
			   ,CAST(Staging_EMDET.DET_TER_DATE AS DATE) AS 'TerminationDate'
			   ,Staging_EMPOS.POS_END AS 'PositionEnd'
			FROM Chris21_DWH.dbo.Staging_EMDET
			INNER JOIN Chris21_DWH.dbo.Staging_EMPOS
				ON Staging_EMPOS.DET_NUMBER = Staging_EMDET.DET_NUMBER
			INNER JOIN Staging_ORGNA
				ON Staging_ORGNA.GNA_ORG_CODE = Staging_EMPOS.POS_L1_CD
			WHERE 1 = 1
			AND Staging_EMPOS.DET_NUMBER IN (SELECT DISTINCT
					Staging_EMDET.DET_NUMBER
				FROM Staging_EMDET
				WHERE (Staging_EMDET.DET_TER_DATE = '0001-01-02'
				OR CAST(Staging_EMDET.DET_TER_DATE AS DATE) >= '01-Jul-2018'))
			AND Staging_EMDET.DET_NUMBER != '9999'
			AND Staging_EMPOS.POS_L1_CD IN ('PASL')
			AND Staging_ORGNA.GNA_SEC_LVL = 1
			AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%') HeadCount
		GROUP BY HeadCount.Division) HeadCount
		ON HeadCount.Division = LeaveLiability.Division
	GROUP BY LeaveLiability.Division
			,HeadCount.Division
			,HeadCount.Retail
			,HeadCount.SupportOffice) LeaveLiability
