IF OBJECT_ID('tempdb..#Dates') IS NOT NULL
DROP TABLE #Dates
IF OBJECT_ID('tempdb..#BaseResultset') IS NOT NULL
DROP TABLE #BaseResultset;


DECLARE @ReportDate INT
DECLARE @BusinessDivision Varchar(12)
SET @ReportDate = 101
SET @BusinessDivision = 'REV'


DECLARE @ReportingPeriodId INT
SET @ReportingPeriodId = @ReportDate

DECLARE @ReportingMonthNumber INT
DECLARE @CurrentFinancialMonthStart Date
DECLARE @CurrentFinancialMonthEnd Date
DECLARE @CurrentFinancialYearId INT

/* YTD */
DECLARE @CurrentFinancialYearStart Date

/* Last Year YTD */
DECLARE @LyFinancialYearStart Date
DECLARE @LyFinancialMonthEnd Date
DECLARE @LyFinancialYearId INT

DECLARE @FortnightlyPayHours FLOAT
DECLARE @MonthlyPayHours  FLOAT

/* Dates needed for the turnover report
 - MTD is report month start and end
 - YTD is start of current FY to end of report month
 - LYTD is start of LAST FY to end of report month LAST YEAR
 - LTM is report month last year + 1 to end of current report month
 */
DECLARE @ReportingPeriod INT
DECLARE @FinancialMonthStart Date
DECLARE @FinancialMonthEnd Date

DECLARE @FinancialYearStart Date

DECLARE @LastFinancialYear INT
DECLARE @LastFinancialYearStart Date
DECLARE @LastFinancialYearMonthEnd Date

DECLARE @LtmStart Date
DECLARE @LtmEnd Date

SET @ReportingMonthNumber = (SELECT TOP 1
		FinancialMonth
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

/* YTD */
SET @CurrentFinancialYearStart = (SELECT TOP 1
		FinancialYearStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialYearId = @CurrentFinancialYearId)

/* Current Year */
SET @CurrentFinancialMonthStart = (SELECT TOP 1
		FinancialMonthStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @CurrentFinancialMonthEnd = (SELECT TOP 1
		FinancialMonthEnd
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @CurrentFinancialYearId = (SELECT TOP 1
		FinancialYearId
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

/* Last Year */
SET @LyFinancialYearId = @CurrentFinancialYearId - 1

SET @LyFinancialYearStart = (SELECT TOP 1
		FinancialYearStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialYearId = @LyFinancialYearId)

SET @LyFinancialMonthEnd = (SELECT TOP 1
		FinancialMonthEnd
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonth = @ReportingMonthNumber
	AND FinancialYearId = @LyFinancialYearId)

SET @ReportingPeriod = (SELECT DISTINCT
		FinancialMonth
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @FinancialMonthStart = (SELECT DISTINCT
		FinancialMonthStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @FinancialMonthEnd = (SELECT DISTINCT
		FinancialMonthEnd
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @FinancialYearStart = (SELECT DISTINCT
		FinancialYearStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)

SET @LastFinancialYear = ((SELECT DISTINCT
		FinancialYear
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId)
- 1)

SET @LastFinancialYearStart = (SELECT DISTINCT
		FinancialYearStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialYear = @LastFinancialYear)

SET @LastFinancialYearMonthEnd = (SELECT DISTINCT
		FinancialMonthEnd
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialYear = @LastFinancialYear
	AND FinancialMonth = @ReportingPeriod)

SET @LtmStart = (SELECT DISTINCT
		FinancialMonthStart
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId - 12)

SET @LtmEnd = (SELECT DISTINCT
		FinancialMonthEnd
	FROM DataWarehouse.dbo.DimDate
	WHERE FinancialMonthId = @ReportingPeriodId - 1)

----SELECT * FROM DataWarehouse.dbo.DimDate where  FinancialMonthId = 90 FinancialMonthEnd = '30-Jun-2017'
PRINT @ReportingMonthNumber
PRINT @CurrentFinancialYearStart
PRINT @CurrentFinancialMonthStart
PRINT @CurrentFinancialMonthEnd
PRINT @CurrentFinancialYearId
PRINT @LyFinancialYearId
PRINT @LyFinancialYearStart
PRINT @LyFinancialMonthEnd

PRINT 'Report PeriodId ' + Convert(varchar(12),@ReportingPeriodId)
PRINT 'Report Period ' + Convert(varchar(12),@ReportingPeriod)
PRINT 'Financial Month Start ' + Convert(varchar(12),@FinancialMonthStart)
PRINT 'Financial Month End ' + Convert(varchar(12),@FinancialMonthEnd)
PRINT 'Financial Year Start ' + Convert(varchar(12),@FinancialYearStart)
PRINT 'Last Financial Year ' + Convert(varchar(12), @LastFinancialYear)
PRINT 'Last Financial Year Start ' + convert(varchar(12), @LastFinancialYearStart)
PRINT 'Last Financial Year Month End ' + convert(varchar(12), @LastFinancialYearMonthEnd)
PRINT 'LTM Start ' + convert(varchar(12), @LtmStart)
PRINT 'LTM End ' + convert(varchar(12), @LtmEnd)


SELECT
	* INTO #Dates
FROM dbo.GetFinancialReportingDatesInclLTM(@FinancialMonthEnd)

--Generate a base table of rows
SELECT DISTINCT
	Division
   ,CASE Position
		WHEN 'RSTR' THEN 'Retail'
		ELSE 'SupportOffice'
	END AS Position
   ,CASE
		WHEN TerminationTypes.TerminationType IN ('VR', 'NS', 'A', 'NW', 'E') THEN 'Voluntary'
		WHEN TerminationTypes.TerminationType IN ('TR', 'CE', 'D', 'I') THEN 'Other'
		WHEN TerminationTypes.TerminationType NOT IN ('VR', 'NS', 'A', 'NW', 'E', 'TR', 'CE', 'D', 'I') THEN 'InVoluntary'
	END AS TerminationType INTO #BaseResultset
FROM (SELECT DISTINCT
		POS_L1_CD AS Division
	   ,POS_L4_CD AS Position
     ,POS_L5_CD AS Location
	FROM Staging_EMPOS) AS A
CROSS JOIN (SELECT DISTINCT
		TER_REAS_CD AS TerminationType
	FROM Staging_EMTER) TerminationTypes
WHERE Division IN (@BusinessDivision)

UNION ALL

SELECT DISTINCT
	Division
   ,CASE Position
		WHEN 'RSTR' THEN 'Retail'
		ELSE 'SupportOffice'
	END AS Position
   ,'Total' AS TerminationType --INTO #BaseResultset
FROM (SELECT DISTINCT
		POS_L1_CD AS Division
	   ,POS_L4_CD AS Position
	FROM Staging_EMPOS) AS A
WHERE Division IN (@BusinessDivision)

SELECT
	@ReportingPeriod 'ReportingPeriod'
   ,@ReportingPeriodId 'ReportingPeriodId'
   ,Termination.Division
   ,HeadCountMTD.DivisionName
   ,Termination.Position
   ,Termination.TerminationType
   ,Termination.MTD
   ,CASE
		WHEN Termination.Position = 'Retail' THEN HeadCountMTD.HeadCountRetail
		WHEN Termination.Position = 'SupportOffice' THEN HeadCountMTD.HeadCountSupportOffice
	END MtdHeadCount
   ,HeadCountMTD.HeadCountMtdTotal
   ,@FinancialMonthStart 'MTD StartDate'
   ,@FinancialMonthEnd 'MTD EndDate'
   ,Termination.YTD
   ,CASE
		WHEN Termination.Position = 'Retail' THEN HeadCountMTD.HeadCountYTDRetail
		WHEN Termination.Position = 'SupportOffice' THEN HeadCountMTD.HeadCountYTDSupportOffice
	END YTDHeadCount
   ,HeadCountMTD.HeadCountYtdTotal
   ,@FinancialYearStart 'YTD StartDate'
   ,@FinancialMonthEnd 'YTD EndDate'
   ,Termination.LYTD
   ,CASE
		WHEN Termination.Position = 'Retail' THEN HeadCountMTD.HeadCountLastYtdRetail
		WHEN Termination.Position = 'SupportOffice' THEN HeadCountMTD.HeadCountLastYtdSupportOffice
	END LastYtdHeadCount
   ,HeadCountMTD.HeadCountLastYtdTotal
   ,@LastFinancialYearStart 'LY StartDate'
   ,@LastFinancialYearMonthEnd 'LY EndDate'
   ,Termination.LTM
   ,CASE
		WHEN Termination.Position = 'Retail' THEN HeadCountMTD.HeadCountLtmRetail
		WHEN Termination.Position = 'SupportOffice' THEN HeadCountMTD.HeadCountLtmSupportOffice
	END LtmHeadCount
   ,HeadCountMTD.HeadCountLtmTotal
   ,@LtmStart 'LTM StartDate'
   ,@LtmEnd 'LTM EndDate'
FROM (SELECT
		#BaseResultset.Division
	   ,#BaseResultset.Position
	   ,#BaseResultset.TerminationType
	   ,COALESCE(Results.MTD, 0) AS MTD
	   ,COALESCE(Results.YTD, 0) AS YTD
	   ,COALESCE(Results.LYTD, 0) AS LYTD
	   ,COALESCE(Results.LTM, 0) AS LTM
	FROM #BaseResultset
	LEFT OUTER JOIN (SELECT DISTINCT
			Staging_EMPOS.POS_L1_CD AS Division
		   ,CASE
				WHEN Staging_EMPOS.POS_L4_CD <> 'RSTR' THEN 'SupportOffice'
				WHEN Staging_EMPOS.POS_L4_CD = 'RSTR' THEN 'Retail'
			END AS 'Position'
		   ,CASE
				WHEN Staging_EMTER.TER_REAS_CD IN ('VR', 'NS', 'A', 'NW', 'E') THEN 'Voluntary'
				WHEN Staging_EMTER.TER_REAS_CD IN ('TR', 'CE', 'D', 'I') THEN 'Other'
				WHEN Staging_EMTER.TER_REAS_CD NOT IN ('VR', 'NS', 'A', 'NW', 'E', 'TR', 'CE', 'D', 'I') THEN 'InVoluntary'
			END AS TerminationType
		   ,ISNULL(COUNT(DISTINCT CASE
				WHEN #Dates.PeriodType = 'Month' AND
					#Dates.CurrentOrPreviousPeriod = 'Current' THEN Staging_EMDET.DET_NUMBER
			END), 0) AS 'MTD'
		   ,ISNULL(COUNT(DISTINCT CASE
				WHEN #Dates.PeriodType = 'Year' AND
					#Dates.CurrentOrPreviousPeriod = 'Current' THEN Staging_EMDET.DET_NUMBER
			END), 0) AS 'YTD'
		   ,ISNULL(COUNT(DISTINCT CASE
				WHEN #Dates.PeriodType = 'Year' AND
					#Dates.CurrentOrPreviousPeriod = 'Previous' THEN Staging_EMDET.DET_NUMBER
			END), 0) AS 'LYTD'
		   ,ISNULL(COUNT(DISTINCT CASE
				WHEN #Dates.PeriodType = 'LTM' AND
					#Dates.CurrentOrPreviousPeriod = 'Previous' THEN Staging_EMDET.DET_NUMBER
			END), 0) AS 'LTM'
		FROM Chris21_DWH.dbo.Staging_EMDET
		INNER JOIN Chris21_DWH.dbo.Staging_EMTER
			ON Staging_EMTER.DET_NUMBER = Staging_EMDET.DET_NUMBER
		INNER JOIN Chris21_DWH.dbo.Staging_EMPOS
			ON Staging_EMPOS.DET_NUMBER = Staging_EMDET.DET_NUMBER
		INNER JOIN #Dates
			ON #Dates.CalendarDate = Staging_EMDET.DET_TER_DATE
		WHERE 1 = 1
		AND (Staging_EMDET.DET_TER_DATE BETWEEN @LyFinancialYearStart AND @FinancialMonthEnd
		OR Staging_EMDET.DET_TER_DATE = '0001-01-02')
		AND Staging_EMDET.DET_NUMBER != '9999'
		AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%'
		AND Staging_EMPOS.POS_L1_CD IN (@BusinessDivision)
		GROUP BY Staging_EMPOS.POS_L1_CD
				,CASE
					 WHEN Staging_EMPOS.POS_L4_CD <> 'RSTR' THEN 'SupportOffice'
					 WHEN Staging_EMPOS.POS_L4_CD = 'RSTR' THEN 'Retail'
				 END
				,CASE
					 WHEN Staging_EMTER.TER_REAS_CD IN ('VR', 'NS', 'A', 'NW', 'E') THEN 'Voluntary'
					 WHEN Staging_EMTER.TER_REAS_CD IN ('TR', 'CE', 'D', 'I') THEN 'Other'
					 WHEN Staging_EMTER.TER_REAS_CD NOT IN ('VR', 'NS', 'A', 'NW', 'E', 'TR', 'CE', 'D', 'I') THEN 'InVoluntary'
				 END) Results
		ON Results.Division = #BaseResultset.Division
		AND Results.Position = #BaseResultset.Position
		AND Results.TerminationType = #BaseResultset.TerminationType) Termination
LEFT JOIN (SELECT
		'HeadCount' AS Measure
	   ,HeadCount.Division
	   ,HeadCount.DivisionName AS 'DivisionName'
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
		END) AS 'HeadCountMtdTotal'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position <> 'RSTR' AND
				HeadCount.JoinedDate <= @FinancialMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @FinancialYearStart) THEN HeadCount.employee
		END) AS 'HeadCountYTDSupportOffice'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position = 'RSTR' AND
				HeadCount.JoinedDate <= @FinancialMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @FinancialYearStart) THEN HeadCount.employee
		END) AS 'HeadCountYTDRetail'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position <> 'RSTR' AND
				HeadCount.JoinedDate <= @FinancialMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @FinancialYearStart) THEN HeadCount.employee
		END)
		+
		COUNT(DISTINCT CASE
			WHEN HeadCount.Position = 'RSTR' AND
				HeadCount.JoinedDate <= @FinancialMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @FinancialYearStart) THEN HeadCount.employee
		END) AS 'HeadCountYtdTotal'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position <> 'RSTR' AND
				HeadCount.JoinedDate <= @LastFinancialYearMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LastFinancialYearStart) THEN HeadCount.employee
		END) AS 'HeadCountLastYtdSupportOffice'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position = 'RSTR' AND
				HeadCount.JoinedDate <= @LastFinancialYearMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LastFinancialYearStart) THEN HeadCount.employee
		END) AS 'HeadCountLastYtdRetail'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position <> 'RSTR' AND
				HeadCount.JoinedDate <= @LastFinancialYearMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LastFinancialYearStart) THEN HeadCount.employee
		END)
		+
		COUNT(DISTINCT CASE
			WHEN HeadCount.Position = 'RSTR' AND
				HeadCount.JoinedDate <= @LastFinancialYearMonthEnd AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LastFinancialYearStart) THEN HeadCount.employee
		END) AS 'HeadCountLastYtdTotal'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position <> 'RSTR' AND
				HeadCount.JoinedDate <= @LtmStart AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LtmStart) THEN HeadCount.employee
		END) AS 'HeadCountLtmSupportOffice'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position = 'RSTR' AND
				HeadCount.JoinedDate <= @LtmStart AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LtmStart) THEN HeadCount.employee
		END) AS 'HeadCountLtmRetail'

	   ,COUNT(DISTINCT CASE
			WHEN HeadCount.Position <> 'RSTR' AND
				HeadCount.JoinedDate <= @LtmStart AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LtmStart) THEN HeadCount.employee
		END)
		+
		COUNT(DISTINCT CASE
			WHEN HeadCount.Position = 'RSTR' AND
				HeadCount.JoinedDate <= @LtmStart AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= @LtmStart) THEN HeadCount.employee
		END) AS 'HeadCountLtmTotal'

	FROM (SELECT DISTINCT
			Staging_EMDET.DET_NUMBER AS 'Employee'
		   ,Staging_ORGNA.GNA_ORG_CODE AS Division
		   ,Staging_ORGNA.GNA_ORG_NAME AS DivisionName
		   ,Staging_EMPOS.POS_L4_CD AS 'Position'
		   ,Staging_EMDET.DET_DATE_JND AS 'JoinedDate'
		   ,Staging_EMDET.DET_TER_DATE AS 'TerminationDate'
		--   ,Staging_EMPOS.POS_END AS 'PositionEnd'
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
			OR Staging_EMDET.DET_TER_DATE >= @LtmStart))
		AND Staging_ORGNA.GNA_ORG_CODE IN (@BusinessDivision)
		AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%') HeadCount
	GROUP BY HeadCount.Division
			,HeadCount.DivisionName) AS HeadCountMTD
	ON HeadCountMTD.Division = Termination.Division
ORDER BY 1, 2


-- SELECT * from #Dates where periodtype = 'Year' and currentorpreviousperiod = 'previous'