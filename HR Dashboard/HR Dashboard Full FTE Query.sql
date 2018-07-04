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

/* Can not use Chris21 to determine the number of hours as 
   the number of fortnight payruns being done are more
   than 2 or 3 per month

 (SELECT
		(COUNT(DISTINCT RCN_PAY_DATE) * 10) * 7.6 AS CycleOneHours
	FROM Chris21_DWH.dbo.Staging_PRRUN
	INNER JOIN DataWarehouse.dbo.DimDate
		ON DimDate.CalendarDate = Staging_PRRUN.RCN_PAY_DATE
	WHERE 1 = 1
	AND RCN_PAY_DATE BETWEEN DimDate.FinancialMonthStart AND DimDate.FinancialMonthEnd
	-- RCN_PAY_TYPE01 30-49 Retail Fortnight, 50-69 HOFN, 70-99 Monthly
	AND DimDate.FinancialMonthId = @ReportingPeriodId
	AND RCN_INTERVAL = 'F'   -- Fortnightly pay intervals i.e. retail staff
	AND RCN_PAY_TYPE01 <> '' -- no anciliary pays - anciliary pays do not have a pay type
)
*/

SET @MonthlyPayHours = (SELECT DISTINCT
		(COUNT(calendardate) * 7.6) AS CycleThreeHours
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId
	AND DayOfWeekId BETWEEN 1 AND 5)

SELECT DISTINCT
	Staging_EMPOS.DET_NUMBER AS 'Employee'
   ,Staging_EMPOS.POS_L1_CD AS Division
   ,Staging_ORGNA.GNA_ORG_NAME AS DivisionName
   ,Staging_EMPOS.POS_L4_CD AS 'Position' INTO #EmpDivPos
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


/*PRINT @FortNightlyPayHours
PRINT @MonthlyPayHours


print @ReportingPeriodId
PRINT @FinancialMonthStart
print @FinancialMonthEnd
*/

/* Headcount */
SELECT
	'HeadCount' AS Measure
   ,HeadCount.Division
   ,COUNT(DISTINCT CASE
		WHEN HeadCount.Position <> 'RSTR' AND
			HeadCount.JoinedDate <= @FinancialMonthEnd AND
			(HeadCount.TerminationDate = '0001-01-02' OR
			HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
	END) AS 'HeadCountSupportOffice'
   ,COUNT(DISTINCT CASE
		WHEN HeadCount.Position = 'RSTR' AND
			HeadCount.JoinedDate <= @FinancialMonthEnd AND
			(HeadCount.TerminationDate = '0001-01-02' OR
			HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
	END) AS 'HeadCountRetail'
   ,COUNT(DISTINCT CASE
		WHEN HeadCount.Position <> 'RSTR' AND
			HeadCount.JoinedDate <= @FinancialMonthEnd AND
			(HeadCount.TerminationDate = '0001-01-02' OR
			HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
	END)
	+
	COUNT(DISTINCT CASE
		WHEN HeadCount.Position = 'RSTR' AND
			HeadCount.JoinedDate <= @FinancialMonthEnd AND
			(HeadCount.TerminationDate = '0001-01-02' OR
			HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
	END) AS 'HeadCountTotal'
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
   ,COUNT(DISTINCT CASE
		WHEN HeadCount.Position <> 'RSTR' AND
			HeadCount.JoinedDate <= @FinancialMonthEnd AND
			(HeadCount.TerminationDate = '0001-01-02' OR
			HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
	END)
	+
	COUNT(DISTINCT CASE
		WHEN HeadCount.Position = 'RSTR' AND
			HeadCount.JoinedDate <= @FinancialMonthEnd AND
			(HeadCount.TerminationDate = '0001-01-02' OR
			HeadCount.TerminationDate >= @FinancialMonthStart) THEN HeadCount.employee
	END) AS 'Total'
   ,'A' AS SortOrder
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
		OR CAST(Staging_EMDET.DET_TER_DATE AS DATE) >= @FinancialMonthStart))
	AND Staging_EMDET.DET_NUMBER != '9999'
	AND Staging_EMPOS.POS_L1_CD IN (@BusinessDivision)
	AND Staging_ORGNA.GNA_SEC_LVL = 1
	AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%') HeadCount
GROUP BY HeadCount.Division

UNION ALL

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
FROM (SELECT
		CAST(EMPIT.DET_NUMBER AS VARCHAR(10)) AS DET_NUMBER
	   ,Staging_PRRUN.RCN_INTERVAL AS PayInterval
	   ,SUM(EMPIT.PIT_HOURS) AS WorkedHours
	   ,ROUND((SUM(EMPIT.PIT_HOURS) / @MonthlyPayHours), 2) AS FTE_Total
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
	WHERE 1 = 1
	AND EMPIT.PIT_RUN_NO != 'STUP'
	AND EMPIT.PIT_CODE IN ('ORD', 'PERS', 'ANN', 'CARE', 'CMP', 'JURY', 'LSL', 'LWOP', 'PAR', 'STC', 'STU', 'TIL', 'UPER', 'UWCM', 'WCM', 'SAL', 'SAL+', 'PHOL')
	AND DimDate.FinancialMonthId = @ReportingPeriodId 
	AND Staging_PRRUN.RCN_PAY_DATE BETWEEN DimDate.FinancialMonthStart AND DimDate.FinancialMonthEnd
	AND EmpDivPos.Division IN (@BusinessDivision)
	--AND Staging_PRRUN.RCN_PAY_TYPE01 != '' -- not an anciliary pay
	--and EMPIT.DET_NUMBER = '02597'
	GROUP BY EMPIT.DET_NUMBER
			,Staging_PRRUN.RCN_INTERVAL
			 --			,Staging_PRRUN.RCN_PAY_TYPE01
			,EmpDivPos.DivisionName
			,EmpDivPos.Position) FTE_Hours
GROUP BY Division

UNION ALL

/* LeaveLiability */
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
				OR CAST(Staging_EMDET.DET_TER_DATE AS DATE) >= @FinancialMonthStart))
			AND Staging_EMDET.DET_NUMBER != '9999'
			AND Staging_EMPOS.POS_L1_CD IN (@BusinessDivision)
			AND Staging_ORGNA.GNA_SEC_LVL = 1
			AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%') HeadCount
		GROUP BY HeadCount.Division) HeadCount
		ON HeadCount.Division = LeaveLiability.Division
	GROUP BY LeaveLiability.Division
			,HeadCount.Division
			,HeadCount.Retail
			,HeadCount.SupportOffice) LeaveLiability

UNION ALL

/* Absenteeism */
SELECT
	'AbsenteeismRate' AS 'Measure'
   ,Absenteeism.Division
   ,COALESCE(HeadCount.SupportOffice, 0) AS HeadcountSupportOffice
   ,COALESCE(HeadCount.Retail, 0) AS HeadcountRetail
   ,CAST(COALESCE(HeadCount.Retail + HeadCount.SupportOffice, 0) AS DECIMAL(18, 4)) AS 'HeadCountTotal'
   ,COALESCE(ROUND(SUM(CASE
		WHEN Absenteeism.Position <> 'Retail' THEN Absenteeism.LveHours
	END), 2), 0) AS 'SupportOffice'
   ,COALESCE(ROUND(SUM(CASE
		WHEN Absenteeism.Position = 'Retail' THEN Absenteeism.LveHours
	END), 2), 0) AS 'Retail'
   ,COALESCE(ROUND(SUM(Absenteeism.LveHours), 2), 0) AS TotalAbsenteeism
   ,'D' AS SortOrder
FROM (SELECT
		EmpDivPos.DivisionName AS Division
	   ,CASE
			WHEN EmpDivPos.Position <> 'RSTR' THEN 'SupportOffice'
			WHEN EmpDivPos.Position = 'RSTR' THEN 'Retail'
		END AS 'Position'
	   ,Staging_EMLVE.DET_NUMBER
	   ,Staging_EMLVE.LVE_START
	   ,Staging_EMLVE.LVE_END
	   ,Staging_EMLVE.LVE_TYPE_CD
	   ,Staging_EMLVE.LVE_HOUR_TKN AS LveHours
	FROM Chris21_DWH.dbo.Staging_EMLVE
	INNER JOIN Staging_EMDET
		ON Staging_EMDET.DET_NUMBER = Staging_EMLVE.DET_NUMBER
	INNER JOIN #EmpDivPos EmpDivPos
		ON EmpDivPos.Employee = Staging_EMLVE.DET_NUMBER
	WHERE 1 = 1
	AND (Staging_EMLVE.Lve_Start >= @FinancialMonthStart
	AND Staging_EMLVE.LVE_END <= @FinancialMonthEnd)
	AND Staging_EMLVE.LVE_TYPE_CD IN ('PERS', 'UPER', 'CARE')
	AND Staging_EMDET.DET_TER_DATE = '0001-01-02'
	AND EmpDivPos.Division IN (@BusinessDivision)) AS Absenteeism

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
			OR CAST(Staging_EMDET.DET_TER_DATE AS DATE) >= @FinancialMonthStart))
		AND Staging_EMDET.DET_NUMBER != '9999'
		AND Staging_EMPOS.POS_L1_CD IN (@BusinessDivision)
		AND Staging_ORGNA.GNA_SEC_LVL = 1
		AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%') HeadCount
	GROUP BY HeadCount.Division) HeadCount
	ON HeadCount.Division = Absenteeism.Division
GROUP BY Absenteeism.Division
		,HeadCount.Division
		,HeadCount.SupportOffice
		,HeadCount.Retail
		