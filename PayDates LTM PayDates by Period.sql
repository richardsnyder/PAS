DECLARE @MyCursor CURSOR 
DECLARE @KeyDate INT, @BaseYear INT, @BasePeriod INT
DECLARE @BaseTable TABLE (BasePeriodId INT, BaseYear INT, BasePeriod INT) 
DECLARE @Result TABLE (KeyDate INT, BasePeriodId INT, BaseYear INT, BasePeriod INT, LTMRetailPeriodId INT,  LtmYear INT, LtmPeriod INT) 

INSERT INTO @BaseTable
SELECT DISTINCT RetailPeriodId,RetailYear, RetailPeriod 
FROM DimDate 

BEGIN 
    SET @MyCursor = CURSOR 
    FOR 
    SELECT BasePeriodId, BaseYear, BasePeriod 
    FROM @BaseTable 
    WHERE BasePeriodId >= 98 
    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor INTO @KeyDate, @BaseYear, @BasePeriod
    WHILE @@FETCH_STATUS = 0 

    BEGIN 
        INSERT 
        INTO @Result 
        SELECT TOP 12 @KeyDate
          , ''
          ,''
          ,''
          ,BasePeriodId As LtmRetailPeriodId
          ,BaseYear AS LtmYear
          ,BasePeriod AS LtmPeriod
        FROM @BaseTable 
        WHERE BasePeriodId <= @KeyDate 
        ORDER BY BasePeriodId DESC 
        FETCH NEXT FROM @MyCursor INTO @KeyDate, @BaseYear, @BasePeriod
    END 
    CLOSE @MyCursor 
    DEALLOCATE @MyCursor 
END

Update ResultTable
SET ResultTable.BasePeriodId = ResultTable.KeyDate
,ResultTable.BaseYear = DimDate.RetailYear
,ResultTable.BasePeriod = DimDate.RetailPeriod
FROM @Result ResultTable
INNER JOIN DimDate
on DimDate.RetailPeriodId = ResultTable.KeyDate
    
SELECT DISTINCT CAST(BaseYear AS VARCHAR(4)) + '_LTM' LEVEL1
, CAST(BaseYear AS VARCHAR(4)) + '_' + CAST(Format(BasePeriod, '\P00') AS VARCHAR(3)) + '_LTM' LEVEL2
, CAST(LtmYear AS VARCHAR(4)) + '_' + CAST(Format(LtmPeriod, '\P00') AS VARCHAR(3)) LEVEL3
, CONVERT(VARCHAR(12),DimDate.RetailWeekEnd, 112) LEVEL4
FROM @Result ResultTable
INNER JOIN DimDate on DimDate.RetailPeriodId = ResultTable.LtmRetailPeriodId
ORDER BY LEVEL1,LEVEL2,3 DESC