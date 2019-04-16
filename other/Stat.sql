USE [master]
GO
/****** Object:  Database [Stat]    Script Date: 16/04/2019 2:08:39 AM ******/
CREATE DATABASE [Stat]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SH_4227', FILENAME = N'D:\STAT_Data\SQL\MSSQL11.STAT\MSSQL\DATA\Stat.mdf' , SIZE = 2725824KB , MAXSIZE = UNLIMITED, FILEGROWTH = 51200KB )
 LOG ON 
( NAME = N'SH_4227_log', FILENAME = N'D:\STAT_Data\SQL\MSSQL11.STAT\MSSQL\DATA\Stat_log.ldf' , SIZE = 564224KB , MAXSIZE = 2048GB , FILEGROWTH = 51200KB )
GO
ALTER DATABASE [Stat] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Stat].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Stat] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Stat] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Stat] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Stat] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Stat] SET ARITHABORT OFF 
GO
ALTER DATABASE [Stat] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Stat] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Stat] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Stat] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Stat] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Stat] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Stat] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Stat] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Stat] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Stat] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Stat] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Stat] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Stat] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Stat] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Stat] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Stat] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Stat] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Stat] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Stat] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Stat] SET  MULTI_USER 
GO
ALTER DATABASE [Stat] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Stat] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Stat] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Stat] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Stat]
GO
/****** Object:  User [StatDB_DJR]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE USER [StatDB_DJR] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [PCLOUD\Distribution SH Stat SQL Database Admin Access]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE USER [PCLOUD\Distribution SH Stat SQL Database Admin Access]
GO
/****** Object:  User [NT AUTHORITY\NETWORK SERVICE]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [IIS APPPOOL\StatPool]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE USER [IIS APPPOOL\StatPool] FOR LOGIN [IIS APPPOOL\StatPool] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [StatDB_DJR]
GO
ALTER ROLE [db_owner] ADD MEMBER [PCLOUD\Distribution SH Stat SQL Database Admin Access]
GO
ALTER ROLE [db_datareader] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
ALTER ROLE [db_datareader] ADD MEMBER [IIS APPPOOL\StatPool]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [IIS APPPOOL\StatPool]
GO
/****** Object:  StoredProcedure [dbo].[ExportPDF]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ExportPDF] 
   @Id BIGINT
  ,@OutPutPath VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
  DECLARE
  @i bigint
, @init int
, @data varbinary(max) 
, @fPath varchar(max)  
, @folderPath  varchar(max) 
 
--Get Data into temp Table variable so that we can iterate over it 
DECLARE @Doctable TABLE (id int identity(1,1), [Doc_Num]  varchar(100) , [FileName]  varchar(100), [Doc_Content] varBinary(max) )
 
INSERT INTO @Doctable([Doc_Num] , [FileName],[Doc_Content])
 Select DocumentInPoolId,OriginalFileName+'.'+OriginalSuffix,a.Attachment from DocumentInPool d left join attachment a on  d.attachmentid= a.AttachmentId where DocumentInPoolId=@Id

SELECT * FROM @Doctable

SELECT @i = COUNT(1) FROM @Doctable
 
WHILE @i >= 1
BEGIN 

	SELECT 
	 @data = [Doc_Content],
	 @fPath = @OutPutPath + '\'+ [FileName],
	 @folderPath = @OutPutPath 
	FROM @Doctable WHERE id = @i
  
  EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT; -- An instace created
  EXEC sp_OASetProperty @init, 'Type', 1;  
  EXEC sp_OAMethod @init, 'Open'; -- Calling a method
  EXEC sp_OAMethod @init, 'Write', NULL, @data; -- Calling a method
  EXEC sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2; -- Calling a method
  EXEC sp_OAMethod @init, 'Close'; -- Calling a method
  EXEC sp_OADestroy @init; -- Closed the resources
 
  print 'Document Generated at - '+  @fPath   

--Reset the variables for next use
SELECT @data = NULL  
, @init = NULL
, @fPath = NULL  
, @folderPath = NULL
SET @i -= 1
END
END

GO
/****** Object:  StoredProcedure [dbo].[GetFilteredPatients]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE[dbo].[GetFilteredPatients]
	@CurrentDateTimeOffset DATETIMEOFFSET = NULL,

	@MustHaveAllConditions VARCHAR(MAX) = NULL, 
	@MustNotHaveAllConditions VARCHAR(MAX) = NULL, 
	@MustHaveAtLeastOneCondition VARCHAR(MAX) = NULL, 
	@MustNotHaveAtLeastOneCondition VARCHAR(MAX) = NULL,
	
	@MustTakeAllMedications VARCHAR(MAX) = NULL,
	@MustNotTakeAllMedications VARCHAR(MAX) = NULL,
	@MustTakeAtLeastOneMedication VARCHAR(MAX) = NULL,
	@MustNotTakeAtLeastOneMedication VARCHAR(MAX) = NULL,
	
	@MustHaveHadAllVaccinations VARCHAR(MAX) = NULL, 
	@MustNotHaveHadAllVaccinations VARCHAR(MAX) = NULL, 
	@MustHaveHadAtLeastOneVaccination VARCHAR(MAX) = NULL, 
	@MustNotHaveHadAtLeastOneVaccination VARCHAR(MAX) = NULL,
	@VaccinationDateFrom DATETIME = NULL,
	@VaccinationDateTo DATETIME = NULL,
	
	@DoBFrom DATETIME = NULL,
	@DoBTo DATETIME = NULL,
	@Postcodes VARCHAR(MAX) = NULL,
	@Genders VARCHAR(100) = NULL,
	@EliteAthleteIds VARCHAR(100) = NULL,
	@EthnicityIds VARCHAR(MAX) = NULL,
	@OccupationIds VARCHAR(MAX) = NULL,
	@HealthFundUids VARCHAR(MAX) = NULL,
	@HealthFundUninsured BIT = NULL,
	@DefaultProviderUserIds VARCHAR(MAX) = NULL,
	@AtsiStatusIds VARCHAR(100) = NULL,
	@DefaultBillCodeUids VARCHAR(MAX) = NULL,
	@PatientClassificationIds VARCHAR(MAX) = NULL,
	@EPAYes BIT = NULL,
	@DVAYes BIT = NULL,
	@DonorYes BIT = NULL,
	@PensionCardYes BIT = NULL,
	@HCCYes BIT = NULL,
	@ActivePatientsOnly BIT = NULL,
	@ExcludeDeceasedPatients BIT = NULL,
	@OverseasAddress BIT = NULL,
	@MobilePhone INT = NULL,
	@EmailAddress INT = NULL,
	@DVAType INT = NULL,
	
	@AppointmentDateFrom DATETIME = NULL,
	@AppointmentDateTo DATETIME = NULL,
	@BillingDateFrom DATETIME = NULL,
	@BillingDateTo DATETIME = NULL,
	--@AppointmentCount SMALLINT = NULL,
	@BillingCount SMALLINT = NULL,
	@AppointmentTypeIds VARCHAR(MAX)= NULL,
	@HaveHadBillingItemNumbersDateFrom DATETIME = NULL,
	@HaveHadBillingItemNumbersDateTo DATETIME = NULL,
	@HaveHadBillingItemNumbers VARCHAR(MAX)= NULL,
	@HaveNotHadBillingItemNumbersDateFrom DATETIME = NULL,
	@HaveNotHadBillingItemNumbersDateTo DATETIME = NULL,
	@HaveNotHadBillingItemNumbers VARCHAR(MAX)= NULL,
	
	@RecallDueDateFrom DATETIME = NULL,
	@RecallDueDateTo DATETIME = NULL,
	@RecallCreatedDateFrom DATETIME = NULL,
	@RecallCreatedDateTo DATETIME = NULL,
	@NotRequireCompliance BIT = NULL,
	@Complied BIT = NULL,
	@NotComplied BIT = NULL,
	@Cancelled BIT = NULL,
	@AllergyNotRecorded BIT = NULL,
	@AllergyNillKnown BIT = NULL,
	@AllergyRecorded BIT = NULL,
	
	@EDDFrom DATETIME = NULL,
	@EDDTo DATETIME = NULL,
		
    /* Smoking */
	@SmokingStatusIds VARCHAR(MAX) = NULL,
	@SmokingStartedDateFrom DATETIME = NULL,
	@SmokingStartedDateTo DATETIME = NULL,
	@SmokingStoppedDateFrom DATETIME = NULL,
	@SmokingStoppedDateTo DATETIME = NULL,
	@SmokingPreferenceIds VARCHAR(MAX) = NULL,
	@SmokingCigarettes INT = NULL,
	@MinSmokingCigarettesNumber INT = NULL,
	@MaxSmokingCigarettesNumber INT = NULL,
	@SmokingCigars INT = NULL,
	@MinSmokingCigarsNumber INT = NULL,
	@MaxSmokingCigarsNumber INT = NULL,
	@SmokingPipe INT = NULL,
	@MinSmokingPipeNumber INT = NULL,
	@MaxSmokingPipeNumber INT = NULL,

    /* Drinking */
	@DrinkingStatusIds VARCHAR(MAX) = NULL,
	@DrinkingPastStatusIds VARCHAR(MAX) = NULL,
	@DrinkingStartedDateFrom DATETIME = NULL,
	@DrinkingStartedDateTo DATETIME = NULL,
	@DrinkingStoppedDateFrom DATETIME = NULL,
	@DrinkingStoppedDateTo DATETIME = NULL,
	@MinDrinkingDrinksPerDay INT = NULL,
	@MaxDrinkingDrinksPerDay INT = NULL,
	@MinDrinkingDaysPerWeek INT = NULL,
	@MaxDrinkingDaysPerWeek INT = NULL,

    /* Recreational Drugs */
	@DrugsStatusIds VARCHAR(MAX) = NULL,

	@MinimumResultDate DATETIME = NULL,
	
	@MeasurementCategoryId1 int = NULL,
	@MinValue1 FLOAT = NULL,
	@MaxValue1 FLOAT = NULL,
		
	@MeasurementCategoryId2 int = NULL,
	@MinValue2 FLOAT = NULL,
	@MaxValue2 FLOAT = NULL,
	
	@MeasurementCategoryId3 int = NULL,
	@MinValue3 FLOAT = NULL,
	@MaxValue3 FLOAT = NULL,
	
	@MeasurementCategoryId4 int = NULL,
	@MinValue4 FLOAT = NULL,
	@MaxValue4 FLOAT = NULL,
	
	@MeasurementCategoryId5 int = NULL,
	@MinValue5 FLOAT = NULL,
	@MaxValue5 FLOAT = NULL,
	
	@MeasurementCategoryId6 int = NULL,
	@MinValue6 FLOAT = NULL,
	@MaxValue6 FLOAT = NULL,
	
	@MeasurementCategoryId7 int = NULL,
	@MinValue7 FLOAT = NULL,
	@MaxValue7 FLOAT = NULL,
	
	@MeasurementCategoryId8 int = NULL,
	@MinValue8 FLOAT = NULL,
	@MaxValue8 FLOAT = NULL,
	
	@MeasurementCategoryId9 int = NULL,
	@MinValue9 FLOAT = NULL,
	@MaxValue9 FLOAT = NULL,
	
	@MeasurementCategoryId10 int = NULL,
	@MinValue10 FLOAT = NULL,
	@MaxValue10 FLOAT = NULL,
	
	@MeasurementCategoryId11 int = NULL,
	@MinValue11 FLOAT = NULL,
	@MaxValue11 FLOAT = NULL,
	
	@MeasurementCategoryId12 int = NULL,
	@MinValue12 FLOAT = NULL,
	@MaxValue12 FLOAT = NULL,
	
	@MeasurementCategoryId13 int = NULL,
	@MinValue13 FLOAT = NULL,
	@MaxValue13 FLOAT = NULL,
	
	@MeasurementCategoryId14 int = NULL,
	@MinValue14 FLOAT = NULL,
	@MaxValue14 FLOAT = NULL,
	
	@MeasurementCategoryId15 int = NULL,
	@MinValue15 FLOAT = NULL,
	@MaxValue15 FLOAT = NULL,
	
	@PapSmearCategoryId int = NULL,
	@HaveNotHadPapSmearSince DATETIME = NULL,
	@HeightWeightMeasurementsSince DATETIME = NULL,
	@WeightMin FLOAT = NULL,
	@WeightMax FLOAT = NULL,
	@BMIMin FLOAT = NULL,
	@BMIMax FLOAT = NULL,
	@BloodPressureMeasurementsSince DATETIME = NULL,
	@SystolicMin INT = NULL,
	@SystolicMax INT = NULL,
	@DiastolicMin INT = NULL,
	@DiastolicMax INT = NULL,
	@ThinPrepCategoryId int = NULL,
	@HaveNotHadThinPrepSince DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
	SELECT PatientDebtor.Id
	FROM PatientDebtor AS PatientDebtor
	WHERE 
	PatientDebtor.PatientDebtorType = '1' --Person
	AND	
	-- Start Condition Filtering
	(
		(@MustHaveAllConditions IS NULL AND 
		 @MustNotHaveAllConditions IS NULL AND
		 @MustHaveAtLeastOneCondition IS NULL AND 
		 @MustNotHaveAtLeastOneCondition IS NULL) 
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientId FROM FilterPatientsByConditions
			(
                CAST(@CurrentDateTimeOffset AS DateTime),
				@MustHaveAllConditions, 
				@MustNotHaveAllConditions, 
				@MustHaveAtLeastOneCondition, 
				@MustNotHaveAtLeastOneCondition
			) 
		)
	)
	-- End Condition Filtering
	
	-- Start Medication Filtering	
	AND 	
	(
		(@MustTakeAllMedications IS NULL AND
		 @MustNotTakeAllMedications IS NULL AND
		 @MustTakeAtLeastOneMedication IS NULL AND
		 @MustNotTakeAtLeastOneMedication IS NULL)
		OR
		PatientDebtor.Id IN
		(	
			SELECT PatientId FROM FilterPatientsByMedications
			(
                @CurrentDateTimeOffset,
				@MustTakeAllMedications,
				@MustNotTakeAllMedications,
				@MustTakeAtLeastOneMedication,
				@MustNotTakeAtLeastOneMedication
			)  
		)
	)
	-- End Medication Filtering
	
	-- Start Vaccination Filtering
	AND 
	(
		(@MustHaveHadAllVaccinations IS NULL AND
		 @MustNotHaveHadAllVaccinations IS NULL AND
		 @MustHaveHadAtLeastOneVaccination IS NULL AND
		 @MustNotHaveHadAtLeastOneVaccination IS NULL)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientId FROM FilterPatientsByVaccinations
			(
				@MustHaveHadAllVaccinations, 
				@MustNotHaveHadAllVaccinations, 
				@MustHaveHadAtLeastOneVaccination, 
				@MustNotHaveHadAtLeastOneVaccination,
				@VaccinationDateFrom,
				@VaccinationDateTo
			) 
		)
	)
	-- End Vaccination Filtering
	
	-- Start Demographic Filtering
	AND
	(
		(
			@DoBFrom IS NULL AND
			@DoBTo IS NULL AND
			@Postcodes IS NULL AND
			@Genders IS NULL AND
			@EliteAthleteIds IS NULL AND
			@EthnicityIds IS NULL AND
			@OccupationIds IS NULL AND
			@HealthFundUids IS NULL AND
            @HealthFundUninsured IS NULL AND
			@DefaultProviderUserIds IS NULL AND
			@AtsiStatusIds IS NULL AND
			@DefaultBillCodeUids IS NULL AND
			@PatientClassificationIds IS NULL AND
			@EPAYes IS NULL AND
			@DVAYes IS NULL AND --CardType can be specified only if this is set.
			@DonorYes IS NULL AND
			@PensionCardYes IS NULL AND
			@HCCYes IS NULL AND
			@ActivePatientsOnly IS NULL AND
			@ExcludeDeceasedPatients IS NULL AND
			@OverseasAddress IS NULL AND
			@MobilePhone IS NULL AND
			@EmailAddress IS NULL AND
			@DVAType IS NULL
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsByDemographicData
			(
				@DoBFrom,
				@DoBTo,
				@Postcodes,
				@Genders,
				@EliteAthleteIds,
				@EthnicityIds,
				@OccupationIds,
				@HealthFundUids,
                @HealthFundUninsured,
				@DefaultProviderUserIds,
				@AtsiStatusIds,
				@DefaultBillCodeUids,
				@PatientClassificationIds,
				@EPAYes,
				@DVAYes,
				@DonorYes,
				@PensionCardYes,
				@HCCYes,
				@ActivePatientsOnly,
				@ExcludeDeceasedPatients,
				@OverseasAddress,
				@MobilePhone,
				@EmailAddress,
				@DVAType
			)
		)
	)
	-- End Demographic Filtering
	
	-- Start Episode Filtering
	AND
	(
		(
			--@AppointmentDateFrom IS NULL AND
			--@AppointmentDateTo IS NULL AND
			@AppointmentTypeIds IS NULL AND
			--@BillingDateFrom IS NULL AND
			--@BillingDateTo IS NULL AND
			@BillingCount IS NULL AND
			--@AppointmentCount IS NULL AND
			--@BillingCount IS NULL -- BillingCount doesn't make sense if the date range is not specified.
			@HaveHadBillingItemNumbers IS NULL AND
			@HaveNotHadBillingItemNumbers IS NULL
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsByEpisodeData
			(
				@AppointmentDateFrom,
				@AppointmentDateTo,
				@BillingDateFrom,
				@BillingDateTo,
				--@AppointmentCount,
				@BillingCount,
				@AppointmentTypeIds,
				@HaveHadBillingItemNumbersDateFrom,
				@HaveHadBillingItemNumbersDateTo,
				@HaveHadBillingItemNumbers,
				@HaveNotHadBillingItemNumbersDateFrom,
				@HaveNotHadBillingItemNumbersDateTo,
				@HaveNotHadBillingItemNumbers
			)
		)
	)
	
	-- End Episode Filtering
	
	-- Start Recalls Filtering
	AND
	(
		(
			(
				@RecallDueDateFrom IS NULL AND
				@RecallDueDateTo IS NULL AND
				@RecallCreatedDateFrom IS NULL AND
				@RecallCreatedDateTo IS NULL 
			)
			OR
			(
				@NotRequireCompliance IS NULL AND
				@Complied IS NULL AND
				@NotComplied IS NULL AND
				@Cancelled IS NULL
			)	
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsByRecallsData
			(
				@RecallDueDateFrom,
				@RecallDueDateTo,
				@RecallCreatedDateFrom,
				@RecallCreatedDateTo,
				@NotRequireCompliance,
				@Complied,
				@NotComplied,
				@Cancelled
			)
		)
	)
	
	-- End Recalls Filtering
	
	-- Start Pregnancy Filtering
	
	AND
	(	
		(
			@EDDFrom IS NULL AND
			@EDDTo IS NULL
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsByPregnancyData
			(
				@EDDFrom,
				@EDDTo
			)
		)
	)
	
	-- End Pregnancy Filtering
	
	-- Start Allergy Filter
	
	AND
	(
		((@AllergyNotRecorded IS NULL OR @AllergyNotRecorded = '0') AND
		(@AllergyNillKnown IS NULL OR @AllergyNillKnown = '0') AND
		(@AllergyRecorded IS NULL OR @AllergyRecorded = '0'))
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientId FROM FilterPatientsByClinicalData (@AllergyNotRecorded, @AllergyNillKnown, @AllergyRecorded)
		)
	)	
	
	-- End Allergy Filter
		
	-- Start Smoking Filtering
	
	AND
	(	
		(
			@SmokingStatusIds IS NULL AND
			@SmokingStartedDateFrom IS NULL AND
			@SmokingStartedDateTo IS NULL AND
			@SmokingStoppedDateFrom IS NULL AND
			@SmokingStoppedDateTo IS NULL AND
			@SmokingPreferenceIds IS NULL
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsBySmokingData
			(
	            @SmokingStatusIds,
	            @SmokingStartedDateFrom,
	            @SmokingStartedDateTo,
	            @SmokingStoppedDateFrom,
	            @SmokingStoppedDateTo,
                @SmokingPreferenceIds,
	            @SmokingCigarettes,
	            @MinSmokingCigarettesNumber,
	            @MaxSmokingCigarettesNumber,
	            @SmokingCigars,
	            @MinSmokingCigarsNumber,
	            @MaxSmokingCigarsNumber,
	            @SmokingPipe,
	            @MinSmokingPipeNumber,
	            @MaxSmokingPipeNumber
			)
		)
	)
	
	-- End Smoking Filtering
		
	-- Start Drinking Filtering
	
	AND
	(	
		(
			@DrinkingStatusIds IS NULL AND
			@DrinkingPastStatusIds IS NULL AND
			@DrinkingStartedDateFrom IS NULL AND
			@DrinkingStartedDateTo IS NULL AND
			@DrinkingStoppedDateFrom IS NULL AND
			@DrinkingStoppedDateTo IS NULL AND
			@MinDrinkingDrinksPerDay IS NULL AND
			@MaxDrinkingDrinksPerDay IS NULL AND
			@MinDrinkingDaysPerWeek IS NULL AND
			@MaxDrinkingDaysPerWeek IS NULL
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsByDrinkingData
			(
	            @DrinkingStatusIds,
	            @DrinkingPastStatusIds,
	            @DrinkingStartedDateFrom,
	            @DrinkingStartedDateTo,
	            @DrinkingStoppedDateFrom,
	            @DrinkingStoppedDateTo,
	            @MinDrinkingDrinksPerDay,
	            @MaxDrinkingDrinksPerDay,
	            @MinDrinkingDaysPerWeek,
	            @MaxDrinkingDaysPerWeek
			)
		)
	)
	
	-- End Drinking Filtering
		
	-- Start Recreational Drugs Filtering
	
	AND
	(	
		(
			@DrugsStatusIds IS NULL
		)
		OR
		PatientDebtor.Id IN
		(
			SELECT PatientID FROM FilterPatientsByRecreationalDrugsData
			(
	            @DrugsStatusIds
			)
		)
	)
	
	-- End Recreational Drugs Filtering

	-- Start Measurement Filtering
	
	AND
	(	
		(
			@MeasurementCategoryId1 IS NULL AND
			@MinValue1 IS NULL AND
			@MaxValue1 IS NULL AND
			
			@MeasurementCategoryId2 IS NULL AND
			@MinValue2 IS NULL AND
			@MaxValue2 IS NULL AND
			
			@MeasurementCategoryId3 IS NULL AND
			@MinValue3 IS NULL AND
			@MaxValue3 IS NULL AND
			
			@MeasurementCategoryId4 IS NULL AND
			@MinValue4 IS NULL AND
			@MaxValue4 IS NULL AND
			
			@MeasurementCategoryId5 IS NULL AND
			@MinValue5 IS NULL AND
			@MaxValue5 IS NULL AND
			
			@MeasurementCategoryId6 IS NULL AND
			@MinValue6 IS NULL AND
			@MaxValue6 IS NULL AND
			
			@MeasurementCategoryId7 IS NULL AND
			@MinValue7 IS NULL AND
			@MaxValue7 IS NULL AND
			
			@MeasurementCategoryId8 IS NULL AND
			@MinValue8 IS NULL AND
			@MaxValue8 IS NULL AND
			
			@MeasurementCategoryId9 IS NULL AND
			@MinValue9 IS NULL AND
			@MaxValue9 IS NULL AND
			
			@MeasurementCategoryId10 IS NULL AND
			@MinValue10 IS NULL AND
			@MaxValue10 IS NULL AND
			
			@MeasurementCategoryId11 IS NULL AND
			@MinValue11 IS NULL AND
			@MaxValue11 IS NULL AND
			
			@MeasurementCategoryId12 IS NULL AND
			@MinValue12 IS NULL AND
			@MaxValue12 IS NULL AND
			
			@MeasurementCategoryId13 IS NULL AND
			@MinValue13 IS NULL AND
			@MaxValue13 IS NULL AND
			
			@MeasurementCategoryId14 IS NULL AND
			@MinValue14 IS NULL AND
			@MaxValue14 IS NULL AND
			
			@MeasurementCategoryId15 IS NULL AND
			@MinValue15 IS NULL AND
			@MaxValue15 IS NULL AND
			
			@PapSmearCategoryId IS NULL AND
			@HaveNotHadPapSmearSince IS NULL AND
			
			@HeightWeightMeasurementsSince IS NULL AND
			@WeightMin IS NULL AND
			@WeightMax IS NULL AND
			@BMIMin IS NULL AND
			@BMIMax IS NULL AND
			
			@BloodPressureMeasurementsSince IS NULL AND
			@SystolicMin IS NULL AND
			@SystolicMax IS NULL AND
			@DiastolicMin IS NULL AND
			@DiastolicMax IS NULL AND
			
			@ThinPrepCategoryId IS NULL AND
			@HaveNotHadThinPrepSince IS NULL
		)
		OR		
		PatientDebtor.Id IN
		(
			SELECT PatientId FROM FilterPatientsByMeasurements
			(
				@MinimumResultDate,
	
				@MeasurementCategoryId1,
				@MinValue1,
				@MaxValue1,
	
				@MeasurementCategoryId2,
				@MinValue2,
				@MaxValue2,
	
				@MeasurementCategoryId3,
				@MinValue3,
				@MaxValue3,
	
				@MeasurementCategoryId4,
				@MinValue4,
				@MaxValue4,
	
				@MeasurementCategoryId5,
				@MinValue5,
				@MaxValue5,
	
				@MeasurementCategoryId6,
				@MinValue6,
				@MaxValue6,
	
				@MeasurementCategoryId7,
				@MinValue7,
				@MaxValue7,
	
				@MeasurementCategoryId8,
				@MinValue8,
				@MaxValue8,
	
				@MeasurementCategoryId9,
				@MinValue9,
				@MaxValue9,
	
				@MeasurementCategoryId10,
				@MinValue10,
				@MaxValue10,
	
				@MeasurementCategoryId11,
				@MinValue11,
				@MaxValue11,
	
				@MeasurementCategoryId12,
				@MinValue12,
				@MaxValue12,
	
				@MeasurementCategoryId13,
				@MinValue13,
				@MaxValue13,
	
				@MeasurementCategoryId14,
				@MinValue14,
				@MaxValue14,
	
				@MeasurementCategoryId15,
				@MinValue15,
				@MaxValue15,
				
				@PapSmearCategoryId,
				@HaveNotHadPapSmearSince,
				
				@HeightWeightMeasurementsSince,
				@WeightMin,
				@WeightMax,
				@BMIMin,
				@BMIMax,
				
				@BloodPressureMeasurementsSince,
				@SystolicMin,
				@SystolicMax,
				@DiastolicMin,
				@DiastolicMax,
				
				@ThinPrepCategoryId,
				@HaveNotHadThinPrepSince
			)
		)
	)
	
	-- End Measurement Filtering
END

GO
/****** Object:  UserDefinedFunction [dbo].[DelimitedParamParser]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[DelimitedParamParser]( @DelimitedIds VARCHAR(MAX), @Delimiter CHAR(1)) 
RETURNS @IdsTable 
TABLE ( Id INT ) 
AS BEGIN

DECLARE @Length INT,
        @Index INT,
        @NextIndex INT

SET @Length = DATALENGTH(@DelimitedIds)
SET @Index = 0
SET @NextIndex = 0


WHILE (@Length > @Index )
BEGIN
	SET @NextIndex = CHARINDEX(@Delimiter, @DelimitedIds, @Index)
	IF (@NextIndex = 0 ) SET @NextIndex = @Length + 2
		INSERT @IdsTable SELECT SUBSTRING( @DelimitedIds, @Index, @NextIndex - @Index )
	SET @index = @nextindex + 1
END
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[DelimitedStringParamParser]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[DelimitedStringParamParser]
( @DelimitedIds VARCHAR(MAX), @Delimiter CHAR(1)) 
RETURNS @IdsTable 
TABLE ( Id VARCHAR(50) ) 
AS BEGIN

DECLARE @Length INT,
        @Index INT,
        @NextIndex INT

SET @Length = DATALENGTH(@DelimitedIds)
SET @Index = 0
SET @NextIndex = 0
WHILE (@Length > @Index )
BEGIN
	SET @NextIndex = CHARINDEX(@Delimiter, @DelimitedIds, @Index)
	IF (@NextIndex = 0 ) SET @NextIndex = @Length + 2
		INSERT @IdsTable SELECT SUBSTRING( @DelimitedIds, @Index, @NextIndex - @Index )
	SET @index = @nextindex + 1
END
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[DelimitedStringValuePairParser]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[DelimitedStringValuePairParser]
(
    @List NVARCHAR(MAX),
    @MajorDelimiter VARCHAR(3) = ',',
    @MinorDelimiter VARCHAR(3) = ':'
)
RETURNS @Items TABLE
(
    Position  INT IDENTITY(1,1) NOT NULL,
    LeftItem  VARCHAR(3) NOT NULL,
    RightItem VARCHAR(3) NOT NULL
)
AS
BEGIN
    DECLARE
        @Item      NVARCHAR(MAX),
        @LeftItem  NVARCHAR(MAX),
        @RightItem NVARCHAR(MAX),
        @Pos       INT;

    SELECT
        @List = @List + ' ',
        @MajorDelimiter = LTRIM(RTRIM(@MajorDelimiter)),
        @MinorDelimiter = LTRIM(RTRIM(@MinorDelimiter));

    WHILE LEN(@List) > 0
    BEGIN
        SET @Pos = CHARINDEX(@MajorDelimiter, @List);

        IF @Pos = 0 
            SET @Pos = LEN(@List) + LEN(@MajorDelimiter);

        SELECT
            @Item = LTRIM(RTRIM(LEFT(@List, @Pos - 1))),
            @LeftItem = LTRIM(RTRIM(LEFT(@Item,
            CHARINDEX(@MinorDelimiter, @Item) - 1))),
            @RightItem = LTRIM(RTRIM(SUBSTRING(@Item,
            CHARINDEX(@MinorDelimiter, @Item)
            + LEN(@MinorDelimiter), LEN(@Item))));

        INSERT @Items(LeftItem, RightItem)
            SELECT @LeftItem, @RightItem;

        SET @List = SUBSTRING(@List,
            @Pos + LEN(@MajorDelimiter), DATALENGTH(@List));
    END
    RETURN;
END

GO
/****** Object:  UserDefinedFunction [dbo].[DelimitedValuePairParser]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE FUNCTION [dbo].[DelimitedValuePairParser]
(
    @List NVARCHAR(MAX),
    @MajorDelimiter VARCHAR(3) = ',',
    @MinorDelimiter VARCHAR(3) = ':'
)
RETURNS @Items TABLE
(
    Position  INT IDENTITY(1,1) NOT NULL,
    LeftItem  INT NOT NULL,
    RightItem INT NOT NULL
)
AS
BEGIN
    DECLARE
        @Item      NVARCHAR(MAX),
        @LeftItem  NVARCHAR(MAX),
        @RightItem NVARCHAR(MAX),
        @Pos       INT;

    SELECT
        @List = @List + ' ',
        @MajorDelimiter = LTRIM(RTRIM(@MajorDelimiter)),
        @MinorDelimiter = LTRIM(RTRIM(@MinorDelimiter));

    WHILE LEN(@List) > 0
    BEGIN
        SET @Pos = CHARINDEX(@MajorDelimiter, @List);

        IF @Pos = 0 
            SET @Pos = LEN(@List) + LEN(@MajorDelimiter);

        SELECT
            @Item = LTRIM(RTRIM(LEFT(@List, @Pos - 1))),
            @LeftItem = LTRIM(RTRIM(LEFT(@Item,
            CHARINDEX(@MinorDelimiter, @Item) - 1))),
            @RightItem = LTRIM(RTRIM(SUBSTRING(@Item,
            CHARINDEX(@MinorDelimiter, @Item)
            + LEN(@MinorDelimiter), LEN(@Item))));

        INSERT @Items(LeftItem, RightItem)
            SELECT @LeftItem, @RightItem;

        SET @List = SUBSTRING(@List,
            @Pos + LEN(@MajorDelimiter), DATALENGTH(@List));
    END
    RETURN;
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByAtomicResultLastTestDate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their last test date. 
-- Returns all the patients who have had the given Measurement's related tests after the given date.
-- Eg: Filter patients who have had X test after 2007/01/01.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByAtomicResultLastTestDate]
(
	@HaveHadTestAfter DATETIME = NULL,	
	@LabResultsCategoryCode int = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id 
FROM PatientDebtor
INNER JOIN statclinical.dbo.[Result] AS ClinicalResultTable
	ON	PatientDebtor.EhrUid = ClinicalResultTable.EhrUid
INNER JOIN statclinical.dbo.[ResultAtomic] AS AtomicResultTable 
	ON	ClinicalResultTable.[ClinicalResultUid] = AtomicResultTable.[ClinicalResultUid]
INNER JOIN 
(
	SELECT ResultsTable.EhrUid, MAX(CAST(ResultsTable.CollectionDateTimeOffset AS DateTime)) AS LatestDate
	FROM statclinical.dbo.[Result] AS ResultsTable
	INNER JOIN statclinical.dbo.[ResultAtomic] ON ResultsTable.[ClinicalResultUid] = [ResultAtomic].[ClinicalResultUid]
	WHERE [ResultAtomic].[LOINCIdentifier] IN (SELECT LabCode FROM [GetLabCodesByLabResultsCategoryCode](@LabResultsCategoryCode)) 
	GROUP BY ResultsTable.EhrUid
) AS ResultsTable
ON 
ResultsTable.EhrUid = PatientDebtor.EhrUid 
WHERE AtomicResultTable.[LOINCIdentifier] IN (SELECT LabCode FROM [GetLabCodesByLabResultsCategoryCode](@LabResultsCategoryCode)) AND
(@HaveHadTestAfter IS NULL OR CAST(ClinicalResultTable.CollectionDateTimeOffset AS DateTime) >= @HaveHadTestAfter)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByClinicalData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their clinical data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByClinicalData]
(
	@AllergyNotRecorded BIT = NULL,
	@AllergyNillKnown BIT = NULL,
	@AllergyRecorded BIT = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT DISTINCT PatientDebtor.Id 
					   FROM PatientDebtor
					   LEFT OUTER JOIN statclinical.dbo.Allergy ON Allergy.EhrUid = PatientDebtor.EhrUid
WHERE
(
	@AllergyNotRecorded = '1' AND 
	PatientDebtor.EhrUid NOT IN (SELECT Allergy.EhrUid FROM statclinical.dbo.Allergy)
)
OR
(
   -- Nill Known check. If a patient has only AllergyType 3(NillKnown) or all the allergies recorded are ceased.
	@AllergyNillKnown = '1' AND
	(
		PatientDebtor.EhrUid IN 
		(
			SELECT DISTINCT Allergy.EhrUid 
			FROM statclinical.dbo.Allergy 
			WHERE Allergy.AllergyType = '3' AND Allergy.VersionNumber = '0' AND Allergy.CeasedDateTime IS NULL AND Allergy.RemovedFromListDateTimeOffset IS NULL
		)
		OR
		(
			PatientDebtor.EhrUid NOT IN 
			(
				SELECT DISTINCT Allergy.EhrUid 
				FROM statclinical.dbo.Allergy 
				WHERE Allergy.CeasedDateTime IS NULL AND Allergy.VersionNumber = '0'  --AND Allergy.RemovedFromListDateTimeOffset IS NULL
				AND Allergy.AllergyType != '3' 
			)
			AND PatientDebtor.EhrUid IN --Get rid of all the patients who don't have any record in Allergy table
			(SELECT DISTINCT Allergy.EhrUid FROM statclinical.dbo.Allergy)
		)	
	)
)
OR
(
	@AllergyRecorded = '1' AND
	PatientDebtor.EhrUid IN
	(
		SELECT DISTINCT Allergy.EhrUid 
		FROM statclinical.dbo.Allergy 
		WHERE Allergy.AllergyType != '3' AND Allergy.VersionNumber = '0' AND Allergy.CeasedDateTime IS NULL AND Allergy.RemovedFromListDateTimeOffset IS NULL
	)
)
OR
(@AllergyNotRecorded = '0' AND @AllergyNillKnown = '0' AND @AllergyRecorded = '0')

 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByClinicalResultsAtomic]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their measurements.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByClinicalResultsAtomic]
(
	@MinimumResultDate DATETIME = NULL, -- Result should not be older than this date.
	@MeasurementCategoryId int = NULL,
	@NumericValueMin FLOAT = NULL,
	@NumericValueMax FLOAT = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id 
FROM PatientDebtor
INNER JOIN statclinical.dbo.[Result] AS ClinicalResultTable
	ON	PatientDebtor.EhrUid = ClinicalResultTable.EhrUid
INNER JOIN statclinical.dbo.[ResultAtomic] AS AtomicResultTable 
	ON	ClinicalResultTable.[ClinicalResultUid] = AtomicResultTable.[ClinicalResultUid]
WHERE AtomicResultTable.[LOINCIdentifier] IN (SELECT LabCode FROM [GetLabCodesByCategoryId](@MeasurementCategoryId)) AND
((@NumericValueMin IS NULL OR @NumericValueMin = 0) OR AtomicResultTable.[NumericValue] >=  @NumericValueMin) AND
((@NumericValueMax IS NULL OR @NumericValueMax = 0) OR AtomicResultTable.[NumericValue] <=  @NumericValueMax) AND
(@MinimumResultDate IS NULL OR CAST(ClinicalResultTable.CollectionDateTimeOffset AS DateTime) >= @MinimumResultDate)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByConditions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their current conditions and returns result PatientIds.

-- @MustHaveAllConditions - Patients must have all these conditions in order to satisfy the filter.
-- @MustNotHaveAllConditions - Patients must not have all of these conditions in order to satisfy the filter.
-- @MustHaveAtLeastOneCondition - Patients must have at least one of these conditions in order to satisfy the filter.
-- @MustNotHaveAtLeastOneCondition - Patients must not have at least one of these conditions in order to satisfy the filter.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByConditions]
(
@CurrentDateTime DATETIME = NULL, 
@MustHaveAllConditions VARCHAR(MAX) = NULL, 
@MustNotHaveAllConditions VARCHAR(MAX) = NULL, 
@MustHaveAtLeastOneCondition VARCHAR(MAX) = NULL, 
@MustNotHaveAtLeastOneCondition VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE 
(
	--MustHaveAllConditions Category
	@MustHaveAllConditions = '' OR @MustHaveAllConditions IS NULL OR
	PatientDebtor.Id IN 
	(
		SELECT PatientId FROM GetPatientsHaveAllConditions(@CurrentDateTime, @MustHaveAllConditions)
	)
)
AND --MustNotHaveAllConditions Filter
(
	@MustNotHaveAllConditions = '' OR @MustNotHaveAllConditions IS NULL OR
	PatientDebtor.Id NOT IN 
	(
		SELECT PatientId FROM GetPatientsHaveAllConditions(@CurrentDateTime, @MustNotHaveAllConditions)
	)
)
AND --@MustHaveAtLeastOneCondition Filter
(
	@MustHaveAtLeastOneCondition = '' OR @MustHaveAtLeastOneCondition IS NULL OR
	PatientDebtor.Id IN 
	(
		SELECT PatientId FROM GetPatientsHaveAnyCondition(@CurrentDateTime, @MustHaveAtLeastOneCondition)
	)
)
AND --@MustNotHaveAtLeastOneCondition Filter
(
	@MustNotHaveAtLeastOneCondition = '' OR @MustNotHaveAtLeastOneCondition IS NULL OR
	PatientDebtor.Id NOT IN 
	(
		SELECT PatientId FROM GetPatientsHaveAnyCondition(@CurrentDateTime, @MustNotHaveAtLeastOneCondition)
	)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByDemographicData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their demographic data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByDemographicData]
(
	@DoBFrom DATETIME = NULL,
	@DoBTo DATETIME = NULL,
	@Postcodes VARCHAR(MAX) = NULL,
	@Genders VARCHAR(100) = NULL,
	@EliteAthleteIds VARCHAR(100) = NULL,
	@EthnicityIds VARCHAR(MAX) = NULL,
	@OccupationIds VARCHAR(MAX) = NULL,
	@HealthFundUids VARCHAR(MAX) = NULL,
	@HealthFundUninsured BIT = NULL,
	@DefaultProviderUserIds VARCHAR(MAX) = NULL,
	@AtsiStatusIds VARCHAR(100) = NULL,
	@DefaultBillCodeUids VARCHAR(MAX) = NULL,
	@PatientClassificationIds VARCHAR(MAX) = NULL,	
	@EPAYes BIT = NULL,
	@DVAYes BIT = NULL,
	@DonorYes BIT = NULL,
	@PensionCardYes BIT = NULL,
	@HCCYes BIT = NULL,
	@ActivePatientsOnly BIT = NULL,
	@ExcludeDeceasedPatients BIT = NULL,
	@OverseasAddress BIT = NULL,
	@MobilePhone INT = NULL,
	@EmailAddress INT = NULL,
	@DVAType INT = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id 
					   FROM PatientDebtor
					   LEFT OUTER JOIN Address ON PatientDebtor.ResidentialAddressId = Address.Id
WHERE 
	(@DoBFrom IS NULL OR PatientDebtor.DoB >= @DoBFrom) AND
	(@DoBTo IS NULL OR PatientDebtor.DoB <= @DoBTo) AND
	(@Postcodes IS NULL OR @Postcodes = '' OR Address.Postcode IN (SELECT Id FROM DelimitedStringParamParser(@Postcodes, ','))) AND
	(@Genders IS NULL OR @Genders = '' OR PatientDebtor.Sex IN (SELECT Id FROM DelimitedParamParser(@Genders, ','))) AND
	
	-- ID for Unknown EliteAthlete is 0 and its value in the table is NULL.
	(
		@EliteAthleteIds IS NULL OR @EliteAthleteIds = '' OR 
		((PatientDebtor.EliteAthlete IN (SELECT Id FROM DelimitedParamParser(@EliteAthleteIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@EliteAthleteIds, ',')) AND PatientDebtor.EliteAthlete IS NULL))
	) 
	AND
	
	-- ID for Unknown Ethnicity is 0 and the value in the table is NULL.
	(
		@EthnicityIds IS NULL OR @EthnicityIds = '' OR
		((PatientDebtor.EthnicityId IN (SELECT Id FROM DelimitedParamParser(@EthnicityIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@EthnicityIds, ',')) AND PatientDebtor.EthnicityId IS NULL))
	) 
	AND
			
	-- ID for Unknown Occupation is 0 and the value in the table is NULL.
	(
		@OccupationIds IS NULL OR @OccupationIds = '' OR
		((PatientDebtor.Employer1OccupationId IN (SELECT Id FROM DelimitedParamParser(@OccupationIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@OccupationIds, ',')) AND PatientDebtor.Employer1OccupationId IS NULL)) OR
		((PatientDebtor.Employer2OccupationId IN (SELECT Id FROM DelimitedParamParser(@OccupationIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@OccupationIds, ',')) AND PatientDebtor.Employer2OccupationId IS NULL))
	) 
	AND

    -- Check the HealthFund OR the Uninsured flag
	-- ID for Unknown HealthFund is 00000000-0000-0000-0000-000000000000 and the value in the table is NULL.
	
	((
		(ISNULL(@HealthFundUids, '') = '' AND @HealthFundUninsured IS NULL)
	)

	OR

	(
        @HealthFundUids IS NULL OR @HealthFundUids = '' OR
		((PatientDebtor.HealthFundUid IN (SELECT Id FROM DelimitedStringParamParser(@HealthFundUids, ','))) OR 
		('00000000-0000-0000-0000-000000000000' IN (SELECT Id FROM DelimitedStringParamParser(@HealthFundUids, ','))
				AND PatientDebtor.HealthFundUid IS NULL
				AND ISNULL(PatientDebtor.HealthFundUninsured, 0) = 0))
	) 

	OR	
		
	(
		@HealthFundUninsured IS NOT NULL AND ( @HealthFundUninsured = 0 AND ISNULL(PatientDebtor.HealthFundUninsured, 0) = 0) OR (@HealthFundUninsured = 1 AND PatientDebtor.HealthFundUninsured = 1 )
	))
	AND	
	
	-- ID for Unknown DefaultProvider is 0 and the value in the table is NULL.
	(
		@DefaultProviderUserIds IS NULL OR @DefaultProviderUserIds = '' OR
		((PatientDebtor.DefaultProviderUserId IN (SELECT Id FROM DelimitedParamParser(@DefaultProviderUserIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@DefaultProviderUserIds, ',')) AND PatientDebtor.DefaultProviderUserId IS NULL))
	) 
	AND
	
	-- ID for Unknown ATSI is 0 and the value in the table is NULL.
	(
		@AtsiStatusIds IS NULL OR @AtsiStatusIds = '' OR
		((PatientDebtor.ATSI IN (SELECT Id FROM DelimitedParamParser(@AtsiStatusIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@AtsiStatusIds, ',')) AND PatientDebtor.ATSI IS NULL))
	) 
	AND
	
	-- ID for Unknown DefaultBillCode is 00000000-0000-0000-0000-000000000000 and the value in the table is NULL.
	(
		@DefaultBillCodeUids IS NULL OR @DefaultBillCodeUids = '' OR
		((PatientDebtor.DefaultBillcodeUid IN (SELECT Id FROM DelimitedStringParamParser(@DefaultBillCodeUids, ','))) OR 
		('00000000-0000-0000-0000-000000000000' IN (SELECT Id FROM DelimitedStringParamParser(@DefaultBillCodeUids, ',')) AND PatientDebtor.DefaultBillcodeUid IS NULL))
	) 
	AND
	
	-- ID for Unknown PatientClassification is 0 and the value in the table is NULL.
	(
		@PatientClassificationIds IS NULL OR @PatientClassificationIds = '' OR
		((PatientDebtor.PatientClassificationId IN (SELECT Id FROM DelimitedParamParser(@PatientClassificationIds, ','))) OR 
		(0 IN (SELECT Id FROM DelimitedParamParser(@PatientClassificationIds, ',')) AND PatientDebtor.PatientClassificationId IS NULL))
	) 
	AND
	
	(
		@EPAYes IS NULL OR ( @EPAYes = 0 AND PatientDebtor.NOKEPA = 1) OR ( @EPAYes = 1 AND PatientDebtor.NOKEPA = 2)
	) 
	AND
	
	(
		@DVAYes IS NULL OR ( @DVAYes = 0 AND PatientDebtor.DvaNumber IS NULL) OR 
		(@DVAYes = 1 AND PatientDebtor.DvaNumber IS NOT NULL AND (@DVAType IS NULL OR PatientDebtor.DVACardType = @DVAType))
	) 
	AND	
	
	(
		@DonorYes IS NULL OR ( @DonorYes = 0 AND PatientDebtor.DonorCardNo IS NULL) OR (@DonorYes = 1 AND PatientDebtor.DonorCardNo IS NOT NULL )
	) 
	AND
	
	(
		@PensionCardYes IS NULL OR ( @PensionCardYes = 0 AND PatientDebtor.PensionCardNo IS NULL) OR (@PensionCardYes = 1 AND PatientDebtor.PensionCardNo IS NOT NULL )
	) 
	AND
	
	(
		@HCCYes IS NULL OR ( @HCCYes = 0 AND PatientDebtor.OtherCardNo IS NULL) OR (@HCCYes = 1 AND PatientDebtor.OtherCardNo IS NOT NULL )
	) 	
	AND
	
	(
		@ActivePatientsOnly IS NULL OR ( @ActivePatientsOnly = 0 AND PatientDebtor.Inactive IS NOT NULL) OR (@ActivePatientsOnly = 1 AND PatientDebtor.Inactive IS NULL )
	) 	
	AND
	
	(
	    @ExcludeDeceasedPatients IS NULL OR @ExcludeDeceasedPatients = 0 OR (@ExcludeDeceasedPatients = 1 AND PatientDebtor.DoD IS NULL ) 
	) 
	AND
	
	(
		(@OverseasAddress IS NULL OR @OverseasAddress = 0 OR (@OverseasAddress = 1 AND ISNULL(Address.OverseasAddress, 0) = 1))
	) 
	AND
	
	(
		@MobilePhone IS NULL 
            OR
        (@MobilePhone = 1 AND ISNULL(PatientDebtor.MobilePhoneContactId, 0) <> 0 AND ISNULL(PatientDebtor.ConsentMobilePhone, 0) = 2) /* Details recorded - Only if consent granted */
            OR
        (@MobilePhone = 2 AND ISNULL(PatientDebtor.MobilePhoneContactId, 0) <> 0 AND ISNULL(PatientDebtor.ConsentMobilePhone, 0) <> 1) /* Details recorded - If consent granted or not recorded */
            OR
        (@MobilePhone = 3 AND ISNULL(PatientDebtor.MobilePhoneContactId, 0) <> 0) /* Details recorded - Always (disregard consent option) */
            OR 
        (@MobilePhone = 4 AND ISNULL(PatientDebtor.MobilePhoneContactId, 0) = 0) /* Details not recorded */
	) 	
	AND
	
	(
		@EmailAddress IS NULL 
            OR
        (@EmailAddress = 1 AND ISNULL(PatientDebtor.EmailContactId, 0) <> 0 AND ISNULL(PatientDebtor.ConsentEmail, 0) = 2) /* Details recorded - Only if consent granted */
            OR
        (@EmailAddress = 2 AND ISNULL(PatientDebtor.EmailContactId, 0) <> 0 AND ISNULL(PatientDebtor.ConsentEmail, 0) <> 1) /* Details recorded - If consent granted or not recorded */
            OR
        (@EmailAddress = 3 AND ISNULL(PatientDebtor.EmailContactId, 0) <> 0) /* Details recorded - Always (disregard consent option) */
            OR 
        (@EmailAddress = 4 AND ISNULL(PatientDebtor.EmailContactId, 0) = 0) /* Details not recorded */
	) 	

 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByDrinkingData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their smoking data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByDrinkingData]
(
	@DrinkingStatusIds VARCHAR(MAX) = NULL,
	@DrinkingPastStatusIds VARCHAR(MAX) = NULL,
	@DrinkingStartedDateFrom DATETIME = NULL,
	@DrinkingStartedDateTo DATETIME = NULL,
	@DrinkingStoppedDateFrom DATETIME = NULL,
	@DrinkingStoppedDateTo DATETIME = NULL,
	@MinDrinkingDrinksPerDay INT = NULL,
	@MaxDrinkingDrinksPerDay INT = NULL,
	@MinDrinkingDaysPerWeek INT = NULL,
	@MaxDrinkingDaysPerWeek INT = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT DISTINCT PatientDebtor.Id 
					   FROM PatientDebtor
					   LEFT OUTER JOIN statclinical.dbo.HealthIndicators ON HealthIndicators.EhrUid = PatientDebtor.EhrUid
WHERE 
ISNULL(HealthIndicators.VersionNumber, 0) = 0
AND
-- ID for Unknown DrinkingStatus is 0 and the value in the table is NULL.
(
    @DrinkingStatusIds IS NULL OR @DrinkingStatusIds = '' OR 
    ((HealthIndicators.CurrentAlcoholIntake IN (SELECT Id FROM DelimitedParamParser(@DrinkingStatusIds, ','))) OR 
    (0 IN (SELECT Id FROM DelimitedParamParser(@DrinkingStatusIds, ',')) AND HealthIndicators.CurrentAlcoholIntake IS NULL))
) 
AND
-- ID for Unknown PastDrinkingStatus is 0 and the value in the table is NULL.
(
    @DrinkingPastStatusIds IS NULL OR @DrinkingPastStatusIds = '' OR 
    ((HealthIndicators.PastAlcoholIntake IN (SELECT Id FROM DelimitedParamParser(@DrinkingPastStatusIds, ','))) OR 
    (0 IN (SELECT Id FROM DelimitedParamParser(@DrinkingPastStatusIds, ',')) AND HealthIndicators.PastAlcoholIntake IS NULL))
) 
AND	
(
    (@DrinkingStartedDateFrom IS NULL OR HealthIndicators.DrinkingStarted >= @DrinkingStartedDateFrom) AND
    (@DrinkingStartedDateTo IS NULL OR HealthIndicators.DrinkingStarted <= @DrinkingStartedDateTo)
)
AND
(	
    (@DrinkingStoppedDateFrom IS NULL OR HealthIndicators.DrinkingStopped >= @DrinkingStoppedDateFrom) AND
    (@DrinkingStoppedDateTo IS NULL OR HealthIndicators.DrinkingStopped <= @DrinkingStoppedDateTo)
)
AND
(
	(@MinDrinkingDrinksPerDay IS NULL OR HealthIndicators.DrinkingStandardDrinksPerDay >= @MinDrinkingDrinksPerDay) AND
	(@MaxDrinkingDrinksPerDay IS NULL OR HealthIndicators.DrinkingStandardDrinksPerDay <= @MaxDrinkingDrinksPerDay)
)
AND
(
	(@MinDrinkingDaysPerWeek IS NULL OR HealthIndicators.DrinkingDaysPerWeek >= @MinDrinkingDaysPerWeek) AND
	(@MaxDrinkingDaysPerWeek IS NULL OR HealthIndicators.DrinkingDaysPerWeek <= @MaxDrinkingDaysPerWeek)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByEpisodeData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their Episode data.
-- @AppointmentCount or Billing Count cannot be given without specifying Date-Range.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByEpisodeData]
(
	@AppointmentDateFrom DATETIME = NULL,
	@AppointmentDateTo DATETIME = NULL,
	@BillingDateFrom DATETIME = NULL,
	@BillingDateTo DATETIME = NULL,
	--@AppointmentCount SMALLINT = NULL,
	@BillingCount SMALLINT = NULL,
	@AppointmentTypeIds VARCHAR(MAX)= NULL,
	@HaveHadBillingItemNumbersDateFrom DATETIME = NULL,
	@HaveHadBillingItemNumbersDateTo DATETIME = NULL,
	@HaveHadBillingItemNumbers VARCHAR(MAX)= NULL,
	@HaveNotHadBillingItemNumbersDateFrom DATETIME = NULL,
	@HaveNotHadBillingItemNumbersDateTo DATETIME = NULL,
	@HaveNotHadBillingItemNumbers VARCHAR(MAX)= NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id 
					   FROM PatientDebtor
WHERE 
(
	@BillingCount IS NULL OR
	PatientDebtor.Id IN
	(
		SELECT	Episode.PatientDebtorPatientId
		FROM	Episode
		INNER JOIN Billing ON Episode.Id = Billing.EpisodeId
		WHERE	@BillingCount IS NULL OR @BillingCount = 0 OR
				(
					(
						((@BillingDateFrom IS  NULL OR (@BillingDateFrom <= CAST(Episode.StartDateTimeOffset AS DateTime))) AND -- Status 4 = Billing Completed
						(@BillingDateTo IS NULL OR (@BillingDateTo >= DATEADD(dd, 0, DATEDIFF(dd, 0, CAST(Episode.StartDateTimeOffset AS DateTime)))))) AND
						Episode.[Status] = 4 AND
						Billing.[Status] IS NOT NULL AND Billing.[Status] != 0 AND Billing.[Status] != 5 -- Status 0 for NONE and 5 for HELD
					)					
				)
		GROUP BY	Episode.PatientDebtorPatientId
		HAVING		(@BillingCount IS NULL OR @BillingCount = 0 OR COUNT(Episode.StartDateTimeOffset) >= @BillingCount)
	)
)
AND
(	
	@AppointmentTypeIds IS NULL OR
	PatientDebtor.Id IN
	(
		SELECT	Episode.PatientDebtorPatientId
		FROM	Episode
		WHERE	(
					@AppointmentTypeIds IS NULL 
					OR
					(
						(@AppointmentDateFrom IS NULL OR Episode.AppointmentDateTime >= @AppointmentDateFrom) AND
						(@AppointmentDateTo IS NULL OR Episode.AppointmentDateTime < DATEADD(d, 1, @AppointmentDateTo)) AND
						(Episode.AppointmentTypeId IN (SELECT Id FROM DelimitedParamParser(@AppointmentTypeIds, ','))) AND
						Episode.[Status] != 5 -- Status 5 = Cancelled appointments.
					) 
				)
		GROUP BY Episode.PatientDebtorPatientId
		HAVING	(@AppointmentTypeIds IS NULL OR  COUNT(Episode.AppointmentDateTime) >= 1)
	)
)
AND
(
	@HaveHadBillingItemNumbers IS NULL OR
	PatientDebtor.Id IN
	(
		SELECT DISTINCT Episode.PatientDebtorPatientId
		FROM	Episode
		INNER JOIN Billing ON Episode.Id = Billing.EpisodeId
		INNER JOIN Invoice ON Invoice.BillingId = Billing.Id
		INNER JOIN InvoiceDetail ON InvoiceDetail.InvoiceId = Invoice.Id
        INNER JOIN ServiceItemDetail ON ServiceItemDetail.Id = InvoiceDetail.ServiceItemDetailId
        INNER JOIN ServiceItem on ServiceItem.Id = ServiceItemDetail.ServiceItemId
		WHERE	ServiceItem.ItemCode IN (SELECT Id FROM DelimitedStringParamParser(@HaveHadBillingItemNumbers, ',')) AND Invoice.ReversalReceiptId IS NULL
				AND (@HaveHadBillingItemNumbersDateFrom IS NULL OR 
					@HaveHadBillingItemNumbersDateFrom <= DATEADD(dd, 0, DATEDIFF(dd, 0, CAST(Episode.StartDateTimeOffset AS DateTime))))
				AND (@HaveHadBillingItemNumbersDateTo IS NULL OR 
					@HaveHadBillingItemNumbersDateTo >= DATEADD(dd, 0, DATEDIFF(dd, 0, CAST(Episode.StartDateTimeOffset AS DateTime)))) --Get rid of the time part
	)
)
AND
(
	@HaveNotHadBillingItemNumbers IS NULL OR
	PatientDebtor.Id NOT IN
	(
		SELECT DISTINCT Episode.PatientDebtorPatientId
		FROM	Episode
		INNER JOIN Billing ON Episode.Id = Billing.EpisodeId
		INNER JOIN Invoice ON Invoice.BillingId = Billing.Id
		INNER JOIN InvoiceDetail ON InvoiceDetail.InvoiceId = Invoice.Id
        INNER JOIN ServiceItemDetail ON ServiceItemDetail.Id = InvoiceDetail.ServiceItemDetailId
        INNER JOIN ServiceItem on ServiceItem.Id = ServiceItemDetail.ServiceItemId
		WHERE	ServiceItem.ItemCode IN (SELECT Id FROM DelimitedStringParamParser(@HaveNotHadBillingItemNumbers, ',')) AND Invoice.ReversalReceiptId IS NULL
				AND (@HaveNotHadBillingItemNumbersDateFrom IS NULL OR 
					@HaveNotHadBillingItemNumbersDateFrom <= DATEADD(dd, 0, DATEDIFF(dd, 0, CAST(Episode.StartDateTimeOffset AS DateTime))))
				AND (@HaveNotHadBillingItemNumbersDateTo IS NULL OR 
					@HaveNotHadBillingItemNumbersDateTo >= DATEADD(dd, 0, DATEDIFF(dd, 0, CAST(Episode.StartDateTimeOffset AS DateTime)))) --Get rid of the time part
	)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByMeasurements]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their measurements.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByMeasurements]
(
	@MinimumResultDate DATETIME = NULL, -- Result should not be older than this date.
	
	@MeasurementCategoryId1 int = NULL,
	@MinValue1 FLOAT = NULL,
	@MaxValue1 FLOAT = NULL,
		
	@MeasurementCategoryId2 int = NULL,
	@MinValue2 FLOAT = NULL,
	@MaxValue2 FLOAT = NULL,
	
	@MeasurementCategoryId3 int = NULL,
	@MinValue3 FLOAT = NULL,
	@MaxValue3 FLOAT = NULL,
	
	@MeasurementCategoryId4 int = NULL,
	@MinValue4 FLOAT = NULL,
	@MaxValue4 FLOAT = NULL,
	
	@MeasurementCategoryId5 int = NULL,
	@MinValue5 FLOAT = NULL,
	@MaxValue5 FLOAT = NULL,
	
	@MeasurementCategoryId6 int = NULL,
	@MinValue6 FLOAT = NULL,
	@MaxValue6 FLOAT = NULL,
	
	@MeasurementCategoryId7 int = NULL,
	@MinValue7 FLOAT = NULL,
	@MaxValue7 FLOAT = NULL,
	
	@MeasurementCategoryId8 int = NULL,
	@MinValue8 FLOAT = NULL,
	@MaxValue8 FLOAT = NULL,
	
	@MeasurementCategoryId9 int = NULL,
	@MinValue9 FLOAT = NULL,
	@MaxValue9 FLOAT = NULL,
	
	@MeasurementCategoryId10 int = NULL,
	@MinValue10 FLOAT = NULL,
	@MaxValue10 FLOAT = NULL,
	
	@MeasurementCategoryId11 int = NULL,
	@MinValue11 FLOAT = NULL,
	@MaxValue11 FLOAT = NULL,
	
	@MeasurementCategoryId12 int = NULL,
	@MinValue12 FLOAT = NULL,
	@MaxValue12 FLOAT = NULL,
	
	@MeasurementCategoryId13 int = NULL,
	@MinValue13 FLOAT = NULL,
	@MaxValue13 FLOAT = NULL,
	
	@MeasurementCategoryId14 int = NULL,
	@MinValue14 FLOAT = NULL,
	@MaxValue14 FLOAT = NULL,
	
	@MeasurementCategoryId15 int = NULL,
	@MinValue15 FLOAT = NULL,
	@MaxValue15 FLOAT = NULL,

	@PapSmearCategoryId int = NULL,
	@HaveNotHadPapSmearSince DATETIME = NULL,
	
	@HeightWeightMeasurementsSince DATETIME = NULL,
	@WeightMin FLOAT = NULL,
	@WeightMax FLOAT = NULL,
	@BMIMin FLOAT = NULL,
	@BMIMax FLOAT = NULL,
	
	@BloodPressureMeasurementsSince DATETIME = NULL,
	@SystolicMin INT = NULL,
	@SystolicMax INT = NULL,
	@DiastolicMin INT = NULL,
	@DiastolicMax INT = NULL,
	
	@ThinPrepCategoryId int = NULL,
	@HaveNotHadThinPrepSince DATETIME = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE 
(
	(
		(@MeasurementCategoryId1 IS NULL OR @MeasurementCategoryId1 = 0) OR 
		((@MinValue1 IS NULL OR @MinValue1 = 0) AND (@MaxValue1 IS NULL OR @MaxValue1 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId1, @MinValue1, @MaxValue1)
		)
	)
	AND
	(
		(@MeasurementCategoryId2 IS NULL OR @MeasurementCategoryId2 = 0) OR 
		((@MinValue2 IS NULL OR @MinValue2 = 0) AND (@MaxValue2 IS NULL OR @MaxValue2 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId2, @MinValue2, @MaxValue2)
		)
	)
	AND
	(
		(@MeasurementCategoryId3 IS NULL OR @MeasurementCategoryId3 = 0) OR 
		((@MinValue3 IS NULL OR @MinValue3 = 0) AND (@MaxValue3 IS NULL OR @MaxValue3 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId3, @MinValue3, @MaxValue3)
		)
	)
	AND
	(
		(@MeasurementCategoryId4 IS NULL OR @MeasurementCategoryId4 = 0) OR 
		((@MinValue4 IS NULL OR @MinValue4 = 0) AND (@MaxValue4 IS NULL OR @MaxValue4 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId4, @MinValue4, @MaxValue4)
		)
	)
	AND
	(
		(@MeasurementCategoryId5 IS NULL OR @MeasurementCategoryId5 = 0) OR 
		((@MinValue5 IS NULL OR @MinValue5 = 0) AND (@MaxValue5 IS NULL OR @MaxValue5 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId5, @MinValue5, @MaxValue5)
		)
	)
	AND
	(
		(@MeasurementCategoryId6 IS NULL OR @MeasurementCategoryId6 = 0) OR 
		((@MinValue6 IS NULL OR @MinValue6 = 0) AND (@MaxValue6 IS NULL OR @MaxValue6 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId6, @MinValue6, @MaxValue6)
		)
	)
	AND
	(
		(@MeasurementCategoryId7 IS NULL OR @MeasurementCategoryId7 = 0) OR 
		((@MinValue7 IS NULL OR @MinValue7 = 0) AND (@MaxValue7 IS NULL OR @MaxValue7 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId7, @MinValue7, @MaxValue7)
		)
	)
	AND
	(
		(@MeasurementCategoryId8 IS NULL OR @MeasurementCategoryId8 = 0) OR 
		((@MinValue8 IS NULL OR @MinValue8 = 0) AND (@MaxValue8 IS NULL OR @MaxValue8 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId8, @MinValue8, @MaxValue8)
		)
	)
	AND
	(
		(@MeasurementCategoryId9 IS NULL OR @MeasurementCategoryId9 = 0) OR 
		((@MinValue9 IS NULL OR @MinValue9 = 0) AND (@MaxValue9 IS NULL OR @MaxValue9 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId9, @MinValue9, @MaxValue9)
		)
	)
	AND
	(
		(@MeasurementCategoryId10 IS NULL OR @MeasurementCategoryId10 = 0) OR 
		((@MinValue10 IS NULL OR @MinValue10 = 0) AND (@MaxValue10 IS NULL OR @MaxValue10 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId10, @MinValue10, @MaxValue10)
		)
	)
	AND
	(
		(@MeasurementCategoryId11 IS NULL OR @MeasurementCategoryId11 = 0) OR 
		((@MinValue11 IS NULL OR @MinValue11 = 0) AND (@MaxValue11 IS NULL OR @MaxValue11 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId11, @MinValue11, @MaxValue11)
		)
	)
	AND
	(
		(@MeasurementCategoryId12 IS NULL OR @MeasurementCategoryId12 = 0) OR 
		((@MinValue12 IS NULL OR @MinValue12 = 0) AND (@MaxValue12 IS NULL OR @MaxValue12 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId12, @MinValue12, @MaxValue12)
		)
	)
	AND
	(
		(@MeasurementCategoryId13 IS NULL OR @MeasurementCategoryId13 = 0) OR 
		((@MinValue13 IS NULL OR @MinValue13 = 0) AND (@MaxValue13 IS NULL OR @MaxValue13 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId13, @MinValue13, @MaxValue13)
		)
	)
	AND
	(
		(@MeasurementCategoryId14 IS NULL OR @MeasurementCategoryId14 = 0) OR 
		((@MinValue14 IS NULL OR @MinValue14 = 0) AND (@MaxValue14 IS NULL OR @MaxValue14 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId14, @MinValue14, @MaxValue14)
		)
	)
	AND
	(
		(@MeasurementCategoryId15 IS NULL OR @MeasurementCategoryId15 = 0) OR 
		((@MinValue15 IS NULL OR @MinValue15 = 0) AND (@MaxValue15 IS NULL OR @MaxValue15 = 0)) OR	
		PatientDebtor.Id IN 
		(
			Select PatientId FROM [FilterPatientsByClinicalResultsAtomic](@MinimumResultDate, @MeasurementCategoryId15, @MinValue15, @MaxValue15)
		)
	)
	AND
	(
		--Have not had Papsmear since Filtering
		(@PapSmearCategoryId = 0 OR @PapSmearCategoryId IS NULL) OR 
		@HaveNotHadPapSmearSince IS NULL OR	
		(
			PatientDebtor.Id NOT IN 
			(
				SELECT PatientId FROM [FilterPatientsByAtomicResultLastTestDate](@HaveNotHadPapSmearSince, @PapSmearCategoryId)
			) 
			--AND
			--PatientDebtor.Sex = '2' -- Females only in order to get rid of male patients
		)
	)
	AND
	(
		--Have not had thin prep pap test since Filtering
		(@ThinPrepCategoryId = 0 OR @ThinPrepCategoryId IS NULL) OR 
		@HaveNotHadThinPrepSince IS NULL OR	
		(
			PatientDebtor.Id NOT IN 
			(
				SELECT PatientId FROM [FilterPatientsByAtomicResultLastTestDate](@HaveNotHadThinPrepSince, @ThinPrepCategoryId)
			)
			--AND
			--PatientDebtor.Sex = '2' -- Females only in order to get rid of male patients
		)
	)
	AND
	(
		(
			(@WeightMin IS NULL OR @WeightMin = 0) AND (@WeightMax IS NULL OR @WeightMax = 0) AND 
			(@BMIMin IS NULL OR @BMIMin = 0) AND (@BMIMax IS NULL OR @BMIMax = 0)
		) OR
		PatientDebtor.Id IN
		(
			SELECT DISTINCT PatientDebtor.Id
			FROM PatientDebtor
			INNER JOIN statclinical.dbo.HeightWeights ON HeightWeights.EhrUid = PatientDebtor.EhrUid
			WHERE	(@HeightWeightMeasurementsSince IS NULL OR CAST(HeightWeights.TestDateTimeOffset AS DateTime) >= @HeightWeightMeasurementsSince) AND
					HeightWeights.Inactive != '1' AND
					((@WeightMin IS NULL OR @WeightMin = 0) OR (HeightWeights.Weight >= @WeightMin)) AND
					((@WeightMax IS NULL OR @WeightMax = 0) OR (HeightWeights.Weight <= @WeightMax)) AND
					((@BMIMin IS NULL OR @BMIMin = 0) OR (HeightWeights.Weight / ((HeightWeights.Height/100) * (HeightWeights.Height/100)) >= @BMIMin)) AND
					((@BMIMax IS NULL OR @BMIMax = 0) OR (HeightWeights.Weight / ((HeightWeights.Height/100) * (HeightWeights.Height/100)) <= @BMIMax))
		)
	)
	AND
	(
		(
			(@SystolicMin IS NULL OR @SystolicMin = 0) AND (@SystolicMax IS NULL OR @SystolicMax = 0) AND 
			(@DiastolicMin IS NULL OR @DiastolicMin = 0) AND (@DiastolicMax IS NULL OR @DiastolicMax = 0)
		) OR
		PatientDebtor.Id IN
		(
			SELECT DISTINCT PatientDebtor.Id
			FROM PatientDebtor
			INNER JOIN statclinical.dbo.BloodPressure ON BloodPressure.EhrUid = PatientDebtor.EhrUid
			WHERE	(@BloodPressureMeasurementsSince IS NULL OR CAST(BloodPressure.TestDateTimeOffset AS DateTime) >= @BloodPressureMeasurementsSince) AND
					BloodPressure.Inactive != '1' AND
					((@SystolicMin IS NULL OR @SystolicMin = 0) OR (BloodPressure.Systolic >= @SystolicMin)) AND
					((@SystolicMax IS NULL OR @SystolicMax = 0) OR (BloodPressure.Systolic <= @SystolicMax)) AND
					((@DiastolicMin IS NULL OR @DiastolicMin = 0) OR (BloodPressure.Diastolic >= @DiastolicMin)) AND
					((@DiastolicMax IS NULL OR @DiastolicMax = 0) OR (BloodPressure.Diastolic <= @DiastolicMax))
		)
	)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByMedications]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their current medications and returns result PatientIds.

-- @MustTakeAllMedications - Patients must take all these medications in order to satisfy the filter.
-- @MustNotTakeAllMedications - Patients must not take all of these medications in order to satisfy the filter.
-- @MustTakeAtLeastOneMedication - Patients must take at least one of these medications in order to satisfy the filter.
-- @MustNotTakeAtLeastOneMedication - Patients must not take at least one of these medications in order to satisfy the filter.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByMedications]
(
    @CurrentDateTimeOffset DATETIMEOFFSET = NULL, 
	@MustTakeAllMedications VARCHAR(MAX) = NULL,
	@MustNotTakeAllMedications VARCHAR(MAX) = NULL,
	@MustTakeAtLeastOneMedication VARCHAR(MAX) = NULL,
	@MustNotTakeAtLeastOneMedication VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN
INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE 
(
	--MustTakeAllMedications Category
	@MustTakeAllMedications = '' OR @MustTakeAllMedications IS NULL OR
	PatientDebtor.Id IN 
	(
		SELECT PatientId FROM [GetPatientsTakeAllMedications](@CurrentDateTimeOffset, @MustTakeAllMedications)
	)
)
AND --MustNotTakeAllMedications Filter
(
	@MustNotTakeAllMedications = '' OR @MustNotTakeAllMedications IS NULL OR
	PatientDebtor.Id NOT IN 
	(
		SELECT PatientId FROM [GetPatientsTakeAllMedications](@CurrentDateTimeOffset, @MustNotTakeAllMedications)
	)
)
AND --MustTakeAtLeastOneMedication Filter
(
	@MustTakeAtLeastOneMedication = '' OR @MustTakeAtLeastOneMedication IS NULL OR
	PatientDebtor.Id IN 
	(
		SELECT PatientId FROM [GetPatientsTakeAnyMedication](@CurrentDateTimeOffset, @MustTakeAtLeastOneMedication)
	)
)
AND --@MustNotTakeAtLeastOneMedication Filter
(
	@MustNotTakeAtLeastOneMedication = '' OR @MustNotTakeAtLeastOneMedication IS NULL OR
	PatientDebtor.Id NOT IN 
	(
		SELECT PatientId FROM [GetPatientsTakeAnyMedication](@CurrentDateTimeOffset, @MustNotTakeAtLeastOneMedication)
	)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByPregnancyData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their pregnancy data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByPregnancyData]
(
	@EDDFrom DATETIME = NULL,
	@EDDTo DATETIME = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT DISTINCT PD.Id 
					   FROM PatientDebtor AS PD
					   INNER JOIN statclinical.dbo.PregnancyCalculation AS PC ON PC.EhrUid = PD.EhrUid
WHERE
PC.VersionNumber = 0
AND
PC.PregnantMethod <> 0
AND 
PC.DeliveredNotCompleted = 0
AND
ISNULL(PC.Complete, 0) = 0
AND
ISNULL(PC.CalculationDate, '17600101') <> '17600101'
AND
(
	@EDDFrom IS NULL 
	OR
	(PC.PregnantMethod = 1 /* LNMP */   AND (DATEADD(WEEK, 40, PC.CalculationDate)) >= @EDDFrom)
	OR
	(PC.PregnantMethod = 2 /* Scan */   AND (DATEADD(WEEK, 40, (DATEADD(DAY, (PC.ScanDays * -1), PC.CalculationDate)))) >= @EDDFrom)
	OR
	(PC.PregnantMethod = 3 /* Agreed */ AND PC.CalculationDate >= @EDDFrom)
)
AND
(
	@EDDTo IS NULL
	OR
	(PC.PregnantMethod = 1 /* LNMP */   AND (DATEADD(WEEK, 40, PC.CalculationDate)) <= @EDDTo)
	OR
	(PC.PregnantMethod = 2 /* Scan */   AND (DATEADD(WEEK, 40, (DATEADD(DAY, (PC.ScanDays * -1), PC.CalculationDate)))) <= @EDDTo)
	OR
	(PC.PregnantMethod = 3 /* Agreed */ AND PC.CalculationDate <= @EDDTo)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByRecallsData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their Recalls data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByRecallsData]
(
	@RecallDueDateFrom DATETIME = NULL,
	@RecallDueDateTo DATETIME = NULL,
	@RecallCreatedDateFrom DATETIME = NULL,
	@RecallCreatedDateTo DATETIME = NULL,
	@NotRequireCompliance BIT = NULL,
	@Complied BIT = NULL,
	@NotComplied BIT = NULL,
	@Cancelled BIT = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT DISTINCT Recall.PatientId 
					   FROM Recall
					   INNER JOIN RecallActivity ON Recall.Id = RecallActivity.RecallId
					   INNER JOIN PatientContact ON Recall.PatientContactId = PatientContact.Id
WHERE
(@RecallDueDateFrom IS NULL OR Recall.DueDate >= @RecallDueDateFrom) AND
(@RecallDueDateTo IS NULL OR Recall.DueDate <= @RecallDueDateTo) AND
(	
	@RecallCreatedDateFrom IS NULL OR 
	(SELECT COUNT(RecallActivity.ActivityDateTimeOffset) FROM RecallActivity 
	WHERE RecallActivity.RecallId = Recall.Id AND RecallActivity.ActivityType = '1' AND CAST(RecallActivity.ActivityDateTimeOffset AS DateTime) >= @RecallCreatedDateFrom) > 0
) 
AND
(	
	@RecallCreatedDateTo IS NULL OR 
	(SELECT COUNT(RecallActivity.ActivityDateTimeOffset) FROM RecallActivity 
	WHERE RecallActivity.RecallId = Recall.Id AND RecallActivity.ActivityType = '1' AND DATEADD(dd, 0, DATEDIFF(dd, 0, CAST(RecallActivity.ActivityDateTimeOffset AS DateTime))) <= @RecallCreatedDateTo) > 0
)
AND
(
	-- Process for Compliance Not Required
	(@NotRequireCompliance = '1' AND PatientContact.RequiresCompliance = '0') -- If compliance not required not process ActivityTypes
	OR
	-- Process for Complied status
	(PatientContact.RequiresCompliance = '1' AND  -- It never compliance complete if not reqiresCompliance.
		@Complied = '1' AND
		RecallActivity.ActivityType = '11'
	)
	OR
	-- Process for Not Complied status
	(PatientContact.RequiresCompliance = '1' AND  -- It never process to complete for compliance if not reqiresCompliance.
		@NotComplied = '1' AND
		('11' NOT IN (SELECT RecallActivity.ActivityType FROM RecallActivity WHERE RecallActivity.RecallId = Recall.Id)) AND  -- Not cancelled
		('12' NOT IN (SELECT RecallActivity.ActivityType FROM RecallActivity WHERE RecallActivity.RecallId = Recall.Id)) -- Not completed
	)
	OR
	-- Process for Cancelled
	(@Cancelled = '1' AND
		RecallActivity.ActivityType = '12'
	)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByRecreationalDrugsData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their smoking data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByRecreationalDrugsData]
(
	@DrugsStatusIds VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT DISTINCT PatientDebtor.Id 
					   FROM PatientDebtor
					   LEFT OUTER JOIN statclinical.dbo.HealthIndicators ON HealthIndicators.EhrUid = PatientDebtor.EhrUid
WHERE 
ISNULL(HealthIndicators.VersionNumber, 0) = 0
AND
-- ID for Unknown RecreationalDrugUsage is 0 and the value in the table is NULL.
(
    @DrugsStatusIds IS NULL OR @DrugsStatusIds = '' OR 
    ((HealthIndicators.RecreationalDrugUsage IN (SELECT Id FROM DelimitedParamParser(@DrugsStatusIds, ','))) OR 
    (0 IN (SELECT Id FROM DelimitedParamParser(@DrugsStatusIds, ',')) AND HealthIndicators.RecreationalDrugUsage IS NULL))
) 
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsBySmokingData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their smoking data.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsBySmokingData]
(
	@SmokingStatusIds VARCHAR(MAX) = NULL,
	@SmokingStartedDateFrom DATETIME = NULL,
	@SmokingStartedDateTo DATETIME = NULL,
	@SmokingStoppedDateFrom DATETIME = NULL,
	@SmokingStoppedDateTo DATETIME = NULL,
	@SmokingPreferenceIds VARCHAR(MAX) = NULL,
	@SmokingCigarettes INT = NULL,
	@MinSmokingCigarettesNumber INT = NULL,
	@MaxSmokingCigarettesNumber INT = NULL,
	@SmokingCigars INT = NULL,
	@MinSmokingCigarsNumber INT = NULL,
	@MaxSmokingCigarsNumber INT = NULL,
	@SmokingPipe INT = NULL,
	@MinSmokingPipeNumber INT = NULL,
	@MaxSmokingPipeNumber INT = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT DISTINCT PatientDebtor.Id 
					   FROM PatientDebtor
					   LEFT OUTER JOIN statclinical.dbo.HealthIndicators ON HealthIndicators.EhrUid = PatientDebtor.EhrUid
WHERE 
ISNULL(HealthIndicators.VersionNumber, 0) = 0
AND
-- ID for Unknown SmokingStatus is 0 and the value in the table is NULL.
(
    @SmokingStatusIds IS NULL OR @SmokingStatusIds = '' OR 
    ((HealthIndicators.SmokingStatus IN (SELECT Id FROM DelimitedParamParser(@SmokingStatusIds, ','))) OR 
    (0 IN (SELECT Id FROM DelimitedParamParser(@SmokingStatusIds, ',')) AND HealthIndicators.SmokingStatus IS NULL))
) 
AND	
(
    (@SmokingStartedDateFrom IS NULL OR HealthIndicators.SmokingStarted >= @SmokingStartedDateFrom) AND
    (@SmokingStartedDateTo IS NULL OR HealthIndicators.SmokingStarted <= @SmokingStartedDateTo)
)
AND
(	
    (@SmokingStoppedDateFrom IS NULL OR HealthIndicators.SmokingStopped >= @SmokingStoppedDateFrom) AND
    (@SmokingStoppedDateTo IS NULL OR HealthIndicators.SmokingStopped <= @SmokingStoppedDateTo)
)
AND
(
	@SmokingPreferenceIds IS NULL OR @SmokingPreferenceIds = '' OR 
	((HealthIndicators.SmokingPreference IN (SELECT Id FROM DelimitedParamParser(@SmokingPreferenceIds, ','))) OR 
	(0 IN (SELECT Id FROM DelimitedParamParser(@SmokingPreferenceIds, ',')) AND HealthIndicators.SmokingPreference IS NULL))
) 
AND
(
	(@SmokingCigarettes IS NULL AND @SmokingCigars IS NULL AND  @SmokingPipe IS NULL)
	OR
	((HealthIndicators.SmokingPreference = @SmokingCigarettes) AND
	(@MinSmokingCigarettesNumber IS NULL OR HealthIndicators.SmokingFrequency >= @MinSmokingCigarettesNumber) AND
	(@MaxSmokingCigarettesNumber IS NULL OR HealthIndicators.SmokingFrequency <= @MaxSmokingCigarettesNumber))
	OR
	((HealthIndicators.SmokingPreference = @SmokingCigars) AND
	(@MinSmokingCigarsNumber IS NULL OR HealthIndicators.SmokingFrequency >= @MinSmokingCigarsNumber) AND
	(@MaxSmokingCigarsNumber IS NULL OR HealthIndicators.SmokingFrequency <= @MaxSmokingCigarsNumber))
	OR
	((HealthIndicators.SmokingPreference = @SmokingPipe) AND
	(@MinSmokingPipeNumber IS NULL OR HealthIndicators.SmokingFrequency >= @MinSmokingPipeNumber) AND
	(@MaxSmokingPipeNumber IS NULL OR HealthIndicators.SmokingFrequency <= @MaxSmokingPipeNumber))
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[FilterPatientsByVaccinations]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their current vaccination and returns result PatientIds.

-- @MustHaveHadAllVaccinations - Patients must have had all these vaccinations in order to satisfy the filter.
-- @MustNotHaveHadAllVaccinations - Patients must not have had all of these Vaccinations in order to satisfy the filter.
-- @MustHaveHadAtLeastOneVaccination - Patients must have had at least one of these Vaccinations in order to satisfy the filter.
-- @MustNotHaveHadAtLeastOneVaccination - Patients must not have had at least one of these Vaccinations in order to satisfy the filter.
-- =============================================
CREATE FUNCTION [dbo].[FilterPatientsByVaccinations]
(
	@MustHaveHadAllVaccinations VARCHAR(MAX) = NULL, 
	@MustNotHaveHadAllVaccinations VARCHAR(MAX) = NULL, 
	@MustHaveHadAtLeastOneVaccination VARCHAR(MAX) = NULL, 
	@MustNotHaveHadAtLeastOneVaccination VARCHAR(MAX) = NULL,
	@VaccinationDateFrom DATETIME = NULL,
	@VaccinationDateTo DATETIME = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE 
(
	--MustHaveHadAllVaccinations Category
	@MustHaveHadAllVaccinations = '' OR @MustHaveHadAllVaccinations IS NULL OR
	PatientDebtor.Id IN 
	(
		SELECT PatientId FROM [GetPatientsHaveHadAllVaccinations] (@MustHaveHadAllVaccinations, @VaccinationDateFrom, @VaccinationDateTo)
	)
)
AND --MustNotHaveHadAllVaccinations Filter
(
	@MustNotHaveHadAllVaccinations = '' OR @MustNotHaveHadAllVaccinations IS NULL OR
	PatientDebtor.Id NOT IN 
	(
		SELECT PatientId FROM [GetPatientsHaveHadAllVaccinations] (@MustNotHaveHadAllVaccinations, @VaccinationDateFrom, @VaccinationDateTo)
	)
)
AND --@MustHaveHadAtLeastOneVaccination Filter
(
	@MustHaveHadAtLeastOneVaccination = '' OR @MustHaveHadAtLeastOneVaccination IS NULL OR
	PatientDebtor.Id IN 
	(
		SELECT PatientId FROM [GetPatientsHaveHadAnyVaccination] (@MustHaveHadAtLeastOneVaccination, @VaccinationDateFrom, @VaccinationDateTo)
	)
)
AND --@MustNotHaveAtLeastOneVaccination Filter
(
	@MustNotHaveHadAtLeastOneVaccination = '' OR @MustNotHaveHadAtLeastOneVaccination IS NULL OR
	PatientDebtor.Id NOT IN 
	(
		SELECT PatientId FROM [GetPatientsHaveHadAnyVaccination] (@MustNotHaveHadAtLeastOneVaccination, @VaccinationDateFrom, @VaccinationDateTo)
	)
)
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetAllICPCConditions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Creates and returns a table with both Temporary ICPC codes and permanent ICPC codes.
-- =============================================
CREATE FUNCTION [dbo].[GetAllICPCConditions]
(
)
RETURNS @Items TABLE
(
    ICPCCode  VARCHAR(3) NOT NULL,
    TermCode VARCHAR(3) NOT NULL
)
AS
BEGIN
    INSERT @Items(ICPCCode, TermCode)
    SELECT ICPC2TRM.ICPCCode, ICPC2TRM.TermCode
    FROM ICPC2TRM
    
    INSERT @Items(ICPCCode, TermCode)
    SELECT ICPCTempTRM.ICPCCode, ICPCTempTRM.TermCode
    FROM ICPCTempTRM
    RETURN;
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetLabCodesByCategoryId]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Gets mapping LabCodes by category id.
-- =============================================
CREATE FUNCTION [dbo].[GetLabCodesByCategoryId]
(
	@MeasurementCategoryId int = NULL
) 

RETURNS @LabCodesTable 
TABLE ( LabCode VARCHAR(100) )
AS BEGIN
	IF ( @MeasurementCategoryId <> 0 AND @MeasurementCategoryId IS NOT NULL)
	BEGIN
		INSERT @LabCodesTable 
		SELECT DISTINCT MeasurementCategoryLabCodeMapping.LabCode
			FROM MeasurementCategory AS MeasurementCategory
			INNER JOIN MeasurementCategoryLabCodeMapping AS MeasurementCategoryLabCodeMapping 
				ON MeasurementCategory.Id = MeasurementCategoryLabCodeMapping.MeasurementId
			WHERE MeasurementCategory.Id = @MeasurementCategoryId
	END
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetLabCodesByLabResultsCategoryCode]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================
-- Gets mapping LabCodes by LabResultsCategoryCode enum.
-- =====================================================
CREATE FUNCTION [dbo].[GetLabCodesByLabResultsCategoryCode]
(
	@LabResultsCategoryCode int = NULL
) 

RETURNS @LabCodesTable 
TABLE ( LabCode VARCHAR(100) )
AS BEGIN
	IF ( @LabResultsCategoryCode <> 0 AND @LabResultsCategoryCode IS NOT NULL)
	BEGIN
		INSERT @LabCodesTable 
		SELECT DISTINCT MeasurementCategoryLabCodeMapping.LabCode
			FROM MeasurementCategory AS MeasurementCategory
			INNER JOIN MeasurementCategoryLabCodeMapping AS MeasurementCategoryLabCodeMapping 
				ON MeasurementCategory.Id = MeasurementCategoryLabCodeMapping.MeasurementId
			WHERE MeasurementCategory.CategoryCode = @LabResultsCategoryCode
	END
 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPatientsHaveAllConditions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their current conditions and returns result PatientIds.
-- @MustHaveAllConditions contains comma separated ICPCCode:TermCode.
-- =============================================
CREATE FUNCTION [dbo].[GetPatientsHaveAllConditions]
(
    @CurrentDateTime DATETIME = NULL, 
@MustHaveAllConditions VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE PatientDebtor.Id IN
(
		SELECT P.Id
		FROM PatientDebtor AS P
		INNER JOIN statclinical.dbo.Encounter AS E ON P.EhrUid = E.EhrUid
		INNER JOIN statclinical.dbo.Condition AS C ON C.EncounterUid = E.EncounterUid		
		INNER JOIN DelimitedStringValuePairParser(@MustHaveAllConditions, ',', ':') AS ConditionFilterTable ON (ConditionFilterTable.LeftItem = C.ICPCCode AND ConditionFilterTable.RightItem = C.ICPCTermCode)
		WHERE (C.DateExpired IS NULL OR C.DateExpired > @CurrentDateTime) AND
	    NOT EXISTS
	    (
			SELECT * 
			FROM statclinical.dbo.Condition
			INNER JOIN statclinical.dbo.Encounter ON Encounter.EncounterUid = Condition.EncounterUid
			INNER JOIN PatientDebtor ON PatientDebtor.EhrUid = E.EhrUid
			WHERE Condition.OriginalConditionUid = C.OriginalConditionUid AND
			PatientDebtor.EhrUid = P.EhrUid AND
			Condition.ConditionUid != C.ConditionUid AND
			Condition.CreatedDateTimeOffset > C.CreatedDateTimeOffset
	   )
		GROUP BY P.Id
		HAVING COUNT(DISTINCT CAST(C.ICPCCode AS VARCHAR) + CAST(C.ICPCTermCode AS VARCHAR)) = (SELECT COUNT(DISTINCT(CountTable.LeftItem)) FROM DelimitedStringValuePairParser(@MustHaveAllConditions, ',', ':') AS CountTable)
)

 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPatientsHaveAnyCondition]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Filter Patients by using their current conditions and returns result PatientIds.
-- @MustHaveAnyConditions contains comma separated ICPC ICPCCode:TermCode.
-- =============================================
CREATE FUNCTION [dbo].[GetPatientsHaveAnyCondition]
(
    @CurrentDateTime DATETIME = NULL, 
@MustHaveAnyConditions VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE PatientDebtor.Id IN
(
		SELECT P.Id
		FROM PatientDebtor AS P
		INNER JOIN statclinical.dbo.Encounter AS E ON P.EhrUid = E.EhrUid
		INNER JOIN statclinical.dbo.Condition AS C ON C.EncounterUid = E.EncounterUid		
		INNER JOIN DelimitedStringValuePairParser(@MustHaveAnyConditions, ',', ':') AS ConditionFilterTable ON (ConditionFilterTable.LeftItem = C.ICPCCode AND ConditionFilterTable.RightItem = C.ICPCTermCode)
		WHERE (C.DateExpired IS NULL OR C.DateExpired > @CurrentDateTime) AND
	    NOT EXISTS
	    (
			SELECT * 
			FROM statclinical.dbo.Condition
			INNER JOIN statclinical.dbo.Encounter ON Encounter.EncounterUid = Condition.EncounterUid
			INNER JOIN PatientDebtor ON PatientDebtor.EhrUid = E.EhrUid
			WHERE Condition.OriginalConditionUid = C.OriginalConditionUid AND
			PatientDebtor.EhrUid = P.EhrUid AND
			Condition.ConditionUid != C.ConditionUid AND
			Condition.CreatedDateTimeOffset > C.CreatedDateTimeOffset
	   )
)

RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPatientsHaveHadAllVaccinations]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetPatientsHaveHadAllVaccinations]
(
	@MustHaveHadAllVaccinations VARCHAR(MAX) = NULL,
	@VaccinationDateFrom DATETIME = NULL,
	@VaccinationDateTo DATETIME = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE PatientDebtor.Id IN
(
		SELECT PatientDebtor.Id
		FROM PatientDebtor 
		INNER JOIN statclinical.dbo.Encounter ON PatientDebtor.EhrUid = Encounter.EhrUid
		INNER JOIN statclinical.dbo.Vaccination ON Vaccination.EncounterUid = Encounter.EncounterUid	
		--INNER JOIN Vaccine ON Vaccine.VaccineUid = Vaccination.VaccineUid	
		WHERE 
		(Vaccination.VaccineUid IN (SELECT Id FROM DelimitedStringParamParser(@MustHaveHadAllVaccinations, ','))) AND
		(@VaccinationDateFrom IS NULL OR @VaccinationDateFrom <= CAST(Vaccination.GivenDateTimeOffset AS DateTime)) AND
		(@VaccinationDateTo IS NULL OR @VaccinationDateTo >= CAST(Vaccination.GivenDateTimeOffset AS DateTime)) AND
		(Vaccination.Removed != '1')
		GROUP BY PatientDebtor.Id
		HAVING COUNT(DISTINCT(Vaccination.VaccineUid)) = (SELECT COUNT(DISTINCT(Id)) FROM DelimitedStringParamParser(@MustHaveHadAllVaccinations, ','))
)

 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPatientsHaveHadAnyVaccination]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetPatientsHaveHadAnyVaccination]
(
	@MustHaveHadAnyVaccination VARCHAR(MAX) = NULL,
	@VaccinationDateFrom DATETIME = NULL,
	@VaccinationDateTo DATETIME = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE PatientDebtor.Id IN
(
		SELECT PatientDebtor.Id
		FROM PatientDebtor 
		INNER JOIN statclinical.dbo.Encounter ON PatientDebtor.EhrUid = Encounter.EhrUid
		INNER JOIN statclinical.dbo.Vaccination ON Vaccination.EncounterUid = Encounter.EncounterUid
		--INNER JOIN Vaccine ON Vaccine.VaccineUid = Vaccination.VaccineUid	
		WHERE (Vaccination.VaccineUid IN (SELECT Id FROM DelimitedStringParamParser(@MustHaveHadAnyVaccination, ','))) AND
		(@VaccinationDateFrom IS NULL OR @VaccinationDateFrom <= CAST(Vaccination.GivenDateTimeOffset AS DateTime)) AND
		(@VaccinationDateTo IS NULL OR @VaccinationDateTo >= CAST(Vaccination.GivenDateTimeOffset AS DateTime)) AND
		(Vaccination.Removed != '1')
)

 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPatientsTakeAllMedications]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[GetPatientsTakeAllMedications]
(
    @CurrentDateTimeOffset DATETIMEOFFSET = NULL, 
	@MustTakeAllMedications VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE PatientDebtor.Id IN
(
SELECT PatientDebtor.Id
		FROM PatientDebtor 
		INNER JOIN statclinical.dbo.CurrentMedication ON PatientDebtor.EhrUid = CurrentMedication.EhrUid
		INNER JOIN DelimitedValuePairParser(@MustTakeAllMedications, ',', ':') AS MedicationFilterTable ON (MedicationFilterTable.LeftItem = CurrentMedication.ProdCode AND MedicationFilterTable.RightItem = CurrentMedication.FormCode)
		WHERE 
		  ( CurrentMedication.CurrentPeriod = 1 OR 
		  CurrentMedication.LastPrescribedDateTimeOffset IS NULL OR 
		  CurrentMedication.LastPrescribedDateTimeOffset >= DateAdd(mm, -1, @CurrentDateTimeOffset)) AND 
		  CurrentMedication.ToBePrescribed IS NULL	AND
		  CurrentMedication.VersionNumber = 0	AND
		  CurrentMedication.ProdCode IS NOT NULL AND
		  CurrentMedication.FormCode IS NOT NULL AND
		  CurrentMedication.PackCode IS NOT NULL	
		GROUP BY PatientDebtor.Id
		--  Create a derived column made up of the multiple columns in order to get COUNT worked with multiple columns.		
		HAVING COUNT(DISTINCT (CAST(CurrentMedication.ProdCode AS VARCHAR) + CAST(CurrentMedication.FormCode AS VARCHAR))) = 
		(SELECT COUNT (DISTINCT(CAST(CountTable.LeftItem AS VARCHAR) + CAST(CountTable.RightItem AS VARCHAR))) FROM DelimitedValuePairParser(@MustTakeAllMedications, ',', ':') AS CountTable)
)

 RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetPatientsTakeAnyMedication]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[GetPatientsTakeAnyMedication]
(
    @CurrentDateTimeOffset DATETIMEOFFSET = NULL, 
	@MustTakeAtLeastOneMedication VARCHAR(MAX) = NULL
) 

RETURNS @PatientIdTable 
TABLE ( PatientId INT )
AS BEGIN

INSERT @PatientIdTable SELECT PatientDebtor.Id FROM PatientDebtor
WHERE PatientDebtor.Id IN
(
	SELECT PatientDebtor.Id
	FROM PatientDebtor 
	INNER JOIN statclinical.dbo.CurrentMedication ON PatientDebtor.EhrUid = CurrentMedication.EhrUid
	INNER JOIN DelimitedValuePairParser(@MustTakeAtLeastOneMedication, ',', ':') AS MedicationFilterTable ON (MedicationFilterTable.LeftItem = CurrentMedication.ProdCode AND MedicationFilterTable.RightItem = CurrentMedication.FormCode)
	WHERE 
	  ( CurrentMedication.CurrentPeriod = 1 OR 
	  CurrentMedication.LastPrescribedDateTimeOffset IS NULL OR 
	  CurrentMedication.LastPrescribedDateTimeOffset >= DateAdd(mm, -1, @CurrentDateTimeOffset)) AND 
	  CurrentMedication.ToBePrescribed IS NULL	AND
	  CurrentMedication.VersionNumber = 0	AND
	  CurrentMedication.ProdCode IS NOT NULL AND
	  CurrentMedication.FormCode IS NOT NULL AND
	  CurrentMedication.PackCode IS NOT NULL		
)

 RETURN
END

GO
/****** Object:  Table [dbo].[AcirClaim]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AcirClaim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimId] [varchar](8) NOT NULL,
	[UserId] [int] NOT NULL,
	[TransactionId] [varchar](24) NOT NULL,
	[ClaimDateTimeOffset] [datetimeoffset](7) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Address]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Address](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[State] [varchar](3) NULL,
	[Postcode] [varchar](4) NULL,
	[Street1] [varchar](60) NULL,
	[Street2] [varchar](60) NULL,
	[Street3] [varchar](60) NULL,
	[SearchKey1] [varchar](60) NULL,
	[SearchKey2] [varchar](60) NULL,
	[SearchKey3] [varchar](60) NULL,
	[Suburb] [varchar](80) NULL,
	[OverseasAddress] [int] NULL,
 CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddressBook]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AddressBook](
	[AddressBookId] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NULL,
	[SpecialityId] [int] NULL,
	[AddressBookGroupId] [int] NULL,
	[EntityType] [int] NULL,
	[LegalPersonNameId] [int] NULL,
	[PreferredPersonNameId] [int] NULL,
	[OrganisationName] [varchar](100) NULL,
	[ContactPosition] [varchar](50) NULL,
	[StreetAddressId] [int] NULL,
	[PostalAddressId] [int] NULL,
	[HomePhoneContactId] [int] NULL,
	[WorkPhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[MobilePhoneContactId] [int] NULL,
	[PagerPhoneContactId] [int] NULL,
	[PagerNumber] [varchar](10) NULL,
	[EmailContactId] [int] NULL,
	[AvailableForRequestsTo] [int] NULL,
	[PathologyRequestEntryFormType] [int] NULL,
	[PathologyRequestTestListType] [int] NULL,
	[PathologyRequestReportFormType] [int] NULL,
	[RadiologyRequestEntryFormType] [int] NULL,
	[RadiologyRequestTestListType] [int] NULL,
	[RadiologyRequestReportFormType] [int] NULL,
	[AvailableForResultsFrom] [int] NULL,
	[ProviderNumber] [varchar](8) NULL,
	[AddressBookNote] [varchar](max) NULL,
	[AddressBookPhoto] [varbinary](max) NULL,
	[AddressBookThumbNail] [varbinary](max) NULL,
	[IsAssistant] [int] NULL,
	[ClinicalFacilityIdentifier] [varchar](180) NULL,
	[FacilityType] [int] NULL,
	[ConvertedSystemId] [varchar](50) NULL,
	[RowVersion] [timestamp] NULL,
	[LinkedOrganisationAddressBookId] [int] NULL,
	[HealthcareIdentifier] [varchar](16) NULL,
	[HiLastUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
	[AvailableForMessagesTo] [int] NULL,
	[MessagesToReferrals] [int] NULL,
	[MessagesToReports] [int] NULL,
	[MessagesToFormat] [int] NULL,
	[MessagesToTransportUid] [uniqueidentifier] NULL,
	[MessagesToAddressNamespaceId] [varchar](200) NULL,
	[MessagesToAddressUniversalId] [varchar](200) NULL,
	[MessagesToAddressUniversalIdType] [varchar](200) NULL,
	[OtherFacilityDocumentType] [int] NULL,
 CONSTRAINT [PK_AddressBook] PRIMARY KEY CLUSTERED 
(
	[AddressBookId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddressBookGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AddressBookGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_AddressBookGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddressBookIdentifier]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AddressBookIdentifier](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AddressBookId] [int] NULL,
	[IdentifierId] [int] NULL,
	[Value] [varchar](10) NULL,
 CONSTRAINT [PK_AddressBookIdentifier] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddressBookMessagingFacilityId]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AddressBookMessagingFacilityId](
	[AddressBookId] [int] NOT NULL,
	[MessagingTransportUid] [uniqueidentifier] NOT NULL,
	[NamespaceId] [varchar](200) NOT NULL,
	[UniversalId] [varchar](200) NULL,
	[UniversalIdType] [varchar](200) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AdjustmentType]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdjustmentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[AdjustmentTypeCode] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_AdjustmentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppointmentCancelledReason]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppointmentCancelledReason](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[DidNotArriveWarningPrompt] [bit] NOT NULL,
 CONSTRAINT [PK_AppointmentCancelledReason] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppointmentCustomField]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppointmentCustomField](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[ForeColor] [int] NULL,
	[BackColor] [int] NULL,
	[ArrivedForeColor] [int] NULL,
	[ArrivedBackColor] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_AppointmentCustomField] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppointmentHistory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppointmentHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EpisodeId] [int] NULL,
	[PatientId] [int] NULL,
	[ResourceId] [int] NULL,
	[AppointmentDateTime] [datetime] NULL,
	[AppointmentTypeId] [int] NULL,
	[LocationId] [int] NULL,
	[UserId] [int] NULL,
	[Reason] [int] NULL,
	[AppointmentConfirmedById] [int] NULL,
	[AppointmentName] [varchar](200) NULL,
	[AppointmentCustomFieldId] [int] NULL,
	[MoveReasonCode] [int] NULL,
	[MoveReasonNotes] [varchar](500) NULL,
	[AppointmentConfirmedDateTimeOffset] [datetimeoffset](7) NULL,
	[ChangeDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[AppointmentCreatedById] [int] NULL,
	[AppointmentCancelledById] [int] NULL,
	[AppointmentCreatedDateTimeOffset] [datetimeoffset](7) NULL,
	[AppointmentCancelledDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AppointmentHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppointmentReminder]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppointmentReminder](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NULL,
	[Description] [varchar](50) NULL,
	[ManuscriptTemplateUid] [uniqueidentifier] NULL,
	[PatientContactConsentType] [int] NULL,
	[DaysInFuture] [int] NULL,
	[AllResources] [int] NULL,
	[ResourceIds] [varchar](500) NULL,
	[AllAppointmentTypes] [int] NULL,
	[AppointmentTypeIds] [varchar](500) NULL,
	[ReferralOption] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[LastRunDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AppointmentReminder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppointmentType]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppointmentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NULL,
	[DisplayCharacter] [char](1) NOT NULL,
	[DisplayCharacterFont] [varchar](50) NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[ForeColor] [int] NULL,
	[BackColor] [int] NULL,
	[ArrivedForeColor] [int] NULL,
	[ArrivedBackColor] [int] NULL,
	[DefaultAppointmentLength] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_AppointmentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Attachment]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Attachment](
	[AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[Attachment] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED 
(
	[AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Autotext]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Autotext](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserIdAvailableTo] [int] NULL,
	[Inactive] [int] NOT NULL,
	[OriginalText] [varchar](10) NOT NULL,
	[SubstitutionText] [varchar](max) NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Autotext] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankAccount]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankAccount](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[LegalEntityId] [int] NULL,
	[AccountName] [varchar](50) NULL,
	[Bank] [varchar](50) NULL,
	[Branch] [varchar](50) NULL,
	[BSB] [varchar](6) NULL,
	[AccountNumber] [varchar](50) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[TyroMerchantId] [varchar](10) NULL,
	[LastIntegratedEftposReconciliationDate] [datetime] NULL,
 CONSTRAINT [PK_BankAccount] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankRun]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankRun](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BankAccountId] [int] NULL,
	[LocationId] [int] NULL,
	[UserId] [int] NULL,
	[BankRunType] [int] NULL,
	[BankedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_BankRun] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BaseFee]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BaseFee](
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Uid] [uniqueidentifier] NOT NULL,
	[DownloadCode] [varchar](50) NULL,
	[SetupDisplayString] [varchar](200) NULL,
	[SpecialType] [int] NULL,
	[IsHealthFundBaseFee] [bit] NOT NULL,
 CONSTRAINT [PK_BaseFee_1] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BaseValue]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BaseValue](
	[BaseValueId] [int] NOT NULL,
	[Description] [varchar](50) NULL,
 CONSTRAINT [PK_BaseValue] PRIMARY KEY CLUSTERED 
(
	[BaseValueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Billcode]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Billcode](
	[Inactive] [int] NOT NULL,
	[Reference] [int] NULL,
	[SpecialBillcode] [int] NULL,
	[ManualPricing] [int] NULL,
	[Description] [varchar](50) NULL,
	[InvoiceMethod] [int] NULL,
	[InvoiceProcessing] [int] NULL,
	[DefaultDebtorType] [int] NULL,
	[DefaultDebtorId] [int] NULL,
	[DisplayOrder] [int] NULL,
	[AutoFee1] [int] NULL,
	[AutoFee2] [int] NULL,
	[AutoFee3] [int] NULL,
	[AutoFee4] [int] NULL,
	[AutoFee5] [int] NULL,
	[AutoFee6] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Uid] [uniqueidentifier] NOT NULL,
	[PracticeFee] [int] NULL,
	[Downloadable] [int] NULL,
	[AutoFee7] [int] NULL,
	[Id] [int] NULL,
	[AutoFee8] [int] NULL,
	[AutoFee9] [int] NULL,
	[ShowGapAmount] [int] NULL,
 CONSTRAINT [PK_Billcode_1] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BillcodeDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BillcodeDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProviderId] [int] NULL,
	[PatientClassificationId] [int] NULL,
	[HealthFundId] [int] NULL,
	[ServiceGroupId] [int] NULL,
	[InHospital] [int] NULL,
	[InHours] [int] NULL,
	[BaseFeeId] [int] NULL,
	[MBSPricingDisabled] [int] NULL,
	[FactorType] [int] NULL,
	[FactorAmount] [decimal](10, 2) NULL,
	[MBSRebateOption] [int] NULL,
	[FundRebateBillcodeId] [int] NULL,
	[AssistFeeBasis] [int] NULL,
	[MinimumGap] [decimal](10, 2) NULL,
	[MaximumGap] [decimal](10, 2) NULL,
	[RoundingMethod] [int] NULL,
	[RoundingAmount] [int] NULL,
	[InvoiceMinimumGap] [decimal](10, 2) NULL,
	[InvoiceMinimumGapDiscountLine] [int] NULL,
	[InvoiceMaximumGap] [decimal](10, 2) NULL,
	[InvoiceMaximumGapDiscountLine] [int] NULL,
	[InvoiceDiscountType] [int] NULL,
	[InvoiceDiscountAmount] [decimal](10, 2) NULL,
	[InvoiceDiscountAmountDiscountLine] [int] NULL,
	[InvoiceDiscountOptional] [int] NULL,
	[InvoiceRoundingMethod] [int] NULL,
	[InvoiceRoundingAmount] [int] NULL,
	[InvoiceRoundingLine] [int] NULL,
	[InvoiceInvoiceNote] [varchar](max) NULL,
	[MultiOperationRuleType] [int] NULL,
	[ApplyMinimumGap] [int] NULL,
	[ApplyMaximumGap] [int] NULL,
	[InvoiceApplyMinimumGap] [int] NULL,
	[InvoiceApplyMaximumGap] [int] NULL,
	[BillcodeUid] [uniqueidentifier] NULL,
	[HealthFundUid] [uniqueidentifier] NULL,
	[HealthFundGroupUid] [uniqueidentifier] NULL,
	[Alert] [varchar](max) NULL,
	[AlertWhenZero] [int] NULL,
	[PriceCalculationType] [int] NULL,
	[BaseFeeUid] [uniqueidentifier] NULL,
	[PriceCalculationBillcodeUid] [uniqueidentifier] NULL,
	[FundRebateCalculationType] [int] NULL,
	[FundRebateBaseFeeUid] [uniqueidentifier] NULL,
	[FundRebateFactorType] [int] NULL,
	[FundRebateFactorAmount] [decimal](10, 2) NULL,
	[FundRebateBillcodeUid] [uniqueidentifier] NULL,
	[ActivateDualItemPricing] [int] NULL,
	[DualPriceOption] [int] NULL,
	[PriceCalculationType2] [int] NULL,
	[BaseFeeUid2] [uniqueidentifier] NULL,
	[FactorType2] [int] NULL,
	[FactorAmount2] [decimal](10, 2) NULL,
	[PriceCalculationBillcodeUid2] [uniqueidentifier] NULL,
	[MBSRebateOption2] [int] NULL,
	[FundRebateCalculationType2] [int] NULL,
	[FundRebateBaseFeeUid2] [uniqueidentifier] NULL,
	[FundRebateFactorType2] [int] NULL,
	[FundRebateFactorAmount2] [decimal](10, 2) NULL,
	[FundRebateBillcodeUid2] [uniqueidentifier] NULL,
	[AssistFeeBasis2] [int] NULL,
	[ApplyMinimumGap2] [int] NULL,
	[MinimumGap2] [decimal](10, 2) NULL,
	[ApplyMaximumGap2] [int] NULL,
	[MaximumGap2] [decimal](10, 2) NULL,
	[RoundingMethod2] [int] NULL,
	[RoundingAmount2] [int] NULL,
	[HealthFundMaximumGapOption] [int] NULL,
	[HealthFundApplyMinimumGap] [int] NULL,
	[HealthFundMinimumGap] [decimal](10, 2) NULL,
	[HealthFundApplyMaximumGap] [int] NULL,
	[HealthFundMaximumGap] [decimal](10, 2) NULL,
	[HealthFundMaximumGapBillcodeUid] [uniqueidentifier] NULL,
	[BillcodeId] [int] NULL,
	[PricingOption] [int] NULL,
	[AssistFeeBasisPrice] [int] NULL,
	[AssistFeeBasisRebate] [int] NULL,
	[AssistFeeBasisPrice2] [int] NULL,
	[AssistFeeBasisRebate2] [int] NULL,
	[UserId] [int] NULL,
	[MBSRuleTypePrice] [int] NULL,
	[MBSRuleTypeRebate] [int] NULL,
	[MBSRuleTypePrice2] [int] NULL,
	[MBSRuleTypeRebate2] [int] NULL,
	[HealthFundPerProviderGap] [int] NULL,
	[AssistFeeBasisSpecifiedGapPrice] [decimal](10, 2) NULL,
	[AssistFeeBasisSpecifiedGapRebate] [decimal](10, 2) NULL,
	[AssistFeeBasisSpecifiedGapPrice2] [decimal](10, 2) NULL,
	[AssistFeeBasisSpecifiedGapRebate2] [decimal](10, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Billing]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Billing](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EpisodeId] [int] NULL,
	[Status] [int] NULL,
	[DebtorType] [int] NULL,
	[OtherDebtorId] [int] NULL,
	[AfterHours] [int] NULL,
	[Eligible10992] [int] NULL,
	[LocationId] [int] NULL,
	[UserId] [int] NULL,
	[InvoiceNote] [varchar](500) NULL,
	[AmountBilled] [money] NULL,
	[AmountSchedule] [money] NULL,
	[AmountRebate] [money] NULL,
	[AmountRebateFund] [money] NULL,
	[AmountGST] [money] NULL,
	[GSTType] [int] NULL,
	[HospitalId] [int] NULL,
	[ReferralOverride] [int] NULL,
	[ReasonForOverrideDescription] [varchar](150) NULL,
	[ReferralReasonIfOverride] [varchar](150) NULL,
	[ReferralId] [int] NULL,
	[InvoiceReferenceId] [int] NULL,
	[Verified] [int] NULL,
	[DirectBillClaimId] [int] NULL,
	[ocClaimType] [int] NULL,
	[ocClaimId] [varchar](22) NULL,
	[ocVoucherId] [varchar](2) NULL,
	[PPCAssessmentType] [int] NULL,
	[ocFullyPaid] [int] NULL,
	[ocPaymentMethod] [int] NULL,
	[ocPayToAddress] [int] NULL,
	[ocBankAccountName] [varchar](50) NULL,
	[ocBankAccountNumber] [varchar](50) NULL,
	[ocBankBSB] [varchar](6) NULL,
	[ocPpcImcClaimType] [int] NULL,
	[ocTransactionId] [varchar](50) NULL,
	[ocAdmissionDate] [datetime] NULL,
	[ocDischargeDate] [datetime] NULL,
	[ocIfcIssue] [int] NULL,
	[ocAccidentInd] [int] NULL,
	[ocCompensationClaim] [int] NULL,
	[ocFinancialInterestDisclosed] [int] NULL,
	[dvaAssignedBenefitCode] [int] NULL,
	[dvaAssignedBenefitReason] [varchar](100) NULL,
	[dvaEmergencyCode] [int] NULL,
	[dvaTreamentLocationCode] [int] NULL,
	[dvaTreamentLocationAdmitted] [int] NULL,
	[dvaCHFPNo] [varchar](8) NULL,
	[dvaReportIssued] [int] NULL,
	[dvaConditionTreatedCode] [int] NULL,
	[dvaWhiteCardCondition] [int] NULL,
	[dvaConditionTreatedDescription] [varchar](100) NULL,
	[dvaLostStolenDate] [datetime] NULL,
	[dvaStatutoryDeclarationSighted] [int] NULL,
	[dvaKilometres] [int] NULL,
	[x400ServiceText] [varchar](50) NULL,
	[HoldReason] [varchar](50) NULL,
	[VerifyHoldReasonId] [int] NULL,
	[ocSuspect] [int] NULL,
	[PracticeLocationId] [int] NULL,
	[BillcodeUid] [uniqueidentifier] NULL,
	[PracticeBillcodeUid] [uniqueidentifier] NULL,
	[HospitalUid] [uniqueidentifier] NULL,
	[BillDateTimeOffset] [datetimeoffset](7) NULL,
	[ClaimDateTimeOffset] [datetimeoffset](7) NULL,
	[ocLodgeDateTimeOffset] [datetimeoffset](7) NULL,
	[ocSuspectDateTimeOffset] [datetimeoffset](7) NULL,
	[NoReferralSelected] [int] NULL,
	[EclipseEnabled] [int] NULL,
	[Modality] [int] NOT NULL,
	[LSPNOverrideMobileLSPNId] [int] NULL,
 CONSTRAINT [PK_Billing] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BillingAdditionalInvoiceDetails]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BillingAdditionalInvoiceDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BillingId] [int] NOT NULL,
	[OptionName] [varchar](500) NULL,
	[OptionValue] [varchar](5000) NULL,
 CONSTRAINT [PK_BillingAdditionalInvoiceDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BillingDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BillingDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BillingId] [int] NULL,
	[ServiceId] [int] NULL,
	[AutoGeneratedItem] [int] NULL,
	[AmountBilled] [money] NULL,
	[AmountBilledClaimed] [money] NULL,
	[AmountSchedule] [money] NULL,
	[AmountRebate] [money] NULL,
	[AmountRebateFund] [money] NULL,
	[AmountBenefit] [money] NULL,
	[AmountPatientContribution] [money] NULL,
	[AmountPatientContributionClaimed] [money] NULL,
	[ManuallyEntered] [int] NULL,
	[AdditionalDescription] [varchar](250) NULL,
	[AfterCareOverride] [int] NULL,
	[AfterCareOverrideReason] [varchar](100) NULL,
	[DuplicateServiceOverride] [int] NULL,
	[DuplicateServiceOverrideReason] [varchar](100) NULL,
	[MultipleProcedureOverride] [int] NULL,
	[MultipleProcedureOverrideReason] [varchar](100) NULL,
	[EquipmentId] [char](5) NULL,
	[DerivedFeePatientsSeen] [int] NULL,
	[DerivedFeeFoetuses] [int] NULL,
	[DerivedFeeFieldQuantity] [int] NULL,
	[DerivedFeeTimeDuration] [int] NULL,
	[SelfDeemedCde] [int] NULL,
	[dvaSelfDeterminedReason] [varchar](100) NULL,
	[ocServiceId] [varchar](4) NULL,
	[ocReasonCode] [int] NULL,
	[AssistantAddressBookId] [int] NULL,
	[RestrictiveConditionOverride] [int] NULL,
	[ServiceItemDetailId] [int] NULL,
	[EligibleItemServiceItemDetailId] [int] NULL,
	[AdditionalDescriptionAssistItems] [varchar](200) NULL,
	[ServiceReference] [varchar](3) NULL,
 CONSTRAINT [PK_EpisodeDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BillingHoldReason]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BillingHoldReason](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_BillingHoldReason] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CDCGrowthChartData]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CDCGrowthChartData](
	[CDCType] [varchar](50) NOT NULL,
	[Sex] [int] NOT NULL,
	[Axis] [decimal](18, 1) NOT NULL,
	[L] [decimal](18, 8) NOT NULL,
	[M] [decimal](18, 8) NOT NULL,
	[S] [decimal](18, 8) NOT NULL,
	[P3] [decimal](18, 8) NOT NULL,
	[P5] [decimal](18, 8) NOT NULL,
	[P10] [decimal](18, 8) NOT NULL,
	[P25] [decimal](18, 8) NOT NULL,
	[P50] [decimal](18, 8) NOT NULL,
	[P75] [decimal](18, 8) NOT NULL,
	[P85] [decimal](18, 8) NULL,
	[P90] [decimal](18, 8) NOT NULL,
	[P95] [decimal](18, 8) NOT NULL,
	[P97] [decimal](18, 8) NOT NULL,
 CONSTRAINT [PK_CDCGrowthChartData] PRIMARY KEY CLUSTERED 
(
	[CDCType] ASC,
	[Sex] ASC,
	[Axis] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CDCGrowthChartDatum]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CDCGrowthChartDatum](
	[CDCType] [varchar](50) NOT NULL,
	[Sex] [int] NOT NULL,
	[Axis] [decimal](18, 1) NOT NULL,
	[Percentile] [int] NOT NULL,
	[Value] [decimal](18, 8) NOT NULL,
 CONSTRAINT [PK_CDCGrowthChartDatum] PRIMARY KEY CLUSTERED 
(
	[CDCType] ASC,
	[Sex] ASC,
	[Axis] ASC,
	[Percentile] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalCache]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalCache](
	[CacheGuid] [uniqueidentifier] NOT NULL,
	[EhrUid] [varchar](50) NOT NULL,
	[ReadOnlyGuid] [uniqueidentifier] NULL,
	[CachedType] [varchar](150) NOT NULL,
	[EncounterOwnerId] [int] NULL,
	[EncounterCacheGuid] [uniqueidentifier] NULL,
	[ParentCacheGuid] [uniqueidentifier] NULL,
	[ParentPropertyName] [varchar](50) NULL,
	[VersionGuid] [uniqueidentifier] NOT NULL,
	[ChildVersionGuid] [uniqueidentifier] NULL,
	[Locked] [bit] NULL,
	[LockedToUserId] [int] NULL,
	[LockedToInstanceGuid] [uniqueidentifier] NULL,
	[Blob] [image] NOT NULL,
 CONSTRAINT [PK_ClinicalCache] PRIMARY KEY CLUSTERED 
(
	[CacheGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalCacheOwner]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalCacheOwner](
	[ClinicalCacheGuid] [uniqueidentifier] NOT NULL,
	[ClinicalInstanceGuid] [uniqueidentifier] NOT NULL,
	[OwnedByUserId] [int] NOT NULL,
	[OwnedByMachineName] [varchar](50) NOT NULL,
	[OwnedByProcessId] [int] NOT NULL,
	[IsOwner] [bit] NOT NULL,
 CONSTRAINT [PK_ClinicalCacheOwner] PRIMARY KEY CLUSTERED 
(
	[ClinicalCacheGuid] ASC,
	[ClinicalInstanceGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalHealthRecordSummaryViewDefaults]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalHealthRecordSummaryViewDefaults](
	[ClinicalHealthRecordSummaryViewDefaultsId] [int] IDENTITY(1,1) NOT NULL,
	[ViewName] [varchar](25) NOT NULL,
	[UserId] [int] NULL,
	[Sequence] [int] NULL,
	[Inactive] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ClinicalHealthRecordSummaryViewDefaults] PRIMARY KEY CLUSTERED 
(
	[ClinicalHealthRecordSummaryViewDefaultsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalHealthRecordSummaryViewDefaultsDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalHealthRecordSummaryViewDefaultsDetail](
	[ClinicalHealthRecordSummaryViewDefaultsId] [int] NOT NULL,
	[Sequence] [int] NOT NULL,
	[UserControlName] [varchar](max) NOT NULL,
	[ClinicalSummaryHeadingId] [int] NULL,
 CONSTRAINT [PK_ClinicalHealthRecordSummaryViewDefaults_1] PRIMARY KEY CLUSTERED 
(
	[ClinicalHealthRecordSummaryViewDefaultsId] ASC,
	[Sequence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalImage]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalImage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ImageBlob] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_ClinicalImage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalSummaryHeading]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalSummaryHeading](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Private] [bit] NOT NULL,
 CONSTRAINT [PK_ClinicalSummaryHeading] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CompletedReports]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CompletedReports](
	[ReportUid] [uniqueidentifier] NOT NULL,
	[ReportName] [varchar](200) NULL,
	[ReportDescription] [varchar](200) NULL,
	[Status] [int] NULL,
	[ParameterDescription] [varchar](500) NULL,
	[PrintOrView] [int] NULL,
	[UserId] [int] NULL,
	[WorkstationId] [int] NULL,
	[ReportData] [varchar](max) NULL,
	[LastPrintedDateTimeOffset] [datetimeoffset](7) NULL,
	[RunDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[ErrorString] [varchar](max) NULL,
 CONSTRAINT [PK_CompletedReports] PRIMARY KEY CLUSTERED 
(
	[ReportUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[IsSystemCategory] [bit] NOT NULL,
	[Inactive] [bit] NOT NULL,
	[Description] [varchar](1000) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ConditionCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionGroup](
	[Uid] [uniqueidentifier] NOT NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_ConditionGroup] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionQuickList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ICPCCode] [char](3) NULL,
	[ICPCTermCode] [char](3) NULL,
	[Description] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ConditionQuickList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionSubCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionSubCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[CategoryId] [int] NOT NULL,
	[IsSystemSubCategory] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[CatDiagnosesType] [int] NULL,
 CONSTRAINT [PK_ConditionSubCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionSubCategoryIcpcMapping]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionSubCategoryIcpcMapping](
	[SubCategoryId] [int] NOT NULL,
	[ICPCCode] [char](3) NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[TermCode] [char](3) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionSubgroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionSubgroup](
	[Uid] [uniqueidentifier] NOT NULL,
	[ConditionGroupUid] [uniqueidentifier] NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_ConditionSubgroup] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionSubgroupICPC]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConditionSubgroupICPC](
	[ConditionSubgroupUid] [uniqueidentifier] NULL,
	[ICPCCode] [char](3) NULL,
	[TermCode] [char](3) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Contact]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Contact](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Detail] [varchar](200) NULL,
 CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DebtorClassification]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DebtorClassification](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_DebtorClassification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DebtorGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DebtorGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_DebtorGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DirectBillClaim]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirectBillClaim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimId] [varchar](8) NULL,
	[ClaimType] [int] NULL,
	[ServiceProviderId] [int] NULL,
	[ClaimStatus] [int] NULL,
	[ProcessedStatus] [int] NULL,
	[TransactionId] [varchar](24) NULL,
	[VoucherCount] [int] NULL,
	[AmountClaimed] [money] NULL,
	[ClaimBenefitPaid] [money] NULL,
	[DirectBillPaymentId] [int] NULL,
	[Suspect] [int] NULL,
	[ClaimDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[LastOnlinePaymentCheckDateTimeOffset] [datetimeoffset](7) NULL,
	[LastOnlineProcessingCheckDateTimeOffset] [datetimeoffset](7) NULL,
	[PaymentReportDateTimeOffset] [datetimeoffset](7) NULL,
	[ProcessingReportDateTimeOffset] [datetimeoffset](7) NULL,
	[SuspectDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_DirectBillClaim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DirectBillClaimException]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirectBillClaimException](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DirectBillClaimId] [int] NULL,
	[BillingId] [int] NULL,
	[MedicareCardFlag] [char](1) NULL,
	[FirstName] [varchar](50) NULL,
	[FamilyName] [varchar](50) NULL,
	[ExceptionProcessMethod] [int] NULL,
	[ExceptionProcessDateTimeOffset] [datetimeoffset](7) NULL,
	[ExceptionProcessedByUserId] [int] NULL,
 CONSTRAINT [PK_DirectBillClaimException] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DirectBillClaimExceptionDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirectBillClaimExceptionDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DirectBillClaimExceptionId] [int] NULL,
	[ExplanationCode] [char](3) NULL,
	[AmountClaimed] [money] NULL,
	[AmountPaid] [money] NULL,
	[BillingDetailId] [int] NULL,
	[InvoiceDetailId] [int] NULL,
	[AutoAccept] [int] NULL,
 CONSTRAINT [PK_DirectBillClaimExceptionDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DirectBillClaimExceptionReason]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirectBillClaimExceptionReason](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimType] [int] NULL,
	[ExceptionCode] [char](5) NULL,
	[ExceptionReason] [varchar](200) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DirectBillPayment]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirectBillPayment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PaymentRunDate] [datetime] NULL,
	[PaymentRunNum] [int] NULL,
	[AmountDeposit] [money] NULL,
	[BSB] [varchar](6) NULL,
	[AccountNumber] [varchar](50) NULL,
	[AccountName] [varchar](50) NULL,
	[BankRunId] [int] NULL,
 CONSTRAINT [PK_DirectBillPayment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Document]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Document](
	[DocumentId] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[OriginalPath] [varchar](250) NULL,
	[OriginalFileName] [varchar](100) NULL,
	[OriginalSuffix] [varchar](50) NOT NULL,
	[OriginalSize] [bigint] NULL,
	[Description] [varchar](100) NULL,
	[Keywords] [varchar](250) NULL,
	[TemplatesAvailableId] [int] NULL,
	[UserId] [int] NOT NULL,
	[DocumentCategoryId] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[DocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DocumentCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NULL,
	[Description] [varchar](50) NULL,
	[DocumentType] [int] NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_DocumentCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DocumentInPool]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentInPool](
	[DocumentInPoolId] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[OriginalFileName] [varchar](100) NOT NULL,
	[OriginalSuffix] [varchar](50) NULL,
	[OriginalSize] [bigint] NULL,
	[UserId] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_DocumentInPool] PRIMARY KEY CLUSTERED 
(
	[DocumentInPoolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DocumentNextAction]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentNextAction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[ActionName] [varchar](50) NOT NULL,
	[Status] [int] NULL,
	[DoNotChangeStatus] [bit] NOT NULL,
	[NextActionByOption] [int] NOT NULL,
	[NextActionByUserId] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_DocumentQuickAction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DocumentNextActionAvailableTo]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentNextActionAvailableTo](
	[DocumentNextActionId] [int] NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DocumentNextActionSelectedUserIds]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentNextActionSelectedUserIds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DocumentNextActionId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_DocumentQuickActionSelectedUserIds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DocumentReviewAction]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentReviewAction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReviewName] [varchar](100) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[UsedForPathology] [bit] NOT NULL,
	[UsedForRadiology] [bit] NOT NULL,
	[UsedForIncomingDocuments] [bit] NOT NULL,
	[MarkAsReviewed] [bit] NOT NULL,
	[OpenHealthRecord] [bit] NOT NULL,
	[CreateAnnotation] [bit] NOT NULL,
	[AnnotationOption] [int] NULL,
	[AnnotationText] [varchar](max) NULL,
	[AnnotationAllowEditText] [bit] NOT NULL,
	[SendSms] [bit] NOT NULL,
	[SmsOption] [int] NULL,
	[SmsTemplateUid] [uniqueidentifier] NULL,
	[SmsAllowEditTemplate] [bit] NOT NULL,
	[SmsText] [varchar](max) NULL,
	[SmsAllowEditText] [bit] NOT NULL,
	[CreateToDo] [bit] NOT NULL,
	[ToDoOption] [int] NULL,
	[ToDoTemplateId] [int] NULL,
	[ToDoAllowEditTemplate] [bit] NOT NULL,
	[ToDoSelectStartDate] [bit] NOT NULL,
	[ToDoSelectDueDate] [bit] NOT NULL,
	[ToDoUseMasterTextAsNotes] [bit] NOT NULL,
	[CreateRecall] [bit] NOT NULL,
	[RecallOption] [int] NULL,
	[RecallTemplateId] [int] NULL,
	[RecallAllowEditTemplate] [bit] NOT NULL,
	[RecallSelectDueDate] [bit] NOT NULL,
	[RecallUseMasterTextAsNotes] [bit] NOT NULL,
	[CreateEncounter] [bit] NOT NULL,
	[EncounterOption] [int] NULL,
	[EncounterText] [varchar](max) NULL,
	[EncounterAllowEditText] [bit] NOT NULL,
	[EncounterDescription] [varchar](250) NULL,
	[EncounterAllowEditDescription] [bit] NOT NULL,
	[EncounterDescriptionAppendResultDescription] [bit] NOT NULL,
	[MasterTextOption] [int] NULL,
	[MasterTextSmsTemplateUid] [uniqueidentifier] NULL,
	[MasterTextAllowEditSmsTemplate] [bit] NOT NULL,
	[MasterTextToDoTemplateId] [int] NULL,
	[MasterTextAllowEditToDoTemplate] [bit] NOT NULL,
	[MasterText] [varchar](max) NULL,
	[MasterTextAllowEdit] [bit] NOT NULL,
 CONSTRAINT [PK_DocumentReviewAction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DocumentTemplate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentTemplate](
	[DocumentTemplateId] [int] IDENTITY(1,1) NOT NULL,
	[Template] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_DocumentTemplate] PRIMARY KEY CLUSTERED 
(
	[DocumentTemplateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DrugQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DrugQuickList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ProdCode] [int] NULL,
	[FormCode] [int] NULL,
	[PackCode] [int] NULL,
	[DrugDescription] [varchar](500) NULL,
	[Quantity] [int] NULL,
	[Dosage] [varchar](5000) NULL,
	[Repeats] [int] NULL,
	[PBS] [int] NULL,
	[RPBS] [int] NULL,
	[Authority] [int] NULL,
	[Reg24] [int] NULL,
	[S8] [int] NULL,
	[BrandSubstitutionNotPermitted] [int] NULL,
	[SingleDrug] [int] NULL,
	[DrugName] [varchar](200) NULL,
	[Form] [varchar](200) NULL,
	[Strength] [varchar](200) NULL,
	[FDBDrugType] [int] NULL,
	[FDBId] [varchar](50) NULL,
	[s11] [int] NULL,
 CONSTRAINT [PK_DrugQuickList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Episode]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Episode](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorPatientId] [int] NULL,
	[ProviderId] [int] NULL,
	[AppointmentDateTime] [datetime] NULL,
	[Status] [int] NULL,
	[TimerSeconds] [int] NULL,
	[CancelledReasonCode] [int] NULL,
	[CancelledNotes] [varchar](500) NULL,
	[AppointmentIndex] [int] NULL,
	[EpisodeResourceId] [int] NULL,
	[EpisodeUserId] [int] NULL,
	[EpisodeProviderStatus] [int] NULL,
	[AuxiliaryResourceId] [int] NULL,
	[AuxiliaryUserId] [int] NULL,
	[AuxiliaryStatus] [int] NULL,
	[EncounterCommitted] [int] NULL,
	[AppointmentResourceId] [int] NULL,
	[AppointmentTypeId] [int] NULL,
	[AppointmentNotes] [varchar](500) NULL,
	[AppointmentLength] [int] NULL,
	[AppointmentLengthMinutes] [int] NULL,
	[ArrivalNotes] [varchar](500) NULL,
	[WalkinPenalty] [int] NULL,
	[Urgent] [int] NULL,
	[LocationId] [int] NULL,
	[ProviderNotes] [varchar](500) NULL,
	[ReferralInId] [int] NULL,
	[ReferralOverride] [int] NULL,
	[ReasonForOverrideDescription] [varchar](150) NULL,
	[ReferralReasonIfOverride] [varchar](150) NULL,
	[AppointmentConfirmedById] [int] NULL,
	[AppointmentName] [varchar](200) NULL,
	[OnlineAppointmentName] [varchar](200) NULL,
	[ServiceLocationId] [int] NULL,
	[CanEdit] [int] NULL,
	[AuxiliaryEpisodeId] [int] NULL,
	[AppointmentCustomFieldId] [int] NULL,
	[NoReferralSelected] [bit] NOT NULL,
	[CreatedFromHealthRecord] [int] NULL,
	[CreatedByQuickBill] [int] NULL,
	[AppointmentConfirmedDateTimeOffset] [datetimeoffset](7) NULL,
	[ArriveDateTimeOffset] [datetimeoffset](7) NULL,
	[CompleteDateTimeOffset] [datetimeoffset](7) NULL,
	[StartDateTimeOffset] [datetimeoffset](7) NULL,
	[AppointmentCreatedById] [int] NULL,
	[AppointmentCancelledById] [int] NULL,
	[AppointmentCreatedDateTimeOffset] [datetimeoffset](7) NULL,
	[AppointmentCancelledDateTimeOffset] [datetimeoffset](7) NULL,
	[OrderSeen] [int] NULL,
	[AuxiliaryOrderSeen] [int] NULL,
	[ArriveUserId] [int] NULL,
	[DidNotArrive] [int] NULL,
 CONSTRAINT [PK_Schedule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ErxPrescriptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErxPrescriptions](
	[EncounterUid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ethnicity]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ethnicity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Ethnicity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FileStore]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileStore](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](255) NOT NULL,
	[Data] [varbinary](max) NOT NULL,
	[UserId] [int] NULL,
	[SaveDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_FileStore] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FilterSetting]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilterSetting](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsSystemReport] [bit] NOT NULL,
	[Description] [varchar](200) NULL,
	[FilterSettings] [varbinary](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_FilterSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HealthFund]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HealthFund](
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[ocParticipantId] [varchar](3) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Uid] [uniqueidentifier] NOT NULL,
	[HealthFundGroupUid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_HealthFund_1] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HealthFundGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HealthFundGroup](
	[Uid] [uniqueidentifier] NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NOT NULL,
 CONSTRAINT [PK_HealthFundGroup] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HealthFundOnlineClaiming]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HealthFundOnlineClaiming](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ocDescription] [varchar](50) NULL,
	[ocParticipantId] [varchar](3) NULL,
	[ocCapabilityImcVersionId] [int] NULL,
	[ocCapabilityImcName] [varchar](50) NULL,
	[ocCapabilityImcAg] [int] NULL,
	[ocCapabilityImcSc] [int] NULL,
	[ocCapabilityImcMb] [int] NULL,
	[ocCapabilityImcPc] [int] NULL,
	[ocCapabilityOpvVersionId] [int] NULL,
	[ocCapabilityOpvName] [varchar](50) NULL,
	[ocCapabilityEraVersionId] [int] NULL,
	[ocCapabilityEraName] [varchar](50) NULL,
	[ocCapabilityOecVersionId] [int] NULL,
	[ocCapabilityOecName] [varchar](50) NULL,
	[ocCapabilityOecOec] [int] NULL,
	[ocCapabilityOecEcf] [int] NULL,
	[ocCapabilityOecEcm] [int] NULL,
	[ocCapabilityIhcVersionId] [int] NULL,
	[ocCapabilityIhcName] [varchar](50) NULL,
	[ocCapabilityOvsVersionId] [int] NULL,
	[ocCapabilityOvsName] [varchar](50) NULL,
 CONSTRAINT [PK_HealthFundOnlineClaiming] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HiReference]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HiReference](
	[HiReferenceType] [int] NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Description] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HiServiceLog]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HiServiceLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType] [int] NULL,
	[SearchType] [int] NULL,
	[SearchEntityType] [int] NULL,
	[RequestingOrganisationHpiO] [varchar](16) NULL,
	[RequestingUserHpiI] [varchar](16) NULL,
	[UserId] [int] NULL,
	[IsResponsibleOfficer] [int] NULL,
	[SearchDescription] [varchar](max) NULL,
	[Message] [varchar](max) NULL,
	[ErrorNumber] [varchar](20) NULL,
	[ErrorMessage] [varchar](max) NULL,
	[RequestMessageId] [varchar](100) NULL,
	[ResponseMessageId] [varchar](100) NULL,
	[HealthcareIdentifier] [varchar](16) NULL,
	[HiNumberStatus] [int] NULL,
	[HiRecordStatus] [int] NULL,
	[HealthcareIdentifierList] [varchar](max) NULL,
	[PatientDebtorId] [int] NULL,
	[AddressBookId] [int] NULL,
	[SearchUserId] [int] NULL,
	[ServiceOperation] [varchar](100) NULL,
	[ServiceVersion] [varchar](20) NULL,
	[BatchIdentifier] [varchar](100) NULL,
	[LogDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_HiServiceLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Hospital]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Hospital](
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[FacilityCode] [varchar](8) NULL,
	[DVARuralPublic] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[LinkedLocationId] [int] NULL,
	[Uid] [uniqueidentifier] NOT NULL,
	[Suburb] [varchar](80) NULL,
	[State] [varchar](3) NULL,
	[Postcode] [varchar](4) NULL,
	[Id] [int] NULL,
	[TimeZoneId] [varchar](50) NULL,
 CONSTRAINT [PK_Hospital] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ICPC2KEY]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ICPC2KEY](
	[KeyId] [int] NOT NULL,
	[Keyword] [varchar](50) NULL,
 CONSTRAINT [PK_ICPC2KEY] PRIMARY KEY CLUSTERED 
(
	[KeyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ICPC2LNK]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICPC2LNK](
	[KeyId] [int] NOT NULL,
	[TermId] [int] NOT NULL,
 CONSTRAINT [PK_ICPC2LNK] PRIMARY KEY CLUSTERED 
(
	[KeyId] ASC,
	[TermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICPC2TRM]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ICPC2TRM](
	[TermId] [int] NOT NULL,
	[Nalan50] [varchar](50) NOT NULL,
	[ICPCCode] [char](3) NOT NULL,
	[TermCode] [char](3) NOT NULL,
	[Status] [char](1) NOT NULL,
	[Replacement] [varchar](6) NULL,
	[Term30] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ICPC2TRM] PRIMARY KEY CLUSTERED 
(
	[TermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ICPCTempKEY]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ICPCTempKEY](
	[KeyId] [uniqueidentifier] NOT NULL,
	[Keyword] [varchar](50) NULL,
 CONSTRAINT [PK_ICPCTempKEY] PRIMARY KEY CLUSTERED 
(
	[KeyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ICPCTempLNK]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICPCTempLNK](
	[KeyId] [uniqueidentifier] NOT NULL,
	[TermId] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICPCTempTRM]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ICPCTempTRM](
	[TermId] [uniqueidentifier] NOT NULL,
	[Nalan50] [varchar](50) NOT NULL,
	[ICPCCode] [char](3) NOT NULL,
	[TermCode] [char](3) NOT NULL,
	[Status] [char](1) NOT NULL,
	[Replacement] [varchar](6) NULL,
	[Term30] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ICPCTempTRM] PRIMARY KEY CLUSTERED 
(
	[TermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Identifier]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Identifier](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[Description] [varchar](50) NULL,
	[FileType] [int] NULL,
	[UsageOption] [int] NULL,
	[Method] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[IsHbcis] [int] NULL,
 CONSTRAINT [PK_Identifier] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImcEraReport]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImcEraReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EraTransactionId] [varchar](24) NULL,
	[PaymentRunDate] [datetime] NULL,
	[PayerName] [varchar](40) NULL,
	[RemittanceAdviceId] [varchar](30) NULL,
	[PartNum] [int] NULL,
	[PartTotal] [int] NULL,
	[BankAccountName] [varchar](30) NULL,
	[BankAccountNum] [varchar](9) NULL,
	[BankAccountBSB] [varchar](6) NULL,
	[PaymentReference] [varchar](30) NULL,
	[DepositAmount] [money] NULL,
	[Processed] [int] NULL,
	[ReceiptId] [int] NULL,
 CONSTRAINT [PK_ImcEraReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImcEraReportDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImcEraReportDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImcEraReportId] [int] NULL,
	[AccountReferenceId] [varchar](20) NULL,
	[TransactionId] [varchar](24) NULL,
	[BenefitAmount] [money] NULL,
	[DateOfLodgement] [datetime] NULL,
 CONSTRAINT [PK_ImcEraReportDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImcProcessingReport]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImcProcessingReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImcTransactionId] [varchar](24) NULL,
	[AccountReferenceId] [varchar](20) NULL,
	[ClaimFundAssessmentCde] [char](1) NULL,
	[ClaimId] [varchar](6) NULL,
	[CurrentPatientFirstName] [varchar](40) NULL,
	[CurrentPatientMedicareCardNum] [varchar](50) NULL,
	[CurrentPatientReferenceNum] [char](1) NULL,
	[FundStatusCode] [varchar](4) NULL,
	[MedicareCardFlagCde] [char](1) NULL,
	[MedicareStatusCode] [varchar](4) NULL,
	[PatientFamilyName] [varchar](40) NULL,
	[PatientFirstName] [varchar](40) NULL,
	[PatientMedicareCardNum] [varchar](10) NULL,
	[PatientReferenceNum] [char](1) NULL,
	[ProcessStatusCde] [varchar](30) NULL,
	[ClaimStatusCode] [int] NULL,
	[ExceptionProcessMethod] [int] NULL,
	[Notes] [varchar](max) NULL,
	[Processed] [int] NULL,
	[ExceptionProcessDateTimeOffset] [datetimeoffset](7) NULL,
	[ProcessedDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ImcProcessingReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImcProcessingReportDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImcProcessingReportDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImcProcessingReportId] [int] NULL,
	[ChargeAmount] [money] NULL,
	[DateOfService] [datetime] NULL,
	[FundBenefitAmount] [money] NULL,
	[ItemNum] [varchar](5) NULL,
	[MedicareBenefitAmount] [money] NULL,
	[MedicareExplanationCode] [varchar](3) NULL,
	[ScheduleFee] [money] NULL,
	[ServiceFundAssessmentCde] [char](1) NULL,
	[ServiceId] [varchar](4) NULL,
 CONSTRAINT [PK_ImcProcessingReportDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImcProcessingReportDetailExplanation]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImcProcessingReportDetailExplanation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImcProcessingReportDetailId] [int] NULL,
	[ExplanationCode] [varchar](4) NULL,
	[ExplanationText] [varchar](260) NULL,
 CONSTRAINT [PK_ImcProcessingReportDetailExplanation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImcProcessingReportExplanation]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImcProcessingReportExplanation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImcProcessingReportId] [int] NULL,
	[ExplanationCode] [varchar](4) NULL,
	[ExplanationText] [varchar](260) NULL,
 CONSTRAINT [PK_ImcProcessingReportExplanation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImmunisationCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImmunisationCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[IsSystemCategory] [bit] NOT NULL,
	[Inactive] [bit] NOT NULL,
	[Description] [varchar](1000) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ImmunisationCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ImmunisationCategoryVaccineMapping]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImmunisationCategoryVaccineMapping](
	[ImmunisationCategoryId] [int] NOT NULL,
	[VaccineUid] [uniqueidentifier] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ImmunisationCategoryVaccineMapping] PRIMARY KEY CLUSTERED 
(
	[ImmunisationCategoryId] ASC,
	[VaccineUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IntegratedEasyclaim]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEasyclaim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[BillingId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[DebtorId] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[FullyPaid] [bit] NOT NULL,
	[SentPayload] [varchar](max) NULL,
	[ReceivedPayload] [varchar](max) NULL,
	[EasyclaimTransactionId] [varchar](max) NULL,
	[TyroTransactionId] [varchar](max) NULL,
	[MerchantId] [varchar](10) NULL,
	[TerminalId] [varchar](10) NULL,
	[ErrorString] [varchar](max) NULL,
	[CardType] [varchar](50) NULL,
 CONSTRAINT [PK_IntegratedEasyclaim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEasyclaimHistory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEasyclaimHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntegratedEasyclaimId] [int] NOT NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[HistoryCreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[BillingId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[DebtorId] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[FullyPaid] [bit] NOT NULL,
	[SentPayload] [varchar](max) NULL,
	[ReceivedPayload] [varchar](max) NULL,
	[EasyclaimTransactionId] [varchar](max) NULL,
	[TyroTransactionId] [varchar](max) NULL,
	[MerchantId] [varchar](10) NULL,
	[TerminalId] [varchar](10) NULL,
	[ErrorString] [varchar](max) NULL,
	[CardType] [varchar](50) NULL,
 CONSTRAINT [PK_IntegratedEasyclaimHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposBankAccountMerchant]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IntegratedEftposBankAccountMerchant](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BankAccountId] [int] NOT NULL,
	[LocationId] [int] NOT NULL,
	[IntegratedEftposMerchantId] [int] NULL,
 CONSTRAINT [PK_IntegratedEftposBankAccountMerchant] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IntegratedEftposMerchant]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposMerchant](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TyroMerchantId] [varchar](10) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[DisplayOrder] [int] NULL,
	[LastReconciledDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_IntegratedEftposMerchant] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [UQ_IntegratedEftposMerchant_TyroMerchantId] UNIQUE NONCLUSTERED 
(
	[TyroMerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposReconciliationAndBankingResult]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposReconciliationAndBankingResult](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReconciliationDate] [datetime] NOT NULL,
	[TyroPurchases] [money] NULL,
	[TyroRefunds] [money] NULL,
	[TyroTotal] [money] NULL,
	[AmountBanked] [money] NULL,
	[BankRunId] [int] NULL,
	[SettlementResult] [varchar](50) NULL,
	[BankAccountId] [int] NOT NULL,
	[MerchantId] [varchar](10) NOT NULL,
	[TyroReconciliationReport] [varchar](max) NULL,
	[TerminalId] [varchar](200) NULL,
	[IntegratedEftposMerchantId] [int] NULL,
 CONSTRAINT [PK_IntegratedEftposReconciliationAndBankingResult] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposReconciliationAndBankingResultDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ResultId] [int] NOT NULL,
	[PaymentId] [int] NULL,
	[SettlementDate] [datetime] NULL,
	[DebtorId] [int] NOT NULL,
	[IntegratedEftposTransactionId] [int] NOT NULL,
	[TerminalId] [varchar](10) NULL,
 CONSTRAINT [PK_IntegratedEftposReconciliationAndBankingResultDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposReconciliationTyroTransactionsToIgnore]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposReconciliationTyroTransactionsToIgnore](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransactionDateTimeString] [varchar](20) NOT NULL,
	[TyroReference] [varchar](50) NOT NULL,
	[AmountString] [varchar](20) NOT NULL,
	[TransactionType] [varchar](50) NOT NULL,
	[CardType] [varchar](50) NOT NULL,
	[MerchantId] [varchar](10) NOT NULL,
	[TerminalId] [varchar](10) NOT NULL,
 CONSTRAINT [PK_IntegratedEftposReconciliationTyroTransactionsToIgnore] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposSettlementAndBankingException]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposSettlementAndBankingException](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReceiptId] [int] NOT NULL,
	[IsResolved] [bit] NOT NULL,
	[Notes] [varchar](max) NULL,
	[ResultId] [int] NOT NULL,
 CONSTRAINT [PK_IntegratedEftposSettlementAndBankingException] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposTransaction]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DebtorId] [int] NULL,
	[Amount] [money] NOT NULL,
	[BankAccountId] [int] NOT NULL,
	[IntegratedEftposTransactionType] [int] NOT NULL,
	[IntegratedEftposTransactionStatus] [int] NOT NULL,
	[ErrorString] [varchar](max) NULL,
	[TransactionReference] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[ElidedPan] [varchar](50) NULL,
	[MerchantId] [varchar](10) NULL,
	[TerminalId] [varchar](10) NULL,
	[RefundedIntegratedEftposTransactionId] [int] NULL,
	[PaymentTypeId] [int] NULL,
	[SettlementDate] [datetime] NULL,
	[ReconciledDate] [datetime] NULL,
	[LocationId] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[HealthPointClaimReferenceTag] [varchar](50) NULL,
 CONSTRAINT [PK_IntegratedEftposTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedEftposTransactionHistory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedEftposTransactionHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntegratedEftposTransactionId] [int] NOT NULL,
	[DebtorId] [int] NULL,
	[Amount] [money] NOT NULL,
	[BankAccountId] [int] NOT NULL,
	[IntegratedEftposTransactionType] [int] NOT NULL,
	[IntegratedEftposTransactionStatus] [int] NOT NULL,
	[ErrorString] [varchar](max) NULL,
	[TransactionReference] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[ElidedPan] [varchar](50) NULL,
	[MerchantId] [varchar](10) NULL,
	[TerminalId] [varchar](10) NULL,
	[RefundedIntegratedEftposTransactionId] [int] NULL,
	[PaymentTypeId] [int] NULL,
	[SettlementDate] [datetime] NULL,
	[ReconciledDate] [datetime] NULL,
	[LocationId] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[HistoryCreatedDateTimeOffset] [datetimeoffset](7) NULL,
	[HealthPointClaimReferenceTag] [varchar](50) NULL,
 CONSTRAINT [PK_IntegratedEftposTransactionHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedHealthPointClaim]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedHealthPointClaim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[BillingId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[BankAccountId] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[TotalClaimAmount] [money] NOT NULL,
	[ClaimReferenceTag] [varchar](50) NULL,
	[BenefitAmount] [money] NULL,
	[GapAmount] [money] NULL,
	[SentPayload] [varchar](max) NULL,
	[ReceivedPayload] [varchar](max) NULL,
	[HealthFundResponseCode] [varchar](max) NULL,
	[HealthFundResponseDescription] [varchar](max) NULL,
	[HealthFundIdentifier] [varchar](max) NULL,
	[HealthFundName] [varchar](max) NULL,
	[SettlementDateTime] [datetime] NULL,
	[MerchantId] [varchar](10) NULL,
	[TerminalId] [varchar](10) NULL,
	[ExtraInformation] [varchar](max) NULL,
	[ErrorString] [varchar](max) NULL,
	[Messages] [varchar](max) NULL,
	[UserNotes] [varchar](max) NULL,
	[LocationId] [int] NOT NULL,
 CONSTRAINT [PK_IntegratedHealthPointClaim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntegratedHealthPointClaimHistory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntegratedHealthPointClaimHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntegratedHealthPointClaimId] [int] NOT NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[BillingId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[BankAccountId] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[TotalClaimAmount] [money] NOT NULL,
	[ClaimReferenceTag] [varchar](50) NULL,
	[BenefitAmount] [money] NULL,
	[GapAmount] [money] NULL,
	[SentPayload] [varchar](max) NULL,
	[ReceivedPayload] [varchar](max) NULL,
	[HealthFundResponseCode] [varchar](max) NULL,
	[HealthFundResponseDescription] [varchar](max) NULL,
	[HealthFundIdentifier] [varchar](max) NULL,
	[HealthFundName] [varchar](max) NULL,
	[SettlementDateTime] [datetime] NULL,
	[MerchantId] [varchar](10) NULL,
	[TerminalId] [varchar](10) NULL,
	[ExtraInformation] [varchar](max) NULL,
	[ErrorString] [varchar](max) NULL,
	[Messages] [varchar](max) NULL,
	[UserNotes] [varchar](max) NULL,
	[HistoryCreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[LocationId] [int] NOT NULL,
 CONSTRAINT [PK_IntegratedHealthPointClaimHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InternalMessage]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InternalMessage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Urgent] [int] NOT NULL,
	[FromUserId] [int] NOT NULL,
	[Subject] [nvarchar](250) NOT NULL,
	[PatientDebtorId] [int] NULL,
	[MessageBody] [varbinary](max) NOT NULL,
	[RecipientsDesc] [nvarchar](max) NOT NULL,
	[CCRecipientsDesc] [nvarchar](max) NULL,
	[SentDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[WrittenDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_InternalMessage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InternalMessageFolder]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternalMessageFolder](
	[Id] [int] IDENTITY(11,1) NOT NULL,
	[ParentId] [int] NOT NULL,
	[FolderName] [nvarchar](50) NOT NULL,
	[UserId] [int] NOT NULL,
	[IsFixed] [int] NOT NULL,
 CONSTRAINT [PK_InternalMessageFolder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InternalMessageRecipient]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternalMessageRecipient](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToUserId] [int] NOT NULL,
	[InternalMessageId] [int] NOT NULL,
	[Deleted] [int] NOT NULL,
	[InternalMessageFolderId] [int] NOT NULL,
	[UserMailGroupId] [int] NULL,
	[ReadDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_MessageRecipient] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Invoice]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Invoice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BillingId] [int] NULL,
	[PatientDebtorDebtorId] [int] NULL,
	[ReversalReceiptId] [int] NULL,
	[ReceiptId] [int] NULL,
	[AmountBilled] [money] NULL,
	[AmountSchedule] [money] NULL,
	[AmountRebate] [money] NULL,
	[AmountRebateFund] [money] NULL,
	[AmountGST] [money] NULL,
	[GSTType] [int] NULL,
	[LocationId] [int] NULL,
	[UserId] [int] NULL,
	[ocPpcImcClaimType] [int] NULL,
	[ocTransactionId] [varchar](50) NULL,
	[PracticeLocationId] [int] NULL,
	[LegalEntityId] [int] NULL,
	[InvoiceDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[InvoicePrintedDateTimeOffset] [datetimeoffset](7) NULL,
	[XeroUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
	[HealthFundUid] [uniqueidentifier] NULL,
	[HealthFundNumber] [varchar](19) NULL,
	[HealthFundExpiryMonth] [int] NULL,
	[HealthFundExpiryYear] [int] NULL,
	[HealthFundReference] [char](2) NULL,
	[HealthFundNote] [varchar](50) NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InvoiceDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceId] [int] NULL,
	[ServiceId] [int] NULL,
	[AutoGeneratedItem] [int] NULL,
	[AmountBilled] [money] NULL,
	[AmountBilledClaimed] [money] NULL,
	[AmountSchedule] [money] NULL,
	[AmountRebate] [money] NULL,
	[AmountRebateFund] [money] NULL,
	[AmountBenefit] [money] NULL,
	[AdditionalDescription] [varchar](250) NULL,
	[AfterCareOverride] [int] NULL,
	[AfterCareOverrideReason] [varchar](100) NULL,
	[DuplicateServiceOverride] [int] NULL,
	[DuplicateServiceOverrideReason] [varchar](100) NULL,
	[MultipleProcedureOverride] [int] NULL,
	[MultipleProcedureOverrideReason] [varchar](100) NULL,
	[EquipmentId] [char](5) NULL,
	[DerivedFeePatientsSeen] [int] NULL,
	[DerivedFeeFoetuses] [int] NULL,
	[DerivedFeeFieldQuantity] [int] NULL,
	[DerivedFeeTimeDuration] [int] NULL,
	[SelfDeemedCde] [int] NULL,
	[dvaSelfDeterminedReason] [varchar](100) NULL,
	[AssistantAddressBookId] [int] NULL,
	[RestrictiveConditionOverride] [int] NULL,
	[ocServiceId] [varchar](4) NULL,
	[ManuallyEntered] [int] NULL,
	[ReportingServiceGroupId] [int] NULL,
	[ServiceItemDetailId] [int] NULL,
	[AdditionalDescriptionAssistItems] [varchar](200) NULL,
 CONSTRAINT [PK_InvoiceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InvoiceDocument]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceDocument](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_InvoiceDocument] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InvoiceDocumentDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceDocumentDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceDocumentId] [int] NULL,
	[InvoiceId] [int] NULL,
 CONSTRAINT [PK_InvoiceDocumentDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InvoiceReference]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceReference](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[PatientDebtorPatientId] [int] NOT NULL,
	[PatientDebtorDebtorId] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[LastUsedDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_InvoiceReference_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InvoiceReferenceDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceReferenceDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceReferenceId] [int] NOT NULL,
	[OptionName] [varchar](500) NULL,
	[OptionValue] [varchar](5000) NULL,
 CONSTRAINT [PK_InvoiceReference] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Leaflet]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Leaflet](
	[Id] [int] NOT NULL,
	[ParentId] [int] NULL,
	[IsFolder] [int] NULL,
	[Name] [varchar](500) NULL,
	[Blob] [varbinary](max) NULL,
 CONSTRAINT [PK_Leaflet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LegalEntity]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LegalEntity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[DisplayOrder] [int] NULL,
	[AddressId] [int] NULL,
	[PhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[EmailContactId] [int] NULL,
	[ACNNumber] [varchar](9) NULL,
	[ABNNumber] [varchar](11) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[PaymentOptionMailTo] [varchar](100) NULL,
	[PaymentOptionCheque] [int] NULL,
	[PaymentOptionChequePayableTo] [varchar](50) NULL,
	[PaymentOptionCard] [int] NULL,
	[PaymentOptionCardMastercard] [int] NULL,
	[PaymentOptionCardVisa] [int] NULL,
	[PaymentOptionCardAmex] [int] NULL,
	[PaymentOptionCardDiners] [int] NULL,
	[PaymentOptionPhone] [int] NULL,
	[PaymentOptionPhoneNumber] [varchar](50) NULL,
	[PaymentOptionBPay] [int] NULL,
	[PaymentOptionBPayBillerCode] [varchar](8) NULL,
	[PaymentOptionBPayCreditCards] [int] NULL,
	[PaymentOptionDirectDeposit] [int] NULL,
	[PaymentOptionDirectDepositBankAccountId] [int] NULL,
	[PaymentOptionAdditionalNote] [varchar](100) NULL,
	[PaymentOptionsOnQuote] [int] NULL,
	[PaymentOptionsAmountDueOptionQuote] [int] NULL,
 CONSTRAINT [PK_LegalEntity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LegalEntityDate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LegalEntityDate](
	[ProviderId] [int] NOT NULL,
	[LegalEntityId] [int] NOT NULL,
	[EffectiveDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LicenceTimerLogging]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LicenceTimerLogging](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LogDateTime] [datetime] NOT NULL,
	[UserId] [int] NULL,
	[ProcessId] [int] NULL,
	[WorkStationId] [int] NULL,
	[MachineName] [varchar](100) NULL,
	[DateTimeUpdatingLicenceTo] [datetime] NOT NULL,
	[RowsAffected] [int] NOT NULL,
 CONSTRAINT [PK_LicenceTimerLogging] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LinkedProvider]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LinkedProvider](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientId] [int] NOT NULL,
	[AddressBookId] [int] NOT NULL,
	[Notes] [varchar](max) NULL,
 CONSTRAINT [PK_LinkedProvider] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Location]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Location](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[LocationLevel] [int] NULL,
	[Name] [varchar](50) NULL,
	[ShortName] [varchar](5) NULL,
	[DisplayOrder] [int] NULL,
	[StreetAddressId] [int] NULL,
	[PostalAddressId] [int] NULL,
	[PhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[EmailContactId] [int] NULL,
	[MbsRemoteLocation] [int] NULL,
	[LSPN] [varchar](6) NULL,
	[AcirClinicCode] [varchar](4) NULL,
	[AcirCommunityCode] [varchar](5) NULL,
	[LocationLevel2Id] [int] NULL,
	[LocationLevel3Id] [int] NULL,
	[LocationLevel4Id] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ReceiptingNotAllowed] [int] NULL,
	[SCPId] [varchar](5) NULL,
	[MapUrl] [varchar](50) NULL,
	[TimeZoneId] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Lock]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Lock](
	[Keyword] [varchar](200) NOT NULL,
	[IsLocked] [int] NULL,
	[IsLicenceLock] [int] NULL,
	[LockKey] [uniqueidentifier] NULL,
	[EntityType] [int] NULL,
	[KeywordQualifier] [int] NULL,
	[KeywordQualifierString] [varchar](100) NULL,
	[UserId] [int] NULL,
	[UserName] [varchar](100) NULL,
	[Machine] [varchar](100) NULL,
	[ProcessId] [int] NULL,
	[LockOrigin] [varchar](100) NULL,
	[Las] [int] NULL,
	[Lac] [int] NULL,
	[Laf] [int] NULL,
	[Lai] [int] NULL,
	[Slu] [int] NULL,
	[Clu] [int] NULL,
	[Flu] [int] NULL,
	[Ilu] [int] NULL,
	[LastUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
	[LockDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Lock] PRIMARY KEY CLUSTERED 
(
	[Keyword] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Logging]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Logging](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[SeverityLevel] [int] NOT NULL,
	[Category] [int] NULL,
	[WorkStationId] [int] NULL,
	[UserId] [int] NULL,
	[Source] [int] NULL,
	[LogDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Logging] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoincGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoincGroup](
	[Uid] [uniqueidentifier] NOT NULL,
	[Description] [varchar](100) NOT NULL,
 CONSTRAINT [PK_LoincGroup] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoincGroupLoinc]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoincGroupLoinc](
	[LoincGroupUid] [uniqueidentifier] NULL,
	[LoincCode] [varchar](20) NULL,
	[TestName] [varchar](100) NULL,
	[TestNameLike] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ManuscriptTemplate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ManuscriptTemplate](
	[ManuscriptTemplateUid] [uniqueidentifier] NOT NULL,
	[Inactive] [int] NOT NULL,
	[stat_UserIdAvailableTo] [int] NULL,
	[Description] [varchar](100) NULL,
	[DocumentType] [int] NOT NULL,
	[DocumentCategoryId] [int] NULL,
	[InitialManuscriptReviewStatus] [int] NULL,
	[IsElectronicallySendable] [int] NULL,
	[ClinicalSummaryId] [int] NULL,
	[ToDoActionPlaces] [varchar](200) NULL,
	[Blob] [varbinary](max) NULL,
	[ResponseExpected] [int] NULL,
	[DocumentSubType] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[PaperName] [varchar](100) NULL,
	[Downloadable] [bit] NOT NULL,
	[Downloaded] [bit] NOT NULL,
	[ModifiedAfterDownloaded] [bit] NOT NULL,
 CONSTRAINT [PK_ManuscriptTemplate] PRIMARY KEY CLUSTERED 
(
	[ManuscriptTemplateUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MeasurementCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MeasurementCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [varchar](200) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[Description] [varchar](1000) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[CategoryCode] [int] NULL,
	[DisplayOrder] [int] NULL,
	[Name] [varchar](100) NULL,
 CONSTRAINT [PK_MeasurementMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MeasurementCategoryLabCodeMapping]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MeasurementCategoryLabCodeMapping](
	[MeasurementId] [int] NOT NULL,
	[LabCode] [varchar](200) NOT NULL,
 CONSTRAINT [PK_MeasurementCategoryLabCodeMapping] PRIMARY KEY CLUSTERED 
(
	[MeasurementId] ASC,
	[LabCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicationCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicationCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[IsSystemCategory] [bit] NOT NULL,
	[Inactive] [bit] NOT NULL,
	[Description] [varchar](1000) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_MedicationCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicationCategorySubstanceMapping]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicationCategorySubstanceMapping](
	[MedicationCategoryId] [int] NOT NULL,
	[SubstanceClassId] [int] NOT NULL,
	[SubstanceClassName] [varchar](200) NULL,
	[RowVersion] [timestamp] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicationGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicationGroup](
	[Uid] [uniqueidentifier] NOT NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_MedicationGroup] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicationSubgroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicationSubgroup](
	[Uid] [uniqueidentifier] NOT NULL,
	[MedicationGroupUid] [uniqueidentifier] NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_MedicationSubgroup] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicationSubgroupDrug]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicationSubgroupDrug](
	[MedicationSubgroupUid] [uniqueidentifier] NULL,
	[ProdCode] [int] NULL,
	[GenCode] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MessageIn]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MessageIn](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AckMessageOutId] [int] NULL,
	[MessageType] [int] NULL,
	[MessageId] [varchar](200) NULL,
	[ReceivedFilename] [varchar](200) NULL,
	[MessageDataText] [varchar](max) NULL,
	[ErrorMessage] [varchar](max) NULL,
	[ProcessedDateTimeOffset] [datetimeoffset](7) NULL,
	[ReceivedDateTimeOffset] [datetimeoffset](7) NULL,
	[MessagingTransportUid] [uniqueidentifier] NULL,
	[ProcessedStatus] [int] NULL,
	[ErrorHandled] [int] NULL,
	[UserNote] [varchar](max) NULL,
 CONSTRAINT [PK_MessageIn] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MessageOut]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MessageOut](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AckMessageInId] [int] NULL,
	[MessageId] [varchar](40) NULL,
	[CorrespondenceUid] [varchar](40) NULL,
	[AuthorUserId] [int] NULL,
	[RecipientAddressBookId] [int] NULL,
	[SentFilename] [varchar](200) NULL,
	[MessageDataText] [varchar](max) NULL,
	[MessageType] [int] NULL,
	[SentDateTimeOffset] [datetimeoffset](7) NULL,
	[MessagingTransportUid] [uniqueidentifier] NULL,
	[CopyDoctorUid] [varchar](40) NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NULL,
	[UserNote] [varchar](max) NULL,
	[NoAckExpected] [int] NULL,
	[ManualAckDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_MessageOut] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MessagingTransport]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MessagingTransport](
	[Uid] [uniqueidentifier] NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[IncomingMessageFolder] [varchar](250) NULL,
	[OutgoingORUMessageFolder] [varchar](250) NULL,
	[OutgoingMDMMessageFolder] [varchar](250) NULL,
	[OutgoingREFMessageFolder] [varchar](250) NULL,
	[OutgoingRRIMessageFolder] [varchar](250) NULL,
	[OutgoingACKMessageFolder] [varchar](250) NULL,
	[AckCreationMethod] [int] NULL,
	[MSH4SendingFacilityNamespaceId] [varchar](200) NULL,
	[MSH4SendingFacilityUniversalId] [varchar](200) NULL,
	[MSH4SendingFacilityUniversalIdType] [varchar](200) NULL,
	[MSH5ReceivingApplicationNamespaceId] [varchar](200) NULL,
	[MSH5ReceivingApplicationUniversalId] [varchar](200) NULL,
	[MSH5ReceivingApplicationUniversalIdType] [varchar](200) NULL,
	[WorkstationId] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[MessageDirection] [int] NULL,
 CONSTRAINT [PK_MessagingTransport] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MobileLSPN]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MobileLSPN](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[LSPN] [varchar](6) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_MobileLSPN] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NameSuffix]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NameSuffix](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](10) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_NameSuffix] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NameTitle]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NameTitle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](10) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_NameTitle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NextNum]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NextNum](
	[Keyword] [varchar](50) NOT NULL,
	[LastNumber] [int] NOT NULL,
	[LastPrefix] [char](1) NULL,
	[LastNumberDate] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Occupation]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Occupation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OnlineClaimLog]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OnlineClaimLog](
	[ClaimId] [varchar](10) NULL,
	[Type] [varchar](50) NULL,
	[LogFile] [varchar](max) NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Message] [varchar](max) NULL,
	[LogDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_OnlineClaimLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PathologyResult]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PathologyResult](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RunNumber] [varchar](15) NULL,
	[Laboratory] [varchar](180) NULL,
	[NATALabNumber] [varchar](250) NULL,
	[OurReference] [int] NULL,
	[PatientNamePrefix] [varchar](10) NULL,
	[PatientFirstName] [varchar](40) NULL,
	[PatientMiddleName] [varchar](80) NULL,
	[PatientLastName] [varchar](40) NULL,
	[PatientNameSuffix] [varchar](40) NULL,
	[LaboratoryReference] [varchar](250) NULL,
	[ReceivingDrCodeOrProviderNo] [varchar](10) NULL,
	[LaboratoryNumber] [varchar](250) NULL,
	[TestCode] [varchar](60) NULL,
	[Street] [varchar](50) NULL,
	[Town] [varchar](50) NULL,
	[State] [varchar](3) NULL,
	[PostCode] [varchar](4) NULL,
	[DOB] [datetime] NULL,
	[Gender] [varchar](1) NULL,
	[HomePhone] [varchar](200) NULL,
	[MedicareNo] [varchar](10) NULL,
	[DVANo] [varchar](10) NULL,
	[DoctorPrefix] [varchar](10) NULL,
	[DoctorFirstName] [varchar](40) NULL,
	[DoctorMiddleName] [varchar](80) NULL,
	[DoctorLastName] [varchar](40) NULL,
	[DoctorSuffix] [varchar](40) NULL,
	[DoctorProviderNo] [varchar](10) NULL,
	[CopyDoctors] [varchar](1000) NULL,
	[IsCopy] [int] NULL,
	[RequestCompleted] [int] NULL,
	[HL7Data] [varchar](max) NULL,
	[PITData] [varchar](max) NULL,
	[DisplayData] [varchar](max) NULL,
	[FailedAutoMatch] [int] NOT NULL,
	[SurgeryId] [varchar](5) NULL,
	[ShortDoctorName] [varchar](32) NULL,
	[Pathologist] [varchar](32) NULL,
	[PathologistPhone] [varchar](12) NULL,
	[ReferringDoctorName] [varchar](120) NULL,
	[ReferringDoctorProviderNo] [varchar](10) NULL,
	[SpecimenType] [varchar](60) NULL,
	[ConfidentialityIndicator] [varchar](1) NULL,
	[NormalResultIndicator] [varchar](1) NOT NULL,
	[UrgentRequestIndicator] [varchar](1) NOT NULL,
	[RequestedTests] [varchar](1000) NULL,
	[PatientEhrUid] [varchar](50) NULL,
	[FacilityAddressBookId] [int] NULL,
	[FacilityType] [int] NULL,
	[UserId] [int] NULL,
	[ManualMatchUserId] [int] NULL,
	[DiscardedByUserId] [int] NULL,
	[ClinicalResultFormat] [int] NULL,
	[FileStoreId] [int] NULL,
	[DisplayBlob] [varbinary](max) NULL,
	[DisplayBlobFileExtension] [varchar](12) NULL,
	[MedicareSubnumerate] [int] NULL,
	[CollectionDateTimeOffset] [datetimeoffset](7) NULL,
	[DiscardedDateTimeOffset] [datetimeoffset](7) NULL,
	[ManualMatchDateTimeOffset] [datetimeoffset](7) NULL,
	[ReportDateTimeOffset] [datetimeoffset](7) NULL,
	[RequestDateTimeOffset] [datetimeoffset](7) NULL,
	[ResultImportDateTimeOffset] [datetimeoffset](7) NULL,
	[RunDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_PathologyResult] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PathologyResultAtomic]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PathologyResultAtomic](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PathologyResultId] [int] NOT NULL,
	[SetID] [int] NULL,
	[ValueType] [varchar](30) NULL,
	[LOINCIdentifier] [varchar](250) NULL,
	[LabResultCode] [varchar](250) NULL,
	[ObservationValue] [varchar](max) NULL,
	[NumericValue] [float] NULL,
	[Units] [varchar](250) NULL,
	[ReferenceRange] [varchar](60) NULL,
	[AbnormalFlags] [varchar](8) NULL,
	[NatureOfAbnormalTest] [varchar](2) NULL,
	[ObservationResultStatus] [varchar](1) NULL,
	[LastNormalObservationDateTimeOffset] [datetimeoffset](7) NULL,
	[PathologyLabAnalysisDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_PathologyResultsAtomic] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PathologyTests]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PathologyTests](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ListType] [int] NOT NULL,
	[TestCode] [varchar](40) NOT NULL,
	[TestDescription] [varchar](500) NOT NULL,
	[Sequence] [int] NOT NULL,
 CONSTRAINT [PK_PathologyTests] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PathologyTestsUserQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PathologyTestsUserQuickList](
	[UserId] [int] NOT NULL,
	[TestDescription] [varchar](250) NOT NULL,
	[Sequence] [int] NOT NULL,
	[TestSet] [varchar](250) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Patient_Document]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patient_Document](
	[PatientId] [int] NOT NULL,
	[DocumentId] [int] NOT NULL,
 CONSTRAINT [PK_Patient_Document] PRIMARY KEY CLUSTERED 
(
	[PatientId] ASC,
	[DocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PatientClassification]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientClassification](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PatientClassification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientContact]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientContact](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[ApplyContactConsent] [int] NOT NULL,
	[RequiresCompliance] [int] NOT NULL,
	[Inactive] [int] NOT NULL,
	[DefaultDelay] [int] NOT NULL,
	[PromptDelayBeforeAppointment] [int] NULL,
	[PromptDelayAfterAppointment] [int] NULL,
	[PromptDelayBeforeHealthRecord] [int] NULL,
	[ProcessEvents] [int] NOT NULL,
	[MaximumEvents] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[Deleted] [int] NOT NULL,
 CONSTRAINT [PK_PatientContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientContactEvent]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientContactEvent](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientContactId] [int] NOT NULL,
	[EventNo] [int] NOT NULL,
	[EventType] [int] NOT NULL,
	[DaysElapsed] [int] NULL,
	[ToDoTemplateId] [int] NULL,
	[SmsText] [varchar](250) NULL,
	[LetterManuscriptTemplateUid] [uniqueidentifier] NULL,
	[EmailManuscriptTemplateUid] [uniqueidentifier] NULL,
	[EmailSubject] [varchar](100) NULL,
	[Deleted] [int] NOT NULL,
	[LetterTemplateId] [int] NULL,
	[EmailTemplateId] [int] NULL,
	[SmsManuscriptTemplateUid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PatientContactEvent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientDebtor]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientDebtor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorType] [int] NULL,
	[SpecialPatientDebtorType] [int] NULL,
	[Inactive] [int] NULL,
	[IsPatient] [int] NULL,
	[IsDebtor] [int] NULL,
	[LegalPersonNameId] [int] NULL,
	[PreferredPersonNameId] [int] NULL,
	[Sex] [int] NULL,
	[ResidentialAddressId] [int] NULL,
	[PostalAddressId] [int] NULL,
	[HomePhoneContactId] [int] NULL,
	[WorkPhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[MobilePhoneContactId] [int] NULL,
	[EmailContactId] [int] NULL,
	[DoB] [datetime] NULL,
	[DoD] [datetime] NULL,
	[FirstVisitDate] [datetime] NULL,
	[EliteAthlete] [int] NULL,
	[EthnicityId] [int] NULL,
	[ATSI] [int] NULL,
	[ConsentMail] [int] NULL,
	[ConsentEmail] [int] NULL,
	[ConsentSMS] [int] NULL,
	[ConsentHomePhone] [int] NULL,
	[ConsentWorkPhone] [int] NULL,
	[ConsentMobilePhone] [int] NULL,
	[OrganisationName] [varchar](100) NULL,
	[TradingAs] [varchar](100) NULL,
	[ACNNumber] [varchar](9) NULL,
	[ABNNumber] [varchar](11) NULL,
	[DefaultProviderUserId] [int] NULL,
	[DefaultDebtorType] [int] NULL,
	[DefaultDebtorId] [int] NULL,
	[PatientClassificationId] [int] NULL,
	[PatientGroupId] [int] NULL,
	[DebtorClassificationId] [int] NULL,
	[DebtorGroupId] [int] NULL,
	[BankBSB] [varchar](6) NULL,
	[BankAccountNumber] [varchar](50) NULL,
	[BankAccountName] [varchar](50) NULL,
	[MedicareNumber] [varchar](10) NULL,
	[MedicareExpiryMonth] [int] NULL,
	[MedicareExpiryYear] [int] NULL,
	[MedicareSubnumerate] [int] NULL,
	[DvaNumber] [varchar](10) NULL,
	[DVAExpiryMonth] [int] NULL,
	[DVAExpiryYear] [int] NULL,
	[DVACardType] [int] NULL,
	[PensionCardNo] [varchar](15) NULL,
	[PensionCardExpiryMonth] [int] NULL,
	[PensionCardExpiryYear] [int] NULL,
	[OtherCardNo] [varchar](50) NULL,
	[OtherCardExpiryMonth] [int] NULL,
	[OtherCardExpiryYear] [int] NULL,
	[SafetyNetNo] [varchar](10) NULL,
	[SafetyNetExpiryMonth] [int] NULL,
	[SafetyNetExpiryYear] [int] NULL,
	[DonorCardNo] [varchar](15) NULL,
	[DonorCardExpiryMonth] [int] NULL,
	[DonorCardExpiryYear] [int] NULL,
	[HealthFundNumber] [varchar](19) NULL,
	[HealthFundExpiryMonth] [int] NULL,
	[HealthFundExpiryYear] [int] NULL,
	[HealthFundReference] [char](2) NULL,
	[HealthFundNote] [varchar](50) NULL,
	[NokName] [varchar](50) NULL,
	[NokRelationshipId] [int] NULL,
	[NokAddressId] [int] NULL,
	[NOKHomePhoneContactId] [int] NULL,
	[NOKWorkPhoneContactId] [int] NULL,
	[NOKMobilePhoneContactId] [int] NULL,
	[NOKEPA] [int] NULL,
	[Contact1Name] [varchar](50) NULL,
	[Contact1RelationshipId] [int] NULL,
	[Contact1AddressId] [int] NULL,
	[Contact1HomePhoneContactId] [int] NULL,
	[Contact1WorkPhoneContactId] [int] NULL,
	[Contact1MobilePhoneContactId] [int] NULL,
	[Contact1EPA] [int] NULL,
	[Contact1Title] [varchar](50) NULL,
	[Contact2Name] [varchar](50) NULL,
	[Contact2RelationshipId] [int] NULL,
	[Contact2AddressId] [int] NULL,
	[Contact2HomePhoneContactId] [int] NULL,
	[Contact2WorkPhoneContactId] [int] NULL,
	[Contact2MobilePhoneContactId] [int] NULL,
	[Contact2EPA] [int] NULL,
	[Contact2Title] [varchar](50) NULL,
	[Employer1Occupation] [varchar](50) NULL,
	[Employer1Employer] [varchar](50) NULL,
	[Employer1AddressId] [int] NULL,
	[Employer1WorkPhoneContactId] [int] NULL,
	[Employer2Occupation] [varchar](50) NULL,
	[Employer2Employer] [varchar](50) NULL,
	[Employer2AddressId] [int] NULL,
	[Employer2WorkPhoneContactId] [int] NULL,
	[AlertReception] [varchar](max) NULL,
	[PatientNote] [varchar](max) NULL,
	[DebtorNote] [varchar](max) NULL,
	[AlwaysIncludeGst] [int] NULL,
	[PatientPhoto] [varbinary](max) NULL,
	[PatientThumbNail] [varbinary](max) NULL,
	[EhrUid] [varchar](50) NULL,
	[ConvertedSystemId] [varchar](50) NULL,
	[RowVersion] [timestamp] NULL,
	[CTG] [int] NULL,
	[HealthcareIdentifier] [varchar](16) NULL,
	[HiNumberStatus] [int] NULL,
	[HiRecordStatus] [int] NULL,
	[ConsentPcehr] [int] NULL,
	[HiSearchMedicareNumber] [varchar](10) NULL,
	[HiSearchMedicareIrn] [int] NULL,
	[HiSearchDvaNumber] [varchar](10) NULL,
	[HiSearchSurname] [varchar](40) NULL,
	[HiSearchGivenName] [varchar](40) NULL,
	[HiSearchDob] [datetime] NULL,
	[HiSearchSex] [int] NULL,
	[PcehrExists] [int] NULL,
	[PcehrAccessCode] [int] NULL,
	[PcehrAccessError] [varchar](max) NULL,
	[Employer1OccupationId] [int] NULL,
	[Employer2OccupationId] [int] NULL,
	[ConversionComplete] [int] NULL,
	[DefaultBillcodeUid] [uniqueidentifier] NULL,
	[HealthFundUid] [uniqueidentifier] NULL,
	[HiLastUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
	[LastHbcisUpdateDateTimeOffset] [datetimeoffset](7) NULL,
	[PcehrAccessCheckedDateTimeOffset] [datetimeoffset](7) NULL,
	[HealthFundUninsured] [int] NULL,
 CONSTRAINT [PK_Patient] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientDebtorAdditionalInvoiceDetails]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientDebtorAdditionalInvoiceDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorId] [int] NOT NULL,
	[OptionName] [varchar](500) NULL,
	[OptionValue] [varchar](5000) NULL,
 CONSTRAINT [PK_PatientDebtorAdditionalInvoiceDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientDebtorFinancialTransactionVersion]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientDebtorFinancialTransactionVersion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorId] [int] NOT NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_PatientDebtorFinancialTransactionVersion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PatientDebtorHistory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientDebtorHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[IsBatch] [int] NULL,
	[HealthcareIdentifierNumber] [varchar](16) NULL,
	[HealthcareIdentifierNumberChanged] [int] NULL,
	[HealthcareIdentifierNumberStatus] [int] NULL,
	[HealthcareIdentifierNumberStatusChanged] [int] NULL,
	[HealthcareIdentifierRecordStatus] [int] NULL,
	[HealthcareIdentifierRecordStatusChanged] [int] NULL,
	[HealthcareIdentifierLastUpdatedChanged] [int] NULL,
	[MedicareNumber] [varchar](10) NULL,
	[MedicareNumberChanged] [int] NULL,
	[MedicareSubnumerate] [int] NULL,
	[MedicareSubnumerateChanged] [int] NULL,
	[DVANumber] [varchar](10) NULL,
	[DVANumberChanged] [int] NULL,
	[LegalFirstName] [varchar](40) NULL,
	[LegalFirstNameChanged] [int] NULL,
	[LegalMiddleName] [varchar](81) NULL,
	[LegalMiddleNameChanged] [int] NULL,
	[LegalFamilyName] [varchar](40) NULL,
	[LegalFamilyNameChanged] [int] NULL,
	[PreferredFirstName] [varchar](40) NULL,
	[PreferredFirstNameChanged] [int] NULL,
	[PreferredMiddleName] [varchar](81) NULL,
	[PreferredMiddleNameChanged] [int] NULL,
	[PreferredFamilyName] [varchar](40) NULL,
	[PreferredFamilyNameChanged] [int] NULL,
	[DOB] [datetime] NULL,
	[DOBChanged] [int] NULL,
	[Sex] [int] NULL,
	[SexChanged] [int] NULL,
	[HealthcareIdentifierLastUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
	[HistoryDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PatientDebtorHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientDebtorIdentifier]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientDebtorIdentifier](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorId] [int] NULL,
	[IdentifierId] [int] NULL,
	[Value] [varchar](50) NULL,
 CONSTRAINT [PK_PatientDebtorIdentifier] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PatientFamily]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientFamily](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LinkPatientId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
 CONSTRAINT [PK_PatientFamily] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PatientGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PatientGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PatientGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Payment]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Payment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReceiptId] [int] NULL,
	[PaymentTypeId] [int] NULL,
	[Amount] [money] NULL,
	[CreditCardType] [int] NULL,
	[Reference] [varchar](30) NULL,
	[Bank] [char](3) NULL,
	[Branch] [varchar](20) NULL,
	[Drawer] [varchar](50) NULL,
	[ChequeNumber] [varchar](20) NULL,
	[BankRunId] [int] NULL,
	[BankingProcess] [int] NULL,
	[IntegratedEftposTransactionId] [int] NULL,
	[IntegratedHealthPointClaimId] [int] NULL,
	[IsRefunded] [int] NULL,
	[RefundedPaymentId] [int] NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PaymentType]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[Description] [varchar](50) NULL,
	[PaymentMethod] [int] NULL,
	[BankingMethod] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PaymentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersonName]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonName](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Surname] [varchar](40) NULL,
	[FirstName] [varchar](40) NULL,
	[MiddleNames] [varchar](81) NULL,
	[NameTitleId] [int] NULL,
	[NameSuffixId] [int] NULL,
 CONSTRAINT [PK_PersonName] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Practice]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Practice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[StreetAddressId] [int] NULL,
	[PostalAddressId] [int] NULL,
	[PhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[EmailContactId] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Practice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PracticeDevice]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeDevice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LocationId] [int] NOT NULL,
	[DeviceIdentifier] [varchar](50) NOT NULL,
 CONSTRAINT [PK_PracticeDevice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PracticeOptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PracticeId] [int] NOT NULL,
	[OptionName] [varchar](500) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[OptionValue] [varchar](max) NULL,
 CONSTRAINT [PK_PracticeOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyReminder]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyReminder](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](50) NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PregnancyReminder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PriceParameter]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceParameter](
	[PriceParameterType] [int] NOT NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ValueString] [varchar](1000) NULL,
	[ValueInt] [int] NULL,
	[ValueMoney] [money] NULL,
	[ValuePercentage] [decimal](8, 4) NULL,
	[HealthFundUid] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Provider]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Provider](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[DisplayOrder] [int] NULL,
	[UserId] [int] NULL,
	[LegalEntityId] [int] NULL,
	[AddressId] [int] NULL,
	[PhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[EmailContactId] [int] NULL,
	[ProviderNumber] [varchar](8) NULL,
	[FundPayeeId] [varchar](12) NULL,
	[PayeeProviderId] [int] NULL,
	[RecognisedGP] [int] NULL,
	[RecognisedSpecialist] [int] NULL,
	[RecognisedLMO] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ConvertedSystemId] [varchar](50) NULL,
	[ServiceLocationId] [int] NULL,
	[Locum] [int] NULL,
 CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProviderOptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProviderOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProviderId] [int] NULL,
	[OptionName] [varchar](500) NULL,
	[OptionValue] [varchar](5000) NULL,
 CONSTRAINT [PK_ProviderOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PublicHoliday]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PublicHoliday](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[PublicHolidayDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PublicHoliday] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuickDose]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickDose](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[UserId] [int] NULL,
	[DisplayOrder] [int] NULL,
	[Text] [varchar](500) NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_QuickDose] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuickInstruction]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickInstruction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[UserId] [int] NULL,
	[DisplayOrder] [int] NULL,
	[Text] [varchar](500) NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_QuickInstruction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuickItem]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickItem](
	[ItemCode] [varchar](10) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Id] [int] NOT NULL,
	[ParentId] [int] NULL,
	[IsFolder] [int] NULL,
	[Inactive] [int] NULL,
	[Description] [varchar](40) NULL,
	[ModalityType] [int] NULL,
	[Modality] [int] NOT NULL,
 CONSTRAINT [PK_QuickItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[QuickListType] [int] NOT NULL,
	[Description] [varchar](250) NULL,
	[Text] [varchar](max) NULL,
	[ICPCCode] [char](3) NULL,
	[ICPCTermCode] [char](3) NULL,
	[ManuscriptTemplateUid] [uniqueidentifier] NULL,
	[Inactive] [bit] NOT NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_QuickList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuickListUserHiddenPracticeList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuickListUserHiddenPracticeList](
	[UserId] [int] NOT NULL,
	[QuickListId] [int] NOT NULL,
 CONSTRAINT [PK_QuickListUserHiddenPracticeList] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[QuickListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuickTemplate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickTemplate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](50) NULL,
	[ManuscriptTemplateUid] [uniqueidentifier] NULL,
	[UserId] [int] NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_QuickTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Quote]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Quote](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProviderId] [int] NULL,
	[LocationId] [int] NULL,
	[HospitalId] [int] NULL,
	[PatientDebtorDebtorId] [int] NULL,
	[PatientDebtorPatientId] [int] NULL,
	[ExpectedEpisodeDateTime] [datetime] NULL,
	[AmountBilled] [money] NULL,
	[AmountSchedule] [money] NULL,
	[AmountRebate] [money] NULL,
	[AmountRebateFund] [money] NULL,
	[AmountGST] [money] NULL,
	[GSTType] [int] NULL,
	[QuoteInfoDescription1] [varchar](50) NULL,
	[QuoteInfoFee1] [money] NULL,
	[QuoteInfoMedicare1] [money] NULL,
	[QuoteInfoFund1] [money] NULL,
	[QuoteInfoDescription2] [varchar](50) NULL,
	[QuoteInfoFee2] [money] NULL,
	[QuoteInfoMedicare2] [money] NULL,
	[QuoteInfoFund2] [money] NULL,
	[QuoteInfoDescription3] [varchar](50) NULL,
	[QuoteInfoFee3] [money] NULL,
	[QuoteInfoMedicare3] [money] NULL,
	[QuoteInfoFund3] [money] NULL,
	[QuoteInfoDescription4] [varchar](50) NULL,
	[QuoteInfoFee4] [money] NULL,
	[QuoteInfoMedicare4] [money] NULL,
	[QuoteInfoFund4] [money] NULL,
	[QuoteInfoDescription5] [varchar](50) NULL,
	[QuoteInfoFee5] [money] NULL,
	[QuoteInfoMedicare5] [money] NULL,
	[QuoteInfoFund5] [money] NULL,
	[QuoteInfoDescription6] [varchar](50) NULL,
	[QuoteInfoFee6] [money] NULL,
	[QuoteInfoMedicare6] [money] NULL,
	[QuoteInfoFund6] [money] NULL,
	[QuoteInfoDescription7] [varchar](50) NULL,
	[QuoteInfoFee7] [money] NULL,
	[QuoteInfoMedicare7] [money] NULL,
	[QuoteInfoFund7] [money] NULL,
	[QuoteInfoBookingInfo] [varchar](500) NULL,
	[QuoteInfoBookingInfoDoc] [varbinary](max) NULL,
	[Description] [varchar](100) NULL,
	[PracticeLocationId] [int] NULL,
	[ServiceLocationId] [int] NULL,
	[AdmissionDate] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[HospitalUid] [uniqueidentifier] NULL,
	[BillcodeUid] [uniqueidentifier] NULL,
	[BilledDateTimeOffset] [datetimeoffset](7) NULL,
	[QuoteDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[QuotePrintedDateTimeOffset] [datetimeoffset](7) NULL,
	[QuoteAmountDueOption] [int] NULL,
	[QuoteAmountDue] [money] NULL,
	[HealthFundUid] [uniqueidentifier] NULL,
	[HealthFundNumber] [varchar](19) NULL,
	[HealthFundRecorded] [int] NULL,
 CONSTRAINT [PK_Quote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuoteBookingInformation]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuoteBookingInformation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[Description] [varchar](50) NULL,
	[BookingInformation] [varchar](250) NULL,
	[Snippet] [varbinary](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[IsAutoInsert] [bit] NOT NULL,
 CONSTRAINT [PK_QuoteBookingInformation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuoteDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuoteDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[QuoteId] [int] NULL,
	[ServiceId] [int] NULL,
	[AutoGeneratedItem] [int] NULL,
	[AmountBilled] [money] NULL,
	[AmountSchedule] [money] NULL,
	[AmountRebate] [money] NULL,
	[AmountRebateFund] [money] NULL,
	[AmountBenefit] [money] NULL,
	[ManuallyEntered] [int] NULL,
	[AdditionalDescription] [varchar](250) NULL,
	[AfterCareOverride] [int] NULL,
	[AfterCareOverrideReason] [varchar](100) NULL,
	[DuplicateServiceOverride] [int] NULL,
	[DuplicateServiceOverrideReason] [varchar](100) NULL,
	[MultipleProcedureOverride] [int] NULL,
	[MultipleProcedureOverrideReason] [varchar](100) NULL,
	[EquipmentId] [char](5) NULL,
	[DerivedFeePatientsSeen] [int] NULL,
	[DerivedFeeFoetuses] [int] NULL,
	[DerivedFeeFieldQuantity] [int] NULL,
	[DerivedFeeTimeDuration] [int] NULL,
	[SelfDeemedCde] [int] NULL,
	[dvaSelfDeterminedReason] [varchar](100) NULL,
	[AssistantAddressBookId] [int] NULL,
	[RestrictiveConditionOverride] [int] NULL,
	[ServiceItemDetailId] [int] NULL,
 CONSTRAINT [PK_QuoteDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RadiologyTestsUserQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RadiologyTestsUserQuickList](
	[UserId] [int] NOT NULL,
	[TestDescription] [varchar](250) NOT NULL,
	[Sequence] [int] NOT NULL,
	[TestSet] [varchar](250) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Recall]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recall](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientId] [int] NOT NULL,
	[PatientContactId] [int] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[LastEventNoProcessed] [int] NULL,
	[FinalEventProcessed] [int] NULL,
	[EpisodeId] [int] NULL,
	[Completed] [int] NULL,
	[LastEventProcessedDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Recall] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RecallActivity]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RecallActivity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RecallId] [int] NOT NULL,
	[ActivityType] [int] NOT NULL,
	[ActivityUserId] [int] NOT NULL,
	[Note] [varchar](max) NULL,
	[EventNo] [int] NULL,
	[EventType] [int] NULL,
	[EpisodeId] [int] NULL,
	[AppointmentDateTime] [datetime] NULL,
	[AppointmentResourceId] [int] NULL,
	[RecallRunId] [int] NULL,
	[EventBlob] [varbinary](max) NULL,
	[EventText] [varchar](max) NULL,
	[ActivityDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_RecallActivity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RecallRun]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecallRun](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RunDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_RecallRun] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RecallRunDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecallRunDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RecallRunId] [int] NOT NULL,
	[RecallId] [int] NOT NULL,
	[EventNo] [int] NOT NULL,
 CONSTRAINT [PK_RecallRunDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Receipt]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Receipt](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Amount] [money] NULL,
	[ReceiptType] [int] NULL,
	[AdjustmentTypeId] [int] NULL,
	[AdjustmentNotes] [varchar](max) NULL,
	[TransferReferenceReceiptId] [int] NULL,
	[ReversalReceiptId] [int] NULL,
	[PayerDebtorId] [int] NULL,
	[PayerName] [varchar](100) NULL,
	[PayerAddressId] [int] NULL,
	[PayerType] [int] NULL,
	[BankAccountId] [int] NULL,
	[LocationId] [int] NULL,
	[UserId] [int] NULL,
	[ReceiptDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[ReceiptPrintedDateTimeOffset] [datetimeoffset](7) NULL,
	[XeroUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Receipt] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReceiptDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReceiptDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReceiptId] [int] NULL,
	[Amount] [money] NULL,
	[AmountGST] [money] NULL,
	[LegalEntityId] [int] NULL,
	[PatientDebtorDebtorId] [int] NULL,
	[InvoiceDetailId] [int] NULL,
	[ReceiptTransferCrossReference] [int] NULL,
 CONSTRAINT [PK_ReceiptDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RecentPatient]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecentPatient](
	[UserId] [int] NOT NULL,
	[PatientDebtorId] [int] NOT NULL,
	[Reason] [int] NOT NULL,
	[LastDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[Uid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_RecentPatient] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ReferralIn]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReferralIn](
	[ReferralInId] [int] IDENTITY(1,1) NOT NULL,
	[PatientId] [int] NULL,
	[FromAddressBookId] [int] NULL,
	[ToUserId] [int] NULL,
	[WrittenDate] [datetime] NULL,
	[FirstUsedDate] [datetime] NULL,
	[ReferralPeriodType] [int] NULL,
	[ReferralPeriodMonths] [int] NULL,
	[ReferralReason] [varchar](150) NULL,
	[Lost] [int] NULL,
	[Inactive] [bit] NOT NULL,
 CONSTRAINT [PK_Referral] PRIMARY KEY CLUSTERED 
(
	[ReferralInId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReferralSource]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReferralSource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ReferralSource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Relationship]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Relationship](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Relationship] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Resource]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Resource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[ProviderId] [int] NULL,
	[Name] [varchar](50) NULL,
	[Shortname] [char](5) NULL,
	[WalkinPenalty] [int] NULL,
	[DisplayOrder] [int] NULL,
	[AppointmentsBeyondRoster] [int] NULL,
	[AppointmentsBeyondBookAheadTimes] [int] NULL,
	[WaitingOnly] [int] NULL,
	[DefaultAppointmentLength] [int] NULL,
	[LocationId] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[LinkedUserId] [int] NULL,
	[OnlineAppointment] [int] NULL,
	[Email] [varchar](250) NULL,
	[AppointmentOnly] [int] NULL,
	[RemoveFromClinicalWaitingListWhenBilled] [int] NULL,
 CONSTRAINT [PK_Resource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ResourceSecondaryResource]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResourceSecondaryResource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ResourceId] [int] NOT NULL,
	[SecondaryResourceId] [int] NOT NULL,
 CONSTRAINT [PK_ResourceSecondaryResource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RosterAppointmentType]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RosterAppointmentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RosterTypeId] [int] NOT NULL,
	[AppointmentTypeId] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_RosterAppointmentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RosterSource]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RosterSource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ResourceId] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[EffectiveDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[RosterWeeks] [int] NULL,
	[RollDate] [datetime] NULL,
	[RosterOverride] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_RosterSource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RosterSourceDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RosterSourceDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RosterSourceId] [int] NOT NULL,
	[WeekNumber] [int] NULL,
	[StartTime] [datetime] NULL,
	[DayNumber] [int] NULL,
	[Length] [int] NULL,
	[RosterTypeId] [int] NULL,
 CONSTRAINT [PK_RosterSourceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RosterType]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RosterType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[BackColor] [int] NULL,
	[ShowAsUnavailable] [int] NULL,
	[BookAhead] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[OnlineAppointment] [int] NULL,
	[AllAppointmentTypes] [int] NULL,
	[LocationId] [int] NULL,
	[BookAheadTime] [datetime] NULL,
 CONSTRAINT [PK_RosterType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScheduleDayNote]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScheduleDayNote](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ScheduleDate] [datetime] NULL,
	[ScheduleViewId] [int] NULL,
	[DayNote] [varchar](500) NULL,
 CONSTRAINT [PK_ScheduleDayNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScheduleView]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScheduleView](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[Description] [varchar](50) NULL,
	[HideIfNoAvailability] [int] NULL,
	[DisplayOrder] [int] NULL,
	[DisplayDayOrWeek] [int] NULL,
	[DisplayAppointmentDetails] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ScheduleView] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScheduleViewResource]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduleViewResource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ScheduleViewId] [int] NULL,
	[ResourceId] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_ScheduleViewResource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SecurityItemAssign]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SecurityItemAssign](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserRoleId] [int] NOT NULL,
	[SecurityItemId] [int] NOT NULL,
	[SecurityItemValue] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_SecurityItemAssign] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ServerCacheUpdate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerCacheUpdate](
	[Keyword] [int] NOT NULL,
	[UpdateDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_ServerCacheUpdate] PRIMARY KEY CLUSTERED 
(
	[Keyword] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ServiceGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[IsPricingServiceGroup] [int] NULL,
	[IsReportingServiceGroup] [int] NULL,
 CONSTRAINT [PK_ServiceGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServiceGroupDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceGroupDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServiceGroupId] [int] NOT NULL,
	[ItemCode] [varchar](10) NULL,
 CONSTRAINT [PK_ServiceGroupDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServiceItem]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [varchar](10) NULL,
	[ItemDisplay] [varchar](50) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Modality] [int] NOT NULL,
 CONSTRAINT [PK_ServiceItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [UQ_ServiceItem_ItemCodeModality] UNIQUE NONCLUSTERED 
(
	[ItemCode] ASC,
	[Modality] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServiceItemDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceItemDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServiceItemId] [int] NOT NULL,
	[EffectiveDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[MbsCategory] [int] NULL,
	[MbsGroup] [int] NULL,
	[MbsSubGroup] [int] NULL,
	[MedicareDescription] [varchar](250) NULL,
	[PracticeDescription] [varchar](50) NULL,
	[PricingServiceGroupId] [int] NULL,
	[ReportingServiceGroupId] [int] NULL,
	[GstType] [int] NULL,
	[AllowAdditionalDescription] [int] NULL,
	[AdditionalDescription] [varchar](250) NULL,
	[RebatePercentInHospital] [decimal](5, 2) NULL,
	[RebatePercentNotHospital] [decimal](5, 2) NULL,
	[RvgUnits] [decimal](4, 1) NULL,
	[DefaultEquipmentId] [varchar](5) NULL,
	[DerivedFeeType] [int] NULL,
	[AssistFeeAllowed] [int] NULL,
	[ReferralRequired] [int] NULL,
	[ReferralType] [int] NULL,
	[InHospitalService] [int] NULL,
	[ClaimToDVA] [int] NULL,
	[ClaimToMedicare] [int] NULL,
	[SpecialServiceItem] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[UseReportingServiceGroupFromEligibleItem] [bit] NOT NULL,
	[ServiceReferenceRequired] [bit] NOT NULL,
 CONSTRAINT [PK_ServiceItemDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServiceItemPrice]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceItemPrice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServiceItemId] [int] NOT NULL,
	[EffectiveDate] [datetime] NULL,
	[BaseFeeUid] [uniqueidentifier] NULL,
	[Price] [money] NULL,
	[DerivedFee] [money] NULL,
	[DerivedFeeExtra] [money] NULL,
	[Factor] [decimal](8, 4) NULL,
	[BasisBaseFeeUid] [uniqueidentifier] NULL,
	[EligibleDVAREI] [int] NULL,
	[EligibleDVAVAP] [int] NULL,
 CONSTRAINT [PK_ServiceItemPrice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SMSReceived]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SMSReceived](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReceivedType] [int] NULL,
	[Processed] [int] NULL,
	[ProcessedMessage] [varchar](max) NULL,
	[SMSSentUid] [uniqueidentifier] NULL,
	[Originator] [varchar](12) NULL,
	[Recipient] [varchar](12) NULL,
	[MessageText] [varchar](max) NULL,
	[DeliveryResult] [varchar](10) NULL,
	[MessageId] [varchar](64) NULL,
	[Reference] [varchar](64) NULL,
	[MessageReceived] [varchar](max) NULL,
	[ProcessedDateTimeOffset] [datetimeoffset](7) NULL,
	[ReceivedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_SMSReceived] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SMSReceivedPatientDebtor]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSReceivedPatientDebtor](
	[SmsReceivedId] [int] NULL,
	[PatientDebtorId] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SMSSent]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SMSSent](
	[SMSUid] [uniqueidentifier] NOT NULL,
	[Recipient] [varchar](12) NULL,
	[PatientDebtorId] [int] NULL,
	[MessageText] [varchar](max) NULL,
	[SMSCategory] [int] NULL,
	[ObjectReferenceId] [int] NULL,
	[ObjectReferenceUid] [uniqueidentifier] NULL,
	[ReplyStatus] [int] NULL,
	[Status] [int] NULL,
	[ErrorMessage] [varchar](max) NULL,
	[UserId] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[DeliveredDateTimeOffset] [datetimeoffset](7) NULL,
	[ErrorDateTimeOffset] [datetimeoffset](7) NULL,
	[QueuedDateTimeOffset] [datetimeoffset](7) NULL,
	[SentDateTimeOffset] [datetimeoffset](7) NULL,
	[Ignore] [int] NULL,
 CONSTRAINT [PK_SMSSent] PRIMARY KEY CLUSTERED 
(
	[SMSUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Snippet]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Snippet](
	[SnippetUid] [varchar](160) NOT NULL,
	[Inactive] [int] NOT NULL,
	[stat_UserIdAvailableTo] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](100) NULL,
	[Path] [varchar](max) NULL,
	[AutoText] [varchar](10) NULL,
	[SnippetType] [int] NULL,
	[EntryPrompt] [varchar](max) NULL,
	[Runtime] [int] NULL,
	[Clinical] [int] NULL,
	[ForcedFormattingType] [int] NULL,
	[AdditionalInfo] [varchar](max) NULL,
	[Blob] [varbinary](max) NULL,
	[Blob2] [varbinary](max) NULL,
	[DefaultCheckBoxValue] [int] NULL,
	[DefaultSelectionValueUid] [uniqueidentifier] NULL,
	[IsUserSystemSnippet] [int] NOT NULL,
	[GroupCode] [varchar](max) NULL,
	[ParentUid] [varchar](160) NULL,
	[ManuscriptTemplateUid] [uniqueidentifier] NULL,
	[ToDoTemplateId] [int] NULL,
	[Downloaded] [bit] NOT NULL,
	[ModifiedAfterDownloaded] [bit] NOT NULL,
	[AutoTextAvailableToAllUsers] [bit] NOT NULL,
 CONSTRAINT [PK_Snippet] PRIMARY KEY CLUSTERED 
(
	[SnippetUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SnippetAutoTextAvailableTo]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SnippetAutoTextAvailableTo](
	[SnippetUid] [varchar](160) NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SnippetContainedSnippets]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SnippetContainedSnippets](
	[SnippetUid] [varchar](160) NOT NULL,
	[ContainedSnippetUid] [varchar](160) NOT NULL,
 CONSTRAINT [PK_SnippetContainedSnippets] PRIMARY KEY CLUSTERED 
(
	[SnippetUid] ASC,
	[ContainedSnippetUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SnippetDateOptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SnippetDateOptions](
	[Uid] [uniqueidentifier] NOT NULL,
	[SnippetUid] [varchar](160) NOT NULL,
	[IsDateMandatory] [bit] NOT NULL,
	[DefaultToCurrentDate] [bit] NOT NULL,
 CONSTRAINT [PK_SnippetDateOptions] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SnippetSelectionValue]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SnippetSelectionValue](
	[SnippetSelectionValueUid] [uniqueidentifier] NOT NULL,
	[SnippetUid] [varchar](160) NOT NULL,
	[Selection] [varchar](max) NOT NULL,
	[Value] [varchar](max) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_SnippetSelectionValue] PRIMARY KEY CLUSTERED 
(
	[SnippetSelectionValueUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Speciality]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Speciality](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[RequiresSpecialist] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Speciality] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatParameter]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatParameter](
	[ParameterType] [int] NULL,
	[ValueString] [varchar](max) NULL,
	[ValueInt] [int] NULL,
	[ValueDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SterilisationLoad]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SterilisationLoad](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SterilisationMethodId] [int] NULL,
	[LoadNumber] [varchar](20) NULL,
	[Notes] [varchar](500) NULL,
	[ChemicalIndicatorChanged] [int] NULL,
	[BiologicalIndicator] [int] NULL,
	[PackingCheck] [int] NULL,
	[SteriliserParametersMet] [int] NULL,
	[OptionalIndicatorUsed] [int] NULL,
	[Removed] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[LoadDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_SterilisationLoad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SterilisationLoadDetail]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SterilisationLoadDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientDebtorId] [int] NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[SterilisationLoadId] [int] NULL,
	[LoadNumber] [varchar](20) NULL,
	[PackNumber] [varchar](20) NULL,
	[Notes] [varchar](500) NULL,
	[Removed] [int] NULL,
	[UsedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_SterilisationLoadDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SterilisationMethod]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SterilisationMethod](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_SterilisationMethod] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Suburb]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Suburb](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Suburb] [varchar](100) NULL,
	[Postcode] [char](4) NULL,
	[State] [char](3) NULL,
	[SuburbCode] [char](2) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Suburb] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbAdmissionOutcome]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbAdmissionOutcome](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbAdmissionOutcome] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbAnaesthetic]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbAnaesthetic](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbAnaesthetic] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbCancelReason]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbCancelReason](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbCancelReason] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbDetails]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbDetails](
	[QuoteId] [int] NOT NULL,
	[EncounterUid] [varchar](40) NULL,
	[Side] [int] NULL,
	[ServiceProviderId] [int] NULL,
	[HospitalId] [int] NULL,
	[HospitalNotified] [int] NULL,
	[EpisodeId] [int] NULL,
	[AdmissionDateTime] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[InpatientDays] [int] NULL,
	[TbIndicationId] [int] NULL,
	[PreOpNotes] [varchar](max) NULL,
	[AssistantAddressBookId] [int] NULL,
	[AssistantNotified] [int] NULL,
	[AnaesthetistAddressBookId] [int] NULL,
	[AnaesthetistNotified] [int] NULL,
	[PaediatricianAddressBookId] [int] NULL,
	[PaediatricianNotified] [int] NULL,
	[TbCategoryId] [int] NULL,
	[TbMagnitudeId] [int] NULL,
	[TbInfectionRiskId] [int] NULL,
	[TbProcedureTypeId] [int] NULL,
	[TbAnaestheticId] [int] NULL,
	[TbProsthesisId] [int] NULL,
	[PackNo] [varchar](50) NULL,
	[ConsentSigned] [int] NULL,
	[PrepaymentReceived] [int] NULL,
	[ConfirmedWithPatient] [int] NULL,
	[ApprovedByThirdParty] [int] NULL,
	[MRSAPositive] [int] NULL,
	[ServiceLocationId] [int] NULL,
	[FastFromDateTime] [datetime] NULL,
	[HospitalUid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TbDetails] PRIMARY KEY CLUSTERED 
(
	[QuoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbDetailsInstrument]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TbDetailsInstrument](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[QuoteId] [int] NOT NULL,
	[TbInstrumentId] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_TbDetailsInstrument] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TbDetailsProcedure]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TbDetailsProcedure](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[QuoteId] [int] NOT NULL,
	[TbProcedureId] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[PlannedOrActual] [int] NULL,
 CONSTRAINT [PK_TbDetailsProcedure] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TbFollowupOutcome]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbFollowupOutcome](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbFollowupOutcome] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbIndication]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbIndication](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbIndication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbInfectionRisk]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbInfectionRisk](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbInfectionRisk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbInstrument]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbInstrument](
	[Id] [int] NOT NULL,
	[ParentId] [int] NULL,
	[Inactive] [int] NOT NULL,
	[IsFolder] [int] NULL,
	[Description] [varchar](150) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbInstrument] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbInstrumentQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TbInstrumentQuickList](
	[QuickListUid] [uniqueidentifier] NOT NULL,
	[TbInstrumentId] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[UserId] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TbMagnitude]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbMagnitude](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbMagnitude] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbOpNotes]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbOpNotes](
	[QuoteId] [int] NOT NULL,
	[OperationCompleteProviderId] [int] NULL,
	[OperationCompleteDate] [datetime] NULL,
	[Findings] [varchar](max) NULL,
	[Technique] [varchar](max) NULL,
	[PostOp] [varchar](max) NULL,
	[AuditSummary] [varchar](max) NULL,
	[TbAdmissionOutcomeId] [int] NULL,
	[FollowupDate] [datetime] NULL,
	[TbFollowupOutcomeId] [int] NULL,
	[SuppurativeInfection] [int] NULL,
	[NonSuppurativeInfection] [int] NULL,
	[WoundHaematoma] [int] NULL,
	[WoundDehiscence] [int] NULL,
	[PulmonaryInfection] [int] NULL,
	[PulmonaryEmbolus] [int] NULL,
	[Reoperation] [int] NULL,
	[IncompleteExcision] [int] NULL,
	[GraftFailure] [int] NULL,
	[TZoneFailure] [int] NULL,
	[BileLeak] [int] NULL,
	[AnastomoticLeak] [int] NULL,
	[FailedLaparoscopy] [int] NULL,
	[HysterectomyUnder35] [int] NULL,
	[EstimatedBloodLoss] [int] NULL,
	[TransfusionAmount] [int] NULL,
	[OtherComplications] [varchar](max) NULL,
	[Status] [int] NULL,
	[TbCancelReasonId] [int] NULL,
	[OperationFinishDateTimeOffset] [datetimeoffset](7) NULL,
	[OperationStartDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_TbOpNotes] PRIMARY KEY CLUSTERED 
(
	[QuoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbOpNotesTemplate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbOpNotesTemplate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[Findings] [varchar](max) NULL,
	[Technique] [varchar](max) NULL,
	[PostOp] [varchar](max) NULL,
	[AuditSummary] [varchar](max) NULL,
	[TbAdmissionOutcomeId] [int] NULL,
	[FollowupDate] [datetime] NULL,
	[TbFollowupOutcomeId] [int] NULL,
	[SuppurativeInfection] [int] NULL,
	[NonSuppurativeInfection] [int] NULL,
	[WoundHaematoma] [int] NULL,
	[WoundDehiscence] [int] NULL,
	[PulmonaryInfection] [int] NULL,
	[PulmonaryEmbolus] [int] NULL,
	[Reoperation] [int] NULL,
	[IncompleteExcision] [int] NULL,
	[GraftFailure] [int] NULL,
	[TZoneFailure] [int] NULL,
	[BileLeak] [int] NULL,
	[AnastomoticLeak] [int] NULL,
	[FailedLaparoscopy] [int] NULL,
	[HysterectomyUnder35] [int] NULL,
	[EstimatedBloodLoss] [int] NULL,
	[TransfusionAmount] [int] NULL,
	[OtherComplications] [varchar](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbOpNotesTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbProcedure]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbProcedure](
	[Inactive] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ParentId] [int] NULL,
	[IsFolder] [int] NULL,
	[Description] [varchar](150) NULL,
	[Id] [int] NOT NULL,
 CONSTRAINT [PK_TbProcedure] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbProcedureQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TbProcedureQuickList](
	[QuickListUid] [uniqueidentifier] NOT NULL,
	[TbProcedureId] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[UserId] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TbProcedureType]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbProcedureType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Description] [varchar](150) NULL,
 CONSTRAINT [PK_TbProcedureType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TbProsthesis]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TbProsthesis](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_TbProsthesis] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TemplatesAvailable]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TemplatesAvailable](
	[TemplatesAvailableId] [int] IDENTITY(1,1) NOT NULL,
	[DocumentType] [int] NOT NULL,
	[DocumentTypeClinicalSummaryHeadingId] [int] NULL,
	[UserIdAvailableTo] [int] NULL,
	[DocumentTemplateId] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[PaperName] [varchar](100) NULL,
	[Inactive] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ConvertedToManuscript] [bit] NOT NULL,
 CONSTRAINT [PK_TemplatesAvailable] PRIMARY KEY CLUSTERED 
(
	[TemplatesAvailableId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TimeZoneUpgradeTracking]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TimeZoneUpgradeTracking](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessStartDateTime] [datetime] NOT NULL,
	[ProcessFinishDateTime] [datetime] NOT NULL,
	[TableName] [varchar](max) NOT NULL,
	[OldColumnName] [varchar](max) NOT NULL,
	[NewColumnName] [varchar](max) NOT NULL,
	[TotalNumberOfRowsInTable] [int] NOT NULL,
	[NumberOfRowsConverted] [int] NOT NULL,
	[NumberOfRowsAlreadyConverted] [int] NOT NULL,
	[NumberOfRowsWithNullDateTimeValue] [int] NOT NULL,
	[ErrorString] [varchar](max) NULL,
	[Notes] [varchar](max) NULL,
	[WasColumnConversionCompleted] [bit] NOT NULL,
 CONSTRAINT [PK_TimeZoneUpgradeTracking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDo]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToDo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Type] [int] NOT NULL,
	[Urgent] [int] NULL,
	[OriginatorType] [int] NULL,
	[OriginatorUserId] [int] NULL,
	[LastActionByUserId] [int] NULL,
	[LinkToDoId] [int] NULL,
	[NotificationUserId] [int] NULL,
	[NotificationDescription] [varchar](100) NULL,
	[CategoryId] [int] NULL,
	[RequiredAfterDateTime] [datetime] NULL,
	[RequiredByDateTime] [datetime] NULL,
	[Privacy] [int] NULL,
	[PublicField] [int] NULL,
	[HealthRecordPrompt] [int] NULL,
	[PatientDebtorId] [int] NULL,
	[AddressBookId] [int] NULL,
	[RecallId] [int] NULL,
	[ClinicalDetailLinkType] [int] NULL,
	[ClinicalDetailUid] [uniqueidentifier] NULL,
	[Status] [int] NULL,
	[ToDoTextBlob] [varbinary](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ToDoPlainText] [varchar](max) NULL,
	[LastUpdatedByUserId] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[LastUpdatedDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ToDo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDoAccessBy]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoAccessBy](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL,
 CONSTRAINT [PK_ToDoAccessBy] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToDoActionNote]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToDoActionNote](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[ActionText] [varchar](max) NOT NULL,
	[ActionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_ToDoActionNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDoCategory]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToDoCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ToDoCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDoChangeNote]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToDoChangeNote](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[ChangeText] [varchar](max) NOT NULL,
	[ChangeDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[ChangeNoteType] [int] NULL,
 CONSTRAINT [PK_ToDoChangeNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDoNextAction]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoNextAction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL,
 CONSTRAINT [PK_ToDoNextAction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToDoOriginalTo]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoOriginalTo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL,
 CONSTRAINT [PK_ToDoOriginalTo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToDoStatus]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToDoStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_ToDoStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDoTemplate]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToDoTemplate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Urgent] [int] NULL,
	[Privacy] [int] NULL,
	[PublicField] [int] NULL,
	[IncludeResultDescription] [int] NULL,
	[HealthRecordPrompt] [int] NULL,
	[CategoryId] [int] NULL,
	[ToDoManuscriptBlob] [varbinary](max) NULL,
	[Inactive] [int] NOT NULL,
	[Operation] [int] NULL,
	[RequiredAfterDateTimeOffset] [int] NULL,
	[RequiredByDateTimeOffset] [int] NULL,
	[ActionPlace] [int] NOT NULL,
	[ToDoBy] [int] NOT NULL,
	[ActionBy] [int] NULL,
	[AutoAnnotate] [int] NULL,
	[OnToolbar] [int] NULL,
	[AllIndividual] [bit] NOT NULL,
 CONSTRAINT [PK_ToDoTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToDoTemplateActionBy]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoTemplateActionBy](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoTemplateId] [int] NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL,
 CONSTRAINT [PK_ToDoTemplateActionBy] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToDoTemplateAvailableTo]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoTemplateAvailableTo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoTemplateId] [int] NOT NULL,
	[UserId] [int] NULL,
	[UserGroupId] [int] NULL,
 CONSTRAINT [PK_ToDoTemplateAvailableTo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToDoUnread]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoUnread](
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[IsUnread] [bit] NOT NULL,
	[LastUpdatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_ToDoUnread] PRIMARY KEY CLUSTERED 
(
	[ToDoId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ToDoUserAction]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ToDoUserAction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ToDoId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Status] [int] NULL,
	[ActionDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ToDoUserAction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UnmatchedMessageIn]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UnmatchedMessageIn](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MessageInId] [int] NULL,
	[PatientId] [int] NULL,
	[PatientAddress1] [varchar](200) NULL,
	[PatientAddress2] [varchar](200) NULL,
	[PatientAddress3] [varchar](200) NULL,
	[PatientIhI] [varchar](16) NULL,
	[PatientMedicareNumber] [varchar](10) NULL,
	[PatientMedicareIrn] [int] NULL,
	[PatientDvaNumber] [varchar](10) NULL,
	[PatientSex] [int] NULL,
	[PatientDob] [datetime] NULL,
	[RecipientUserId] [int] NULL,
	[RecipientUserName] [varchar](200) NULL,
	[RecipientUserHpiI] [varchar](16) NULL,
	[RecipientUserProviderNumber] [varchar](8) NULL,
	[SendingOrganisationAddressBookId] [int] NULL,
	[SendingOrganisationName] [varchar](200) NULL,
	[SendingOrganisationHpiO] [varchar](16) NULL,
	[SendingPersonAddressBookId] [int] NULL,
	[SendingPersonName] [varchar](200) NULL,
	[SendingPersonHpiI] [varchar](16) NULL,
	[SendingPersonAddress1] [varchar](200) NULL,
	[SendingPersonAddress2] [varchar](200) NULL,
	[SendingPersonAddress3] [varchar](200) NULL,
	[MessageDetailType] [int] NULL,
	[Description] [varchar](200) NULL,
	[MatchedByUserId] [int] NULL,
	[DiscardedByUserId] [int] NULL,
	[PatientFirstName] [varchar](200) NULL,
	[PatientLastName] [varchar](200) NULL,
	[SendingPersonProviderNumber] [varchar](8) NULL,
	[OurReference] [int] NULL,
	[LabReference] [varchar](200) NULL,
	[OrderedBy] [varchar](200) NULL,
	[RunNumber] [varchar](20) NULL,
	[CopyDoctors] [varchar](200) NULL,
	[IsUrgent] [int] NULL,
	[IsAbnormal] [int] NULL,
	[RequestComplete] [int] NULL,
	[CollectionDateTimeOffset] [datetimeoffset](7) NULL,
	[DiscardedDateTimeOffset] [datetimeoffset](7) NULL,
	[MatchedDateTimeOffset] [datetimeoffset](7) NULL,
	[RequestDateTimeOffset] [datetimeoffset](7) NULL,
	[MessageWrittenDateTimeOffset] [datetimeoffset](7) NULL,
	[MessageReceivedDateTimeOffset] [datetimeoffset](7) NULL,
	[DisplayText] [varchar](max) NULL,
	[DisplayBlob] [varbinary](max) NULL,
	[DisplayFormatExtension] [varchar](20) NULL,
	[DisplayCompliance] [int] NULL,
	[DisplayText2] [varchar](max) NULL,
	[DisplayBlob2] [varbinary](max) NULL,
	[DisplayFormatExtension2] [varchar](20) NULL,
	[DisplayCompliance2] [int] NULL,
	[MessageMatchStatus] [int] NULL,
	[AutomatchFailReason] [int] NULL,
	[LaboratoryNumber] [varchar](200) NULL,
	[RequestUid] [uniqueidentifier] NULL,
	[ReferralReason] [varchar](50) NULL,
	[ReferralDisposition] [varchar](50) NULL,
	[ReferralType] [varchar](50) NULL,
 CONSTRAINT [PK_UnmatchedMessageIn] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UnmatchedMessageInAtomic]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UnmatchedMessageInAtomic](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UnmatchedMessageInId] [int] NOT NULL,
	[SetID] [int] NULL,
	[ValueType] [varchar](30) NULL,
	[LOINCIdentifier] [varchar](250) NULL,
	[LabResultCode] [varchar](250) NULL,
	[ObservationValue] [varchar](max) NULL,
	[NumericValue] [float] NULL,
	[Units] [varchar](250) NULL,
	[ReferenceRange] [varchar](60) NULL,
	[AbnormalFlags] [varchar](8) NULL,
	[NatureOfAbnormalTest] [varchar](2) NULL,
	[ObservationResultStatus] [varchar](1) NULL,
	[LastNormalObservationDateTimeOffset] [datetimeoffset](7) NULL,
	[PathologyLabAnalysisDateTimeOffset] [datetimeoffset](7) NULL,
	[EncodingType] [varchar](30) NULL,
	[CodingSystem] [varchar](30) NULL,
 CONSTRAINT [PK_UnmatchedMessageInAtomic] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UpgradeProcess]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UpgradeProcess](
	[Keyword] [varchar](100) NOT NULL,
	[ProcessDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_UpgradeProcess] PRIMARY KEY CLUSTERED 
(
	[Keyword] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[LegalPersonNameId] [int] NULL,
	[ResidentialAddressId] [int] NULL,
	[PostalAddressId] [int] NULL,
	[WorkPhoneContactId] [int] NULL,
	[FaxContactId] [int] NULL,
	[MobilePhoneContactId] [int] NULL,
	[EmailContactId] [int] NULL,
	[IsServiceProvider] [int] NULL,
	[IsAdministrator] [int] NULL,
	[AllowAddressToUser] [int] NULL,
	[IsStatUser] [int] NULL,
	[UserGroupId] [int] NULL,
	[NameToDisplay] [varchar](100) NULL,
	[IdentifierToDisplay] [varchar](5) NULL,
	[PreferredPersonNameId] [int] NULL,
	[DoB] [datetime] NULL,
	[DoD] [datetime] NULL,
	[Sex] [int] NULL,
	[HomePhoneContactId] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ConvertedSystemId] [varchar](50) NULL,
	[Password] [varchar](max) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserDictionary]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserDictionary](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[word] [varchar](200) NULL,
 CONSTRAINT [PK_UserDictionary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserFundPayee]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserFundPayee](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[HealthFundUid] [uniqueidentifier] NULL,
	[HealthFundId] [int] NULL,
	[FundPayeeId] [varchar](12) NULL,
	[UserFundEclipseOption] [int] NULL,
	[PricingOption] [int] NULL,
	[AssistFeeMultiplier] [decimal](8, 4) NULL,
	[AssistFeeMultiplierGap] [decimal](8, 4) NULL,
	[AssistFeeMultiplierNoGap] [decimal](8, 4) NULL,
 CONSTRAINT [PK_UserFundPayee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserGroupAlerts]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserGroupAlerts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserGroupId] [int] NULL,
	[AlertEnumValue] [int] NULL,
	[Enabled] [bit] NOT NULL,
	[Highlight] [bit] NOT NULL,
	[HideIfNone] [bit] NOT NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_UserGroupAlerts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [UC_UserGroupAlerts] UNIQUE NONCLUSTERED 
(
	[UserGroupId] ASC,
	[AlertEnumValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserGroupOptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserGroupOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserGroupId] [int] NULL,
	[OptionName] [varchar](500) NULL,
	[OptionValue] [varchar](5000) NULL,
 CONSTRAINT [PK_UserGroupOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserMailGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserMailGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[DisplayOrder] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserMailGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserMailGroupUsers]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMailGroupUsers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[UserMailGroupId] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserMailGroupUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserOptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[OptionName] [varchar](500) NULL,
	[OptionValue] [varchar](max) NULL,
 CONSTRAINT [PK_UserOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserOptionsQuickList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserOptionsQuickList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[QuickListType] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Text] [varchar](1000) NULL,
 CONSTRAINT [PK_UserOptionsQuickList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserProcess]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserProcess](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserIdAvailableTo] [int] NULL,
	[Inactive] [int] NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[FilePath] [varchar](max) NOT NULL,
	[WorkingDirectory] [varchar](max) NULL,
	[Arguments] [varchar](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserProcess] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserResource]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserResource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ResourceId] [int] NOT NULL,
	[WaitingListOption] [int] NULL,
 CONSTRAINT [PK_UserResource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserRole](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [varchar](50) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Description] [varchar](max) NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserRoleAssign]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoleAssign](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[UserRoleId] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserRoleAssign] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Vaccine]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Vaccine](
	[VaccineUid] [uniqueidentifier] NOT NULL,
	[ACIRCode] [varchar](20) NOT NULL,
	[BrandName] [varchar](50) NOT NULL,
	[Disease] [varchar](50) NOT NULL,
	[MaxDoses] [int] NOT NULL,
	[ACIR] [int] NULL,
	[Stocked] [int] NULL,
	[Obsolete] [int] NULL,
	[ConvertedSystemId] [varchar](50) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Vaccine] PRIMARY KEY CLUSTERED 
(
	[VaccineUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VaccineBatch]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VaccineBatch](
	[VaccineUid] [uniqueidentifier] NOT NULL,
	[BatchNumber] [varchar](25) NOT NULL,
 CONSTRAINT [PK_VaccineBatch] PRIMARY KEY CLUSTERED 
(
	[VaccineUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VaccineGroup]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VaccineGroup](
	[Id] [int] NOT NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_VaccineGroup_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VaccineGroupVaccine]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VaccineGroupVaccine](
	[VaccineUid] [uniqueidentifier] NULL,
	[VaccineGroupId] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VaccineSchedule]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VaccineSchedule](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Inactive] [int] NOT NULL,
	[DisplayOrder] [int] NULL,
	[Description] [varchar](100) NULL,
	[Filename] [varchar](100) NULL,
	[Blob] [varbinary](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_VaccineSchedule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WaitList]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WaitList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EpisodeId] [int] NULL,
	[SameResource] [int] NULL,
	[Notes] [varchar](max) NULL,
	[ResourceId] [int] NULL,
 CONSTRAINT [PK_WaitList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WorkerBee]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkerBee](
	[ErxCheck] [int] NULL,
	[SmsSentCheck] [int] NULL,
	[SmsReceivedCheck] [int] NULL,
	[MessageOutCheck] [int] NULL,
	[MessageInCheck] [int] NULL,
	[XeroInterfaceCheck] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Workstation]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Workstation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[Inactive] [bit] NOT NULL,
 CONSTRAINT [PK_Workstation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WorkstationFileImport]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkstationFileImport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WorkstationId] [int] NOT NULL,
	[FileImportType] [int] NOT NULL,
	[Inactive] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_WorkstationFileImports] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WorkstationFileImportFolder]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkstationFileImportFolder](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WorkstationFileImportId] [int] NOT NULL,
	[LocalFolderName] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_WorkstationFileImportFolder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WorkstationOptions]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WorkstationOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WorkstationId] [int] NULL,
	[Optionname] [varchar](500) NULL,
	[OptionValue] [varchar](5000) NULL,
 CONSTRAINT [PK_WorkstationOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WorkstationReport]    Script Date: 16/04/2019 2:08:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WorkstationReport](
	[WorkstationReportId] [int] IDENTITY(1,1) NOT NULL,
	[WorkstationId] [int] NOT NULL,
	[PrinterName] [varchar](250) NULL,
	[LeftMargin] [int] NULL,
	[TopMargin] [int] NULL,
	[ReportName] [varchar](250) NOT NULL,
 CONSTRAINT [PK_WorkstationReport] PRIMARY KEY CLUSTERED 
(
	[WorkstationReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_Address_5_2121058592__K1_2_3_4_5_6_10_11]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Address_5_2121058592__K1_2_3_4_5_6_10_11] ON [dbo].[Address]
(
	[Id] ASC
)
INCLUDE ( 	[Street1],
	[Street2],
	[Street3],
	[State],
	[Postcode],
	[Suburb],
	[OverseasAddress]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_AddressBook_5_2085582468__K1_K3_K6_K7_8_28]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_AddressBook_5_2085582468__K1_K3_K6_K7_8_28] ON [dbo].[AddressBook]
(
	[AddressBookId] ASC,
	[SpecialityId] ASC,
	[LegalPersonNameId] ASC,
	[PreferredPersonNameId] ASC
)
INCLUDE ( 	[OrganisationName],
	[ProviderNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_AddressBook_ClinicalFacilityIdentifier]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_AddressBook_ClinicalFacilityIdentifier] ON [dbo].[AddressBook]
(
	[ClinicalFacilityIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_AddressBook_EntityType_LinkedOrganisationAddressBookId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_AddressBook_EntityType_LinkedOrganisationAddressBookId] ON [dbo].[AddressBook]
(
	[EntityType] ASC,
	[LinkedOrganisationAddressBookId] ASC
)
INCLUDE ( 	[AddressBookId],
	[LegalPersonNameId],
	[PreferredPersonNameId],
	[OrganisationName],
	[StreetAddressId],
	[ProviderNumber],
	[HealthcareIdentifier],
	[HiLastUpdatedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_AddressBook_PostalAddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_AddressBook_PostalAddressId] ON [dbo].[AddressBook]
(
	[PostalAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_AddressBook_StreetAddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_AddressBook_StreetAddressId] ON [dbo].[AddressBook]
(
	[StreetAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [AppointmentHistory]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [AppointmentHistory] ON [dbo].[AppointmentHistory]
(
	[EpisodeId] ASC,
	[ChangeDateTimeOffset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_AppointmentHistory_PatientId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_AppointmentHistory_PatientId] ON [dbo].[AppointmentHistory]
(
	[PatientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Billing_DirectBillClaimId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_DirectBillClaimId] ON [dbo].[Billing]
(
	[DirectBillClaimId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Billing_EpisodeId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_EpisodeId] ON [dbo].[Billing]
(
	[EpisodeId] ASC
)
INCLUDE ( 	[Id],
	[BillcodeUid],
	[HoldReason]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Billing_LocationId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_LocationId] ON [dbo].[Billing]
(
	[LocationId] ASC
)
INCLUDE ( 	[Id],
	[EpisodeId],
	[BillcodeUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Billing_PracticeLocationId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_PracticeLocationId] ON [dbo].[Billing]
(
	[PracticeLocationId] ASC
)
INCLUDE ( 	[Id],
	[EpisodeId],
	[BillcodeUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Billing_Status]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_Status] ON [dbo].[Billing]
(
	[Status] ASC
)
INCLUDE ( 	[Id],
	[EpisodeId],
	[BillDateTimeOffset],
	[DebtorType],
	[OtherDebtorId],
	[AmountBilled],
	[Verified],
	[DirectBillClaimId],
	[HoldReason],
	[VerifyHoldReasonId],
	[BillcodeUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Billing_Status_LocationId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_Status_LocationId] ON [dbo].[Billing]
(
	[Status] ASC,
	[LocationId] ASC
)
INCLUDE ( 	[EpisodeId],
	[BillDateTimeOffset],
	[BillcodeUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Billing_Status_PracticeLocationId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Billing_Status_PracticeLocationId] ON [dbo].[Billing]
(
	[Status] ASC,
	[PracticeLocationId] ASC
)
INCLUDE ( 	[EpisodeId],
	[BillDateTimeOffset],
	[BillcodeUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_BillingDetail_BillingId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_BillingDetail_BillingId] ON [dbo].[BillingDetail]
(
	[BillingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_CDCGrowthChartData_SexAxisCDCType]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_CDCGrowthChartData_SexAxisCDCType] ON [dbo].[CDCGrowthChartData]
(
	[Sex] ASC,
	[Axis] ASC,
	[CDCType] ASC
)
INCLUDE ( 	[L],
	[M],
	[S]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ClinicalImage_Inactive]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalImage_Inactive] ON [dbo].[ClinicalImage]
(
	[Inactive] ASC
)
INCLUDE ( 	[Id],
	[Description],
	[DisplayOrder],
	[RowVersion]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_DirectBillClaim_ClaimId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_DirectBillClaim_ClaimId] ON [dbo].[DirectBillClaim]
(
	[ClaimId] ASC
)
INCLUDE ( 	[ClaimStatus],
	[ClaimDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Episode_Appointment]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [Episode_Appointment] ON [dbo].[Episode]
(
	[AppointmentResourceId] ASC,
	[AppointmentDateTime] ASC,
	[PatientDebtorPatientId] ASC,
	[AppointmentIndex] ASC
)
INCLUDE ( 	[Id],
	[Status],
	[AppointmentNotes],
	[AppointmentTypeId],
	[AppointmentLength],
	[AppointmentLengthMinutes],
	[ReferralInId],
	[ReferralOverride],
	[AppointmentName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Episode_AppointmentDateTime]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Episode_AppointmentDateTime] ON [dbo].[Episode]
(
	[AppointmentDateTime] ASC
)
INCLUDE ( 	[Id],
	[PatientDebtorPatientId],
	[OnlineAppointmentName],
	[Status],
	[AppointmentIndex],
	[AppointmentTypeId],
	[AppointmentNotes],
	[AppointmentLength],
	[AppointmentLengthMinutes],
	[AppointmentConfirmedById],
	[ReferralInId],
	[ReferralOverride],
	[AppointmentName],
	[AppointmentCustomFieldId],
	[AppointmentConfirmedDateTimeOffset],
	[AppointmentResourceId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Episode_AppointmentDateTime_AppointmentIndex]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Episode_AppointmentDateTime_AppointmentIndex] ON [dbo].[Episode]
(
	[AppointmentDateTime] ASC,
	[AppointmentIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Episode_AppointmentResourceIdAppointmentDateTime]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Episode_AppointmentResourceIdAppointmentDateTime] ON [dbo].[Episode]
(
	[AppointmentResourceId] ASC,
	[AppointmentDateTime] ASC
)
INCLUDE ( 	[Id],
	[PatientDebtorPatientId],
	[ArriveDateTimeOffset],
	[Status],
	[AppointmentTypeId],
	[AppointmentNotes],
	[AppointmentLength],
	[AppointmentLengthMinutes],
	[AppointmentName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Episode_Status]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Episode_Status] ON [dbo].[Episode]
(
	[Status] ASC
)
INCLUDE ( 	[Id],
	[PatientDebtorPatientId],
	[AppointmentDateTime],
	[AppointmentResourceId],
	[AppointmentTypeId],
	[AppointmentNotes],
	[AppointmentLength],
	[AppointmentLengthMinutes],
	[AppointmentConfirmedDateTimeOffset],
	[AppointmentConfirmedById]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Episode_StatusAppointmentTypeId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Episode_StatusAppointmentTypeId] ON [dbo].[Episode]
(
	[Status] ASC,
	[AppointmentTypeId] ASC
)
INCLUDE ( 	[Id],
	[PatientDebtorPatientId],
	[AppointmentDateTime],
	[AppointmentResourceId],
	[AppointmentNotes],
	[AppointmentLength],
	[AppointmentLengthMinutes],
	[AppointmentConfirmedDateTimeOffset],
	[AppointmentConfirmedById]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Episode_StatusStartDateTime]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Episode_StatusStartDateTime] ON [dbo].[Episode]
(
	[Status] ASC,
	[StartDateTimeOffset] ASC
)
INCLUDE ( 	[Id],
	[PatientDebtorPatientId],
	[ProviderId],
	[LocationId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RadiologyRequestTest_PatientDebtorPatientId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RadiologyRequestTest_PatientDebtorPatientId] ON [dbo].[Episode]
(
	[PatientDebtorPatientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RadiologyRequestTest_Status]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RadiologyRequestTest_Status] ON [dbo].[Episode]
(
	[Status] ASC
)
INCLUDE ( 	[Id],
	[AppointmentDateTime],
	[ArriveDateTimeOffset],
	[EpisodeResourceId],
	[WalkinPenalty],
	[Urgent]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_HiServiceLog_LogDateTime]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_HiServiceLog_LogDateTime] ON [dbo].[HiServiceLog]
(
	[LogDateTimeOffset] ASC
)
INCLUDE ( 	[Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ICPC2LNK_TermId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ICPC2LNK_TermId] ON [dbo].[ICPC2LNK]
(
	[TermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ICPC2TRM_ICPCCode_TermCode]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ICPC2TRM_ICPCCode_TermCode] ON [dbo].[ICPC2TRM]
(
	[ICPCCode] ASC,
	[TermCode] ASC
)
INCLUDE ( 	[Term30],
	[Nalan50]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ImcProcessingReportDetail_ImcProcessingReportId_ServiceId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ImcProcessingReportDetail_ImcProcessingReportId_ServiceId] ON [dbo].[ImcProcessingReportDetail]
(
	[ImcProcessingReportId] ASC,
	[ServiceId] ASC
)
INCLUDE ( 	[Id],
	[FundBenefitAmount],
	[MedicareBenefitAmount],
	[MedicareExplanationCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_IntegratedEftposTransaction_IntegratedEftposTransactionStatus]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_IntegratedEftposTransaction_IntegratedEftposTransactionStatus] ON [dbo].[IntegratedEftposTransaction]
(
	[IntegratedEftposTransactionStatus] ASC
)
INCLUDE ( 	[CreatedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_IntegratedEftposTransactionHistory_IntegratedEftposTransactionId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_IntegratedEftposTransactionHistory_IntegratedEftposTransactionId] ON [dbo].[IntegratedEftposTransactionHistory]
(
	[IntegratedEftposTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_InternalMessageRecipient_ToUserId_Deleted_InternalMessageFolderId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_InternalMessageRecipient_ToUserId_Deleted_InternalMessageFolderId] ON [dbo].[InternalMessageRecipient]
(
	[ToUserId] ASC,
	[Deleted] ASC,
	[InternalMessageFolderId] ASC
)
INCLUDE ( 	[Id],
	[InternalMessageId],
	[ReadDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_InternalMessageRecipient_ToUserId_ReadDate_Deleted_InternalMessageFolderId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_InternalMessageRecipient_ToUserId_ReadDate_Deleted_InternalMessageFolderId] ON [dbo].[InternalMessageRecipient]
(
	[ToUserId] ASC,
	[ReadDateTimeOffset] ASC,
	[Deleted] ASC,
	[InternalMessageFolderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Invoice_5_226099846__K2_K1_K4_3_5_6_12]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Invoice_5_226099846__K2_K1_K4_3_5_6_12] ON [dbo].[Invoice]
(
	[BillingId] ASC,
	[Id] ASC,
	[InvoiceDateTimeOffset] ASC
)
INCLUDE ( 	[PatientDebtorDebtorId],
	[InvoicePrintedDateTimeOffset],
	[ReversalReceiptId],
	[AmountGST]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Invoice_InvoiceDateTime]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Invoice_InvoiceDateTime] ON [dbo].[Invoice]
(
	[InvoiceDateTimeOffset] ASC
)
INCLUDE ( 	[Id],
	[BillingId],
	[PatientDebtorDebtorId],
	[InvoicePrintedDateTimeOffset],
	[ReversalReceiptId],
	[ReceiptId],
	[AmountGST],
	[PracticeLocationId],
	[UserId],
	[ocPpcImcClaimType],
	[ocTransactionId],
	[LegalEntityId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Invoice_InvoicePrintedDateTimeOffset]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Invoice_InvoicePrintedDateTimeOffset] ON [dbo].[Invoice]
(
	[InvoicePrintedDateTimeOffset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Invoice_PatientDebtorDebtorId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Invoice_PatientDebtorDebtorId] ON [dbo].[Invoice]
(
	[PatientDebtorDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_InvoiceDetail_5_626101271__K2D_K1_K30_5]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_InvoiceDetail_5_626101271__K2D_K1_K30_5] ON [dbo].[InvoiceDetail]
(
	[InvoiceId] ASC,
	[Id] ASC,
	[ServiceItemDetailId] ASC
)
INCLUDE ( 	[AmountBilled]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_InvoiceDetail_ServiceItemDetailId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_InvoiceDetail_ServiceItemDetailId] ON [dbo].[InvoiceDetail]
(
	[ServiceItemDetailId] ASC
)
INCLUDE ( 	[Id],
	[InvoiceId],
	[ReportingServiceGroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_InvoiceDocumentDetail_5_690101499__K3_2]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_InvoiceDocumentDetail_5_690101499__K3_2] ON [dbo].[InvoiceDocumentDetail]
(
	[InvoiceId] ASC
)
INCLUDE ( 	[InvoiceDocumentId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_MessageIn_Id_Transport]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_MessageIn_Id_Transport] ON [dbo].[MessageIn]
(
	[Id] ASC
)
INCLUDE ( 	[MessagingTransportUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_MessageOut_SentDateTimeOffsetMessageType_MessagingTransportUid]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_MessageOut_SentDateTimeOffsetMessageType_MessagingTransportUid] ON [dbo].[MessageOut]
(
	[SentDateTimeOffset] ASC,
	[MessageType] ASC,
	[MessagingTransportUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PathologyResult_DiscardedByUserId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PathologyResult_DiscardedByUserId] ON [dbo].[PathologyResult]
(
	[DiscardedByUserId] ASC
)
INCLUDE ( 	[Laboratory],
	[FacilityAddressBookId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PathologyResult_DiscardedByUserIdLaboratory]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PathologyResult_DiscardedByUserIdLaboratory] ON [dbo].[PathologyResult]
(
	[DiscardedByUserId] ASC,
	[Laboratory] ASC
)
INCLUDE ( 	[Id],
	[FacilityAddressBookId],
	[FacilityType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PathologyResult_FailedAutoMatch_FacilityType_DiscardedByUserId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PathologyResult_FailedAutoMatch_FacilityType_DiscardedByUserId] ON [dbo].[PathologyResult]
(
	[FailedAutoMatch] ASC,
	[FacilityType] ASC,
	[DiscardedByUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PathologyResult_FailedAutoMatchDiscardedByUserId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PathologyResult_FailedAutoMatchDiscardedByUserId] ON [dbo].[PathologyResult]
(
	[FailedAutoMatch] ASC,
	[DiscardedByUserId] ASC
)
INCLUDE ( 	[Id],
	[RunNumber],
	[Laboratory],
	[RunDateTimeOffset],
	[PatientNamePrefix],
	[PatientFirstName],
	[PatientMiddleName],
	[PatientLastName],
	[PatientNameSuffix],
	[ReceivingDrCodeOrProviderNo],
	[LaboratoryNumber],
	[TestCode],
	[Street],
	[Town],
	[State],
	[PostCode],
	[DOB],
	[Gender],
	[HomePhone],
	[MedicareNo],
	[DVANo],
	[DoctorPrefix],
	[DoctorFirstName],
	[DoctorMiddleName],
	[DoctorLastName],
	[DoctorSuffix],
	[DoctorProviderNo],
	[CopyDoctors],
	[IsCopy],
	[RequestCompleted],
	[ResultImportDateTimeOffset],
	[SurgeryId],
	[ShortDoctorName],
	[Pathologist],
	[PathologistPhone],
	[ReferringDoctorName],
	[ReferringDoctorProviderNo],
	[SpecimenType],
	[RequestDateTimeOffset],
	[ReportDateTimeOffset],
	[ConfidentialityIndicator],
	[NormalResultIndicator],
	[UrgentRequestIndicator],
	[RequestedTests],
	[CollectionDateTimeOffset],
	[FacilityAddressBookId],
	[FacilityType],
	[MedicareSubnumerate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_PatientDebtor_5_2053582354__K2_K29_K1_K7_K8_K10_K11_K12_K13_K14_K15_K16_K34_9_17_18]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_PatientDebtor_5_2053582354__K2_K29_K1_K7_K8_K10_K11_K12_K13_K14_K15_K16_K34_9_17_18] ON [dbo].[PatientDebtor]
(
	[PatientDebtorType] ASC,
	[OrganisationName] ASC,
	[Id] ASC,
	[LegalPersonNameId] ASC,
	[PreferredPersonNameId] ASC,
	[ResidentialAddressId] ASC,
	[PostalAddressId] ASC,
	[HomePhoneContactId] ASC,
	[WorkPhoneContactId] ASC,
	[FaxContactId] ASC,
	[MobilePhoneContactId] ASC,
	[EmailContactId] ASC,
	[DefaultProviderUserId] ASC
)
INCLUDE ( 	[Sex],
	[DoB],
	[DoD]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_PatientDebtor_5_2053582354__K2_K7_K8_K29_K1_K10_K11_K12_K13_K14_K15_K16_K34_9_17_18]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_PatientDebtor_5_2053582354__K2_K7_K8_K29_K1_K10_K11_K12_K13_K14_K15_K16_K34_9_17_18] ON [dbo].[PatientDebtor]
(
	[PatientDebtorType] ASC,
	[LegalPersonNameId] ASC,
	[PreferredPersonNameId] ASC,
	[OrganisationName] ASC,
	[Id] ASC,
	[ResidentialAddressId] ASC,
	[PostalAddressId] ASC,
	[HomePhoneContactId] ASC,
	[WorkPhoneContactId] ASC,
	[FaxContactId] ASC,
	[MobilePhoneContactId] ASC,
	[EmailContactId] ASC,
	[DefaultProviderUserId] ASC
)
INCLUDE ( 	[Sex],
	[DoB],
	[DoD]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_PatientDebtor_5_2053582354__K3]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_PatientDebtor_5_2053582354__K3] ON [dbo].[PatientDebtor]
(
	[SpecialPatientDebtorType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_PatientDebtor_5_2053582354__K8_K2_K1]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_PatientDebtor_5_2053582354__K8_K2_K1] ON [dbo].[PatientDebtor]
(
	[PreferredPersonNameId] ASC,
	[PatientDebtorType] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_Contact1AddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_Contact1AddressId] ON [dbo].[PatientDebtor]
(
	[Contact1AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_Contact2AddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_Contact2AddressId] ON [dbo].[PatientDebtor]
(
	[Contact2AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_DoB]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_DoB] ON [dbo].[PatientDebtor]
(
	[DoB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_Employer1AddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_Employer1AddressId] ON [dbo].[PatientDebtor]
(
	[Employer1AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_Employer2AddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_Employer2AddressId] ON [dbo].[PatientDebtor]
(
	[Employer2AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PatientDebtor_MedicareNumber]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_MedicareNumber] ON [dbo].[PatientDebtor]
(
	[MedicareNumber] ASC
)
INCLUDE ( 	[Id],
	[Inactive],
	[LegalPersonNameId],
	[PreferredPersonNameId],
	[ResidentialAddressId],
	[PostalAddressId],
	[DoB]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PatientDebtor_MedicareNumber_DvaNumber]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_MedicareNumber_DvaNumber] ON [dbo].[PatientDebtor]
(
	[MedicareNumber] ASC,
	[DvaNumber] ASC
)
INCLUDE ( 	[Id],
	[LegalPersonNameId],
	[PreferredPersonNameId],
	[ResidentialAddressId],
	[PostalAddressId],
	[DoB]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_NokAddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_NokAddressId] ON [dbo].[PatientDebtor]
(
	[NokAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PatientDebtor_PatientDebtorType]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_PatientDebtorType] ON [dbo].[PatientDebtor]
(
	[PatientDebtorType] ASC
)
INCLUDE ( 	[Id],
	[LegalPersonNameId],
	[Sex],
	[ResidentialAddressId],
	[HomePhoneContactId],
	[WorkPhoneContactId],
	[MobilePhoneContactId],
	[DoB],
	[EhrUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_PatientDebtorType_MobilePhoneContactId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_PatientDebtorType_MobilePhoneContactId] ON [dbo].[PatientDebtor]
(
	[PatientDebtorType] ASC,
	[MobilePhoneContactId] ASC
)
INCLUDE ( 	[Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PatientDebtor_PatientDebtorType2]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_PatientDebtorType2] ON [dbo].[PatientDebtor]
(
	[PatientDebtorType] ASC
)
INCLUDE ( 	[Id],
	[TradingAs]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_PostalAddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_PostalAddressId] ON [dbo].[PatientDebtor]
(
	[PostalAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtor_ResidentialAddressId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_ResidentialAddressId] ON [dbo].[PatientDebtor]
(
	[ResidentialAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PatientDebtor_Sex_MedicareSubnumerate]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtor_Sex_MedicareSubnumerate] ON [dbo].[PatientDebtor]
(
	[Sex] ASC,
	[MedicareSubnumerate] ASC
)
INCLUDE ( 	[Id],
	[Inactive],
	[LegalPersonNameId],
	[PreferredPersonNameId],
	[ResidentialAddressId],
	[PostalAddressId],
	[DoB],
	[MedicareNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [PatientDebtor_5_2053582354__K1_K7_17_34]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [PatientDebtor_5_2053582354__K1_K7_17_34] ON [dbo].[PatientDebtor]
(
	[Id] ASC,
	[LegalPersonNameId] ASC
)
INCLUDE ( 	[DoB],
	[DefaultProviderUserId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PatientDebtor_Covering]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [PatientDebtor_Covering] ON [dbo].[PatientDebtor]
(
	[EhrUid] ASC,
	[LegalPersonNameId] ASC
)
INCLUDE ( 	[Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PatientDebtor_EhrUid]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [PatientDebtor_EhrUid] ON [dbo].[PatientDebtor]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtorFinancialTransactionVersion_PatientDebtorId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtorFinancialTransactionVersion_PatientDebtorId] ON [dbo].[PatientDebtorFinancialTransactionVersion]
(
	[PatientDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_PatientDebtorIdentifier_IdentifierIdPatientDebtorId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtorIdentifier_IdentifierIdPatientDebtorId] ON [dbo].[PatientDebtorIdentifier]
(
	[IdentifierId] ASC,
	[PatientDebtorId] ASC
)
INCLUDE ( 	[Id],
	[Value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientDebtorIdentifier_PatientDebtorId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientDebtorIdentifier_PatientDebtorId] ON [dbo].[PatientDebtorIdentifier]
(
	[PatientDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PatientFamily_PatientId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_PatientFamily_PatientId] ON [dbo].[PatientFamily]
(
	[PatientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Payment_BankRunId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Payment_BankRunId] ON [dbo].[Payment]
(
	[BankRunId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Payment_IntegratedEftposTransactionId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Payment_IntegratedEftposTransactionId] ON [dbo].[Payment]
(
	[IntegratedEftposTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Payment_ReceiptId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Payment_ReceiptId] ON [dbo].[Payment]
(
	[ReceiptId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_PersonName_5_1797581442__K2_K3_K1]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_PersonName_5_1797581442__K2_K3_K1] ON [dbo].[PersonName]
(
	[Surname] ASC,
	[FirstName] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Quote_PatientDebtorPatientId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Quote_PatientDebtorPatientId] ON [dbo].[Quote]
(
	[PatientDebtorPatientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Recall_DueDate]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Recall_DueDate] ON [dbo].[Recall]
(
	[DueDate] ASC
)
INCLUDE ( 	[PatientId],
	[PatientContactId],
	[LastEventNoProcessed],
	[LastEventProcessedDateTimeOffset],
	[FinalEventProcessed],
	[EpisodeId],
	[Completed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Recall_EpisodeId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Recall_EpisodeId] ON [dbo].[Recall]
(
	[EpisodeId] ASC
)
INCLUDE ( 	[Id],
	[PatientId],
	[PatientContactId],
	[DueDate],
	[LastEventNoProcessed],
	[LastEventProcessedDateTimeOffset],
	[FinalEventProcessed],
	[Completed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Recall_PatientContactIdDueDate]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Recall_PatientContactIdDueDate] ON [dbo].[Recall]
(
	[PatientContactId] ASC,
	[DueDate] ASC
)
INCLUDE ( 	[PatientId],
	[LastEventNoProcessed],
	[LastEventProcessedDateTimeOffset],
	[FinalEventProcessed],
	[EpisodeId],
	[Completed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Recall_PatientId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Recall_PatientId] ON [dbo].[Recall]
(
	[PatientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RecallActivity_RecallId_ActivityType]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RecallActivity_RecallId_ActivityType] ON [dbo].[RecallActivity]
(
	[RecallId] ASC,
	[ActivityType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Receipt_5_494624805__K1_K5_8]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Receipt_5_494624805__K1_K5_8] ON [dbo].[Receipt]
(
	[Id] ASC,
	[ReceiptType] ASC
)
INCLUDE ( 	[TransferReferenceReceiptId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Receipt_LocationId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Receipt_LocationId] ON [dbo].[Receipt]
(
	[LocationId] ASC
)
INCLUDE ( 	[Id],
	[ReceiptDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Receipt_TransferReferenceReceiptId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Receipt_TransferReferenceReceiptId] ON [dbo].[Receipt]
(
	[TransferReferenceReceiptId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ReceiptDetail_5_386100416__K2_K5_K7_K1_K3_K4_K6]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ReceiptDetail_5_386100416__K2_K5_K7_K1_K3_K4_K6] ON [dbo].[ReceiptDetail]
(
	[ReceiptId] ASC,
	[LegalEntityId] ASC,
	[InvoiceDetailId] ASC,
	[Id] ASC,
	[Amount] ASC,
	[AmountGST] ASC,
	[PatientDebtorDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ReceiptDetail_5_386100416__K7_K2_3]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ReceiptDetail_5_386100416__K7_K2_3] ON [dbo].[ReceiptDetail]
(
	[InvoiceDetailId] ASC,
	[ReceiptId] ASC
)
INCLUDE ( 	[Amount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ReceiptDetail_PatientDebtorDebtorId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ReceiptDetail_PatientDebtorDebtorId] ON [dbo].[ReceiptDetail]
(
	[PatientDebtorDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RecentPatient_UserId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RecentPatient_UserId] ON [dbo].[RecentPatient]
(
	[UserId] ASC
)
INCLUDE ( 	[PatientDebtorId],
	[LastDateTimeOffset],
	[Reason]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RecentPatient_UserIdPatientId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RecentPatient_UserIdPatientId] ON [dbo].[RecentPatient]
(
	[UserId] ASC,
	[PatientDebtorId] ASC
)
INCLUDE ( 	[LastDateTimeOffset],
	[Reason]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ReferralIn_5_2117582582__K2_K4_K3_K5_1_6_7_8_10]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ReferralIn_5_2117582582__K2_K4_K3_K5_1_6_7_8_10] ON [dbo].[ReferralIn]
(
	[PatientId] ASC,
	[ToUserId] ASC,
	[FromAddressBookId] ASC,
	[WrittenDate] ASC
)
INCLUDE ( 	[ReferralInId],
	[FirstUsedDate],
	[ReferralPeriodType],
	[ReferralPeriodMonths],
	[Lost]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RosterSource_ResourceIdEffectiveDate]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RosterSource_ResourceIdEffectiveDate] ON [dbo].[RosterSource]
(
	[ResourceId] ASC,
	[EffectiveDate] ASC
)
INCLUDE ( 	[Id],
	[ExpiryDate],
	[RosterWeeks],
	[RollDate],
	[RosterOverride]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RosterSourceDetail_RosterSourceId_WeekNumber_DayNumber]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_RosterSourceDetail_RosterSourceId_WeekNumber_DayNumber] ON [dbo].[RosterSourceDetail]
(
	[RosterSourceId] ASC,
	[WeekNumber] ASC,
	[DayNumber] ASC
)
INCLUDE ( 	[Id],
	[StartTime],
	[Length],
	[RosterTypeId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ServiceItem_ItemSearch1]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ServiceItem_ItemSearch1] ON [dbo].[ServiceItem]
(
	[ItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ServiceItem_ItemSearch2]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ServiceItem_ItemSearch2] ON [dbo].[ServiceItem]
(
	[Id] ASC,
	[ItemDisplay] ASC,
	[ItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ServiceItemDetail_ItemSearch3]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ServiceItemDetail_ItemSearch3] ON [dbo].[ServiceItemDetail]
(
	[ServiceItemId] ASC,
	[EffectiveDate] ASC
)
INCLUDE ( 	[Id],
	[MedicareDescription],
	[PracticeDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ServiceItemDetail_PricingServiceGroupId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ServiceItemDetail_PricingServiceGroupId] ON [dbo].[ServiceItemDetail]
(
	[PricingServiceGroupId] ASC
)
INCLUDE ( 	[Id],
	[ServiceItemId],
	[EffectiveDate],
	[ExpiryDate],
	[MedicareDescription],
	[PracticeDescription],
	[SpecialServiceItem]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ServiceItemDetail_ReportingServiceGroupId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ServiceItemDetail_ReportingServiceGroupId] ON [dbo].[ServiceItemDetail]
(
	[ReportingServiceGroupId] ASC
)
INCLUDE ( 	[Id],
	[ServiceItemId],
	[EffectiveDate],
	[ExpiryDate],
	[MedicareDescription],
	[PracticeDescription],
	[SpecialServiceItem]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ServiceItemDetail_SpecialServiceItem]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ServiceItemDetail_SpecialServiceItem] ON [dbo].[ServiceItemDetail]
(
	[SpecialServiceItem] ASC
)
INCLUDE ( 	[Id],
	[ServiceItemId],
	[EffectiveDate],
	[ExpiryDate],
	[MbsCategory],
	[MbsGroup],
	[MbsSubGroup],
	[MedicareDescription],
	[PracticeDescription],
	[PricingServiceGroupId],
	[ReportingServiceGroupId],
	[GstType],
	[AllowAdditionalDescription],
	[AdditionalDescription],
	[RebatePercentInHospital],
	[RebatePercentNotHospital],
	[RvgUnits],
	[DefaultEquipmentId],
	[DerivedFeeType],
	[AssistFeeAllowed],
	[ReferralRequired],
	[ReferralType],
	[InHospitalService],
	[ClaimToDVA],
	[ClaimToMedicare],
	[RowVersion]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ServiceItemPrice_ServiceItemId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ServiceItemPrice_ServiceItemId] ON [dbo].[ServiceItemPrice]
(
	[ServiceItemId] ASC
)
INCLUDE ( 	[Id],
	[EffectiveDate],
	[BaseFeeUid],
	[Price],
	[DerivedFee],
	[DerivedFeeExtra],
	[Factor],
	[BasisBaseFeeUid],
	[EligibleDVAREI],
	[EligibleDVAVAP]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_SMSReceivedPatientDebtor_SmsReceivedId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_SMSReceivedPatientDebtor_SmsReceivedId] ON [dbo].[SMSReceivedPatientDebtor]
(
	[SmsReceivedId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_SMSSent_PatientDebtorIdStatus]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_SMSSent_PatientDebtorIdStatus] ON [dbo].[SMSSent]
(
	[PatientDebtorId] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_SMSSent_SMSCategory_ObjectReferenceId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_SMSSent_SMSCategory_ObjectReferenceId] ON [dbo].[SMSSent]
(
	[SMSCategory] ASC,
	[ObjectReferenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_SMSSent_SMSCategory_ReplyStatusRecipient_Status]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_SMSSent_SMSCategory_ReplyStatusRecipient_Status] ON [dbo].[SMSSent]
(
	[SMSCategory] ASC,
	[ReplyStatus] ASC,
	[Recipient] ASC,
	[Status] ASC
)
INCLUDE ( 	[ObjectReferenceId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Snippet_Name]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_Snippet_Name] ON [dbo].[Snippet]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_SterilisationLoadDetail_PatientDebtorId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_SterilisationLoadDetail_PatientDebtorId] ON [dbo].[SterilisationLoadDetail]
(
	[PatientDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Suburb_Covering]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [Suburb_Covering] ON [dbo].[Suburb]
(
	[Suburb] ASC,
	[Postcode] ASC
)
INCLUDE ( 	[Id],
	[State],
	[SuburbCode],
	[RowVersion]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_TbDetails_EncounterUid]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_TbDetails_EncounterUid] ON [dbo].[TbDetails]
(
	[EncounterUid] ASC
)
INCLUDE ( 	[QuoteId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_TbDetails_EpisodeId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_TbDetails_EpisodeId] ON [dbo].[TbDetails]
(
	[EpisodeId] ASC
)
INCLUDE ( 	[QuoteId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_TbDetailsProcedure_QuoteId_PlannedOrActual]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_TbDetailsProcedure_QuoteId_PlannedOrActual] ON [dbo].[TbDetailsProcedure]
(
	[QuoteId] ASC,
	[PlannedOrActual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ToDo_5_2142630676__K19]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ToDo_5_2142630676__K19] ON [dbo].[ToDo]
(
	[PatientDebtorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDo_RequiredAfterDateTime]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDo_RequiredAfterDateTime] ON [dbo].[ToDo]
(
	[RequiredAfterDateTime] ASC
)
INCLUDE ( 	[Id],
	[Type],
	[Urgent],
	[RequiredByDateTime],
	[Status],
	[LastUpdatedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDo_Type]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDo_Type] ON [dbo].[ToDo]
(
	[Type] ASC
)
INCLUDE ( 	[RequiredByDateTime],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoActionNote_ToDoId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoActionNote_ToDoId] ON [dbo].[ToDoActionNote]
(
	[ToDoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoChangeNote_ChangeNoteType]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoChangeNote_ChangeNoteType] ON [dbo].[ToDoChangeNote]
(
	[ChangeNoteType] ASC
)
INCLUDE ( 	[ToDoId],
	[ChangeDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoChangeNote_ToDoId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoChangeNote_ToDoId] ON [dbo].[ToDoChangeNote]
(
	[ToDoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ToDoNextAction_5_155147598__K2_K1_K4_K3]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ToDoNextAction_5_155147598__K2_K1_K4_K3] ON [dbo].[ToDoNextAction]
(
	[ToDoId] ASC,
	[Id] ASC,
	[UserGroupId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoNextAction_ToDoId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoNextAction_ToDoId] ON [dbo].[ToDoNextAction]
(
	[ToDoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoNextAction_UserGroupId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoNextAction_UserGroupId] ON [dbo].[ToDoNextAction]
(
	[UserGroupId] ASC
)
INCLUDE ( 	[ToDoId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoNextAction_UserId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoNextAction_UserId] ON [dbo].[ToDoNextAction]
(
	[UserId] ASC
)
INCLUDE ( 	[ToDoId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoUnread_UserId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoUnread_UserId] ON [dbo].[ToDoUnread]
(
	[UserId] ASC
)
INCLUDE ( 	[ToDoId],
	[IsUnread],
	[LastUpdatedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ToDoUserAction_5_379148396__K2_K3_K5]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ToDoUserAction_5_379148396__K2_K3_K5] ON [dbo].[ToDoUserAction]
(
	[ToDoId] ASC,
	[UserId] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ToDoUserAction_ToDoId]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_ToDoUserAction_ToDoId] ON [dbo].[ToDoUserAction]
(
	[ToDoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_UnmatchedMessageIn_DiscardedByUserId_MessageMatchStatusMessageDetailType]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_UnmatchedMessageIn_DiscardedByUserId_MessageMatchStatusMessageDetailType] ON [dbo].[UnmatchedMessageIn]
(
	[DiscardedByUserId] ASC,
	[MessageMatchStatus] ASC,
	[MessageDetailType] ASC
)
INCLUDE ( 	[RequestDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_UserOptions_UserId_OptionName]    Script Date: 16/04/2019 2:08:40 AM ******/
CREATE NONCLUSTERED INDEX [ix_UserOptions_UserId_OptionName] ON [dbo].[UserOptions]
(
	[UserId] ASC,
	[OptionName] ASC
)
INCLUDE ( 	[OptionValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppointmentCancelledReason] ADD  CONSTRAINT [AppointmentCancelledReason_DidNotArriveWarningPrompt]  DEFAULT ((0)) FOR [DidNotArriveWarningPrompt]
GO
ALTER TABLE [dbo].[Autotext] ADD  CONSTRAINT [DF_Autotext_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[BaseFee] ADD  CONSTRAINT [DF_BaseFee_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[BaseFee] ADD  CONSTRAINT [DF_BaseFee_IsHealthFundBaseFee]  DEFAULT ((0)) FOR [IsHealthFundBaseFee]
GO
ALTER TABLE [dbo].[Billcode] ADD  CONSTRAINT [DF_Billcode_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[Billing] ADD  CONSTRAINT [DF_Billing_Modality]  DEFAULT ((1)) FOR [Modality]
GO
ALTER TABLE [dbo].[ClinicalHealthRecordSummaryViewDefaults] ADD  CONSTRAINT [DF_ClinicalHealthRecordSummaryViewDefaults_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[ClinicalSummaryHeading] ADD  CONSTRAINT [DF_ClinicalSummaryHeading_Private]  DEFAULT ((0)) FOR [Private]
GO
ALTER TABLE [dbo].[ConditionCategory] ADD  CONSTRAINT [DF_ConditionCategory_IsSystemCategory]  DEFAULT ((0)) FOR [IsSystemCategory]
GO
ALTER TABLE [dbo].[ConditionCategory] ADD  CONSTRAINT [DF_ConditionCategory_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[ConditionSubCategory] ADD  CONSTRAINT [DF_ConditionSubCategory_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[DocumentCategory] ADD  CONSTRAINT [DF_DocumentCategory_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[Episode] ADD  CONSTRAINT [DF_Episode_AppointmentLength]  DEFAULT ((1)) FOR [AppointmentLength]
GO
ALTER TABLE [dbo].[Episode] ADD  CONSTRAINT [DF_Episode_ReferralNotSelected]  DEFAULT ((0)) FOR [NoReferralSelected]
GO
ALTER TABLE [dbo].[FilterSetting] ADD  CONSTRAINT [DF_FilterSetting_IsSystemReport]  DEFAULT ((0)) FOR [IsSystemReport]
GO
ALTER TABLE [dbo].[HealthFund] ADD  CONSTRAINT [DF_HealthFund_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[HealthFundGroup] ADD  CONSTRAINT [DF_HealthFundGroup_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[Hospital] ADD  CONSTRAINT [DF_Hospital_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[ImmunisationCategory] ADD  CONSTRAINT [DF_ImmunisationCategory_IsSystemCategory]  DEFAULT ((0)) FOR [IsSystemCategory]
GO
ALTER TABLE [dbo].[ImmunisationCategory] ADD  CONSTRAINT [DF_ImmunisationCategory_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[IntegratedEftposMerchant] ADD  CONSTRAINT [DF_IntegratedEftposMerchant_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail] ADD  CONSTRAINT [DF__Integrate__Integ__2B203F5D]  DEFAULT ((0)) FOR [IntegratedEftposTransactionId]
GO
ALTER TABLE [dbo].[InternalMessage] ADD  CONSTRAINT [DF_InternalMessage_Urgent]  DEFAULT ((0)) FOR [Urgent]
GO
ALTER TABLE [dbo].[InternalMessage] ADD  CONSTRAINT [DF_InternalMessage_Status]  DEFAULT ((0)) FOR [RecipientsDesc]
GO
ALTER TABLE [dbo].[InternalMessageFolder] ADD  CONSTRAINT [DF_InternalMessageFolder_IsFixed]  DEFAULT ((0)) FOR [IsFixed]
GO
ALTER TABLE [dbo].[InternalMessageRecipient] ADD  CONSTRAINT [DF_MessageRecipient_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[InternalMessageRecipient] ADD  CONSTRAINT [DF_InternalMessageRecipient_MessageFolderId]  DEFAULT ((1)) FOR [InternalMessageFolderId]
GO
ALTER TABLE [dbo].[Location] ADD  CONSTRAINT [DF_Location_TimeZoneId]  DEFAULT ('') FOR [TimeZoneId]
GO
ALTER TABLE [dbo].[ManuscriptTemplate] ADD  CONSTRAINT [DF_ManuscriptTemplate_Downloadable]  DEFAULT ((0)) FOR [Downloadable]
GO
ALTER TABLE [dbo].[ManuscriptTemplate] ADD  CONSTRAINT [DF_ManuscriptTemplate_Downloaded]  DEFAULT ((0)) FOR [Downloaded]
GO
ALTER TABLE [dbo].[ManuscriptTemplate] ADD  CONSTRAINT [DF_ManuscriptTemplate_ModifiedAfterDownloaded]  DEFAULT ((0)) FOR [ModifiedAfterDownloaded]
GO
ALTER TABLE [dbo].[MeasurementCategory] ADD  CONSTRAINT [DF_MeasurementMapping_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[MedicationCategory] ADD  CONSTRAINT [DF_MedicationCategory_IsSystemCategory]  DEFAULT ((0)) FOR [IsSystemCategory]
GO
ALTER TABLE [dbo].[MedicationCategory] ADD  CONSTRAINT [DF_MedicationCategory_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[MessagingTransport] ADD  CONSTRAINT [DF_MessagingTransport_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[PathologyResult] ADD  CONSTRAINT [DF_PathologyResult_FailedAutoMatch]  DEFAULT ((1)) FOR [FailedAutoMatch]
GO
ALTER TABLE [dbo].[PathologyTests] ADD  CONSTRAINT [DF_PathologyTests_Sequence]  DEFAULT ((50)) FOR [Sequence]
GO
ALTER TABLE [dbo].[PatientContact] ADD  CONSTRAINT [DF_PatientContact_ApplyContactConsent]  DEFAULT ((0)) FOR [ApplyContactConsent]
GO
ALTER TABLE [dbo].[PatientContact] ADD  CONSTRAINT [DF_PatientContact_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[PatientContact] ADD  CONSTRAINT [DF_PatientContact_MaximumEvents]  DEFAULT ((1)) FOR [MaximumEvents]
GO
ALTER TABLE [dbo].[PatientContact] ADD  CONSTRAINT [DF_PatientContact_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[PatientContactEvent] ADD  CONSTRAINT [DF_PatientContactEvent_MaximumEvents]  DEFAULT ((1)) FOR [EventNo]
GO
ALTER TABLE [dbo].[PatientContactEvent] ADD  CONSTRAINT [DF_PatientContactEvent_Event1Type]  DEFAULT ((0)) FOR [EventType]
GO
ALTER TABLE [dbo].[PatientContactEvent] ADD  CONSTRAINT [DF_PatientContactEvent_Event2DaysElapsed]  DEFAULT ((0)) FOR [DaysElapsed]
GO
ALTER TABLE [dbo].[PatientContactEvent] ADD  CONSTRAINT [DF_PatientContactEvent_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[QuickItem] ADD  CONSTRAINT [DF_QuickItem_Modality]  DEFAULT ((1)) FOR [Modality]
GO
ALTER TABLE [dbo].[QuoteBookingInformation] ADD  CONSTRAINT [DF__QuoteBook__IsAut__2C938683]  DEFAULT ((0)) FOR [IsAutoInsert]
GO
ALTER TABLE [dbo].[Recall] ADD  CONSTRAINT [DF_Recall_Active]  DEFAULT ((1)) FOR [Completed]
GO
ALTER TABLE [dbo].[RecentPatient] ADD  CONSTRAINT [DF_RecentPatient_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[ReferralIn] ADD  CONSTRAINT [DF_ReferralIn_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[ServiceItem] ADD  CONSTRAINT [DF_ServiceItem_Modality]  DEFAULT ((1)) FOR [Modality]
GO
ALTER TABLE [dbo].[ServiceItemDetail] ADD  CONSTRAINT [DF_ServiceItem_UseReportingServiceGroupFromEligibleItem]  DEFAULT ((0)) FOR [UseReportingServiceGroupFromEligibleItem]
GO
ALTER TABLE [dbo].[ServiceItemDetail] ADD  CONSTRAINT [DF_ServiceItemDetail_ServiceReferenceRequired]  DEFAULT ((0)) FOR [ServiceReferenceRequired]
GO
ALTER TABLE [dbo].[Snippet] ADD  CONSTRAINT [DF_Snippet_DefaultCheckBoxValue]  DEFAULT ((1)) FOR [DefaultCheckBoxValue]
GO
ALTER TABLE [dbo].[Snippet] ADD  CONSTRAINT [DF_Snippet_IsUserSystemSnippet]  DEFAULT ((0)) FOR [IsUserSystemSnippet]
GO
ALTER TABLE [dbo].[Snippet] ADD  CONSTRAINT [DF_Snippet_Downloaded]  DEFAULT ((0)) FOR [Downloaded]
GO
ALTER TABLE [dbo].[Snippet] ADD  CONSTRAINT [DF_Snippet_ModifiedAfterDownloaded]  DEFAULT ((0)) FOR [ModifiedAfterDownloaded]
GO
ALTER TABLE [dbo].[Snippet] ADD  CONSTRAINT [DF_Snippet_AutoTextAvailableToAllUsers]  DEFAULT ((0)) FOR [AutoTextAvailableToAllUsers]
GO
ALTER TABLE [dbo].[SnippetDateOptions] ADD  CONSTRAINT [DF_SnippetDateOptions_IsDateMandatory]  DEFAULT ((1)) FOR [IsDateMandatory]
GO
ALTER TABLE [dbo].[SnippetDateOptions] ADD  CONSTRAINT [DF_SnippetDateOptions_DefaultToCurrentDate]  DEFAULT ((1)) FOR [DefaultToCurrentDate]
GO
ALTER TABLE [dbo].[SnippetSelectionValue] ADD  CONSTRAINT [DF_SnippetSelectionValue_DisplayOrder]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[TemplatesAvailable] ADD  CONSTRAINT [DF_TemplatesAvailable_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[TemplatesAvailable] ADD  CONSTRAINT [DF_TemplatesAvailable_ConvertedToManuscript]  DEFAULT ((0)) FOR [ConvertedToManuscript]
GO
ALTER TABLE [dbo].[ToDoTemplate] ADD  CONSTRAINT [DF_ToDoTemplate_AllIndividual]  DEFAULT ((0)) FOR [AllIndividual]
GO
ALTER TABLE [dbo].[ToDoUnread] ADD  CONSTRAINT [DF_ToDoUnread_IsUnread]  DEFAULT ((1)) FOR [IsUnread]
GO
ALTER TABLE [dbo].[UserGroupAlerts] ADD  CONSTRAINT [DF_UserGroupAlerts_Enabled]  DEFAULT ((0)) FOR [Enabled]
GO
ALTER TABLE [dbo].[UserGroupAlerts] ADD  CONSTRAINT [DF_UserGroupAlerts_Highlight]  DEFAULT ((0)) FOR [Highlight]
GO
ALTER TABLE [dbo].[UserGroupAlerts] ADD  CONSTRAINT [DF_UserGroupAlerts_HideIfNone]  DEFAULT ((0)) FOR [HideIfNone]
GO
ALTER TABLE [dbo].[UserProcess] ADD  CONSTRAINT [DF_UserProcess_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[Workstation] ADD  CONSTRAINT [df_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[WorkstationFileImport] ADD  CONSTRAINT [DF_WorkstationFileImports_Inactive]  DEFAULT ((0)) FOR [Inactive]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Address] FOREIGN KEY([StreetAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Address]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Address1] FOREIGN KEY([PostalAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Address1]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_AddressBook] FOREIGN KEY([LinkedOrganisationAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_AddressBook]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_AddressBookGroup] FOREIGN KEY([AddressBookGroupId])
REFERENCES [dbo].[AddressBookGroup] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_AddressBookGroup]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Contact] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Contact]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Contact1] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Contact1]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Contact2] FOREIGN KEY([MobilePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Contact2]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Contact3] FOREIGN KEY([WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Contact3]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_MessagingTransport] FOREIGN KEY([MessagesToTransportUid])
REFERENCES [dbo].[MessagingTransport] ([Uid])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_MessagingTransport]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_PersonName] FOREIGN KEY([PreferredPersonNameId])
REFERENCES [dbo].[PersonName] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_PersonName]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_PersonName1] FOREIGN KEY([LegalPersonNameId])
REFERENCES [dbo].[PersonName] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_PersonName1]
GO
ALTER TABLE [dbo].[AddressBook]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Speciality] FOREIGN KEY([SpecialityId])
REFERENCES [dbo].[Speciality] ([Id])
GO
ALTER TABLE [dbo].[AddressBook] CHECK CONSTRAINT [FK_AddressBook_Speciality]
GO
ALTER TABLE [dbo].[AddressBookIdentifier]  WITH CHECK ADD  CONSTRAINT [FK_AddressBookIdentifier_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[AddressBookIdentifier] CHECK CONSTRAINT [FK_AddressBookIdentifier_AddressBook]
GO
ALTER TABLE [dbo].[AddressBookIdentifier]  WITH CHECK ADD  CONSTRAINT [FK_AddressBookIdentifier_Identifier] FOREIGN KEY([IdentifierId])
REFERENCES [dbo].[Identifier] ([Id])
GO
ALTER TABLE [dbo].[AddressBookIdentifier] CHECK CONSTRAINT [FK_AddressBookIdentifier_Identifier]
GO
ALTER TABLE [dbo].[AddressBookMessagingFacilityId]  WITH CHECK ADD  CONSTRAINT [FK_AddressBookMessagingFacilityId_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[AddressBookMessagingFacilityId] CHECK CONSTRAINT [FK_AddressBookMessagingFacilityId_AddressBook]
GO
ALTER TABLE [dbo].[AddressBookMessagingFacilityId]  WITH CHECK ADD  CONSTRAINT [FK_AddressBookMessagingFacilityId_MessagingTransport] FOREIGN KEY([MessagingTransportUid])
REFERENCES [dbo].[MessagingTransport] ([Uid])
GO
ALTER TABLE [dbo].[AddressBookMessagingFacilityId] CHECK CONSTRAINT [FK_AddressBookMessagingFacilityId_MessagingTransport]
GO
ALTER TABLE [dbo].[AppointmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentHistory_AppointmentCancelledReason] FOREIGN KEY([MoveReasonCode])
REFERENCES [dbo].[AppointmentCancelledReason] ([Id])
GO
ALTER TABLE [dbo].[AppointmentHistory] CHECK CONSTRAINT [FK_AppointmentHistory_AppointmentCancelledReason]
GO
ALTER TABLE [dbo].[AppointmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentHistory_AppointmentType] FOREIGN KEY([AppointmentTypeId])
REFERENCES [dbo].[AppointmentType] ([Id])
GO
ALTER TABLE [dbo].[AppointmentHistory] CHECK CONSTRAINT [FK_AppointmentHistory_AppointmentType]
GO
ALTER TABLE [dbo].[AppointmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentHistory_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[AppointmentHistory] CHECK CONSTRAINT [FK_AppointmentHistory_Location]
GO
ALTER TABLE [dbo].[AppointmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentHistory_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[AppointmentHistory] CHECK CONSTRAINT [FK_AppointmentHistory_PatientDebtor]
GO
ALTER TABLE [dbo].[AppointmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentHistory_Resource] FOREIGN KEY([ResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[AppointmentHistory] CHECK CONSTRAINT [FK_AppointmentHistory_Resource]
GO
ALTER TABLE [dbo].[AppointmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentHistory_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[AppointmentHistory] CHECK CONSTRAINT [FK_AppointmentHistory_User]
GO
ALTER TABLE [dbo].[Autotext]  WITH CHECK ADD  CONSTRAINT [FK_Autotext_User] FOREIGN KEY([UserIdAvailableTo])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Autotext] CHECK CONSTRAINT [FK_Autotext_User]
GO
ALTER TABLE [dbo].[BankAccount]  WITH CHECK ADD  CONSTRAINT [FK_BankAccount_LegalEntity] FOREIGN KEY([LegalEntityId])
REFERENCES [dbo].[LegalEntity] ([Id])
GO
ALTER TABLE [dbo].[BankAccount] CHECK CONSTRAINT [FK_BankAccount_LegalEntity]
GO
ALTER TABLE [dbo].[BankRun]  WITH CHECK ADD  CONSTRAINT [FK_BankRun_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[BankRun] CHECK CONSTRAINT [FK_BankRun_BankAccount]
GO
ALTER TABLE [dbo].[BankRun]  WITH CHECK ADD  CONSTRAINT [FK_BankRun_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[BankRun] CHECK CONSTRAINT [FK_BankRun_Location]
GO
ALTER TABLE [dbo].[BankRun]  WITH CHECK ADD  CONSTRAINT [FK_BankRun_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[BankRun] CHECK CONSTRAINT [FK_BankRun_User]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_BaseFee] FOREIGN KEY([BaseFeeUid])
REFERENCES [dbo].[BaseFee] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_BaseFee]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_BaseFee2] FOREIGN KEY([FundRebateBaseFeeUid])
REFERENCES [dbo].[BaseFee] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_BaseFee2]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_BaseFee3] FOREIGN KEY([BaseFeeUid2])
REFERENCES [dbo].[BaseFee] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_BaseFee3]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_BaseFee4] FOREIGN KEY([FundRebateBaseFeeUid2])
REFERENCES [dbo].[BaseFee] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_BaseFee4]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_Billcode1] FOREIGN KEY([BillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_Billcode1]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_Billcode2] FOREIGN KEY([FundRebateBillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_Billcode2]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_Billcode3] FOREIGN KEY([PriceCalculationBillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_Billcode3]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_Billcode4] FOREIGN KEY([PriceCalculationBillcodeUid2])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_Billcode4]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_Billcode5] FOREIGN KEY([FundRebateBillcodeUid2])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_Billcode5]
GO
ALTER TABLE [dbo].[BillcodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillcodeDetail_Billcode6] FOREIGN KEY([HealthFundMaximumGapBillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[BillcodeDetail] CHECK CONSTRAINT [FK_BillcodeDetail_Billcode6]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_Billcode] FOREIGN KEY([BillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_Billcode]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_Billcode2] FOREIGN KEY([PracticeBillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_Billcode2]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_DirectBillClaim] FOREIGN KEY([DirectBillClaimId])
REFERENCES [dbo].[DirectBillClaim] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_DirectBillClaim]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_Episode] FOREIGN KEY([EpisodeId])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_Episode]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_Hospital] FOREIGN KEY([HospitalUid])
REFERENCES [dbo].[Hospital] ([Uid])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_Hospital]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_InvoiceReference] FOREIGN KEY([InvoiceReferenceId])
REFERENCES [dbo].[InvoiceReference] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_InvoiceReference]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_Location]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_Location1] FOREIGN KEY([PracticeLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_Location1]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_MobileLSPN] FOREIGN KEY([LSPNOverrideMobileLSPNId])
REFERENCES [dbo].[MobileLSPN] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_MobileLSPN]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_PatientDebtor] FOREIGN KEY([OtherDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_PatientDebtor]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_ReferralIn] FOREIGN KEY([ReferralId])
REFERENCES [dbo].[ReferralIn] ([ReferralInId])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_ReferralIn]
GO
ALTER TABLE [dbo].[Billing]  WITH CHECK ADD  CONSTRAINT [FK_Billing_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Billing] CHECK CONSTRAINT [FK_Billing_User]
GO
ALTER TABLE [dbo].[BillingAdditionalInvoiceDetails]  WITH CHECK ADD  CONSTRAINT [FK_BillingAdditionalInvoiceDetails_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[BillingAdditionalInvoiceDetails] CHECK CONSTRAINT [FK_BillingAdditionalInvoiceDetails_Billing]
GO
ALTER TABLE [dbo].[BillingDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillingDetail_AddressBook] FOREIGN KEY([AssistantAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[BillingDetail] CHECK CONSTRAINT [FK_BillingDetail_AddressBook]
GO
ALTER TABLE [dbo].[BillingDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillingDetail_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[BillingDetail] CHECK CONSTRAINT [FK_BillingDetail_Billing]
GO
ALTER TABLE [dbo].[BillingDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillingDetail_ServiceItemDetail] FOREIGN KEY([ServiceItemDetailId])
REFERENCES [dbo].[ServiceItemDetail] ([Id])
GO
ALTER TABLE [dbo].[BillingDetail] CHECK CONSTRAINT [FK_BillingDetail_ServiceItemDetail]
GO
ALTER TABLE [dbo].[BillingDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillingDetail_ServiceItemDetail2] FOREIGN KEY([EligibleItemServiceItemDetailId])
REFERENCES [dbo].[ServiceItemDetail] ([Id])
GO
ALTER TABLE [dbo].[BillingDetail] CHECK CONSTRAINT [FK_BillingDetail_ServiceItemDetail2]
GO
ALTER TABLE [dbo].[ClinicalHealthRecordSummaryViewDefaultsDetail]  WITH CHECK ADD  CONSTRAINT [FK_ClinicalHealthRecordSummaryViewDefaultsDetail_ClinicalSummaryHeading] FOREIGN KEY([ClinicalSummaryHeadingId])
REFERENCES [dbo].[ClinicalSummaryHeading] ([Id])
GO
ALTER TABLE [dbo].[ClinicalHealthRecordSummaryViewDefaultsDetail] CHECK CONSTRAINT [FK_ClinicalHealthRecordSummaryViewDefaultsDetail_ClinicalSummaryHeading]
GO
ALTER TABLE [dbo].[CompletedReports]  WITH CHECK ADD  CONSTRAINT [FK_CompletedReports_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[CompletedReports] CHECK CONSTRAINT [FK_CompletedReports_User]
GO
ALTER TABLE [dbo].[CompletedReports]  WITH CHECK ADD  CONSTRAINT [FK_CompletedReports_Workstation] FOREIGN KEY([WorkstationId])
REFERENCES [dbo].[Workstation] ([Id])
GO
ALTER TABLE [dbo].[CompletedReports] CHECK CONSTRAINT [FK_CompletedReports_Workstation]
GO
ALTER TABLE [dbo].[ConditionSubCategory]  WITH CHECK ADD  CONSTRAINT [FK_ConditionCategoryId] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[ConditionCategory] ([Id])
GO
ALTER TABLE [dbo].[ConditionSubCategory] CHECK CONSTRAINT [FK_ConditionCategoryId]
GO
ALTER TABLE [dbo].[ConditionSubgroup]  WITH CHECK ADD  CONSTRAINT [FK_ConditionSubgroup_ConditionGroup] FOREIGN KEY([ConditionGroupUid])
REFERENCES [dbo].[ConditionGroup] ([Uid])
GO
ALTER TABLE [dbo].[ConditionSubgroup] CHECK CONSTRAINT [FK_ConditionSubgroup_ConditionGroup]
GO
ALTER TABLE [dbo].[ConditionSubgroupICPC]  WITH CHECK ADD  CONSTRAINT [FK_ConditionSubgroupICPC_ConditionSubgroup] FOREIGN KEY([ConditionSubgroupUid])
REFERENCES [dbo].[ConditionSubgroup] ([Uid])
GO
ALTER TABLE [dbo].[ConditionSubgroupICPC] CHECK CONSTRAINT [FK_ConditionSubgroupICPC_ConditionSubgroup]
GO
ALTER TABLE [dbo].[DirectBillClaim]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaim_DirectBillPayment] FOREIGN KEY([DirectBillPaymentId])
REFERENCES [dbo].[DirectBillPayment] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaim] CHECK CONSTRAINT [FK_DirectBillClaim_DirectBillPayment]
GO
ALTER TABLE [dbo].[DirectBillClaimException]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaimException_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaimException] CHECK CONSTRAINT [FK_DirectBillClaimException_Billing]
GO
ALTER TABLE [dbo].[DirectBillClaimException]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaimException_DirectBillClaim] FOREIGN KEY([DirectBillClaimId])
REFERENCES [dbo].[DirectBillClaim] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaimException] CHECK CONSTRAINT [FK_DirectBillClaimException_DirectBillClaim]
GO
ALTER TABLE [dbo].[DirectBillClaimException]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaimException_ExceptionProcessedByUserId] FOREIGN KEY([ExceptionProcessedByUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaimException] CHECK CONSTRAINT [FK_DirectBillClaimException_ExceptionProcessedByUserId]
GO
ALTER TABLE [dbo].[DirectBillClaimExceptionDetail]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaimExceptionDetail_BillingDetail] FOREIGN KEY([BillingDetailId])
REFERENCES [dbo].[BillingDetail] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaimExceptionDetail] CHECK CONSTRAINT [FK_DirectBillClaimExceptionDetail_BillingDetail]
GO
ALTER TABLE [dbo].[DirectBillClaimExceptionDetail]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaimExceptionDetail_DirectBillClaimException] FOREIGN KEY([DirectBillClaimExceptionId])
REFERENCES [dbo].[DirectBillClaimException] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaimExceptionDetail] CHECK CONSTRAINT [FK_DirectBillClaimExceptionDetail_DirectBillClaimException]
GO
ALTER TABLE [dbo].[DirectBillClaimExceptionDetail]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillClaimExceptionDetail_InvoiceDetail] FOREIGN KEY([InvoiceDetailId])
REFERENCES [dbo].[InvoiceDetail] ([Id])
GO
ALTER TABLE [dbo].[DirectBillClaimExceptionDetail] CHECK CONSTRAINT [FK_DirectBillClaimExceptionDetail_InvoiceDetail]
GO
ALTER TABLE [dbo].[DirectBillPayment]  WITH CHECK ADD  CONSTRAINT [FK_DirectBillPayment_BankRun] FOREIGN KEY([BankRunId])
REFERENCES [dbo].[BankRun] ([Id])
GO
ALTER TABLE [dbo].[DirectBillPayment] CHECK CONSTRAINT [FK_DirectBillPayment_BankRun]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_Attachment]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_DocumentCategory] FOREIGN KEY([DocumentCategoryId])
REFERENCES [dbo].[DocumentCategory] ([Id])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_DocumentCategory]
GO
ALTER TABLE [dbo].[DocumentInPool]  WITH CHECK ADD  CONSTRAINT [FK_DocumentInPool_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO
ALTER TABLE [dbo].[DocumentInPool] CHECK CONSTRAINT [FK_DocumentInPool_Attachment]
GO
ALTER TABLE [dbo].[DocumentNextActionAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_DocumentNextActionAvailableTo_DocumentNextAction] FOREIGN KEY([DocumentNextActionId])
REFERENCES [dbo].[DocumentNextAction] ([Id])
GO
ALTER TABLE [dbo].[DocumentNextActionAvailableTo] CHECK CONSTRAINT [FK_DocumentNextActionAvailableTo_DocumentNextAction]
GO
ALTER TABLE [dbo].[DocumentNextActionAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_DocumentNextActionAvailableTo_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[DocumentNextActionAvailableTo] CHECK CONSTRAINT [FK_DocumentNextActionAvailableTo_User]
GO
ALTER TABLE [dbo].[DocumentNextActionAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_DocumentNextActionAvailableTo_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[DocumentNextActionAvailableTo] CHECK CONSTRAINT [FK_DocumentNextActionAvailableTo_UserGroup]
GO
ALTER TABLE [dbo].[DrugQuickList]  WITH CHECK ADD  CONSTRAINT [FK_DrugQuickList_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[DrugQuickList] CHECK CONSTRAINT [FK_DrugQuickList_User]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Appointment_AppointmentType1] FOREIGN KEY([AppointmentTypeId])
REFERENCES [dbo].[AppointmentType] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Appointment_AppointmentType1]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_AppointmentCancelledReason] FOREIGN KEY([CancelledReasonCode])
REFERENCES [dbo].[AppointmentCancelledReason] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_AppointmentCancelledReason]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Episode] FOREIGN KEY([Id])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Episode]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Location]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Location1] FOREIGN KEY([ServiceLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Location1]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Provider] FOREIGN KEY([ProviderId])
REFERENCES [dbo].[Provider] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Provider]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_ReferralIn] FOREIGN KEY([ReferralInId])
REFERENCES [dbo].[ReferralIn] ([ReferralInId])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_ReferralIn]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Resource] FOREIGN KEY([AppointmentResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Resource]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Resource1] FOREIGN KEY([EpisodeResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Resource1]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_Resource2] FOREIGN KEY([AuxiliaryResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_Resource2]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_User] FOREIGN KEY([AuxiliaryUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_User]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_User2] FOREIGN KEY([EpisodeUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_User2]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Episode_User3] FOREIGN KEY([ArriveUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Episode_User3]
GO
ALTER TABLE [dbo].[Episode]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_Patient] FOREIGN KEY([PatientDebtorPatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Episode] CHECK CONSTRAINT [FK_Schedule_Patient]
GO
ALTER TABLE [dbo].[HealthFund]  WITH CHECK ADD  CONSTRAINT [FK_HealthFund_HealthFundGroup] FOREIGN KEY([HealthFundGroupUid])
REFERENCES [dbo].[HealthFundGroup] ([Uid])
GO
ALTER TABLE [dbo].[HealthFund] CHECK CONSTRAINT [FK_HealthFund_HealthFundGroup]
GO
ALTER TABLE [dbo].[HiServiceLog]  WITH CHECK ADD  CONSTRAINT [FK_HiServiceLog_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[HiServiceLog] CHECK CONSTRAINT [FK_HiServiceLog_AddressBook]
GO
ALTER TABLE [dbo].[HiServiceLog]  WITH CHECK ADD  CONSTRAINT [FK_HiServiceLog_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[HiServiceLog] CHECK CONSTRAINT [FK_HiServiceLog_PatientDebtor]
GO
ALTER TABLE [dbo].[HiServiceLog]  WITH CHECK ADD  CONSTRAINT [FK_HiServiceLog_SearchUser] FOREIGN KEY([SearchUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[HiServiceLog] CHECK CONSTRAINT [FK_HiServiceLog_SearchUser]
GO
ALTER TABLE [dbo].[HiServiceLog]  WITH CHECK ADD  CONSTRAINT [FK_HiServiceLog_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[HiServiceLog] CHECK CONSTRAINT [FK_HiServiceLog_User]
GO
ALTER TABLE [dbo].[Hospital]  WITH CHECK ADD  CONSTRAINT [FK_Hospital_Location] FOREIGN KEY([LinkedLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Hospital] CHECK CONSTRAINT [FK_Hospital_Location]
GO
ALTER TABLE [dbo].[ICPC2KEY]  WITH CHECK ADD  CONSTRAINT [FK_ICPC2KEY_ICPC2KEY] FOREIGN KEY([KeyId])
REFERENCES [dbo].[ICPC2KEY] ([KeyId])
GO
ALTER TABLE [dbo].[ICPC2KEY] CHECK CONSTRAINT [FK_ICPC2KEY_ICPC2KEY]
GO
ALTER TABLE [dbo].[ICPC2LNK]  WITH CHECK ADD  CONSTRAINT [FK_ICPC2LNK_ICPC2KEY] FOREIGN KEY([KeyId])
REFERENCES [dbo].[ICPC2KEY] ([KeyId])
GO
ALTER TABLE [dbo].[ICPC2LNK] CHECK CONSTRAINT [FK_ICPC2LNK_ICPC2KEY]
GO
ALTER TABLE [dbo].[ICPC2LNK]  WITH CHECK ADD  CONSTRAINT [FK_ICPC2LNK_ICPC2TRM] FOREIGN KEY([TermId])
REFERENCES [dbo].[ICPC2TRM] ([TermId])
GO
ALTER TABLE [dbo].[ICPC2LNK] CHECK CONSTRAINT [FK_ICPC2LNK_ICPC2TRM]
GO
ALTER TABLE [dbo].[ICPC2LNK]  WITH CHECK ADD  CONSTRAINT [FK_ICPC2LNK_ICPC2TRM1] FOREIGN KEY([TermId])
REFERENCES [dbo].[ICPC2TRM] ([TermId])
GO
ALTER TABLE [dbo].[ICPC2LNK] CHECK CONSTRAINT [FK_ICPC2LNK_ICPC2TRM1]
GO
ALTER TABLE [dbo].[ICPCTempLNK]  WITH CHECK ADD  CONSTRAINT [FK_ICPCTempLNK_ICPCTempKEY] FOREIGN KEY([KeyId])
REFERENCES [dbo].[ICPCTempKEY] ([KeyId])
GO
ALTER TABLE [dbo].[ICPCTempLNK] CHECK CONSTRAINT [FK_ICPCTempLNK_ICPCTempKEY]
GO
ALTER TABLE [dbo].[ICPCTempLNK]  WITH CHECK ADD  CONSTRAINT [FK_ICPCTempLNK_ICPCTempTRM] FOREIGN KEY([TermId])
REFERENCES [dbo].[ICPCTempTRM] ([TermId])
GO
ALTER TABLE [dbo].[ICPCTempLNK] CHECK CONSTRAINT [FK_ICPCTempLNK_ICPCTempTRM]
GO
ALTER TABLE [dbo].[ImcEraReport]  WITH CHECK ADD  CONSTRAINT [FK_ImcEraReport_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [dbo].[Receipt] ([Id])
GO
ALTER TABLE [dbo].[ImcEraReport] CHECK CONSTRAINT [FK_ImcEraReport_Receipt]
GO
ALTER TABLE [dbo].[ImcProcessingReportDetail]  WITH CHECK ADD  CONSTRAINT [FK_ImcProcessingReportDetail_ImcProcessingReport] FOREIGN KEY([ImcProcessingReportId])
REFERENCES [dbo].[ImcProcessingReport] ([Id])
GO
ALTER TABLE [dbo].[ImcProcessingReportDetail] CHECK CONSTRAINT [FK_ImcProcessingReportDetail_ImcProcessingReport]
GO
ALTER TABLE [dbo].[ImcProcessingReportDetailExplanation]  WITH CHECK ADD  CONSTRAINT [FK_ImcProcessingReportDetailExplanation_ImcProcessingReportDetail] FOREIGN KEY([ImcProcessingReportDetailId])
REFERENCES [dbo].[ImcProcessingReportDetail] ([Id])
GO
ALTER TABLE [dbo].[ImcProcessingReportDetailExplanation] CHECK CONSTRAINT [FK_ImcProcessingReportDetailExplanation_ImcProcessingReportDetail]
GO
ALTER TABLE [dbo].[ImcProcessingReportExplanation]  WITH CHECK ADD  CONSTRAINT [FK_ImcProcessingReportExplanation_ImcProcessingReport] FOREIGN KEY([ImcProcessingReportId])
REFERENCES [dbo].[ImcProcessingReport] ([Id])
GO
ALTER TABLE [dbo].[ImcProcessingReportExplanation] CHECK CONSTRAINT [FK_ImcProcessingReportExplanation_ImcProcessingReport]
GO
ALTER TABLE [dbo].[ImmunisationCategoryVaccineMapping]  WITH CHECK ADD  CONSTRAINT [FK_ImmunisationCategoryVaccineMapping_ImmunisationCategory] FOREIGN KEY([ImmunisationCategoryId])
REFERENCES [dbo].[ImmunisationCategory] ([Id])
GO
ALTER TABLE [dbo].[ImmunisationCategoryVaccineMapping] CHECK CONSTRAINT [FK_ImmunisationCategoryVaccineMapping_ImmunisationCategory]
GO
ALTER TABLE [dbo].[ImmunisationCategoryVaccineMapping]  WITH CHECK ADD  CONSTRAINT [FK_ImmunisationCategoryVaccineMapping_Vaccine] FOREIGN KEY([VaccineUid])
REFERENCES [dbo].[Vaccine] ([VaccineUid])
GO
ALTER TABLE [dbo].[ImmunisationCategoryVaccineMapping] CHECK CONSTRAINT [FK_ImmunisationCategoryVaccineMapping_Vaccine]
GO
ALTER TABLE [dbo].[IntegratedEasyclaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEasyclaim_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEasyclaim] CHECK CONSTRAINT [FK_IntegratedEasyclaim_Billing]
GO
ALTER TABLE [dbo].[IntegratedEasyclaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEasyclaim_Debtor] FOREIGN KEY([DebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEasyclaim] CHECK CONSTRAINT [FK_IntegratedEasyclaim_Debtor]
GO
ALTER TABLE [dbo].[IntegratedEasyclaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEasyclaim_Patient] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEasyclaim] CHECK CONSTRAINT [FK_IntegratedEasyclaim_Patient]
GO
ALTER TABLE [dbo].[IntegratedEasyclaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEasyclaimHistory_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEasyclaimHistory] CHECK CONSTRAINT [FK_IntegratedEasyclaimHistory_Billing]
GO
ALTER TABLE [dbo].[IntegratedEasyclaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEasyclaimHistory_Debtor] FOREIGN KEY([DebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEasyclaimHistory] CHECK CONSTRAINT [FK_IntegratedEasyclaimHistory_Debtor]
GO
ALTER TABLE [dbo].[IntegratedEasyclaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEasyclaimHistory_Patient] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEasyclaimHistory] CHECK CONSTRAINT [FK_IntegratedEasyclaimHistory_Patient]
GO
ALTER TABLE [dbo].[IntegratedEftposBankAccountMerchant]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposBankAccountMerchant_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposBankAccountMerchant] CHECK CONSTRAINT [FK_IntegratedEftposBankAccountMerchant_BankAccount]
GO
ALTER TABLE [dbo].[IntegratedEftposBankAccountMerchant]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposBankAccountMerchant_IntegratedEftposMerchant] FOREIGN KEY([IntegratedEftposMerchantId])
REFERENCES [dbo].[IntegratedEftposMerchant] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposBankAccountMerchant] CHECK CONSTRAINT [FK_IntegratedEftposBankAccountMerchant_IntegratedEftposMerchant]
GO
ALTER TABLE [dbo].[IntegratedEftposBankAccountMerchant]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposBankAccountMerchant_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposBankAccountMerchant] CHECK CONSTRAINT [FK_IntegratedEftposBankAccountMerchant_Location]
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResult]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResult_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResult] CHECK CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResult_BankAccount]
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResult]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResult_IntegratedEftposMerchant] FOREIGN KEY([IntegratedEftposMerchantId])
REFERENCES [dbo].[IntegratedEftposMerchant] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResult] CHECK CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResult_IntegratedEftposMerchant]
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResultDetail_IntegratedEftposReconciliationAndBankingResult] FOREIGN KEY([ResultId])
REFERENCES [dbo].[IntegratedEftposReconciliationAndBankingResult] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail] CHECK CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResultDetail_IntegratedEftposReconciliationAndBankingResult]
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResultDetail_PatientDebtor] FOREIGN KEY([DebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail] CHECK CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResultDetail_PatientDebtor]
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResultDetail_Payment] FOREIGN KEY([PaymentId])
REFERENCES [dbo].[Payment] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposReconciliationAndBankingResultDetail] CHECK CONSTRAINT [FK_IntegratedEftposReconciliationAndBankingResultDetail_Payment]
GO
ALTER TABLE [dbo].[IntegratedEftposSettlementAndBankingException]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposSettlementAndBankingException_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [dbo].[Receipt] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposSettlementAndBankingException] CHECK CONSTRAINT [FK_IntegratedEftposSettlementAndBankingException_Receipt]
GO
ALTER TABLE [dbo].[IntegratedEftposTransaction]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransaction_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransaction] CHECK CONSTRAINT [FK_IntegratedEftposTransaction_BankAccount]
GO
ALTER TABLE [dbo].[IntegratedEftposTransaction]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransaction_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransaction] CHECK CONSTRAINT [FK_IntegratedEftposTransaction_Location]
GO
ALTER TABLE [dbo].[IntegratedEftposTransaction]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransaction_PatientDebtor] FOREIGN KEY([DebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransaction] CHECK CONSTRAINT [FK_IntegratedEftposTransaction_PatientDebtor]
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransactionHistory_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory] CHECK CONSTRAINT [FK_IntegratedEftposTransactionHistory_BankAccount]
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransactionHistory_IntegratedEftposTransaction] FOREIGN KEY([IntegratedEftposTransactionId])
REFERENCES [dbo].[IntegratedEftposTransaction] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory] CHECK CONSTRAINT [FK_IntegratedEftposTransactionHistory_IntegratedEftposTransaction]
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransactionHistory_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory] CHECK CONSTRAINT [FK_IntegratedEftposTransactionHistory_Location]
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedEftposTransactionHistory_PatientDebtor] FOREIGN KEY([DebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedEftposTransactionHistory] CHECK CONSTRAINT [FK_IntegratedEftposTransactionHistory_PatientDebtor]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaim_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim] CHECK CONSTRAINT [FK_IntegratedHealthPointClaim_BankAccount]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaim_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim] CHECK CONSTRAINT [FK_IntegratedHealthPointClaim_Billing]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaim_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim] CHECK CONSTRAINT [FK_IntegratedHealthPointClaim_LocationId]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaim_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaim] CHECK CONSTRAINT [FK_IntegratedHealthPointClaim_PatientDebtor]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaimHistory_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory] CHECK CONSTRAINT [FK_IntegratedHealthPointClaimHistory_BankAccount]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaimHistory_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory] CHECK CONSTRAINT [FK_IntegratedHealthPointClaimHistory_Billing]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaimHistory_IntegratedHealthPointClaim] FOREIGN KEY([IntegratedHealthPointClaimId])
REFERENCES [dbo].[IntegratedHealthPointClaim] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory] CHECK CONSTRAINT [FK_IntegratedHealthPointClaimHistory_IntegratedHealthPointClaim]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaimHistory_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory] CHECK CONSTRAINT [FK_IntegratedHealthPointClaimHistory_LocationId]
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory]  WITH CHECK ADD  CONSTRAINT [FK_IntegratedHealthPointClaimHistory_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[IntegratedHealthPointClaimHistory] CHECK CONSTRAINT [FK_IntegratedHealthPointClaimHistory_PatientDebtor]
GO
ALTER TABLE [dbo].[InternalMessageFolder]  WITH CHECK ADD  CONSTRAINT [FK_InternalMessageFolder_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[InternalMessageFolder] CHECK CONSTRAINT [FK_InternalMessageFolder_User]
GO
ALTER TABLE [dbo].[InternalMessageRecipient]  WITH CHECK ADD  CONSTRAINT [FK_InternalMessageRecipient_InternalMessage] FOREIGN KEY([InternalMessageId])
REFERENCES [dbo].[InternalMessage] ([Id])
GO
ALTER TABLE [dbo].[InternalMessageRecipient] CHECK CONSTRAINT [FK_InternalMessageRecipient_InternalMessage]
GO
ALTER TABLE [dbo].[InternalMessageRecipient]  WITH CHECK ADD  CONSTRAINT [FK_InternalMessageRecipient_UserMailGroup] FOREIGN KEY([UserMailGroupId])
REFERENCES [dbo].[UserMailGroup] ([Id])
GO
ALTER TABLE [dbo].[InternalMessageRecipient] CHECK CONSTRAINT [FK_InternalMessageRecipient_UserMailGroup]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [DF_Invoice_HealthFund] FOREIGN KEY([HealthFundUid])
REFERENCES [dbo].[HealthFund] ([Uid])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [DF_Invoice_HealthFund]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Billing] FOREIGN KEY([BillingId])
REFERENCES [dbo].[Billing] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Billing]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_LegalEntity] FOREIGN KEY([LegalEntityId])
REFERENCES [dbo].[LegalEntity] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_LegalEntity]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Location]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Location1] FOREIGN KEY([PracticeLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Location1]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_PatientDebtor1] FOREIGN KEY([PatientDebtorDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_PatientDebtor1]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [dbo].[Receipt] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Receipt]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_User]
GO
ALTER TABLE [dbo].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_AddressBook] FOREIGN KEY([AssistantAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_AddressBook]
GO
ALTER TABLE [dbo].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
GO
ALTER TABLE [dbo].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_Invoice]
GO
ALTER TABLE [dbo].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_ServiceGroup] FOREIGN KEY([ReportingServiceGroupId])
REFERENCES [dbo].[ServiceGroup] ([Id])
GO
ALTER TABLE [dbo].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_ServiceGroup]
GO
ALTER TABLE [dbo].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_ServiceItemDetail] FOREIGN KEY([ServiceItemDetailId])
REFERENCES [dbo].[ServiceItemDetail] ([Id])
GO
ALTER TABLE [dbo].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_ServiceItemDetail]
GO
ALTER TABLE [dbo].[InvoiceDocumentDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDocumentDetail_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
GO
ALTER TABLE [dbo].[InvoiceDocumentDetail] CHECK CONSTRAINT [FK_InvoiceDocumentDetail_Invoice]
GO
ALTER TABLE [dbo].[InvoiceDocumentDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDocumentDetail_InvoiceDocument] FOREIGN KEY([InvoiceDocumentId])
REFERENCES [dbo].[InvoiceDocument] ([Id])
GO
ALTER TABLE [dbo].[InvoiceDocumentDetail] CHECK CONSTRAINT [FK_InvoiceDocumentDetail_InvoiceDocument]
GO
ALTER TABLE [dbo].[InvoiceReference]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceReference_PatientDebtorDebtor] FOREIGN KEY([PatientDebtorDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[InvoiceReference] CHECK CONSTRAINT [FK_InvoiceReference_PatientDebtorDebtor]
GO
ALTER TABLE [dbo].[InvoiceReference]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceReference_PatientDebtorPatient] FOREIGN KEY([PatientDebtorPatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[InvoiceReference] CHECK CONSTRAINT [FK_InvoiceReference_PatientDebtorPatient]
GO
ALTER TABLE [dbo].[InvoiceReferenceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceReferenceDetail_InvoiceReference] FOREIGN KEY([InvoiceReferenceId])
REFERENCES [dbo].[InvoiceReference] ([Id])
GO
ALTER TABLE [dbo].[InvoiceReferenceDetail] CHECK CONSTRAINT [FK_InvoiceReferenceDetail_InvoiceReference]
GO
ALTER TABLE [dbo].[LegalEntity]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntity_Address] FOREIGN KEY([AddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[LegalEntity] CHECK CONSTRAINT [FK_LegalEntity_Address]
GO
ALTER TABLE [dbo].[LegalEntity]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntity_BankAccount] FOREIGN KEY([PaymentOptionDirectDepositBankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[LegalEntity] CHECK CONSTRAINT [FK_LegalEntity_BankAccount]
GO
ALTER TABLE [dbo].[LegalEntity]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntity_Contact] FOREIGN KEY([PhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[LegalEntity] CHECK CONSTRAINT [FK_LegalEntity_Contact]
GO
ALTER TABLE [dbo].[LegalEntity]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntity_Contact1] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[LegalEntity] CHECK CONSTRAINT [FK_LegalEntity_Contact1]
GO
ALTER TABLE [dbo].[LegalEntity]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntity_Contact2] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[LegalEntity] CHECK CONSTRAINT [FK_LegalEntity_Contact2]
GO
ALTER TABLE [dbo].[LegalEntityDate]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntityDate_LegalEntity] FOREIGN KEY([LegalEntityId])
REFERENCES [dbo].[LegalEntity] ([Id])
GO
ALTER TABLE [dbo].[LegalEntityDate] CHECK CONSTRAINT [FK_LegalEntityDate_LegalEntity]
GO
ALTER TABLE [dbo].[LegalEntityDate]  WITH CHECK ADD  CONSTRAINT [FK_LegalEntityDate_Provider] FOREIGN KEY([ProviderId])
REFERENCES [dbo].[Provider] ([Id])
GO
ALTER TABLE [dbo].[LegalEntityDate] CHECK CONSTRAINT [FK_LegalEntityDate_Provider]
GO
ALTER TABLE [dbo].[LinkedProvider]  WITH CHECK ADD  CONSTRAINT [FK_LinkedProvider_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[LinkedProvider] CHECK CONSTRAINT [FK_LinkedProvider_AddressBook]
GO
ALTER TABLE [dbo].[LinkedProvider]  WITH CHECK ADD  CONSTRAINT [FK_LinkedProvider_Patient] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[LinkedProvider] CHECK CONSTRAINT [FK_LinkedProvider_Patient]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Address] FOREIGN KEY([StreetAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Address]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Address1] FOREIGN KEY([PostalAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Address1]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Contact] FOREIGN KEY([PhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Contact]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Contact1] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Contact1]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Contact2] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Contact2]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Location] FOREIGN KEY([LocationLevel2Id])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Location]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Location1] FOREIGN KEY([LocationLevel3Id])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Location1]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Location2] FOREIGN KEY([LocationLevel4Id])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Location2]
GO
ALTER TABLE [dbo].[LoincGroupLoinc]  WITH CHECK ADD  CONSTRAINT [FK_LoincGroupLoinc_LoincGroup] FOREIGN KEY([LoincGroupUid])
REFERENCES [dbo].[LoincGroup] ([Uid])
GO
ALTER TABLE [dbo].[LoincGroupLoinc] CHECK CONSTRAINT [FK_LoincGroupLoinc_LoincGroup]
GO
ALTER TABLE [dbo].[ManuscriptTemplate]  WITH CHECK ADD  CONSTRAINT [FK_ManuscriptTemplate_ClinicalSummaryHeading] FOREIGN KEY([ClinicalSummaryId])
REFERENCES [dbo].[ClinicalSummaryHeading] ([Id])
GO
ALTER TABLE [dbo].[ManuscriptTemplate] CHECK CONSTRAINT [FK_ManuscriptTemplate_ClinicalSummaryHeading]
GO
ALTER TABLE [dbo].[MeasurementCategoryLabCodeMapping]  WITH CHECK ADD  CONSTRAINT [FK_MeasurementCategoryLabCodeMapping_MeasurementCategory] FOREIGN KEY([MeasurementId])
REFERENCES [dbo].[MeasurementCategory] ([Id])
GO
ALTER TABLE [dbo].[MeasurementCategoryLabCodeMapping] CHECK CONSTRAINT [FK_MeasurementCategoryLabCodeMapping_MeasurementCategory]
GO
ALTER TABLE [dbo].[MedicationCategorySubstanceMapping]  WITH CHECK ADD  CONSTRAINT [FK_MedicationCategorySubstanceMapping_MedicationCategory] FOREIGN KEY([MedicationCategoryId])
REFERENCES [dbo].[MedicationCategory] ([Id])
GO
ALTER TABLE [dbo].[MedicationCategorySubstanceMapping] CHECK CONSTRAINT [FK_MedicationCategorySubstanceMapping_MedicationCategory]
GO
ALTER TABLE [dbo].[MedicationSubgroup]  WITH CHECK ADD  CONSTRAINT [FK_MedicationSubgroup_MedicationGroup] FOREIGN KEY([MedicationGroupUid])
REFERENCES [dbo].[MedicationGroup] ([Uid])
GO
ALTER TABLE [dbo].[MedicationSubgroup] CHECK CONSTRAINT [FK_MedicationSubgroup_MedicationGroup]
GO
ALTER TABLE [dbo].[MedicationSubgroupDrug]  WITH CHECK ADD  CONSTRAINT [FK_MedicationSubgroupDrug_MedicationSubgroup] FOREIGN KEY([MedicationSubgroupUid])
REFERENCES [dbo].[MedicationSubgroup] ([Uid])
GO
ALTER TABLE [dbo].[MedicationSubgroupDrug] CHECK CONSTRAINT [FK_MedicationSubgroupDrug_MedicationSubgroup]
GO
ALTER TABLE [dbo].[MessageIn]  WITH CHECK ADD  CONSTRAINT [FK_MessageIn_MessageOut] FOREIGN KEY([AckMessageOutId])
REFERENCES [dbo].[MessageOut] ([Id])
GO
ALTER TABLE [dbo].[MessageIn] CHECK CONSTRAINT [FK_MessageIn_MessageOut]
GO
ALTER TABLE [dbo].[MessageIn]  WITH CHECK ADD  CONSTRAINT [FK_MessageIn_MessagingTransport] FOREIGN KEY([MessagingTransportUid])
REFERENCES [dbo].[MessagingTransport] ([Uid])
GO
ALTER TABLE [dbo].[MessageIn] CHECK CONSTRAINT [FK_MessageIn_MessagingTransport]
GO
ALTER TABLE [dbo].[MessageOut]  WITH CHECK ADD  CONSTRAINT [FK_MessageOut_AddressBook] FOREIGN KEY([RecipientAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[MessageOut] CHECK CONSTRAINT [FK_MessageOut_AddressBook]
GO
ALTER TABLE [dbo].[MessageOut]  WITH CHECK ADD  CONSTRAINT [FK_MessageOut_MessageIn] FOREIGN KEY([AckMessageInId])
REFERENCES [dbo].[MessageIn] ([Id])
GO
ALTER TABLE [dbo].[MessageOut] CHECK CONSTRAINT [FK_MessageOut_MessageIn]
GO
ALTER TABLE [dbo].[MessageOut]  WITH CHECK ADD  CONSTRAINT [FK_MessageOut_MessagingTransport] FOREIGN KEY([MessagingTransportUid])
REFERENCES [dbo].[MessagingTransport] ([Uid])
GO
ALTER TABLE [dbo].[MessageOut] CHECK CONSTRAINT [FK_MessageOut_MessagingTransport]
GO
ALTER TABLE [dbo].[MessageOut]  WITH CHECK ADD  CONSTRAINT [FK_MessageOut_User] FOREIGN KEY([AuthorUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[MessageOut] CHECK CONSTRAINT [FK_MessageOut_User]
GO
ALTER TABLE [dbo].[MessagingTransport]  WITH CHECK ADD  CONSTRAINT [FK_MessagingTransport_Workstation] FOREIGN KEY([WorkstationId])
REFERENCES [dbo].[Workstation] ([Id])
GO
ALTER TABLE [dbo].[MessagingTransport] CHECK CONSTRAINT [FK_MessagingTransport_Workstation]
GO
ALTER TABLE [dbo].[PathologyResult]  WITH CHECK ADD  CONSTRAINT [FK_PathologyResult_PathologyResult] FOREIGN KEY([Id])
REFERENCES [dbo].[PathologyResult] ([Id])
GO
ALTER TABLE [dbo].[PathologyResult] CHECK CONSTRAINT [FK_PathologyResult_PathologyResult]
GO
ALTER TABLE [dbo].[PathologyResultAtomic]  WITH CHECK ADD  CONSTRAINT [FK_PathologyResultAtomic_PathologyResult] FOREIGN KEY([PathologyResultId])
REFERENCES [dbo].[PathologyResult] ([Id])
GO
ALTER TABLE [dbo].[PathologyResultAtomic] CHECK CONSTRAINT [FK_PathologyResultAtomic_PathologyResult]
GO
ALTER TABLE [dbo].[Patient_Document]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Document_Document] FOREIGN KEY([DocumentId])
REFERENCES [dbo].[Document] ([DocumentId])
GO
ALTER TABLE [dbo].[Patient_Document] CHECK CONSTRAINT [FK_Patient_Document_Document]
GO
ALTER TABLE [dbo].[Patient_Document]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Document_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Patient_Document] CHECK CONSTRAINT [FK_Patient_Document_PatientDebtor]
GO
ALTER TABLE [dbo].[PatientContactEvent]  WITH CHECK ADD  CONSTRAINT [FK_PatientContactEvent_PatientContact] FOREIGN KEY([PatientContactId])
REFERENCES [dbo].[PatientContact] ([Id])
GO
ALTER TABLE [dbo].[PatientContactEvent] CHECK CONSTRAINT [FK_PatientContactEvent_PatientContact]
GO
ALTER TABLE [dbo].[PatientContactEvent]  WITH CHECK ADD  CONSTRAINT [FK_PatientContactEvent_ToDoTemplate] FOREIGN KEY([ToDoTemplateId])
REFERENCES [dbo].[ToDoTemplate] ([Id])
GO
ALTER TABLE [dbo].[PatientContactEvent] CHECK CONSTRAINT [FK_PatientContactEvent_ToDoTemplate]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address] FOREIGN KEY([ResidentialAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address1] FOREIGN KEY([PostalAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address1]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address2] FOREIGN KEY([NokAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address2]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address3] FOREIGN KEY([Contact1AddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address3]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address4] FOREIGN KEY([Contact2AddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address4]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address5] FOREIGN KEY([Employer1AddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address5]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Address6] FOREIGN KEY([Employer2AddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Address6]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Billcode] FOREIGN KEY([DefaultBillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Billcode]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact] FOREIGN KEY([HomePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact1] FOREIGN KEY([WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact1]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact10] FOREIGN KEY([Contact1MobilePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact10]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact11] FOREIGN KEY([Contact2HomePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact11]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact12] FOREIGN KEY([Contact2WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact12]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact13] FOREIGN KEY([Contact2MobilePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact13]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact14] FOREIGN KEY([Employer1WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact14]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact15] FOREIGN KEY([Employer2WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact15]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact2] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact2]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact3] FOREIGN KEY([MobilePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact3]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact4] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact4]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact5] FOREIGN KEY([NOKHomePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact5]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact6] FOREIGN KEY([NOKWorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact6]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact7] FOREIGN KEY([NOKMobilePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact7]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact8] FOREIGN KEY([Contact1HomePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact8]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Contact9] FOREIGN KEY([Contact1WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Contact9]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_DebtorClassification] FOREIGN KEY([DebtorClassificationId])
REFERENCES [dbo].[DebtorClassification] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_DebtorClassification]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_DebtorGroup] FOREIGN KEY([DebtorGroupId])
REFERENCES [dbo].[DebtorGroup] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_DebtorGroup]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Ethnicity] FOREIGN KEY([EthnicityId])
REFERENCES [dbo].[Ethnicity] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Ethnicity]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_HealthFund] FOREIGN KEY([HealthFundUid])
REFERENCES [dbo].[HealthFund] ([Uid])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_HealthFund]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Occupation1] FOREIGN KEY([Employer1OccupationId])
REFERENCES [dbo].[Occupation] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Occupation1]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Occupation2] FOREIGN KEY([Employer2OccupationId])
REFERENCES [dbo].[Occupation] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Occupation2]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_PatientClassification] FOREIGN KEY([PatientClassificationId])
REFERENCES [dbo].[PatientClassification] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_PatientClassification]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_PatientGroup] FOREIGN KEY([PatientGroupId])
REFERENCES [dbo].[PatientGroup] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_PatientGroup]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_PersonName] FOREIGN KEY([LegalPersonNameId])
REFERENCES [dbo].[PersonName] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_PersonName]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_PersonName1] FOREIGN KEY([PreferredPersonNameId])
REFERENCES [dbo].[PersonName] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_PersonName1]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Provider] FOREIGN KEY([DefaultProviderUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Provider]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Relationship] FOREIGN KEY([NokRelationshipId])
REFERENCES [dbo].[Relationship] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Relationship]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Relationship1] FOREIGN KEY([Contact1RelationshipId])
REFERENCES [dbo].[Relationship] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Relationship1]
GO
ALTER TABLE [dbo].[PatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Relationship2] FOREIGN KEY([Contact2RelationshipId])
REFERENCES [dbo].[Relationship] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtor] CHECK CONSTRAINT [FK_Patient_Relationship2]
GO
ALTER TABLE [dbo].[PatientDebtorAdditionalInvoiceDetails]  WITH CHECK ADD  CONSTRAINT [FK_PatientDebtorAdditionalInvoiceDetails_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtorAdditionalInvoiceDetails] CHECK CONSTRAINT [FK_PatientDebtorAdditionalInvoiceDetails_PatientDebtor]
GO
ALTER TABLE [dbo].[PatientDebtorFinancialTransactionVersion]  WITH CHECK ADD  CONSTRAINT [FK_PatientDebtorFinancialTransactionVersion_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtorFinancialTransactionVersion] CHECK CONSTRAINT [FK_PatientDebtorFinancialTransactionVersion_PatientDebtor]
GO
ALTER TABLE [dbo].[PatientDebtorHistory]  WITH CHECK ADD  CONSTRAINT [FK_PatientDebtorHistory_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtorHistory] CHECK CONSTRAINT [FK_PatientDebtorHistory_PatientDebtor]
GO
ALTER TABLE [dbo].[PatientDebtorHistory]  WITH CHECK ADD  CONSTRAINT [FK_PatientDebtorHistory_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtorHistory] CHECK CONSTRAINT [FK_PatientDebtorHistory_User]
GO
ALTER TABLE [dbo].[PatientDebtorIdentifier]  WITH CHECK ADD  CONSTRAINT [FK_PatientDebtorIdentifier_Identifier] FOREIGN KEY([IdentifierId])
REFERENCES [dbo].[Identifier] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtorIdentifier] CHECK CONSTRAINT [FK_PatientDebtorIdentifier_Identifier]
GO
ALTER TABLE [dbo].[PatientDebtorIdentifier]  WITH CHECK ADD  CONSTRAINT [FK_PatientDebtorIdentifier_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[PatientDebtorIdentifier] CHECK CONSTRAINT [FK_PatientDebtorIdentifier_PatientDebtor]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_BankRun] FOREIGN KEY([BankRunId])
REFERENCES [dbo].[BankRun] ([Id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_BankRun]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_IntegratedEftposTransaction] FOREIGN KEY([IntegratedEftposTransactionId])
REFERENCES [dbo].[IntegratedEftposTransaction] ([Id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_IntegratedEftposTransaction]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_IntegratedHealthPointClaim] FOREIGN KEY([IntegratedHealthPointClaimId])
REFERENCES [dbo].[IntegratedHealthPointClaim] ([Id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_IntegratedHealthPointClaim]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Payment] FOREIGN KEY([RefundedPaymentId])
REFERENCES [dbo].[Payment] ([Id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_Payment]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_PaymentType1] FOREIGN KEY([PaymentTypeId])
REFERENCES [dbo].[PaymentType] ([Id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_PaymentType1]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [dbo].[Receipt] ([Id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_Receipt]
GO
ALTER TABLE [dbo].[PersonName]  WITH CHECK ADD  CONSTRAINT [FK_PersonName_NameSuffix] FOREIGN KEY([NameSuffixId])
REFERENCES [dbo].[NameSuffix] ([Id])
GO
ALTER TABLE [dbo].[PersonName] CHECK CONSTRAINT [FK_PersonName_NameSuffix]
GO
ALTER TABLE [dbo].[PersonName]  WITH CHECK ADD  CONSTRAINT [FK_PersonName_NameTitle] FOREIGN KEY([NameTitleId])
REFERENCES [dbo].[NameTitle] ([Id])
GO
ALTER TABLE [dbo].[PersonName] CHECK CONSTRAINT [FK_PersonName_NameTitle]
GO
ALTER TABLE [dbo].[Practice]  WITH CHECK ADD  CONSTRAINT [FK_Practice_Address] FOREIGN KEY([StreetAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[Practice] CHECK CONSTRAINT [FK_Practice_Address]
GO
ALTER TABLE [dbo].[Practice]  WITH CHECK ADD  CONSTRAINT [FK_Practice_Address1] FOREIGN KEY([PostalAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[Practice] CHECK CONSTRAINT [FK_Practice_Address1]
GO
ALTER TABLE [dbo].[Practice]  WITH CHECK ADD  CONSTRAINT [FK_Practice_Contact] FOREIGN KEY([PhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Practice] CHECK CONSTRAINT [FK_Practice_Contact]
GO
ALTER TABLE [dbo].[Practice]  WITH CHECK ADD  CONSTRAINT [FK_Practice_Contact1] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Practice] CHECK CONSTRAINT [FK_Practice_Contact1]
GO
ALTER TABLE [dbo].[Practice]  WITH CHECK ADD  CONSTRAINT [FK_Practice_Contact2] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Practice] CHECK CONSTRAINT [FK_Practice_Contact2]
GO
ALTER TABLE [dbo].[PracticeDevice]  WITH CHECK ADD  CONSTRAINT [FK_PracticeDevice_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[PracticeDevice] CHECK CONSTRAINT [FK_PracticeDevice_Location]
GO
ALTER TABLE [dbo].[PracticeOptions]  WITH CHECK ADD  CONSTRAINT [FK_PracticeOptions_Practice] FOREIGN KEY([PracticeId])
REFERENCES [dbo].[Practice] ([Id])
GO
ALTER TABLE [dbo].[PracticeOptions] CHECK CONSTRAINT [FK_PracticeOptions_Practice]
GO
ALTER TABLE [dbo].[PriceParameter]  WITH CHECK ADD  CONSTRAINT [FK_PriceParameter_HealthFund] FOREIGN KEY([HealthFundUid])
REFERENCES [dbo].[HealthFund] ([Uid])
GO
ALTER TABLE [dbo].[PriceParameter] CHECK CONSTRAINT [FK_PriceParameter_HealthFund]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_Address] FOREIGN KEY([AddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_Address]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_Contact] FOREIGN KEY([PhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_Contact]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_Contact1] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_Contact1]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_Contact2] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_Contact2]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_LegalEntity] FOREIGN KEY([LegalEntityId])
REFERENCES [dbo].[LegalEntity] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_LegalEntity]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_Location] FOREIGN KEY([ServiceLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_Location]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_Provider] FOREIGN KEY([PayeeProviderId])
REFERENCES [dbo].[Provider] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_Provider]
GO
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [FK_Provider_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [FK_Provider_User]
GO
ALTER TABLE [dbo].[ProviderOptions]  WITH CHECK ADD  CONSTRAINT [FK_ProviderOptions_Provider] FOREIGN KEY([ProviderId])
REFERENCES [dbo].[Provider] ([Id])
GO
ALTER TABLE [dbo].[ProviderOptions] CHECK CONSTRAINT [FK_ProviderOptions_Provider]
GO
ALTER TABLE [dbo].[QuickDose]  WITH CHECK ADD  CONSTRAINT [FK_QuickDose_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[QuickDose] CHECK CONSTRAINT [FK_QuickDose_User]
GO
ALTER TABLE [dbo].[QuickItem]  WITH CHECK ADD  CONSTRAINT [FK_QuickItem_QuickItem] FOREIGN KEY([ParentId])
REFERENCES [dbo].[QuickItem] ([Id])
GO
ALTER TABLE [dbo].[QuickItem] CHECK CONSTRAINT [FK_QuickItem_QuickItem]
GO
ALTER TABLE [dbo].[QuickListUserHiddenPracticeList]  WITH CHECK ADD  CONSTRAINT [FK_QuickListUserHiddenPracticeList_QuickList] FOREIGN KEY([QuickListId])
REFERENCES [dbo].[QuickList] ([Id])
GO
ALTER TABLE [dbo].[QuickListUserHiddenPracticeList] CHECK CONSTRAINT [FK_QuickListUserHiddenPracticeList_QuickList]
GO
ALTER TABLE [dbo].[QuickListUserHiddenPracticeList]  WITH CHECK ADD  CONSTRAINT [FK_QuickListUserHiddenPracticeList_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[QuickListUserHiddenPracticeList] CHECK CONSTRAINT [FK_QuickListUserHiddenPracticeList_User]
GO
ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Billcode] FOREIGN KEY([BillcodeUid])
REFERENCES [dbo].[Billcode] ([Uid])
GO
ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Billcode]
GO
ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_HealthFund] FOREIGN KEY([HealthFundUid])
REFERENCES [dbo].[HealthFund] ([Uid])
GO
ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_HealthFund]
GO
ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Hospital] FOREIGN KEY([HospitalUid])
REFERENCES [dbo].[Hospital] ([Uid])
GO
ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Hospital]
GO
ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Location1] FOREIGN KEY([PracticeLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Location1]
GO
ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Location2] FOREIGN KEY([ServiceLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Location2]
GO
ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_PatientDebtor1] FOREIGN KEY([PatientDebtorDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_PatientDebtor1]
GO
ALTER TABLE [dbo].[QuoteDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuoteDetail_AddressBook] FOREIGN KEY([AssistantAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_AddressBook]
GO
ALTER TABLE [dbo].[QuoteDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuoteDetail_Quote] FOREIGN KEY([QuoteId])
REFERENCES [dbo].[Quote] ([Id])
GO
ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_Quote]
GO
ALTER TABLE [dbo].[QuoteDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuoteDetail_ServiceItemDetail] FOREIGN KEY([ServiceItemDetailId])
REFERENCES [dbo].[ServiceItemDetail] ([Id])
GO
ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_ServiceItemDetail]
GO
ALTER TABLE [dbo].[Recall]  WITH CHECK ADD  CONSTRAINT [FK_Recall_Episode] FOREIGN KEY([EpisodeId])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[Recall] CHECK CONSTRAINT [FK_Recall_Episode]
GO
ALTER TABLE [dbo].[Recall]  WITH CHECK ADD  CONSTRAINT [FK_Recall_PatientContact] FOREIGN KEY([PatientContactId])
REFERENCES [dbo].[PatientContact] ([Id])
GO
ALTER TABLE [dbo].[Recall] CHECK CONSTRAINT [FK_Recall_PatientContact]
GO
ALTER TABLE [dbo].[Recall]  WITH CHECK ADD  CONSTRAINT [FK_Recall_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Recall] CHECK CONSTRAINT [FK_Recall_PatientDebtor]
GO
ALTER TABLE [dbo].[RecallActivity]  WITH CHECK ADD  CONSTRAINT [FK_RecallActivity_Episode] FOREIGN KEY([EpisodeId])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[RecallActivity] CHECK CONSTRAINT [FK_RecallActivity_Episode]
GO
ALTER TABLE [dbo].[RecallActivity]  WITH CHECK ADD  CONSTRAINT [FK_RecallActivity_Recall] FOREIGN KEY([RecallId])
REFERENCES [dbo].[Recall] ([Id])
GO
ALTER TABLE [dbo].[RecallActivity] CHECK CONSTRAINT [FK_RecallActivity_Recall]
GO
ALTER TABLE [dbo].[RecallActivity]  WITH CHECK ADD  CONSTRAINT [FK_RecallActivity_RecallRun] FOREIGN KEY([RecallRunId])
REFERENCES [dbo].[RecallRun] ([Id])
GO
ALTER TABLE [dbo].[RecallActivity] CHECK CONSTRAINT [FK_RecallActivity_RecallRun]
GO
ALTER TABLE [dbo].[RecallActivity]  WITH CHECK ADD  CONSTRAINT [FK_RecallActivity_Resource] FOREIGN KEY([AppointmentResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[RecallActivity] CHECK CONSTRAINT [FK_RecallActivity_Resource]
GO
ALTER TABLE [dbo].[RecallActivity]  WITH CHECK ADD  CONSTRAINT [FK_RecallActivity_User] FOREIGN KEY([ActivityUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[RecallActivity] CHECK CONSTRAINT [FK_RecallActivity_User]
GO
ALTER TABLE [dbo].[RecallRunDetail]  WITH CHECK ADD  CONSTRAINT [FK_RecallRunDetail_Recall] FOREIGN KEY([RecallId])
REFERENCES [dbo].[Recall] ([Id])
GO
ALTER TABLE [dbo].[RecallRunDetail] CHECK CONSTRAINT [FK_RecallRunDetail_Recall]
GO
ALTER TABLE [dbo].[RecallRunDetail]  WITH CHECK ADD  CONSTRAINT [FK_RecallRunDetail_RecallRun] FOREIGN KEY([RecallRunId])
REFERENCES [dbo].[RecallRun] ([Id])
GO
ALTER TABLE [dbo].[RecallRunDetail] CHECK CONSTRAINT [FK_RecallRunDetail_RecallRun]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_Address] FOREIGN KEY([PayerAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_Address]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_AdjustmentType] FOREIGN KEY([AdjustmentTypeId])
REFERENCES [dbo].[AdjustmentType] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_AdjustmentType]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_BankAccount] FOREIGN KEY([BankAccountId])
REFERENCES [dbo].[BankAccount] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_BankAccount]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_Location]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_PatientDebtor] FOREIGN KEY([PayerDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_PatientDebtor]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_ReceiptTransfer] FOREIGN KEY([TransferReferenceReceiptId])
REFERENCES [dbo].[Receipt] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_ReceiptTransfer]
GO
ALTER TABLE [dbo].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Receipt] CHECK CONSTRAINT [FK_Receipt_User]
GO
ALTER TABLE [dbo].[ReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptDetail_InvoiceDetail1] FOREIGN KEY([InvoiceDetailId])
REFERENCES [dbo].[InvoiceDetail] ([Id])
GO
ALTER TABLE [dbo].[ReceiptDetail] CHECK CONSTRAINT [FK_ReceiptDetail_InvoiceDetail1]
GO
ALTER TABLE [dbo].[ReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptDetail_LegalEntity] FOREIGN KEY([LegalEntityId])
REFERENCES [dbo].[LegalEntity] ([Id])
GO
ALTER TABLE [dbo].[ReceiptDetail] CHECK CONSTRAINT [FK_ReceiptDetail_LegalEntity]
GO
ALTER TABLE [dbo].[ReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptDetail_PatientDebtor] FOREIGN KEY([PatientDebtorDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[ReceiptDetail] CHECK CONSTRAINT [FK_ReceiptDetail_PatientDebtor]
GO
ALTER TABLE [dbo].[ReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptDetail_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [dbo].[Receipt] ([Id])
GO
ALTER TABLE [dbo].[ReceiptDetail] CHECK CONSTRAINT [FK_ReceiptDetail_Receipt]
GO
ALTER TABLE [dbo].[RecentPatient]  WITH CHECK ADD  CONSTRAINT [FK_RecentPatient_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[RecentPatient] CHECK CONSTRAINT [FK_RecentPatient_PatientDebtor]
GO
ALTER TABLE [dbo].[RecentPatient]  WITH CHECK ADD  CONSTRAINT [FK_RecentPatient_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[RecentPatient] CHECK CONSTRAINT [FK_RecentPatient_User]
GO
ALTER TABLE [dbo].[ReferralIn]  WITH CHECK ADD  CONSTRAINT [FK_Referral_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[ReferralIn] CHECK CONSTRAINT [FK_Referral_PatientDebtor]
GO
ALTER TABLE [dbo].[ReferralIn]  WITH CHECK ADD  CONSTRAINT [FK_ReferralIn_AddressBook] FOREIGN KEY([FromAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[ReferralIn] CHECK CONSTRAINT [FK_ReferralIn_AddressBook]
GO
ALTER TABLE [dbo].[ReferralIn]  WITH CHECK ADD  CONSTRAINT [FK_ReferralIn_User] FOREIGN KEY([ToUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ReferralIn] CHECK CONSTRAINT [FK_ReferralIn_User]
GO
ALTER TABLE [dbo].[Resource]  WITH CHECK ADD  CONSTRAINT [FK_Resource_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[Resource] CHECK CONSTRAINT [FK_Resource_Location]
GO
ALTER TABLE [dbo].[Resource]  WITH CHECK ADD  CONSTRAINT [FK_Resource_User] FOREIGN KEY([LinkedUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Resource] CHECK CONSTRAINT [FK_Resource_User]
GO
ALTER TABLE [dbo].[ResourceSecondaryResource]  WITH CHECK ADD  CONSTRAINT [FK_ResourceSecondaryResource_Resource] FOREIGN KEY([ResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[ResourceSecondaryResource] CHECK CONSTRAINT [FK_ResourceSecondaryResource_Resource]
GO
ALTER TABLE [dbo].[ResourceSecondaryResource]  WITH CHECK ADD  CONSTRAINT [FK_ResourceSecondaryResource_SecondaryResource] FOREIGN KEY([SecondaryResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[ResourceSecondaryResource] CHECK CONSTRAINT [FK_ResourceSecondaryResource_SecondaryResource]
GO
ALTER TABLE [dbo].[RosterAppointmentType]  WITH CHECK ADD  CONSTRAINT [FK_RosterAppointmentType_AppointmentType] FOREIGN KEY([AppointmentTypeId])
REFERENCES [dbo].[AppointmentType] ([Id])
GO
ALTER TABLE [dbo].[RosterAppointmentType] CHECK CONSTRAINT [FK_RosterAppointmentType_AppointmentType]
GO
ALTER TABLE [dbo].[RosterAppointmentType]  WITH CHECK ADD  CONSTRAINT [FK_RosterAppointmentType_RosterType] FOREIGN KEY([RosterTypeId])
REFERENCES [dbo].[RosterType] ([Id])
GO
ALTER TABLE [dbo].[RosterAppointmentType] CHECK CONSTRAINT [FK_RosterAppointmentType_RosterType]
GO
ALTER TABLE [dbo].[RosterSource]  WITH CHECK ADD  CONSTRAINT [FK_RosterSource_Resource] FOREIGN KEY([ResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[RosterSource] CHECK CONSTRAINT [FK_RosterSource_Resource]
GO
ALTER TABLE [dbo].[RosterSourceDetail]  WITH CHECK ADD  CONSTRAINT [FK_RosterSourceDetail_RosterSource] FOREIGN KEY([RosterSourceId])
REFERENCES [dbo].[RosterSource] ([Id])
GO
ALTER TABLE [dbo].[RosterSourceDetail] CHECK CONSTRAINT [FK_RosterSourceDetail_RosterSource]
GO
ALTER TABLE [dbo].[RosterSourceDetail]  WITH CHECK ADD  CONSTRAINT [FK_RosterSourceDetail_RosterType] FOREIGN KEY([RosterTypeId])
REFERENCES [dbo].[RosterType] ([Id])
GO
ALTER TABLE [dbo].[RosterSourceDetail] CHECK CONSTRAINT [FK_RosterSourceDetail_RosterType]
GO
ALTER TABLE [dbo].[RosterType]  WITH CHECK ADD  CONSTRAINT [FK_RosterType_Location] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[RosterType] CHECK CONSTRAINT [FK_RosterType_Location]
GO
ALTER TABLE [dbo].[ScheduleDayNote]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDayNotes_ScheduleView] FOREIGN KEY([ScheduleViewId])
REFERENCES [dbo].[ScheduleView] ([Id])
GO
ALTER TABLE [dbo].[ScheduleDayNote] CHECK CONSTRAINT [FK_ScheduleDayNotes_ScheduleView]
GO
ALTER TABLE [dbo].[ScheduleViewResource]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleViewResource_ResourceId] FOREIGN KEY([ResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[ScheduleViewResource] CHECK CONSTRAINT [FK_ScheduleViewResource_ResourceId]
GO
ALTER TABLE [dbo].[ScheduleViewResource]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleViewResource_ScheduleView] FOREIGN KEY([ScheduleViewId])
REFERENCES [dbo].[ScheduleView] ([Id])
GO
ALTER TABLE [dbo].[ScheduleViewResource] CHECK CONSTRAINT [FK_ScheduleViewResource_ScheduleView]
GO
ALTER TABLE [dbo].[SecurityItemAssign]  WITH CHECK ADD  CONSTRAINT [FK_SecurityItemAssign_UserRole] FOREIGN KEY([UserRoleId])
REFERENCES [dbo].[UserRole] ([Id])
GO
ALTER TABLE [dbo].[SecurityItemAssign] CHECK CONSTRAINT [FK_SecurityItemAssign_UserRole]
GO
ALTER TABLE [dbo].[ServiceGroupDetail]  WITH CHECK ADD  CONSTRAINT [FK_ServiceGroupDetail_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [dbo].[ServiceGroup] ([Id])
GO
ALTER TABLE [dbo].[ServiceGroupDetail] CHECK CONSTRAINT [FK_ServiceGroupDetail_ServiceGroup]
GO
ALTER TABLE [dbo].[ServiceItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_ServiceItemDetail_ServiceGroup1] FOREIGN KEY([PricingServiceGroupId])
REFERENCES [dbo].[ServiceGroup] ([Id])
GO
ALTER TABLE [dbo].[ServiceItemDetail] CHECK CONSTRAINT [FK_ServiceItemDetail_ServiceGroup1]
GO
ALTER TABLE [dbo].[ServiceItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_ServiceItemDetail_ServiceGroup2] FOREIGN KEY([ReportingServiceGroupId])
REFERENCES [dbo].[ServiceGroup] ([Id])
GO
ALTER TABLE [dbo].[ServiceItemDetail] CHECK CONSTRAINT [FK_ServiceItemDetail_ServiceGroup2]
GO
ALTER TABLE [dbo].[ServiceItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_ServiceItemDetail_ServiceItem] FOREIGN KEY([ServiceItemId])
REFERENCES [dbo].[ServiceItem] ([Id])
GO
ALTER TABLE [dbo].[ServiceItemDetail] CHECK CONSTRAINT [FK_ServiceItemDetail_ServiceItem]
GO
ALTER TABLE [dbo].[ServiceItemPrice]  WITH CHECK ADD  CONSTRAINT [FK_ServiceItemPrice_BaseFee1] FOREIGN KEY([BaseFeeUid])
REFERENCES [dbo].[BaseFee] ([Uid])
GO
ALTER TABLE [dbo].[ServiceItemPrice] CHECK CONSTRAINT [FK_ServiceItemPrice_BaseFee1]
GO
ALTER TABLE [dbo].[ServiceItemPrice]  WITH CHECK ADD  CONSTRAINT [FK_ServiceItemPrice_BaseFee2] FOREIGN KEY([BasisBaseFeeUid])
REFERENCES [dbo].[BaseFee] ([Uid])
GO
ALTER TABLE [dbo].[ServiceItemPrice] CHECK CONSTRAINT [FK_ServiceItemPrice_BaseFee2]
GO
ALTER TABLE [dbo].[ServiceItemPrice]  WITH CHECK ADD  CONSTRAINT [FK_ServiceItemPrice_ServiceItem] FOREIGN KEY([ServiceItemId])
REFERENCES [dbo].[ServiceItem] ([Id])
GO
ALTER TABLE [dbo].[ServiceItemPrice] CHECK CONSTRAINT [FK_ServiceItemPrice_ServiceItem]
GO
ALTER TABLE [dbo].[SMSReceived]  WITH CHECK ADD  CONSTRAINT [FK_SMSReceived_SMSSent] FOREIGN KEY([SMSSentUid])
REFERENCES [dbo].[SMSSent] ([SMSUid])
GO
ALTER TABLE [dbo].[SMSReceived] CHECK CONSTRAINT [FK_SMSReceived_SMSSent]
GO
ALTER TABLE [dbo].[SMSReceivedPatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_SMSReceivedPatientDebtor_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[SMSReceivedPatientDebtor] CHECK CONSTRAINT [FK_SMSReceivedPatientDebtor_PatientDebtor]
GO
ALTER TABLE [dbo].[SMSReceivedPatientDebtor]  WITH CHECK ADD  CONSTRAINT [FK_SMSReceivedPatientDebtor_SMSReceived] FOREIGN KEY([SmsReceivedId])
REFERENCES [dbo].[SMSReceived] ([Id])
GO
ALTER TABLE [dbo].[SMSReceivedPatientDebtor] CHECK CONSTRAINT [FK_SMSReceivedPatientDebtor_SMSReceived]
GO
ALTER TABLE [dbo].[Snippet]  WITH CHECK ADD  CONSTRAINT [FK_Snippet_ManuscriptTemplate] FOREIGN KEY([ManuscriptTemplateUid])
REFERENCES [dbo].[ManuscriptTemplate] ([ManuscriptTemplateUid])
GO
ALTER TABLE [dbo].[Snippet] CHECK CONSTRAINT [FK_Snippet_ManuscriptTemplate]
GO
ALTER TABLE [dbo].[Snippet]  WITH CHECK ADD  CONSTRAINT [FK_Snippet_Snippet] FOREIGN KEY([ParentUid])
REFERENCES [dbo].[Snippet] ([SnippetUid])
GO
ALTER TABLE [dbo].[Snippet] CHECK CONSTRAINT [FK_Snippet_Snippet]
GO
ALTER TABLE [dbo].[Snippet]  WITH CHECK ADD  CONSTRAINT [FK_Snippet_ToDoTemplate] FOREIGN KEY([ToDoTemplateId])
REFERENCES [dbo].[ToDoTemplate] ([Id])
GO
ALTER TABLE [dbo].[Snippet] CHECK CONSTRAINT [FK_Snippet_ToDoTemplate]
GO
ALTER TABLE [dbo].[SnippetAutoTextAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_SnippetAutoTextAvailableTo_Snippet] FOREIGN KEY([SnippetUid])
REFERENCES [dbo].[Snippet] ([SnippetUid])
GO
ALTER TABLE [dbo].[SnippetAutoTextAvailableTo] CHECK CONSTRAINT [FK_SnippetAutoTextAvailableTo_Snippet]
GO
ALTER TABLE [dbo].[SnippetAutoTextAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_SnippetAutoTextAvailableTo_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[SnippetAutoTextAvailableTo] CHECK CONSTRAINT [FK_SnippetAutoTextAvailableTo_User]
GO
ALTER TABLE [dbo].[SnippetAutoTextAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_SnippetAutoTextAvailableTo_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[SnippetAutoTextAvailableTo] CHECK CONSTRAINT [FK_SnippetAutoTextAvailableTo_UserGroup]
GO
ALTER TABLE [dbo].[SnippetContainedSnippets]  WITH CHECK ADD  CONSTRAINT [FK_SnippetContainedSnippets_Snippet] FOREIGN KEY([SnippetUid])
REFERENCES [dbo].[Snippet] ([SnippetUid])
GO
ALTER TABLE [dbo].[SnippetContainedSnippets] CHECK CONSTRAINT [FK_SnippetContainedSnippets_Snippet]
GO
ALTER TABLE [dbo].[SnippetContainedSnippets]  WITH CHECK ADD  CONSTRAINT [FK_SnippetContainedSnippets_Snippet2] FOREIGN KEY([ContainedSnippetUid])
REFERENCES [dbo].[Snippet] ([SnippetUid])
GO
ALTER TABLE [dbo].[SnippetContainedSnippets] CHECK CONSTRAINT [FK_SnippetContainedSnippets_Snippet2]
GO
ALTER TABLE [dbo].[SnippetDateOptions]  WITH CHECK ADD  CONSTRAINT [FK_SnippetDateOptions_Snippet] FOREIGN KEY([SnippetUid])
REFERENCES [dbo].[Snippet] ([SnippetUid])
GO
ALTER TABLE [dbo].[SnippetDateOptions] CHECK CONSTRAINT [FK_SnippetDateOptions_Snippet]
GO
ALTER TABLE [dbo].[SterilisationLoad]  WITH CHECK ADD  CONSTRAINT [FK_SterilisationLoad_SterilisationMethod] FOREIGN KEY([SterilisationMethodId])
REFERENCES [dbo].[SterilisationMethod] ([Id])
GO
ALTER TABLE [dbo].[SterilisationLoad] CHECK CONSTRAINT [FK_SterilisationLoad_SterilisationMethod]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_AddressBook1] FOREIGN KEY([AssistantAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_AddressBook1]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_AddressBook2] FOREIGN KEY([AnaesthetistAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_AddressBook2]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_AddressBook3] FOREIGN KEY([PaediatricianAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_AddressBook3]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_Episode] FOREIGN KEY([EpisodeId])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_Episode]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_Hospital] FOREIGN KEY([HospitalUid])
REFERENCES [dbo].[Hospital] ([Uid])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_Hospital]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_Provider] FOREIGN KEY([ServiceProviderId])
REFERENCES [dbo].[Provider] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_Provider]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_Quote] FOREIGN KEY([QuoteId])
REFERENCES [dbo].[Quote] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_Quote]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_ServiceLocation] FOREIGN KEY([ServiceLocationId])
REFERENCES [dbo].[Location] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_ServiceLocation]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbAnaesthetic] FOREIGN KEY([TbAnaestheticId])
REFERENCES [dbo].[TbAnaesthetic] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbAnaesthetic]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbCategory] FOREIGN KEY([TbCategoryId])
REFERENCES [dbo].[TbCategory] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbCategory]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbIndication] FOREIGN KEY([TbIndicationId])
REFERENCES [dbo].[TbIndication] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbIndication]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbInfectionRisk] FOREIGN KEY([TbInfectionRiskId])
REFERENCES [dbo].[TbInfectionRisk] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbInfectionRisk]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbMagnitude] FOREIGN KEY([TbMagnitudeId])
REFERENCES [dbo].[TbMagnitude] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbMagnitude]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbProcedureType] FOREIGN KEY([TbProcedureTypeId])
REFERENCES [dbo].[TbProcedureType] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbProcedureType]
GO
ALTER TABLE [dbo].[TbDetails]  WITH CHECK ADD  CONSTRAINT [FK_TbDetails_TbProsthesis] FOREIGN KEY([TbProsthesisId])
REFERENCES [dbo].[TbProsthesis] ([Id])
GO
ALTER TABLE [dbo].[TbDetails] CHECK CONSTRAINT [FK_TbDetails_TbProsthesis]
GO
ALTER TABLE [dbo].[TbDetailsInstrument]  WITH CHECK ADD  CONSTRAINT [FK_TbDetailsInstrument_Quote] FOREIGN KEY([QuoteId])
REFERENCES [dbo].[Quote] ([Id])
GO
ALTER TABLE [dbo].[TbDetailsInstrument] CHECK CONSTRAINT [FK_TbDetailsInstrument_Quote]
GO
ALTER TABLE [dbo].[TbDetailsInstrument]  WITH CHECK ADD  CONSTRAINT [FK_TbDetailsInstrument_TbInstrument] FOREIGN KEY([TbInstrumentId])
REFERENCES [dbo].[TbInstrument] ([Id])
GO
ALTER TABLE [dbo].[TbDetailsInstrument] CHECK CONSTRAINT [FK_TbDetailsInstrument_TbInstrument]
GO
ALTER TABLE [dbo].[TbDetailsProcedure]  WITH CHECK ADD  CONSTRAINT [FK_TbDetailsProcedure_Quote] FOREIGN KEY([QuoteId])
REFERENCES [dbo].[Quote] ([Id])
GO
ALTER TABLE [dbo].[TbDetailsProcedure] CHECK CONSTRAINT [FK_TbDetailsProcedure_Quote]
GO
ALTER TABLE [dbo].[TbDetailsProcedure]  WITH CHECK ADD  CONSTRAINT [FK_TbDetailsProcedure_TbProcedure] FOREIGN KEY([TbProcedureId])
REFERENCES [dbo].[TbProcedure] ([Id])
GO
ALTER TABLE [dbo].[TbDetailsProcedure] CHECK CONSTRAINT [FK_TbDetailsProcedure_TbProcedure]
GO
ALTER TABLE [dbo].[TbInstrument]  WITH CHECK ADD  CONSTRAINT [FK_TbInstrument_TbInstrument] FOREIGN KEY([ParentId])
REFERENCES [dbo].[TbInstrument] ([Id])
GO
ALTER TABLE [dbo].[TbInstrument] CHECK CONSTRAINT [FK_TbInstrument_TbInstrument]
GO
ALTER TABLE [dbo].[TbInstrumentQuickList]  WITH CHECK ADD  CONSTRAINT [FK_TbInstrumentQuickList_TbInstrument] FOREIGN KEY([TbInstrumentId])
REFERENCES [dbo].[TbInstrument] ([Id])
GO
ALTER TABLE [dbo].[TbInstrumentQuickList] CHECK CONSTRAINT [FK_TbInstrumentQuickList_TbInstrument]
GO
ALTER TABLE [dbo].[TbInstrumentQuickList]  WITH CHECK ADD  CONSTRAINT [FK_TbInstrumentQuickList_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[TbInstrumentQuickList] CHECK CONSTRAINT [FK_TbInstrumentQuickList_User]
GO
ALTER TABLE [dbo].[TbOpNotes]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotes_Provider] FOREIGN KEY([OperationCompleteProviderId])
REFERENCES [dbo].[Provider] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotes] CHECK CONSTRAINT [FK_TbOpNotes_Provider]
GO
ALTER TABLE [dbo].[TbOpNotes]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotes_Quote] FOREIGN KEY([QuoteId])
REFERENCES [dbo].[Quote] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotes] CHECK CONSTRAINT [FK_TbOpNotes_Quote]
GO
ALTER TABLE [dbo].[TbOpNotes]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotes_TbAdmissionOutcome] FOREIGN KEY([TbAdmissionOutcomeId])
REFERENCES [dbo].[TbAdmissionOutcome] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotes] CHECK CONSTRAINT [FK_TbOpNotes_TbAdmissionOutcome]
GO
ALTER TABLE [dbo].[TbOpNotes]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotes_TbCancelReason] FOREIGN KEY([TbCancelReasonId])
REFERENCES [dbo].[TbCancelReason] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotes] CHECK CONSTRAINT [FK_TbOpNotes_TbCancelReason]
GO
ALTER TABLE [dbo].[TbOpNotes]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotes_TbFollowupOutcome] FOREIGN KEY([TbFollowupOutcomeId])
REFERENCES [dbo].[TbFollowupOutcome] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotes] CHECK CONSTRAINT [FK_TbOpNotes_TbFollowupOutcome]
GO
ALTER TABLE [dbo].[TbOpNotesTemplate]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotesTemplate_TbAdmissionOutcome] FOREIGN KEY([TbAdmissionOutcomeId])
REFERENCES [dbo].[TbAdmissionOutcome] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotesTemplate] CHECK CONSTRAINT [FK_TbOpNotesTemplate_TbAdmissionOutcome]
GO
ALTER TABLE [dbo].[TbOpNotesTemplate]  WITH CHECK ADD  CONSTRAINT [FK_TbOpNotesTemplate_TbFollowupOutcome] FOREIGN KEY([TbFollowupOutcomeId])
REFERENCES [dbo].[TbFollowupOutcome] ([Id])
GO
ALTER TABLE [dbo].[TbOpNotesTemplate] CHECK CONSTRAINT [FK_TbOpNotesTemplate_TbFollowupOutcome]
GO
ALTER TABLE [dbo].[TbProcedure]  WITH CHECK ADD  CONSTRAINT [FK_TbProcedure_TbProcedure] FOREIGN KEY([ParentId])
REFERENCES [dbo].[TbProcedure] ([Id])
GO
ALTER TABLE [dbo].[TbProcedure] CHECK CONSTRAINT [FK_TbProcedure_TbProcedure]
GO
ALTER TABLE [dbo].[TbProcedureQuickList]  WITH CHECK ADD  CONSTRAINT [FK_TbProcedureQuickList_TbProcedure] FOREIGN KEY([TbProcedureId])
REFERENCES [dbo].[TbProcedure] ([Id])
GO
ALTER TABLE [dbo].[TbProcedureQuickList] CHECK CONSTRAINT [FK_TbProcedureQuickList_TbProcedure]
GO
ALTER TABLE [dbo].[TbProcedureQuickList]  WITH CHECK ADD  CONSTRAINT [FK_TbProcedureQuickList_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[TbProcedureQuickList] CHECK CONSTRAINT [FK_TbProcedureQuickList_User]
GO
ALTER TABLE [dbo].[TemplatesAvailable]  WITH CHECK ADD  CONSTRAINT [FK_TemplatesAvailable_ClinicalSummaryHeading] FOREIGN KEY([DocumentTypeClinicalSummaryHeadingId])
REFERENCES [dbo].[ClinicalSummaryHeading] ([Id])
GO
ALTER TABLE [dbo].[TemplatesAvailable] CHECK CONSTRAINT [FK_TemplatesAvailable_ClinicalSummaryHeading]
GO
ALTER TABLE [dbo].[TemplatesAvailable]  WITH CHECK ADD  CONSTRAINT [FK_TemplatesAvailable_DocumentTemplate] FOREIGN KEY([DocumentTemplateId])
REFERENCES [dbo].[DocumentTemplate] ([DocumentTemplateId])
GO
ALTER TABLE [dbo].[TemplatesAvailable] CHECK CONSTRAINT [FK_TemplatesAvailable_DocumentTemplate]
GO
ALTER TABLE [dbo].[TemplatesAvailable]  WITH CHECK ADD  CONSTRAINT [FK_TemplatesAvailable_User] FOREIGN KEY([UserIdAvailableTo])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[TemplatesAvailable] CHECK CONSTRAINT [FK_TemplatesAvailable_User]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_AddressBook]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_PatientDebtor] FOREIGN KEY([PatientDebtorId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_PatientDebtor]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_Recall] FOREIGN KEY([RecallId])
REFERENCES [dbo].[Recall] ([Id])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_Recall]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_ToDo] FOREIGN KEY([LinkToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_ToDo]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_ToDoCategory] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[ToDoCategory] ([Id])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_ToDoCategory]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_User1] FOREIGN KEY([OriginatorUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_User1]
GO
ALTER TABLE [dbo].[ToDo]  WITH CHECK ADD  CONSTRAINT [FK_ToDo_User2] FOREIGN KEY([NotificationUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDo] CHECK CONSTRAINT [FK_ToDo_User2]
GO
ALTER TABLE [dbo].[ToDoAccessBy]  WITH CHECK ADD  CONSTRAINT [FK_ToDoAccessBy_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoAccessBy] CHECK CONSTRAINT [FK_ToDoAccessBy_ToDo]
GO
ALTER TABLE [dbo].[ToDoAccessBy]  WITH CHECK ADD  CONSTRAINT [FK_ToDoAccessBy_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoAccessBy] CHECK CONSTRAINT [FK_ToDoAccessBy_User]
GO
ALTER TABLE [dbo].[ToDoAccessBy]  WITH CHECK ADD  CONSTRAINT [FK_ToDoAccessBy_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[ToDoAccessBy] CHECK CONSTRAINT [FK_ToDoAccessBy_UserGroup]
GO
ALTER TABLE [dbo].[ToDoActionNote]  WITH CHECK ADD  CONSTRAINT [FK_ToDoActionNote_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoActionNote] CHECK CONSTRAINT [FK_ToDoActionNote_ToDo]
GO
ALTER TABLE [dbo].[ToDoActionNote]  WITH CHECK ADD  CONSTRAINT [FK_ToDoActionNote_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoActionNote] CHECK CONSTRAINT [FK_ToDoActionNote_User]
GO
ALTER TABLE [dbo].[ToDoChangeNote]  WITH CHECK ADD  CONSTRAINT [FK_ToDoChangeNote_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoChangeNote] CHECK CONSTRAINT [FK_ToDoChangeNote_ToDo]
GO
ALTER TABLE [dbo].[ToDoChangeNote]  WITH CHECK ADD  CONSTRAINT [FK_ToDoChangeNote_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoChangeNote] CHECK CONSTRAINT [FK_ToDoChangeNote_User]
GO
ALTER TABLE [dbo].[ToDoNextAction]  WITH CHECK ADD  CONSTRAINT [FK_ToDoNextAction_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoNextAction] CHECK CONSTRAINT [FK_ToDoNextAction_ToDo]
GO
ALTER TABLE [dbo].[ToDoNextAction]  WITH CHECK ADD  CONSTRAINT [FK_ToDoNextAction_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoNextAction] CHECK CONSTRAINT [FK_ToDoNextAction_User]
GO
ALTER TABLE [dbo].[ToDoNextAction]  WITH CHECK ADD  CONSTRAINT [FK_ToDoNextAction_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[ToDoNextAction] CHECK CONSTRAINT [FK_ToDoNextAction_UserGroup]
GO
ALTER TABLE [dbo].[ToDoOriginalTo]  WITH CHECK ADD  CONSTRAINT [FK_ToDoOriginalTo_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoOriginalTo] CHECK CONSTRAINT [FK_ToDoOriginalTo_ToDo]
GO
ALTER TABLE [dbo].[ToDoOriginalTo]  WITH CHECK ADD  CONSTRAINT [FK_ToDoOriginalTo_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoOriginalTo] CHECK CONSTRAINT [FK_ToDoOriginalTo_User]
GO
ALTER TABLE [dbo].[ToDoOriginalTo]  WITH CHECK ADD  CONSTRAINT [FK_ToDoOriginalTo_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[ToDoOriginalTo] CHECK CONSTRAINT [FK_ToDoOriginalTo_UserGroup]
GO
ALTER TABLE [dbo].[ToDoTemplateActionBy]  WITH CHECK ADD  CONSTRAINT [FK_ToDoTemplateActionBy_ToDoTemplate] FOREIGN KEY([ToDoTemplateId])
REFERENCES [dbo].[ToDoTemplate] ([Id])
GO
ALTER TABLE [dbo].[ToDoTemplateActionBy] CHECK CONSTRAINT [FK_ToDoTemplateActionBy_ToDoTemplate]
GO
ALTER TABLE [dbo].[ToDoTemplateActionBy]  WITH CHECK ADD  CONSTRAINT [FK_ToDoTemplateActionBy_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoTemplateActionBy] CHECK CONSTRAINT [FK_ToDoTemplateActionBy_User]
GO
ALTER TABLE [dbo].[ToDoTemplateActionBy]  WITH CHECK ADD  CONSTRAINT [FK_ToDoTemplateActionBy_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[ToDoTemplateActionBy] CHECK CONSTRAINT [FK_ToDoTemplateActionBy_UserGroup]
GO
ALTER TABLE [dbo].[ToDoTemplateAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_ToDoTemplateAvailableTo_ToDoTemplate] FOREIGN KEY([ToDoTemplateId])
REFERENCES [dbo].[ToDoTemplate] ([Id])
GO
ALTER TABLE [dbo].[ToDoTemplateAvailableTo] CHECK CONSTRAINT [FK_ToDoTemplateAvailableTo_ToDoTemplate]
GO
ALTER TABLE [dbo].[ToDoTemplateAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_ToDoTemplateAvailableTo_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoTemplateAvailableTo] CHECK CONSTRAINT [FK_ToDoTemplateAvailableTo_User]
GO
ALTER TABLE [dbo].[ToDoTemplateAvailableTo]  WITH CHECK ADD  CONSTRAINT [FK_ToDoTemplateAvailableTo_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[ToDoTemplateAvailableTo] CHECK CONSTRAINT [FK_ToDoTemplateAvailableTo_UserGroup]
GO
ALTER TABLE [dbo].[ToDoUnread]  WITH CHECK ADD  CONSTRAINT [FK_ToDoUnread_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoUnread] CHECK CONSTRAINT [FK_ToDoUnread_ToDo]
GO
ALTER TABLE [dbo].[ToDoUnread]  WITH CHECK ADD  CONSTRAINT [FK_ToDoUnread_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoUnread] CHECK CONSTRAINT [FK_ToDoUnread_User]
GO
ALTER TABLE [dbo].[ToDoUserAction]  WITH CHECK ADD  CONSTRAINT [FK_ToDoUserAction_ToDo] FOREIGN KEY([ToDoId])
REFERENCES [dbo].[ToDo] ([Id])
GO
ALTER TABLE [dbo].[ToDoUserAction] CHECK CONSTRAINT [FK_ToDoUserAction_ToDo]
GO
ALTER TABLE [dbo].[ToDoUserAction]  WITH CHECK ADD  CONSTRAINT [FK_ToDoUserAction_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ToDoUserAction] CHECK CONSTRAINT [FK_ToDoUserAction_User]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_Addressbook1] FOREIGN KEY([SendingOrganisationAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_Addressbook1]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_Addressbook2] FOREIGN KEY([SendingPersonAddressBookId])
REFERENCES [dbo].[AddressBook] ([AddressBookId])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_Addressbook2]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_MessageIn] FOREIGN KEY([MessageInId])
REFERENCES [dbo].[MessageIn] ([Id])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_MessageIn]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_PatientDebtor] FOREIGN KEY([PatientId])
REFERENCES [dbo].[PatientDebtor] ([Id])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_PatientDebtor]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_User] FOREIGN KEY([RecipientUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_User]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_User1] FOREIGN KEY([MatchedByUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_User1]
GO
ALTER TABLE [dbo].[UnmatchedMessageIn]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageIn_User2] FOREIGN KEY([DiscardedByUserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UnmatchedMessageIn] CHECK CONSTRAINT [FK_UnmatchedMessageIn_User2]
GO
ALTER TABLE [dbo].[UnmatchedMessageInAtomic]  WITH CHECK ADD  CONSTRAINT [FK_UnmatchedMessageInAtomic_UnmatchedMessageIn] FOREIGN KEY([UnmatchedMessageInId])
REFERENCES [dbo].[UnmatchedMessageIn] ([Id])
GO
ALTER TABLE [dbo].[UnmatchedMessageInAtomic] CHECK CONSTRAINT [FK_UnmatchedMessageInAtomic_UnmatchedMessageIn]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_EmailContact] FOREIGN KEY([EmailContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_EmailContact]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_FaxContact] FOREIGN KEY([FaxContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_FaxContact]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_HomePhoneContact] FOREIGN KEY([WorkPhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_HomePhoneContact]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_MobilePhoneContact] FOREIGN KEY([MobilePhoneContactId])
REFERENCES [dbo].[Contact] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_MobilePhoneContact]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_PersonName] FOREIGN KEY([LegalPersonNameId])
REFERENCES [dbo].[PersonName] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_PersonName]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_PostalAddress] FOREIGN KEY([PostalAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_PostalAddress]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_ResidentialAddress] FOREIGN KEY([ResidentialAddressId])
REFERENCES [dbo].[Address] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_ResidentialAddress]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_UserGroup]
GO
ALTER TABLE [dbo].[UserFundPayee]  WITH CHECK ADD  CONSTRAINT [FK_UserFundPayee_HealthFund] FOREIGN KEY([HealthFundUid])
REFERENCES [dbo].[HealthFund] ([Uid])
GO
ALTER TABLE [dbo].[UserFundPayee] CHECK CONSTRAINT [FK_UserFundPayee_HealthFund]
GO
ALTER TABLE [dbo].[UserFundPayee]  WITH CHECK ADD  CONSTRAINT [FK_UserFundPayee_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserFundPayee] CHECK CONSTRAINT [FK_UserFundPayee_User]
GO
ALTER TABLE [dbo].[UserGroupAlerts]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupAlerts_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[UserGroupAlerts] CHECK CONSTRAINT [FK_UserGroupAlerts_UserGroup]
GO
ALTER TABLE [dbo].[UserGroupOptions]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupOptions_UserGroup] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroup] ([Id])
GO
ALTER TABLE [dbo].[UserGroupOptions] CHECK CONSTRAINT [FK_UserGroupOptions_UserGroup]
GO
ALTER TABLE [dbo].[UserMailGroupUsers]  WITH CHECK ADD  CONSTRAINT [FK_UserMailGroupUsers_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserMailGroupUsers] CHECK CONSTRAINT [FK_UserMailGroupUsers_User]
GO
ALTER TABLE [dbo].[UserMailGroupUsers]  WITH CHECK ADD  CONSTRAINT [FK_UserMailGroupUsers_UserMailGroup] FOREIGN KEY([UserMailGroupId])
REFERENCES [dbo].[UserMailGroup] ([Id])
GO
ALTER TABLE [dbo].[UserMailGroupUsers] CHECK CONSTRAINT [FK_UserMailGroupUsers_UserMailGroup]
GO
ALTER TABLE [dbo].[UserOptions]  WITH CHECK ADD  CONSTRAINT [FK_UserOptions_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserOptions] CHECK CONSTRAINT [FK_UserOptions_User]
GO
ALTER TABLE [dbo].[UserOptionsQuickList]  WITH CHECK ADD  CONSTRAINT [FK_UserOptionsQuickList_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserOptionsQuickList] CHECK CONSTRAINT [FK_UserOptionsQuickList_User]
GO
ALTER TABLE [dbo].[UserProcess]  WITH CHECK ADD  CONSTRAINT [FK_UserProcess_User] FOREIGN KEY([UserIdAvailableTo])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserProcess] CHECK CONSTRAINT [FK_UserProcess_User]
GO
ALTER TABLE [dbo].[UserResource]  WITH CHECK ADD  CONSTRAINT [FK_UserResource_Resource] FOREIGN KEY([ResourceId])
REFERENCES [dbo].[Resource] ([Id])
GO
ALTER TABLE [dbo].[UserResource] CHECK CONSTRAINT [FK_UserResource_Resource]
GO
ALTER TABLE [dbo].[UserResource]  WITH CHECK ADD  CONSTRAINT [FK_UserResource_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserResource] CHECK CONSTRAINT [FK_UserResource_User]
GO
ALTER TABLE [dbo].[UserRoleAssign]  WITH CHECK ADD  CONSTRAINT [FK_UserRoleAssign_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserRoleAssign] CHECK CONSTRAINT [FK_UserRoleAssign_User]
GO
ALTER TABLE [dbo].[UserRoleAssign]  WITH CHECK ADD  CONSTRAINT [FK_UserRoleAssign_UserRole] FOREIGN KEY([UserRoleId])
REFERENCES [dbo].[UserRole] ([Id])
GO
ALTER TABLE [dbo].[UserRoleAssign] CHECK CONSTRAINT [FK_UserRoleAssign_UserRole]
GO
ALTER TABLE [dbo].[VaccineBatch]  WITH CHECK ADD  CONSTRAINT [FK_VaccineBatch_Vaccine] FOREIGN KEY([VaccineUid])
REFERENCES [dbo].[Vaccine] ([VaccineUid])
GO
ALTER TABLE [dbo].[VaccineBatch] CHECK CONSTRAINT [FK_VaccineBatch_Vaccine]
GO
ALTER TABLE [dbo].[VaccineGroupVaccine]  WITH CHECK ADD  CONSTRAINT [FK_VaccineGroupVaccine_Vaccine] FOREIGN KEY([VaccineUid])
REFERENCES [dbo].[Vaccine] ([VaccineUid])
GO
ALTER TABLE [dbo].[VaccineGroupVaccine] CHECK CONSTRAINT [FK_VaccineGroupVaccine_Vaccine]
GO
ALTER TABLE [dbo].[VaccineGroupVaccine]  WITH CHECK ADD  CONSTRAINT [FK_VaccineGroupVaccine_VaccineGroup] FOREIGN KEY([VaccineGroupId])
REFERENCES [dbo].[VaccineGroup] ([Id])
GO
ALTER TABLE [dbo].[VaccineGroupVaccine] CHECK CONSTRAINT [FK_VaccineGroupVaccine_VaccineGroup]
GO
ALTER TABLE [dbo].[WaitList]  WITH CHECK ADD  CONSTRAINT [FK_WaitList_Episode] FOREIGN KEY([EpisodeId])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[WaitList] CHECK CONSTRAINT [FK_WaitList_Episode]
GO
ALTER TABLE [dbo].[WorkstationFileImport]  WITH CHECK ADD  CONSTRAINT [FK_WorkstationFileImport_Workstation] FOREIGN KEY([WorkstationId])
REFERENCES [dbo].[Workstation] ([Id])
GO
ALTER TABLE [dbo].[WorkstationFileImport] CHECK CONSTRAINT [FK_WorkstationFileImport_Workstation]
GO
ALTER TABLE [dbo].[WorkstationFileImportFolder]  WITH CHECK ADD  CONSTRAINT [FK_WorkstationFileImportFolder_WorkstationFileImport] FOREIGN KEY([WorkstationFileImportId])
REFERENCES [dbo].[WorkstationFileImport] ([Id])
GO
ALTER TABLE [dbo].[WorkstationFileImportFolder] CHECK CONSTRAINT [FK_WorkstationFileImportFolder_WorkstationFileImport]
GO
ALTER TABLE [dbo].[WorkstationOptions]  WITH CHECK ADD  CONSTRAINT [FK_WorkstationOptions_Workstation] FOREIGN KEY([WorkstationId])
REFERENCES [dbo].[Workstation] ([Id])
GO
ALTER TABLE [dbo].[WorkstationOptions] CHECK CONSTRAINT [FK_WorkstationOptions_Workstation]
GO
ALTER TABLE [dbo].[WorkstationReport]  WITH CHECK ADD  CONSTRAINT [FK_WorkstationReport_Workstation] FOREIGN KEY([WorkstationId])
REFERENCES [dbo].[Workstation] ([Id])
GO
ALTER TABLE [dbo].[WorkstationReport] CHECK CONSTRAINT [FK_WorkstationReport_Workstation]
GO
USE [master]
GO
ALTER DATABASE [Stat] SET  READ_WRITE 
GO
