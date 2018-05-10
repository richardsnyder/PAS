SELECT
	DISTINCT 'Paydates YTD' Level1
	, CASE
	  WHEN p.RetailWeek % 2 = 0 THEN CONVERT(VARCHAR(4), p.RetailYear) + ' YTD RE/BA/YT'
    ELSE CONVERT(VARCHAR(4), p.RetailYear) + ' YTD ME'
    END Level2
	, CONVERT(VARCHAR(12),p.RetailWeekEnd, 112) + ' YTD' PayDateYtd 
FROM
	dbo.DimDate p 
WHERE
	calendardate > '24-Jun-2018' 
ORDER BY 3,2