SELECT DISTINCT
  'TOTAL' AS TotalID,
  'Total' AS TotalDesc,
  CAST(BusinessDivisionTranslation.ToCode AS VARCHAR(50)) AS PlanningDivisionID,
  CAST(BusinessDivisionTranslation.ToName AS VARCHAR(255)) AS PlanningDivisionDesc,
  CAST(COALESCE(DepartmentTranslation.ToCode, MatProduct.DepartmentCode) AS VARCHAR(50)) AS DeptID,
  CAST(DimDepartment.Name AS VARCHAR(255)) AS DeptDesc,
  CAST(COALESCE(CategoryTranslation.ToCode, MatProduct.CategoryCode) AS VARCHAR(50)) AS CategoryID,
  CAST(DimCategory.Name AS VARCHAR(255)) AS CategoryDesc,
  CAST(COALESCE(SubCategoryTranslation.ToCode, MatProduct.SubCategoryCode) AS VARCHAR(50)) AS SubCategoryID,
  CAST(DimSubCategory.Name AS VARCHAR(255)) AS SubCategoryDesc,
  CAST(dbo.FuncRemoveSpecialChars(MatProduct.StyleCode) AS VARCHAR(50)) AS StyleID,
  CAST(dbo.FuncRemoveSpecialChars(MatProduct.StyleName) AS VARCHAR(255)) AS StyleDesc,
  CAST(dbo.FuncRemoveSpecialChars(MatProduct.StyleCode) + '.' + dbo.FuncRemoveSpecialChars(MatProduct.ColourCode) AS VARCHAR(50)) AS StyleColourID,
  CAST(dbo.FuncRemoveSpecialChars(MatProduct.StyleCode) + ' - ' + dbo.FuncRemoveSpecialChars(MatProduct.StyleName) + '.' + dbo.FuncRemoveSpecialChars(MatProduct.ColourName) AS VARCHAR(255)) AS StyleColourDesc,
  CASE WHEN MatProduct.BusinessDivisionCode = 16 AND MatProduct.PatternMakerId = 17 /* DWPlanned */  THEN 'Y' ELSE 'N' END AS PlanningFlag
FROM
(
  SELECT DISTINCT
    StyleCode,
    StyleName,
    ColourCode,
    ColourName,
    CategoryCode,
    CategoryName,
    SubCategoryCode,
    SubCategoryName,
    DepartmentCode,
    DepartmentName,
    ComponentGroupCode,
    BusinessDivisionCode,
    PatternMakerId
  FROM
    dbo.MatProduct
  WHERE
    IsActive = 1
    AND TunId IS NULL
    AND BusinessDivisionCode IN ('18', '10', '26','16')
    AND ComponentGroupCode = 'FG'
    AND IsActive = 1
    AND ColourId != 1
) AS MatProduct
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS BusinessDivisionTranslation ON
  BusinessDivisionTranslation.FromValue = MatProduct.BusinessDivisionCode
  AND BusinessDivisionTranslation.FromColumn = 'BusDiv'
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS DepartmentTranslation ON
  DepartmentTranslation.FromValue = MatProduct.DepartmentCode
  And DepartmentTranslation.FromColumn = 'DeptCode'
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS CategoryTranslation ON
  CategoryTranslation.FromValue = MatProduct.CategoryCode
  AND CategoryTranslation.FromColumn = 'CategoryCode'
LEFT OUTER JOIN
  dbo.DimPlanningTranslation AS SubCategoryTranslation ON
  SubCategoryTranslation.FromValue = MatProduct.SubCategoryCode
  AND SubCategoryTranslation.FromColumn = 'SubCategoryCode'
LEFT OUTER JOIN
  dbo.DimDepartment ON
  DimDepartment.Code = COALESCE(DepartmentTranslation.ToCode, MatProduct.DepartmentCode)
LEFT OUTER JOIN
  dbo.DimCategory ON
  DimCategory.Code = COALESCE(CategoryTranslation.ToCode, MatProduct.CategoryCode)
LEFT OUTER JOIN
  dbo.DimSubCategory ON
  DimSubCategory.Code = COALESCE(SubCategoryTranslation.ToCode, MatProduct.SubCategoryCode)