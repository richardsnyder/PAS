DECLARE @StageData TABLE (
  DET_NUMBER VARCHAR(7) NULL
 ,Alternative_DET_NUMBER VARCHAR(31) NULL
 ,LEGACY_DET_NUMBER VARCHAR(7) NULL
 ,Title VARCHAR(4) NULL
 ,Surname VARCHAR(24) NULL
 ,FirstName VARCHAR(20) NULL
 ,MiddleName VARCHAR(20) NULL
 ,MiddleName2 VARCHAR(20) NULL
 ,Surname_Initials VARCHAR(31) NULL
 ,DateJoined NVARCHAR(10) NULL
 ,TerminationDate NVARCHAR(10) NULL
 ,Birthdate NVARCHAR(10) NULL
 ,Gender VARCHAR(1) NULL
 ,Email VARCHAR(100) NULL
 ,MobileNumber VARCHAR(20) NULL
 ,Country VARCHAR(10) NULL
 ,PayType VARCHAR(3) NULL
 ,PaySlipType VARCHAR(4) NULL
 ,EDE_KTS_TYPE VARCHAR(3) NULL
 ,DET_GSU_IND VARCHAR(1) NULL
 ,PayInterval VARCHAR(1) NULL
 ,PayCompany VARCHAR(10) NULL
 ,Pay_PayType VARCHAR(2) NULL
 ,PayDateClear DATE NULL
)

INSERT INTO @StageData (DET_NUMBER
, Alternative_DET_NUMBER
, LEGACY_DET_NUMBER
, Title
, Surname
, FirstName
, MiddleName
, MiddleName2
, Surname_Initials
, DateJoined
, TerminationDate
, Birthdate
, Gender
, Email
, MobileNumber
, Country
, PayTYpe
, PaySlipType
, EDE_KTS_TYPE
, DET_GSU_IND
 ,PayInterval
 ,PayCompany
 ,Pay_PayType
 ,PayDateClear)

  SELECT
    Staging_EMDET.DET_NUMBER
   ,Staging_EMDET.DET_ALT_NBR
   ,Staging_EMDET.DET_WOL_NUM
   ,Staging_EMDET.DET_TITLE
   ,Staging_EMDET.DET_SURNAME
   ,Staging_EMDET.DET_G1_NAME1
   ,Staging_EMDET.DET_G1_NAME2
   ,Staging_EMDET.DET_G1_NAME3
   ,Staging_EMDET.DET_KEY_NAME
   ,Staging_EMDET.DET_DATE_JND
   ,Staging_EMDET.DET_TER_DATE
   ,Staging_EMDET.DET_BIR_DATE
   ,Staging_EMDET.DET_SEX
   ,Staging_EMDET.DET_EMAIL_AD
   ,Staging_EMDET.DET_MOBILE
   ,Staging_EMDET.DET_COUNTRY
   ,Staging_EMDET.DET_PAY_TYPE
   ,Staging_EMDET.DET_PAY_SLIP
   ,Staging_EMDET.EDE_KTS_TYPE
   ,Staging_EMDET.DET_GSU_IND
   ,Staging_EMPAY.PYD_INTERVAL
   ,Staging_EMPAY.PYD_COMPANY
   ,Staging_EMPAY.PYD_TYPE
   ,CAST(Staging_EMPAY.PYT_DATE_CLR AS DATE)
  FROM DataWarehouseChris21RawData.dbo.Staging_EMDET Staging_EMDET
  LEFT JOIN DataWarehouseChris21RawData.dbo.Staging_EMPAY Staging_EMPAY
  ON Staging_EMPAY.DET_NUMBER = Staging_EMDET.DET_NUMBER
  WHERE NULLIF(DET_TER_DATE, '0001-01-02') IS NULL OR DET_TER_DATE >= (SELECT MIN(CalendarDate) FROM DataWarehouseChris21.dbo.DimDate)


MERGE dbo.DimEmployee AS Destination USING @StageData AS Source
ON Source.DET_NUMBER = Destination.DET_NUMBER

WHEN NOT MATCHED
  THEN INSERT (DET_NUMBER
    , Alternative_DET_NUMBER
    , LEGACY_DET_NUMBER
    , Title
    , Surname
    , FirstName
    , MiddleName
    , MiddleName2
    , Surname_Initials
    , DateJoined
    , TerminationDate
    , Birthdate
    , Gender
    , Email
    , MobileNumber
    , Country
    , PayTYpe
    , PaySlipType
    , EDE_KTS_TYPE
    , DET_GSU_IND
    ,PayInterval
    ,PayCompany
    ,Pay_PayType
    ,PayDateClear
    , CreateDate
    , Createuser)
      VALUES (Source.DET_NUMBER
      , Source.Alternative_DET_NUMBER
      , Source.LEGACY_DET_NUMBER
      , Source.Title
      , Source.Surname
      , Source.FirstName
      , Source.MiddleName
      , Source.MiddleName2
      , Source.Surname_Initials
      , Source.DateJoined
      , Source.TerminationDate
      , Source.Birthdate
      , Source.Gender
      , Source.Email
      , Source.MobileNumber
      , Source.Country
      , Source.PayTYpe
      , Source.PaySlipType
      , Source.EDE_KTS_TYPE
      , Source.DET_GSU_IND
      , Source.PayInterval
      , Source.PayCompany
      , Source.Pay_PayType
      , Source.PayDateClear
      , CURRENT_TIMESTAMP
      , system_user)

WHEN MATCHED
  AND ISNULL(Source.Alternative_DET_NUMBER, '') != ISNULL(Destination.Alternative_DET_NUMBER, '')
  OR ISNULL(Source.LEGACY_DET_NUMBER, '') != ISNULL(Destination.LEGACY_DET_NUMBER, '')
  OR ISNULL(Source.Title, '') != ISNULL(Destination.Title, '')
  OR ISNULL(Source.Surname, '') != ISNULL(Destination.Surname, '')
  OR ISNULL(Source.FirstName, '') != ISNULL(Destination.FirstName, '')
  OR ISNULL(Source.MiddleName, '') != ISNULL(Destination.MiddleName, '')
  OR ISNULL(Source.MiddleName2, '') != ISNULL(Destination.MiddleName2, '')
  OR ISNULL(Source.Surname_Initials, '') != ISNULL(Destination.Surname_Initials, '')
  OR ISNULL(Source.DateJoined, '') != ISNULL(Destination.DateJoined, '')
  OR ISNULL(Source.TerminationDate, '') != ISNULL(Destination.TerminationDate, '')
  OR ISNULL(Source.Birthdate, '') != ISNULL(Destination.Birthdate, '')
  OR ISNULL(Source.Gender, '') != ISNULL(Destination.Gender, '')
  OR ISNULL(Source.Email, '') != ISNULL(Destination.Email, '')
  OR ISNULL(Source.MobileNumber, '') != ISNULL(Destination.MobileNumber, '')
  OR ISNULL(Source.Country, '') != ISNULL(Destination.Country, '')
  OR ISNULL(Source.PayTYpe, '') != ISNULL(Destination.PayTYpe, '')
  OR ISNULL(Source.PaySlipType, '') != ISNULL(Destination.PaySlipType, '')
  OR ISNULL(Source.EDE_KTS_TYPE, '') != ISNULL(Destination.EDE_KTS_TYPE, '')
  OR ISNULL(Source.DET_GSU_IND, '') != ISNULL(Destination.DET_GSU_IND, '')
  OR ISNULL(Source.PayInterval, '') != ISNULL(Destination.PayInterval, '')
  OR ISNULL(Source.PayCompany, '') != ISNULL(Destination.PayCompany, '')
  OR ISNULL(Source.Pay_PayType, '') != ISNULL(Destination.Pay_PayType, '')
  OR ISNULL(Source.PayDateClear, '') != ISNULL(Destination.PayDateClear, '')

  THEN UPDATE
    SET Destination.DET_NUMBER = Source.DET_NUMBER
       ,Destination.Alternative_DET_NUMBER = Source.Alternative_DET_NUMBER
       ,Destination.LEGACY_DET_NUMBER = Source.LEGACY_DET_NUMBER
       ,Destination.Title = Source.Title
       ,Destination.Surname = Source.Surname
       ,Destination.FirstName = Source.FirstName
       ,Destination.MiddleName = Source.MiddleName
       ,Destination.MiddleName2 = Source.MiddleName2
       ,Destination.Surname_Initials = Source.Surname_Initials
       ,Destination.DateJoined = Source.DateJoined
       ,Destination.TerminationDate = Source.TerminationDate
       ,Destination.Birthdate = Source.Birthdate
       ,Destination.Gender = Source.Gender
       ,Destination.Email = Source.Email
       ,Destination.MobileNumber = Source.MobileNumber
       ,Destination.Country = Source.Country
       ,Destination.PayTYpe = Source.PayTYpe
       ,Destination.PaySlipType = Source.PaySlipType
       ,Destination.EDE_KTS_TYPE = Source.EDE_KTS_TYPE
       ,Destination.DET_GSU_IND = Source.DET_GSU_IND
       ,Destination.PayInterval = Source.PayInterval
       ,Destination.PayCompany = Source.PayCompany
       ,Destination.Pay_PayType = Source.Pay_PayType
       ,Destination.PayDateClear = Source.PayDateClear
       ,Destination.UpdateDate = current_timestamp
       ,Destination.UpdateUser = system_user
;
