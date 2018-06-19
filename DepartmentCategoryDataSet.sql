
SELECT
DISTINCT DimDepartment.Code AS DepartmentCode
,DimDepartment.Name AS DepartmentName
,DimCategory.Code AS CategoryCode
,DimCategory.Name AS CategoryName
FROM DimDepartment
INNER JOIN DimCategory on DimCategory.DepartmentId = DimDepartment.Id
INNER JOIN DimBusinessDivision ON DimBusinessDivision.Id = DimDepartment.BusinessDivisionId
WHERE
'[Business Division].[Business Division Name].&[' + DimBusinessDivision.Name + ']' in ('[Business Division].[Business Division Name].&[Black Pepper Brands]')
order by 1,3
        