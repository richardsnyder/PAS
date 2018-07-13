SELECT FactTermination.EmployeeId EmployeeId
,FactTermination.Employee_Number EmployeeNumber
,CAST(FactTermination.TER_DATE AS DATE) AS TerminationDate
,FactTermination.TER_REAS_CD TermiationReasonCode
,FactPosition.POS_L0_CD Country
,FactPosition.POS_L2_CD BusinessDivisionCode
,FactPosition.POS_L3_CD PositionType
,FactPosition.POS_L4_CD PositionTypeCode
,FactPosition.POS_L5_CD ProfitCentreCode
,FactPosition.POS_L6_CD [State]
,FactPosition.POS_TITLE PositionTitle
FROM FactTermination
INNER JOIN FactPosition
ON FactPosition.PostionDate = FactTermination.TER_DATE
AND FactPosition.EmployeeId = FactTermination.EmployeeId