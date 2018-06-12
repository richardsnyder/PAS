SELECT HeadCount.Division
			,HeadCount.DivisionName
      ,HeadCount.Position
      ,HeadCount.PositionTitle
      ,HeadCount.Location
      ,COUNT(DISTINCT CASE
			WHEN HeadCount.JoinedDate <= '31-May-2018' AND
				(HeadCount.TerminationDate = '0001-01-02' OR
				HeadCount.TerminationDate >= '01-May-2018') THEN HeadCount.employee
		END) AS 'HeadCountMtd'
FROM (
SELECT DISTINCT
			Staging_EMDET.DET_NUMBER AS 'Employee'
       ,Staging_ORGNA.GNA_ORG_CODE AS Division
       ,Staging_ORGNA.GNA_ORG_NAME AS DivisionName
       ,Staging_EMPOS.POS_L4_CD AS 'Position'
       ,Staging_EMPOS.POS_TITLE AS PositionTitle
       ,Staging_EMPOS.POS_L5_CD AS Location
       ,Staging_EMDET.DET_DATE_JND AS 'JoinedDate'
       ,Staging_EMDET.DET_TER_DATE AS 'TerminationDate'
		--   ,Staging_EMPOS.POS_END AS 'PositionEnd'
		FROM Chris21_DWH.dbo.Staging_EMDET
		INNER JOIN Chris21_DWH.dbo.Staging_EMPOS
			ON Staging_EMPOS.DET_NUMBER = Staging_EMDET.DET_NUMBER
		INNER JOIN dbo.Staging_ORGNA
			ON Staging_ORGNA.GNA_ORG_CODE = Staging_EMPOS.POS_L1_CD
		WHERE 1 = 1
		AND Staging_EMPOS.DET_NUMBER IN (SELECT DISTINCT
				Staging_EMDET.DET_NUMBER
			FROM dbo.Staging_EMDET
			WHERE (Staging_EMDET.DET_TER_DATE = '0001-01-02'
			OR Staging_EMDET.DET_TER_DATE >= '01-Jun-2017'))
		AND Staging_ORGNA.GNA_ORG_CODE IN ('REV')
		AND Staging_EMDET.DET_NUMBER NOT LIKE 'H%') Headcount
    GROUP BY HeadCount.Division
			,HeadCount.DivisionName
      ,HeadCount.Position
      ,HeadCount.PositionTitle
      ,HeadCount.Location

