WITH Terminations
AS
(
  SELECT FactTermination.EmployeeId EmployeeId
  ,FactTermination.Employee_Number EmployeeNumber
  ,DimEmployee.FirstName 
  ,DimEmployee.Surname LastName
  ,DimEmployee.DateJoined StartDate
  ,DimEmployee.TerminationDate EmployeeTermDate
  ,CAST(FactTermination.TER_DATE AS DATE) AS TerminationDate
  ,FactTermination.TER_REAS_CD TermiationReasonCode
  ,CASE
		WHEN FactTermination.TER_REAS_CD IN ('VR', 'NS', 'A', 'NW', 'E') THEN 'Voluntary'
		WHEN FactTermination.TER_REAS_CD IN ('TR', 'CE', 'D', 'I') THEN 'Other'
		WHEN FactTermination.TER_REAS_CD NOT IN ('VR', 'NS', 'A', 'NW', 'E', 'TR', 'CE', 'D', 'I') THEN 'InVoluntary'
	END AS TerminationType 
  ,FactPosition.POS_L0_CD Country
  ,FactPosition.POS_L2_CD BusinessDivisionCode
  ,FactPosition.POS_L3_CD PositionType
  ,FactPosition.POS_L4_CD PositionTypeCode
  ,FactPosition.POS_L5_CD ProfitCentreCode
  ,DimProfitCentre.Chris21_ProfitCentreName ProfitCentreName
  ,FactPosition.POS_L5_CD + FactPosition.POS_L2_CD AS ProfitCentreSourceKey
  ,FactPosition.POS_L6_CD [State]
  ,FactPosition.POS_TITLE PositionTitle
  ,FactPosition.POS_NUMBER
  ,DimAreaManager.AreaManagerId
  ,DimAreaManager.AreaManagerName
  FROM FactTermination
  INNER JOIN FactPosition
  ON FactPosition.PositionDate = FactTermination.TER_DATE
  AND FactPosition.EmployeeId = FactTermination.EmployeeId
  INNER JOIN DimEmployee 
  ON DimEmployee.Id = FactTermination.EmployeeId
  INNER JOIN dimdate
  ON DimDate.CalendarDate = FactPosition.PositionDate
  INNER JOIN DimProfitCentre
  ON DimProfitCentre.Chris21_ProfitCentreCode = FactPosition.POS_L5_CD
  AND DimProfitCentre.Chris21_BusinessDivisionCode = FactPosition.POS_L2_CD
  LEFT JOIN DimAreaManager
  ON DimAreaManager.AreaManagerId = DimProfitCentre.DataWarehouse_AreaManagerId
)

SELECT DimDate.FinancialMonthId
,Terminations.BusinessDivisionCode
,Terminations.ProfitCentreCode
,Terminations.ProfitCentreName
,Terminations.ProfitCentreCode + ' ' + Terminations.ProfitCentreName ProfitCentreNumberName
,Terminations.ProfitCentreSourceKey
,Terminations.State
,Terminations.AreaManagerId
,Terminations.AreaManagerName
,Terminations.TermiationReasonCode
,Terminations.TerminationType
--,Terminations.PositionTitle FullPositionTitle
,Case when CHARINDEX(Terminations.ProfitCentreCode + ' ' + Terminations.ProfitCentreName,Terminations.PositionTitle) = 0 
     Then Terminations.ProfitCentreCode + ' ' + Terminations.BusinessDivisionCode + ' ' + Terminations.ProfitCentreName + ' ' + Terminations.PositionTitle
     ELSE Terminations.PositionTitle
END AS FullPositionTitle
,LTRIM(RTRIM(REPLACE(Terminations.PositionTitle,Terminations.ProfitCentreCode + ' ' + Terminations.ProfitCentreName,'' ))) ShortPositionTitle
,Terminations.EmployeeId
,Terminations.EmployeeNumber
,Terminations.FirstName
,Terminations.LastName
,Terminations.StartDate
,Terminations.TerminationDate
,DATEDIFF(MONTH,Terminations.StartDate, Terminations.TerminationDate) TenureInMonths
,COUNT(Terminations.EmployeeId) CountOfTerminations
FROM Terminations
INNER JOIN DimDate
ON DimDate.CalendarDate = Terminations.TerminationDate
GROUP BY DimDate.FinancialMonthId
,Terminations.TerminationDate
,Terminations.BusinessDivisionCode
,Terminations.ProfitCentreCode
,Terminations.ProfitCentreName
,Terminations.ProfitCentreSourceKey
,Terminations.State
,Terminations.AreaManagerId
,Terminations.AreaManagerName
,Terminations.TermiationReasonCode
,Terminations.TerminationType
,Terminations.PositionTitle
,Terminations.EmployeeId
,Terminations.EmployeeNumber
,Terminations.FirstName
,Terminations.LastName
,Terminations.StartDate


--SELECT FactTermination.* FROM FactTermination
--INNER JOIN dimdate ON dimdate.CalendarDate = FactTermination.TER_DATE
--WHERE dimdate.FinancialMonthId = 55
