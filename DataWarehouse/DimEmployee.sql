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
 ,PayTYpe VARCHAR(3) NULL
 ,PaySlipType VARCHAR(4) NULL
 ,EDE_KTS_TYPE VARCHAR(3) NULL
 ,DET_GSU_IND VARCHAR(1) NULL
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
, DET_GSU_IND)

  SELECT
    DET_NUMBER
   ,DET_ALT_NBR
   ,DET_WOL_NUM
   ,DET_TITLE
   ,DET_SURNAME
   ,DET_G1_NAME1
   ,DET_G1_NAME2
   ,DET_G1_NAME3
   ,DET_KEY_NAME
   ,DET_DATE_JND
   ,DET_TER_DATE
   ,DET_BIR_DATE
   ,DET_SEX
   ,DET_EMAIL_AD
   ,DET_MOBILE
   ,DET_COUNTRY
   ,DET_PAY_TYPE
   ,DET_PAY_SLIP
   ,EDE_KTS_TYPE
   ,DET_GSU_IND
  FROM DataWarehouseChris21RawData.dbo.Staging_EMDET

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
       ,Destination.UpdateDate = current_timestamp
       ,Destination.UpdateUser = system_user
;
