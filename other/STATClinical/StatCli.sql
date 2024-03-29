USE [master]
GO
/****** Object:  Database [StatClinical]    Script Date: 9/04/2019 12:40:16 AM ******/
CREATE DATABASE [StatClinical]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SH_4228', FILENAME = N'D:\STAT_Data\SQL\MSSQL11.STAT\MSSQL\DATA\StatClinical.mdf' , SIZE = 14550848KB , MAXSIZE = UNLIMITED, FILEGROWTH = 51200KB )
 LOG ON 
( NAME = N'SH_4228_log', FILENAME = N'D:\STAT_Data\SQL\MSSQL11.STAT\MSSQL\DATA\StatClinical_log.ldf' , SIZE = 103424KB , MAXSIZE = 2048GB , FILEGROWTH = 51200KB )
GO
ALTER DATABASE [StatClinical] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [StatClinical].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [StatClinical] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [StatClinical] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [StatClinical] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [StatClinical] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [StatClinical] SET ARITHABORT OFF 
GO
ALTER DATABASE [StatClinical] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [StatClinical] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [StatClinical] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [StatClinical] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [StatClinical] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [StatClinical] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [StatClinical] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [StatClinical] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [StatClinical] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [StatClinical] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [StatClinical] SET  DISABLE_BROKER 
GO
ALTER DATABASE [StatClinical] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [StatClinical] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [StatClinical] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [StatClinical] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [StatClinical] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [StatClinical] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [StatClinical] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [StatClinical] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [StatClinical] SET  MULTI_USER 
GO
ALTER DATABASE [StatClinical] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [StatClinical] SET DB_CHAINING OFF 
GO
ALTER DATABASE [StatClinical] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [StatClinical] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [StatClinical]
GO
/****** Object:  User [StatDB_DJR]    Script Date: 9/04/2019 12:40:16 AM ******/
CREATE USER [StatDB_DJR] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [PCLOUD\Distribution SH Stat SQL Database Admin Access]    Script Date: 9/04/2019 12:40:17 AM ******/
CREATE USER [PCLOUD\Distribution SH Stat SQL Database Admin Access]
GO
/****** Object:  User [NT AUTHORITY\NETWORK SERVICE]    Script Date: 9/04/2019 12:40:17 AM ******/
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [IIS APPPOOL\StatPool]    Script Date: 9/04/2019 12:40:17 AM ******/
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
/****** Object:  Table [dbo].[AddressBook_Document]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddressBook_Document](
	[AddressBookDocumentUid] [uniqueidentifier] NOT NULL,
	[stat_AddressBookId] [int] NOT NULL,
	[ManuscriptUid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AddressBook_Document] PRIMARY KEY CLUSTERED 
(
	[AddressBookDocumentUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Allergy]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Allergy](
	[AllergyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NULL,
	[stat_AddedToListUserId] [int] NOT NULL,
	[RemovedFromList] [int] NULL,
	[stat_RemovedFromListUserId] [int] NULL,
	[CommencedDateTime] [datetime] NULL,
	[CeasedDateTime] [datetime] NULL,
	[Description] [varchar](200) NULL,
	[Notes] [varchar](max) NULL,
	[Severity] [int] NULL,
	[AllergyType] [int] NULL,
	[AllergenReferenceGuid] [uniqueidentifier] NULL,
	[ConvertedUnlinked] [int] NULL,
	[ProdCode] [int] NULL,
	[FormCode] [int] NULL,
	[PackCode] [int] NULL,
	[FDBDrugType] [int] NULL,
	[FDBId] [varchar](20) NULL,
	[AllergenGroupId] [int] NULL,
	[AddedToListDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[RecordedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[RemovedFromListDateTimeOffset] [datetimeoffset](7) NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Allergy] PRIMARY KEY CLUSTERED 
(
	[AllergyUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Annotation]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Annotation](
	[AnnotationUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[ItemUid] [uniqueidentifier] NOT NULL,
	[Stat_UserId] [int] NOT NULL,
	[AnnotationType] [int] NOT NULL,
	[AnnotationText] [varchar](max) NULL,
	[AnnotationDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Annotation] PRIMARY KEY CLUSTERED 
(
	[AnnotationUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BloodGlucose]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BloodGlucose](
	[BloodGlucoseUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[stat_UserId] [int] NULL,
	[BloodGlucoseLevel] [float] NOT NULL,
	[TargetRangeUpper] [float] NULL,
	[TargetRangeLower] [float] NULL,
	[Fasting] [bit] NULL,
	[Inactive] [bit] NOT NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_BloodGlucose] PRIMARY KEY CLUSTERED 
(
	[BloodGlucoseUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BloodPressure]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BloodPressure](
	[BloodPressureUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[stat_UserId] [int] NOT NULL,
	[Systolic] [int] NULL,
	[Diastolic] [int] NULL,
	[Pulse] [int] NULL,
	[Position] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[Inactive] [bit] NOT NULL,
	[Origin] [int] NOT NULL,
	[PositionId] [int] NOT NULL,
	[HeartbeatType] [int] NOT NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_BloodPressure] PRIMARY KEY CLUSTERED 
(
	[BloodPressureUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CardiovascularRisk]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CardiovascularRisk](
	[CardiovascularRiskUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[stat_UserId] [int] NULL,
	[Age] [int] NOT NULL,
	[Smoker] [bit] NOT NULL,
	[Diabetes] [bit] NOT NULL,
	[SystolicBP] [float] NOT NULL,
	[TotalCholesterol] [float] NOT NULL,
	[HDLCholesterol] [float] NOT NULL,
	[RiskLevel] [int] NOT NULL,
	[Inactive] [bit] NOT NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_CardiovascularRisk] PRIMARY KEY CLUSTERED 
(
	[CardiovascularRiskUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CardiovascularRiskValues]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CardiovascularRiskValues](
	[Age] [int] NOT NULL,
	[Smoker] [bit] NOT NULL,
	[Diabetes] [bit] NOT NULL,
	[Gender] [varchar](6) NOT NULL,
	[CholesterolRatio] [int] NOT NULL,
	[DiastolicBP] [float] NOT NULL,
	[SystolicBP] [float] NOT NULL,
	[RiskLevel] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalAlert]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalAlert](
	[ClinicalAlertUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[Alert] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ClinicalAlert] PRIMARY KEY CLUSTERED 
(
	[ClinicalAlertUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalNote]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClinicalNote](
	[NoteUid] [uniqueidentifier] NOT NULL,
	[stat_UserIdEnteredBy] [int] NOT NULL,
	[AttachmentUid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ClinicalRequest]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalRequest](
	[RequestUid] [uniqueidentifier] NOT NULL,
	[OurReference] [int] IDENTITY(1,1) NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[stat_AddressBookId] [int] NOT NULL,
	[PhoneFaxNumber] [varchar](50) NULL,
	[RequestNumber] [int] NULL,
	[ClinicalNotes] [varchar](2500) NULL,
	[RequestDate] [datetime] NOT NULL,
	[stat_UserIdRequesting] [int] NOT NULL,
	[Removed] [int] NULL,
	[Completed] [int] NULL,
	[Stat_UserIdCompleted] [int] NULL,
	[CompleteDate] [datetime] NULL,
	[ShowOnAuditReport] [bit] NULL,
	[DueDate] [datetime] NULL,
	[NoReportToMHR] [int] NULL,
 CONSTRAINT [PK_ClinicalRequest] PRIMARY KEY CLUSTERED 
(
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalRequestCopyDoctor]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClinicalRequestCopyDoctor](
	[Uid] [uniqueidentifier] NOT NULL,
	[RequestUid] [uniqueidentifier] NOT NULL,
	[stat_AddressBookId] [int] NOT NULL,
 CONSTRAINT [PK_ClinicalRequestCopyDoctor] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ClinicalResult]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalResult](
	[ClinicalResultUid] [uniqueidentifier] NOT NULL,
	[RunNumber] [varchar](15) NULL,
	[Laboratory] [varchar](180) NULL,
	[NATALabNumber] [varchar](250) NULL,
	[OurReference] [int] NULL,
	[LaboratoryReference] [varchar](250) NULL,
	[ReceivingDrCodeOrProviderNo] [varchar](10) NULL,
	[LaboratoryNumber] [varchar](250) NULL,
	[TestCode] [varchar](60) NULL,
	[CopyDoctors] [varchar](1000) NULL,
	[IsCopy] [int] NULL,
	[RequestCompleted] [int] NULL,
	[HL7Data] [varchar](max) NULL,
	[PITData] [varchar](max) NULL,
	[DisplayData] [varchar](max) NULL,
	[FailedAutoMatch] [int] NOT NULL,
	[SurgeryId] [varchar](5) NULL,
	[Pathologist] [varchar](120) NULL,
	[PathologistPhone] [varchar](12) NULL,
	[OrderingDoctorName] [varchar](120) NULL,
	[ReferringDoctorName] [varchar](120) NULL,
	[ReferringDoctorProviderNo] [varchar](10) NULL,
	[SpecimenType] [varchar](60) NULL,
	[ConfidentialityIndicator] [varchar](1) NULL,
	[NormalResultIndicator] [varchar](1) NOT NULL,
	[UrgentRequestIndicator] [varchar](1) NOT NULL,
	[RequestedTests] [varchar](1000) NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[FacilityAddressBookId] [int] NULL,
	[FacilityType] [int] NULL,
	[UserId] [int] NULL,
	[ManualMatchUserId] [int] NULL,
	[Reviewed] [int] NOT NULL,
	[RequestUid] [uniqueidentifier] NULL,
	[Removed] [int] NULL,
	[ClinicalResultFormat] [int] NULL,
	[FileStoreId] [int] NULL,
	[OriginalPatientName] [varchar](250) NULL,
	[OriginalDOB] [datetime] NULL,
	[DisplayBlob] [varbinary](max) NULL,
	[DisplayBlobFileExtension] [varchar](12) NULL,
	[CollectionDateTimeOffset] [datetimeoffset](7) NULL,
	[ManualMatchDateTimeOffset] [datetimeoffset](7) NULL,
	[ReportDateTimeOffset] [datetimeoffset](7) NULL,
	[RequestDateTimeOffset] [datetimeoffset](7) NULL,
	[ResultImportDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[RunDateTimeOffset] [datetimeoffset](7) NULL,
	[EncounterUid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PathologyResult] PRIMARY KEY CLUSTERED 
(
	[ClinicalResultUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicalResultAtomic]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicalResultAtomic](
	[ClinicalResultAtomicUid] [uniqueidentifier] NOT NULL,
	[ClinicalResultUid] [uniqueidentifier] NOT NULL,
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
 CONSTRAINT [PK_PathologyResultAtomic] PRIMARY KEY CLUSTERED 
(
	[ClinicalResultAtomicUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Condition]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Condition](
	[ConditionUid] [uniqueidentifier] NOT NULL,
	[ICPCCode] [char](3) NULL,
	[ICPCTermCode] [char](3) NULL,
	[Description] [varchar](50) NOT NULL,
	[DateCommenced] [datetime] NOT NULL,
	[DateExpired] [datetime] NULL,
	[OriginalConditionUid] [uniqueidentifier] NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[Notes] [varchar](2000) NULL,
	[stat_UserId] [int] NOT NULL,
	[ICPCKeyId] [int] NULL,
	[ICPCTermId] [int] NULL,
	[Significant] [int] NULL,
	[UploadToPcehr] [int] NULL,
	[NilKnown] [int] NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[LastReviewedDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Condition] PRIMARY KEY CLUSTERED 
(
	[ConditionUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CopyDoctor]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CopyDoctor](
	[CopyDoctorUid] [uniqueidentifier] NOT NULL,
	[ParentUid] [uniqueidentifier] NOT NULL,
	[stat_AddressBookId] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[SendMessage] [int] NULL,
	[stat_MessageOutId] [int] NULL,
	[SendMessageError] [varchar](max) NULL,
	[CopyAddedLater] [int] NULL,
 CONSTRAINT [PK_CopyDoctor] PRIMARY KEY CLUSTERED 
(
	[CopyDoctorUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Correspondence]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Correspondence](
	[CorrespondenceUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[ManuscriptUid] [uniqueidentifier] NOT NULL,
	[OriginalCorrespondenceUid] [uniqueidentifier] NULL,
	[VersionNumber] [int] NULL,
	[Description] [varchar](250) NULL,
	[Incoming] [int] NOT NULL,
	[ShowOutsideClinical] [int] NULL,
	[DocumentType] [int] NOT NULL,
	[DocumentCategoryId] [int] NULL,
	[stat_ClinicalSummaryHeadingId] [int] NULL,
	[stat_OutgoingRecipientAddressBookId] [int] NULL,
	[stat_OutgoingAuthorProviderId] [int] NULL,
	[DraftStatus] [int] NULL,
	[stat_DraftNextActionUserId] [int] NULL,
	[stat_EditedByUserId] [int] NULL,
	[stat_IncomingRecipientUserId] [int] NULL,
	[ReviewRequired] [int] NULL,
	[ReviewFinalized] [int] NULL,
	[Body] [varchar](max) NULL,
	[Removed] [int] NULL,
	[stat_OwnerId] [int] NULL,
	[stat_UserId] [int] NOT NULL,
	[stat_OutgoingAuthorUserId] [int] NULL,
	[stat_SendingOrganisationAddressBookId] [int] NULL,
	[stat_SendingPersonAddressBookId] [int] NULL,
	[IsEditableInExternalEditorOnly] [bit] NOT NULL,
	[CreatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[stat_MessageInId] [int] NULL,
	[stat_UnmatchedMessageInId] [int] NULL,
	[IsElectronicallySendable] [int] NULL,
	[SendMessage] [int] NULL,
	[stat_MessageOutId] [int] NULL,
	[SendMessageError] [varchar](max) NULL,
 CONSTRAINT [PK_Correspondence] PRIMARY KEY CLUSTERED 
(
	[CorrespondenceUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentMedication]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentMedication](
	[CurrentMedicationUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NULL,
	[stat_AddedToListUserId] [int] NOT NULL,
	[RemovedFromList] [int] NULL,
	[stat_RemovedFromListUserId] [int] NULL,
	[ConvertedUnlinked] [int] NULL,
	[ProdCode] [int] NULL,
	[FormCode] [int] NULL,
	[PackCode] [int] NULL,
	[DrugDescription] [varchar](500) NOT NULL,
	[Quantity] [int] NULL,
	[Dosage] [varchar](max) NULL,
	[Repeats] [int] NULL,
	[PBS] [int] NULL,
	[RPBS] [int] NULL,
	[Authority] [int] NULL,
	[AuthorityApprovalType] [int] NULL,
	[AuthorityCode] [varchar](20) NULL,
	[AuthorityIndication] [varchar](max) NULL,
	[AuthorityIndicationId] [int] NULL,
	[Reg24] [int] NULL,
	[S8] [int] NULL,
	[BrandSubstitutionNotPermitted] [int] NULL,
	[SingleDrug] [int] NULL,
	[stat_LastPrescribedUserId] [int] NULL,
	[LastAuthorityIndicationId] [int] NULL,
	[CurrentPeriod] [int] NULL,
	[ToBePrescribed] [int] NULL,
	[DrugName] [varchar](200) NULL,
	[Form] [varchar](200) NULL,
	[Strength] [varchar](200) NULL,
	[FDBDrugType] [int] NULL,
	[FDBId] [varchar](20) NULL,
	[TransmitScript] [int] NULL,
	[CTG] [int] NULL,
	[NilKnown] [int] NULL,
	[LastAuthorityIndication] [varchar](max) NULL,
	[AddedToListDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[LastPrescribedDateTimeOffset] [datetimeoffset](7) NULL,
	[RemovedFromListDateTimeOffset] [datetimeoffset](7) NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[s11] [int] NULL,
 CONSTRAINT [PK_CurrentMedication] PRIMARY KEY CLUSTERED 
(
	[CurrentMedicationUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CurrentMedicationSchedule]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurrentMedicationSchedule](
	[Uid] [uniqueidentifier] NOT NULL,
	[CurrentMedicationUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[Breakfast] [varchar](250) NULL,
	[Lunch] [varchar](250) NULL,
	[Dinner] [varchar](250) NULL,
	[BedTime] [varchar](250) NULL,
	[Instructions] [varchar](max) NULL,
	[DoNotInclude] [bit] NOT NULL,
 CONSTRAINT [PK_CurrentMedicationSchedule] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DiabetesCare]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DiabetesCare](
	[DiabetesUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[stat_UserId] [int] NOT NULL,
	[DiabetesType] [int] NULL,
	[DiabetesTypeLastDiagnosed] [datetime] NULL,
	[DiabetesManagement] [int] NULL,
	[DiabetesManagementLastDetermined] [datetime] NULL,
	[Weight] [float] NULL,
	[WeightLastMeasured] [datetime] NULL,
	[Height] [float] NULL,
	[HeightLastMeasured] [datetime] NULL,
	[Waist] [float] NULL,
	[WaistLastMeasured] [datetime] NULL,
	[Systolic] [float] NULL,
	[BPPosition] [int] NULL,
	[SystolicLastMeasured] [datetime] NULL,
	[Diastolic] [float] NULL,
	[DiastolicLastMeasured] [datetime] NULL,
	[Pulse] [float] NULL,
	[PulseLastMeasured] [datetime] NULL,
	[HeartBeatType] [int] NULL,
	[BloodGlucose] [float] NULL,
	[BloodGlucoseLastMeasured] [datetime] NULL,
	[BloodGlucoseFasting] [int] NULL,
	[Pregnant] [int] NULL,
	[WeeksPregnant] [int] NULL,
	[DaysPregnant] [int] NULL,
	[PregnantLastDetermined] [datetime] NULL,
	[SignOfOedema] [int] NULL,
	[SignOfOedemaExamDate] [datetime] NULL,
	[SevereHypoglycaemicAttacks] [int] NULL,
	[SevereHypoglycaemicAttackLastDetermined] [datetime] NULL,
	[DailyPhysicalActivity] [int] NULL,
	[DailyPhysicalActivityLastDetermined] [datetime] NULL,
	[Notes] [varchar](max) NULL,
	[TotalCholesterol] [float] NULL,
	[TotalCholesterolLastMeasured] [datetime] NULL,
	[HDL] [float] NULL,
	[HDLLastMeasured] [datetime] NULL,
	[LDL] [float] NULL,
	[LDLLastMeasured] [datetime] NULL,
	[Triglycerides] [float] NULL,
	[TriglyceridesLastMeasured] [datetime] NULL,
	[HbA1C] [float] NULL,
	[HbA1CLastMeasured] [datetime] NULL,
	[MicroAlbuminuria] [float] NULL,
	[MicroAlbuminuriaUnits] [int] NULL,
	[MicroAlbuminuriaLastMeasured] [datetime] NULL,
	[eGFR] [float] NULL,
	[eGFRLastMeasured] [datetime] NULL,
	[SmokingStatus] [int] NULL,
	[SmokingStatusLastDetermined] [datetime] NULL,
	[SmokingPreference] [int] NULL,
	[SmokingFrequency] [int] NULL,
	[SmokingStarted] [datetime] NULL,
	[SmokingStopped] [datetime] NULL,
	[CurrentAlcoholIntake] [int] NULL,
	[CurrentAlcoholIntakeLastDetermined] [datetime] NULL,
	[StandardDrinksPerDay] [float] NULL,
	[StandardDrinksDaysPerWeek] [float] NULL,
	[PastAlcoholIntake] [int] NULL,
	[DrinkingStarted] [datetime] NULL,
	[DrinkingStopped] [datetime] NULL,
	[LastHealthAssessment] [datetime] NULL,
	[LastCarePlan] [datetime] NULL,
	[LastCaseConference] [datetime] NULL,
	[FeetSelfCare] [int] NULL,
	[FeetExamDate] [datetime] NULL,
	[LeftFootDeformity] [int] NULL,
	[LeftFootLesion] [int] NULL,
	[LeftFootUlcer] [int] NULL,
	[LeftFootVascularDisease] [int] NULL,
	[LeftFootPeripheralNeuropathy] [int] NULL,
	[RightFootDeformity] [int] NULL,
	[RightFootLesion] [int] NULL,
	[RightFootUlcer] [int] NULL,
	[RightFootVascularDisease] [int] NULL,
	[RightFootPeripheralNeuropathy] [int] NULL,
	[OnInsulin] [int] NULL,
	[EyeExamDate] [datetime] NULL,
	[LeftEyeCondition] [int] NULL,
	[LeftEyeCataracts] [int] NULL,
	[RightEyeCondition] [int] NULL,
	[RightEyeCataracts] [int] NULL,
	[EndocrinologistId] [int] NULL,
	[EndocrinologistExamDate] [datetime] NULL,
	[OphthalmologistId] [int] NULL,
	[OphthalmologistExamDate] [datetime] NULL,
	[DiabetesEducatorId] [int] NULL,
	[DiabetesEducatorExamDate] [datetime] NULL,
	[DietitianId] [int] NULL,
	[DietitianExamDate] [datetime] NULL,
	[PodiatristId] [int] NULL,
	[PodiatristExamDate] [datetime] NULL,
	[ExerciseProfessionalId] [int] NULL,
	[ExerciseProfessionalExamDate] [datetime] NULL,
	[OralHealthProfessionalId] [int] NULL,
	[OralHealthProfessionalExamDate] [datetime] NULL,
	[PhysiotherapistId] [int] NULL,
	[PhysiotherapistExamDate] [datetime] NULL,
	[HbA1CCategoryCode] [int] NULL,
	[RecreationalDrugUsageLastDetermined] [datetime] NULL,
	[SmokingNotes] [varchar](max) NULL,
	[DrinkingStandardDrinksPerDay] [int] NULL,
	[DrinkingDaysPerWeek] [int] NULL,
	[DrinkingNotes] [varchar](max) NULL,
	[RecreationalDrugUsage] [int] NULL,
	[DrugNotes] [varchar](max) NULL,
	[BloodGlucoseStringValue] [varchar](30) NULL,
	[TotalCholesterolStringValue] [varchar](30) NULL,
	[HDLStringValue] [varchar](30) NULL,
	[LDLStringValue] [varchar](30) NULL,
	[TriglyceridesStringValue] [varchar](30) NULL,
	[HbA1CStringValue] [varchar](30) NULL,
	[MicroAlbuminuriaStringValue] [varchar](30) NULL,
	[eGFRStringValue] [varchar](30) NULL,
	[ReviewDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[OptometristId] [int] NULL,
	[OptometristExamDate] [datetime] NULL,
	[AnnualCycleOfCare] [datetime] NULL,
 CONSTRAINT [PK_DiabetesCare] PRIMARY KEY CLUSTERED 
(
	[DiabetesUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Encounter]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Encounter](
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[stat_Committer_Id] [int] NOT NULL,
	[stat_Composer_Id] [int] NOT NULL,
	[stat_ProviderId] [int] NULL,
	[CommitterType] [varchar](50) NOT NULL,
	[ComposerType] [varchar](50) NOT NULL,
	[stat_EpisodeId] [int] NOT NULL,
	[EncounterDescription] [varchar](250) NULL,
	[Removed] [int] NULL,
	[TentativeEncounter] [int] NULL,
	[CompleteDateTimeOffset] [datetimeoffset](7) NULL,
	[StartDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Encounter] PRIMARY KEY CLUSTERED 
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Encounter_Condition]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Encounter_Condition](
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[ConditionUid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Encounter_Condition] PRIMARY KEY CLUSTERED 
(
	[EncounterUid] ASC,
	[ConditionUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EncounterNotes]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EncounterNotes](
	[NotesUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[stat_UserId] [int] NOT NULL,
	[ManuscriptUid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_EncounterNotes] PRIMARY KEY CLUSTERED 
(
	[NotesUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HealthIndicators]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HealthIndicators](
	[EhrUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NULL,
	[stat_UserIdUpdated] [int] NOT NULL,
	[CeasedSmoking] [datetime] NULL,
	[AlcoholNotes] [varchar](250) NULL,
	[SmokingStatus] [int] NULL,
	[SmokingPreference] [int] NULL,
	[SmokingFrequency] [int] NULL,
	[SmokingStarted] [datetime] NULL,
	[SmokingStopped] [datetime] NULL,
	[SmokingNotes] [varchar](max) NULL,
	[CurrentAlcoholIntake] [int] NULL,
	[DrinkingStandardDrinksPerDay] [int] NULL,
	[DrinkingDaysPerWeek] [int] NULL,
	[PastAlcoholIntake] [int] NULL,
	[DrinkingStarted] [datetime] NULL,
	[DrinkingStopped] [datetime] NULL,
	[DrinkingNotes] [varchar](max) NULL,
	[RecreationalDrugUsage] [int] NULL,
	[DrugNotes] [varchar](max) NULL,
	[Smoking] [int] NULL,
	[CigsPerDay] [int] NULL,
	[Alcohol] [int] NULL,
	[DrinksPerDay] [int] NULL,
	[Drugs] [int] NULL,
	[UpdatedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[Uid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_HealthIndicators] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HeightWeights]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HeightWeights](
	[HeightWeightsUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[stat_UserId] [int] NULL,
	[HeightWeightType] [int] NOT NULL,
	[Height] [float] NULL,
	[Weight] [float] NULL,
	[Length] [float] NULL,
	[HeadCircumference] [float] NULL,
	[WaistCircumference] [float] NULL,
	[Description] [varchar](500) NULL,
	[Inactive] [bit] NOT NULL,
	[DiseaseRisk] [varchar](25) NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_HeightWeights] PRIMARY KEY CLUSTERED 
(
	[HeightWeightsUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IncomingReview]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncomingReview](
	[IncomingReviewUid] [uniqueidentifier] NOT NULL,
	[CorrespondenceUid] [uniqueidentifier] NULL,
	[ClinicalResultUid] [uniqueidentifier] NULL,
	[IncomingReviewType] [int] NOT NULL,
	[ReviewNumberType] [int] NOT NULL,
	[ReviewedByUserId] [int] NOT NULL,
	[ReviewDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[UnreviewDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_IncomingReview] PRIMARY KEY CLUSTERED 
(
	[IncomingReviewUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[INRRecords]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[INRRecords](
	[Uid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[stat_UserId] [int] NOT NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[Reason] [varchar](100) NOT NULL,
	[Origin] [int] NOT NULL,
	[TargetINRFrom] [float] NOT NULL,
	[TargetINRTo] [float] NOT NULL,
	[ActualINR] [float] NOT NULL,
	[CurrentDose] [varchar](50) NULL,
	[NewDose] [varchar](50) NULL,
	[NextTestWeeks] [int] NULL,
	[NextTestDays] [int] NULL,
	[Notes] [varchar](max) NULL,
	[Removed] [bit] NOT NULL,
 CONSTRAINT [PK_INRRecords] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Lactation]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lactation](
	[LactationUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NULL,
	[Lactating] [int] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Lactation] PRIMARY KEY CLUSTERED 
(
	[LactationUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Manuscript]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Manuscript](
	[ManuscriptUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[OriginalPathname] [varchar](500) NULL,
	[ManuscriptStatusType] [int] NULL,
	[KeyWords] [varchar](250) NULL,
	[Description] [varchar](100) NULL,
	[CreatedDateTime] [datetime] NULL,
	[ManuscriptAttachmentUid] [uniqueidentifier] NULL,
	[AttachmentSize] [bigint] NOT NULL,
	[PlainText] [varchar](max) NULL,
	[PDFManuscriptAttachmentUid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Manuscript] PRIMARY KEY CLUSTERED 
(
	[ManuscriptUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ManuscriptAnswer]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ManuscriptAnswer](
	[ManuscriptAnswerUid] [uniqueidentifier] NOT NULL,
	[ManuscriptUid] [uniqueidentifier] NOT NULL,
	[SnippetUid] [varchar](160) NOT NULL,
	[AnswerString] [varchar](max) NULL,
	[AnswerInt1] [int] NULL,
	[AnswerInt2] [int] NULL,
	[AnswerDateTime] [datetime] NULL,
	[AnswerBool] [int] NULL,
 CONSTRAINT [PK_ManuscriptAnswer] PRIMARY KEY CLUSTERED 
(
	[ManuscriptAnswerUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ManuscriptAttachment]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ManuscriptAttachment](
	[ManuscriptAttachmentUid] [uniqueidentifier] NOT NULL,
	[Blob] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_ManuscriptAttachment] PRIMARY KEY CLUSTERED 
(
	[ManuscriptAttachmentUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicalTest]    Script Date: 9/04/2019 12:40:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicalTest](
	[TestUid] [uniqueidentifier] NOT NULL,
	[DeviceIdentifier] [varchar](50) NOT NULL,
	[TestId] [varchar](50) NULL,
	[MedicalTestType] [int] NOT NULL,
	[TestDate] [datetime] NOT NULL,
	[UserComment] [varchar](max) NULL,
	[Interpretation] [varchar](max) NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[RecordedBy] [int] NOT NULL,
	[TestFileName] [varchar](max) NULL,
	[TestResults] [varbinary](max) NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[Removed] [int] NULL,
 CONSTRAINT [PK_MedicalTest] PRIMARY KEY CLUSTERED 
(
	[TestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PathologyRequest]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PathologyRequest](
	[RequestUid] [uniqueidentifier] NOT NULL,
	[BillingMethod] [int] NOT NULL,
	[CervicalCytologySite] [int] NOT NULL,
	[AppearanceCervix] [int] NOT NULL,
	[Urgency] [int] NOT NULL,
	[Fasting] [int] NOT NULL,
	[PostNatal] [bit] NOT NULL,
	[PostMenopausal] [bit] NOT NULL,
	[Radiotherapy] [bit] NOT NULL,
	[IUCD] [bit] NOT NULL,
	[AbnormalBleed] [bit] NOT NULL,
	[Pregnant] [bit] NOT NULL,
	[HormoneTherapy] [bit] NOT NULL,
	[PostOperative] [bit] NOT NULL,
	[LNMP] [datetime] NULL,
	[EDC] [datetime] NULL,
	[GestationalAge] [int] NULL,
	[UrgentBy] [varchar](50) NULL,
	[UrgentContactType] [int] NOT NULL,
	[PrivacyRequest] [bit] NOT NULL,
	[HospitalStatus] [int] NULL,
	[Rule3Exemption] [bit] NOT NULL,
	[Frequency] [varchar](50) NULL,
	[Duration] [varchar](50) NULL,
 CONSTRAINT [PK_PathologyRequest] PRIMARY KEY CLUSTERED 
(
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PathologyRequestTest]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PathologyRequestTest](
	[PathologyRequestTestUid] [uniqueidentifier] NOT NULL,
	[RequestUid] [uniqueidentifier] NOT NULL,
	[TestRequested] [varchar](max) NOT NULL,
 CONSTRAINT [PK_PathologyRequestTest] PRIMARY KEY CLUSTERED 
(
	[PathologyRequestTestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PcehrUploadedDocument]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PcehrUploadedDocument](
	[PcehrUploadedDocumentUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[DocumentId] [varchar](60) NULL,
	[CorrespondenceUid] [uniqueidentifier] NULL,
	[stat_UploadedUserId] [int] NULL,
	[stat_RemovedUserId] [int] NULL,
	[DocumentXml] [varchar](max) NULL,
	[RemovedDateTimeOffset] [datetimeoffset](7) NULL,
	[UploadedDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PcehrUploadedDocument] PRIMARY KEY CLUSTERED 
(
	[PcehrUploadedDocumentUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyAneuploidyScreening]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyAneuploidyScreening](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[NiptDiscussed] [bit] NOT NULL,
	[NiptPerformed] [bit] NOT NULL,
	[NiptResults] [varchar](200) NULL,
	[CombinedFirstTriScreeningDiscussed] [bit] NOT NULL,
	[CombinedFirstTriScreeningPerformed] [bit] NOT NULL,
	[CombinedFirstTriScreeningResults] [varchar](200) NULL,
	[PgdDiscussed] [bit] NOT NULL,
	[PgdPerformed] [bit] NOT NULL,
	[PgdResults] [varchar](200) NULL,
	[CvsAmnioDiscussed] [bit] NOT NULL,
	[CvsAmnioPerformed] [bit] NOT NULL,
	[CvsAmnioResults] [varchar](200) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyAneuploidyScreening] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyCalculation]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyCalculation](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[PregnantMethod] [int] NULL,
	[CalculationDate] [datetime] NULL,
	[CycleLength] [int] NOT NULL,
	[ScanDays] [int] NULL,
	[DeliveredNotCompleted] [bit] NOT NULL,
	[Complete] [bit] NOT NULL,
	[PregnancyInactive] [bit] NOT NULL,
	[PregnancyInactiveReason] [varchar](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[CompletedDateTimeOffset] [datetimeoffset](7) NULL,
	[PregnancyInactiveDateTimeOffset] [datetimeoffset](7) NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyCalculation] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyFetusGender]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyFetusGender](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[FetusNumber] [int] NOT NULL,
	[Gender] [int] NULL,
	[DoesNotWishToKnow] [bit] NOT NULL,
	[Notes] [varchar](max) NULL,
	[Removed] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyFetusGender] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyInvestigation]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyInvestigation](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[FirstTrimesterDate] [datetime] NULL,
	[SecondTrimesterDate] [datetime] NULL,
	[ThirdTrimesterDate] [datetime] NULL,
	[MCV] [int] NULL,
	[Hb1] [int] NULL,
	[Hb2] [int] NULL,
	[Hb3] [int] NULL,
	[Platelets1] [int] NULL,
	[Platelets2] [int] NULL,
	[Platelets3] [int] NULL,
	[AntibodyScreen1] [int] NULL,
	[AntibodyScreen2] [int] NULL,
	[AntibodyScreen3] [int] NULL,
	[GTT1] [int] NULL,
	[GTT2] [int] NULL,
	[VitaminD1] [varchar](200) NULL,
	[VitaminD2] [varchar](200) NULL,
	[AntiD2] [bit] NOT NULL,
	[AntiD3] [bit] NOT NULL,
	[GBS] [int] NULL,
	[BloodGroup] [int] NULL,
	[Syphilis] [int] NULL,
	[HIV] [int] NULL,
	[HepatitisB] [int] NULL,
	[HepatitisC] [int] NULL,
	[VZV] [int] NULL,
	[MSU] [int] NULL,
	[PappA] [int] NULL,
	[Rubella] [int] NULL,
	[Toxo] [int] NULL,
	[Parvovirus] [int] NULL,
	[CMV] [int] NULL,
	[TFT] [int] NULL,
	[Chlamydia] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyInvestigation] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyNeonatalRecord]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PregnancyNeonatalRecord](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[OutcomeUid] [uniqueidentifier] NOT NULL,
	[Weight] [int] NULL,
	[Feeding] [int] NULL,
	[HadPaediatricVisit] [bit] NOT NULL,
	[PaediatricVisitResult] [int] NULL,
	[Removed] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyNeonatalRecord] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PregnancyNew]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PregnancyNew](
	[Uid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PregnancyNew] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PregnancyOutcome]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyOutcome](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[BirthOrder] [int] NOT NULL,
	[Name] [varchar](40) NULL,
	[DateTime] [datetime] NULL,
	[GestationalAgeDays] [int] NULL,
	[Gender] [int] NULL,
	[Weight] [int] NULL,
	[Length] [float] NULL,
	[HeadCircumference] [float] NULL,
	[Apgar1] [int] NULL,
	[Apgar5] [int] NULL,
	[Labour] [int] NULL,
	[Delivery] [int] NULL,
	[Outcome] [int] NULL,
	[Feeding] [int] NULL,
	[AccoucherAddressBookId] [int] NULL,
	[PaediatricianAddressBookId] [int] NULL,
	[AnaesthetistAddressBookId] [int] NULL,
	[CustomAccoucher] [varchar](100) NULL,
	[CustomPaediatrician] [varchar](100) NULL,
	[CustomAnaesthetist] [varchar](100) NULL,
	[Notes] [varchar](max) NULL,
	[Removed] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyOutcome] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyOutcomeMaternal]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PregnancyOutcomeMaternal](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[PerinealStatus] [int] NULL,
	[Placenta] [int] NULL,
	[AntiD] [int] NULL,
	[EBL] [int] NULL,
	[AnalgesiaTypeNone] [bit] NOT NULL,
	[AnalgesiaTypeNitrous] [bit] NOT NULL,
	[AnalgesiaTypeOpioid] [bit] NOT NULL,
	[AnalgesiaTypePudendal] [bit] NOT NULL,
	[AnalgesiaTypeSpinal] [bit] NOT NULL,
	[AnalgesiaTypeEpidural] [bit] NOT NULL,
	[AnalgesiaTypeGA] [bit] NOT NULL,
	[AnalgesiaTypeOther] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyOutcomeMaternal] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PregnancyPhysicalExam]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyPhysicalExam](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[BreastsResult] [int] NULL,
	[BreastsNotes] [varchar](200) NULL,
	[ThyroidResult] [int] NULL,
	[ThyroidNotes] [varchar](200) NULL,
	[HeartSoundsResult] [int] NULL,
	[HeartSoundsNotes] [varchar](200) NULL,
	[ChestResult] [int] NULL,
	[ChestNotes] [varchar](200) NULL,
	[AbdomenResult] [int] NULL,
	[AbdomenNotes] [varchar](200) NULL,
	[PelvisResult] [int] NULL,
	[PelvisNotes] [varchar](200) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyPhysicalExam] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyPostnatal]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyPostnatal](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[ReviewDate] [datetime] NOT NULL,
	[HistoryLochia] [int] NULL,
	[HistoryPerineum] [int] NULL,
	[HistoryBladder] [int] NULL,
	[HistoryBowels] [int] NULL,
	[HistoryBreasts] [int] NULL,
	[HistoryMenses] [int] NULL,
	[HistoryIntercourse] [int] NULL,
	[ExaminationBp] [varchar](100) NULL,
	[ExaminationPerineum] [int] NULL,
	[ExaminationBreasts] [int] NULL,
	[ExaminationAbdomen] [int] NULL,
	[ExaminationSpeculum] [int] NULL,
	[ExaminationPv] [int] NULL,
	[ExaminationCervicalScreening] [int] NULL,
	[ExaminationContraception] [varchar](100) NULL,
	[Notes] [varchar](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyPostnatal] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyReminderItem]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PregnancyReminderItem](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[ReminderId] [int] NOT NULL,
	[IsChecked] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyReminderItem] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PregnancyScreeningUltrasound]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyScreeningUltrasound](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[DatingResult] [int] NULL,
	[DatingNotes] [varchar](200) NULL,
	[TwelveWeekResult] [int] NULL,
	[TwelveWeekNotes] [varchar](200) NULL,
	[MorphologyResult] [int] NULL,
	[MorphologyNotes] [varchar](200) NULL,
	[PlacentaResult] [int] NULL,
	[PlacentaNotes] [varchar](200) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancyScreeningUltrasound] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancySummary]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancySummary](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[OriginalUid] [uniqueidentifier] NOT NULL,
	[VersionNumber] [int] NOT NULL,
	[HospitalId] [int] NULL,
	[Partner] [varchar](50) NULL,
	[LastContraception] [varchar](200) NULL,
	[LastContraceptionCeasedDate] [datetime] NULL,
	[CervicalScreening] [varchar](200) NULL,
	[CervicalScreeningDate] [datetime] NULL,
	[PregnancyOverview] [varchar](max) NULL,
	[MedicalHistory] [varchar](max) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[HospitalUid] [uniqueidentifier] NULL,
	[VersionDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PregnancySummary] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyUltrasound]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyUltrasound](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[Date] [datetime] NOT NULL,
	[GestationalAgeDays] [int] NULL,
	[FetusNumber] [int] NULL,
	[BiparietalDiameter] [int] NULL,
	[HeadCircumference] [int] NULL,
	[AbdominalCircumference] [int] NULL,
	[FemurLength] [int] NULL,
	[DeepestVerticalPocket] [float] NULL,
	[SDRatio] [float] NULL,
	[EstimatedFetalWeight] [int] NULL,
	[Notes] [varchar](max) NULL,
	[Removed] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PregnancyUltrasound] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PregnancyVisit]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PregnancyVisit](
	[Uid] [uniqueidentifier] NOT NULL,
	[PregnancyUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[Date] [datetime] NOT NULL,
	[GestationalAgeDays] [int] NULL,
	[ProviderUserId] [int] NULL,
	[Fundus] [varchar](50) NULL,
	[Presentation] [int] NULL,
	[Engagement] [int] NULL,
	[FHR] [varchar](50) NULL,
	[FetalMovement] [int] NULL,
	[Oedema] [int] NULL,
	[Liquor] [int] NULL,
	[Urine] [varchar](50) NULL,
	[NextVisitWeeks] [int] NULL,
	[Notes] [varchar](max) NULL,
	[Removed] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[HeightWeightUid] [uniqueidentifier] NULL,
	[BloodPressureUid] [uniqueidentifier] NULL,
	[FundalHeight] [int] NULL,
 CONSTRAINT [PK_PregnancyVisit] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Prescription]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Prescription](
	[PrescriptionUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[stat_UserId] [int] NOT NULL,
	[PrescriptionNumber] [int] NOT NULL,
	[Authority] [int] NULL,
	[AuthorityPrescriptionNumber] [int] NULL,
	[AuthorityApprovalType] [int] NULL,
	[AuthorityCode] [varchar](20) NULL,
	[AuthorityIndication] [varchar](max) NULL,
	[AuthorityIndicationId] [int] NULL,
	[PBS] [int] NULL,
	[RPBS] [int] NULL,
	[BrandSubstitutionNotPermitted] [int] NULL,
	[ErxId] [varchar](18) NULL,
	[ErxTimesRetried] [int] NULL,
	[ErxSendStatus] [int] NULL,
	[ErxSendMessage] [varchar](max) NULL,
	[ErxSendPayload] [varchar](max) NULL,
	[DrugCount] [int] NOT NULL,
	[SingleDrug] [int] NULL,
	[CTGAnnotation] [varchar](6) NULL,
	[ErxInitialSendAttemptDateTimeOffset] [datetimeoffset](7) NULL,
	[PrintedDateTimeOffset] [datetimeoffset](7) NOT NULL,
	[SentToErxDateTimeOffset] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Prescription] PRIMARY KEY CLUSTERED 
(
	[PrescriptionUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PrescriptionDrug]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PrescriptionDrug](
	[PrescriptionDrugUid] [uniqueidentifier] NOT NULL,
	[PrescriptionUid] [uniqueidentifier] NOT NULL,
	[PrescriptionDrugSequence] [int] NOT NULL,
	[ProdCode] [int] NULL,
	[FormCode] [int] NULL,
	[PackCode] [int] NULL,
	[DrugDescription] [varchar](500) NOT NULL,
	[Quantity] [int] NULL,
	[Dosage] [varchar](max) NULL,
	[Repeats] [int] NULL,
	[Reg24] [int] NULL,
	[S8] [int] NULL,
	[DrugName] [varchar](200) NULL,
	[Form] [varchar](200) NULL,
	[Strength] [varchar](200) NULL,
	[FDBDrugType] [int] NULL,
	[FDBId] [varchar](20) NULL,
	[Removed] [bit] NOT NULL,
	[s11] [int] NULL,
 CONSTRAINT [PK_PrescriptionDrug] PRIMARY KEY CLUSTERED 
(
	[PrescriptionDrugUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PrescriptionDrugErxNotification]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PrescriptionDrugErxNotification](
	[PrescriptionDrugErxNotificationUid] [uniqueidentifier] NOT NULL,
	[PrescriptionDrugUid] [uniqueidentifier] NOT NULL,
	[NotificationAddedDate] [datetime] NULL,
	[NotificationCreatedDate] [datetime] NULL,
	[ErxStatus] [varchar](50) NULL,
	[DispenseDate] [datetime] NULL,
	[PharmacyName] [varchar](100) NULL,
	[PharmacySuburb] [varchar](100) NULL,
	[PharmacyPhone] [varchar](10) NULL,
	[SupplyNumber] [varchar](10) NULL,
	[DispensedItemDescription] [varchar](200) NULL,
	[DispensedQuantity] [varchar](10) NULL,
 CONSTRAINT [PK_PrescriptionDrugErxNotification] PRIMARY KEY CLUSTERED 
(
	[PrescriptionDrugErxNotificationUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RadiologyRequestTest]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RadiologyRequestTest](
	[RadiologyRequestTestUid] [uniqueidentifier] NOT NULL,
	[RequestUid] [uniqueidentifier] NOT NULL,
	[TestRequested] [varchar](max) NOT NULL,
 CONSTRAINT [PK_RadiologyRequestTest_1] PRIMARY KEY CLUSTERED 
(
	[RadiologyRequestTestUid] ASC,
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RenalFunction]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RenalFunction](
	[RenalFunctionUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[stat_UserId] [int] NULL,
	[Height] [float] NULL,
	[Weight] [float] NULL,
	[ConcentrationType] [int] NOT NULL,
	[Concentration] [float] NOT NULL,
	[CalculationType] [int] NOT NULL,
	[Result] [float] NOT NULL,
	[Inactive] [bit] NOT NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_RenalFunction] PRIMARY KEY CLUSTERED 
(
	[RenalFunctionUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RespiratoryFunction]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RespiratoryFunction](
	[RespiratoryFunctionUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NULL,
	[stat_UserId] [int] NULL,
	[Comments] [varchar](max) NULL,
	[PredictedValue] [float] NOT NULL,
	[ActualValuePreVentolin] [float] NOT NULL,
	[ActualValuePostVentolin] [float] NOT NULL,
	[MeasureType] [int] NOT NULL,
	[Inactive] [bit] NOT NULL,
	[TestDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_RespiratoryFunction] PRIMARY KEY CLUSTERED 
(
	[RespiratoryFunctionUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Result]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Result](
	[ClinicalResultUid] [uniqueidentifier] NOT NULL,
	[EhrUid] [uniqueidentifier] NOT NULL,
	[MessageInId] [int] NULL,
	[UnmatchedMessageInId] [int] NULL,
	[RunNumber] [varchar](15) NULL,
	[OurReference] [int] NULL,
	[LaboratoryReference] [varchar](250) NULL,
	[LaboratoryNumber] [varchar](250) NULL,
	[CopyDoctors] [varchar](1000) NULL,
	[MessageReceivedDateTimeOffset] [datetimeoffset](7) NULL,
	[MessageWrittenDateTimeOffset] [datetimeoffset](7) NULL,
	[DisplayText] [varchar](max) NULL,
	[DisplayBlob] [varbinary](max) NULL,
	[DisplayFormatExtension] [varchar](20) NULL,
	[DisplayCompliance] [int] NULL,
	[Automatched] [int] NULL,
	[MatchedByUserId] [int] NULL,
	[MatchedDateTimeOffset] [datetimeoffset](7) NULL,
	[OrderingDoctorName] [varchar](120) NULL,
	[RequestDateTimeOffset] [datetimeoffset](7) NULL,
	[IsAbnormal] [int] NULL,
	[IsUrgent] [int] NULL,
	[RequestedTests] [varchar](1000) NULL,
	[CollectionDateTimeOffset] [datetimeoffset](7) NULL,
	[RecipientUserId] [int] NULL,
	[SendingOrganisationAddressBookId] [int] NULL,
	[FacilityType] [int] NULL,
	[RequestUid] [uniqueidentifier] NULL,
	[Reviewed] [int] NULL,
	[Removed] [int] NULL,
 CONSTRAINT [PK_Result] PRIMARY KEY CLUSTERED 
(
	[ClinicalResultUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ResultAtomic]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ResultAtomic](
	[ClinicalResultAtomicUid] [uniqueidentifier] NOT NULL,
	[ClinicalResultUid] [uniqueidentifier] NOT NULL,
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
 CONSTRAINT [PK_ResultAtomic] PRIMARY KEY CLUSTERED 
(
	[ClinicalResultAtomicUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Vaccination]    Script Date: 9/04/2019 12:40:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Vaccination](
	[VaccinationUid] [uniqueidentifier] NOT NULL,
	[EncounterUid] [uniqueidentifier] NOT NULL,
	[Notes] [varchar](1000) NULL,
	[stat_UserIdVaccinated] [int] NOT NULL,
	[UserIdOnBehalfOf] [int] NOT NULL,
	[AcirClaimId] [varchar](8) NULL,
	[BirthHepB] [int] NULL,
	[GivenElsewhere] [int] NULL,
	[Removed] [int] NULL,
	[HoldAcir] [int] NULL,
	[AcirError] [varchar](250) NULL,
	[PrivateVaccine] [int] NOT NULL,
	[VaccineUid] [uniqueidentifier] NULL,
	[NilKnown] [int] NULL,
	[BatchNumber] [varchar](25) NULL,
	[Administration] [int] NULL,
	[Site] [varchar](50) NULL,
	[DoseNumber] [int] NULL,
	[GivenDateTimeOffset] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Vaccine] PRIMARY KEY CLUSTERED 
(
	[VaccinationUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [AddressBook_Document_ManuscriptUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [AddressBook_Document_ManuscriptUid] ON [dbo].[AddressBook_Document]
(
	[ManuscriptUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Allergy_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Allergy_EhrUid] ON [dbo].[Allergy]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Allergy_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Allergy_EhrUid] ON [dbo].[Allergy]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Allergy_VersionNumber_CeasedDateTime]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Allergy_VersionNumber_CeasedDateTime] ON [dbo].[Allergy]
(
	[VersionNumber] ASC,
	[CeasedDateTime] ASC
)
INCLUDE ( 	[EhrUid],
	[AllergyType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_Annotation_6_2137058649__K3_K1_K4_K8_2_6_7]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Annotation_6_2137058649__K3_K1_K4_K8_2_6_7] ON [dbo].[Annotation]
(
	[ItemUid] ASC,
	[AnnotationUid] ASC,
	[Stat_UserId] ASC,
	[AnnotationDateTimeOffset] ASC
)
INCLUDE ( 	[EhrUid],
	[AnnotationType],
	[AnnotationText]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Annotation_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Annotation_EhrUid] ON [dbo].[Annotation]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Annotation_ItemUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Annotation_ItemUid] ON [dbo].[Annotation]
(
	[ItemUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Annotation_ItemUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Annotation_ItemUid] ON [dbo].[Annotation]
(
	[ItemUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [BloodGlucose_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [BloodGlucose_EhrUid] ON [dbo].[BloodGlucose]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [BloodGlucose_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [BloodGlucose_EncounterUid] ON [dbo].[BloodGlucose]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [BloodPressure_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [BloodPressure_EhrUid] ON [dbo].[BloodPressure]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [BloodPressure_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [BloodPressure_EncounterUid] ON [dbo].[BloodPressure]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_BloodPressure_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_BloodPressure_EhrUid] ON [dbo].[BloodPressure]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [CardiovascularRisk_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [CardiovascularRisk_EhrUid] ON [dbo].[CardiovascularRisk]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [CardiovascularRisk_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [CardiovascularRisk_EncounterUid] ON [dbo].[CardiovascularRisk]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ClinicalAlert_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalAlert_EhrUid] ON [dbo].[ClinicalAlert]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ClinicalRequest_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalRequest_Covering] ON [dbo].[ClinicalRequest]
(
	[EncounterUid] ASC,
	[stat_UserIdRequesting] ASC,
	[RequestUid] ASC
)
INCLUDE ( 	[stat_AddressBookId],
	[RequestDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ClinicalRequest_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalRequest_EncounterUid] ON [dbo].[ClinicalRequest]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ClinicalRequest_Completed_ShowOnAuditReport_DueDate]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalRequest_Completed_ShowOnAuditReport_DueDate] ON [dbo].[ClinicalRequest]
(
	[Completed] ASC,
	[ShowOnAuditReport] ASC,
	[DueDate] ASC
)
INCLUDE ( 	[RequestUid],
	[EncounterUid],
	[RequestDate],
	[stat_UserIdRequesting]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ClinicalRequest_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalRequest_EncounterUid] ON [dbo].[ClinicalRequest]
(
	[EncounterUid] ASC
)
INCLUDE ( 	[RequestUid],
	[stat_AddressBookId],
	[RequestNumber],
	[ClinicalNotes],
	[RequestDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ClinicalRequest_RequestNumber]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalRequest_RequestNumber] ON [dbo].[ClinicalRequest]
(
	[RequestNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ClinicalRequest_stat_UserIdRequestingCompleted_ShowOnAuditReport_DueDate]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalRequest_stat_UserIdRequestingCompleted_ShowOnAuditReport_DueDate] ON [dbo].[ClinicalRequest]
(
	[stat_UserIdRequesting] ASC,
	[Completed] ASC,
	[ShowOnAuditReport] ASC,
	[DueDate] ASC
)
INCLUDE ( 	[RequestUid],
	[EncounterUid],
	[RequestDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ClinicalResult_Alerts]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalResult_Alerts] ON [dbo].[ClinicalResult]
(
	[Reviewed] ASC,
	[FacilityType] ASC,
	[ClinicalResultUid] ASC
)
INCLUDE ( 	[RequestDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ClinicalResult_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalResult_Covering] ON [dbo].[ClinicalResult]
(
	[FacilityType] ASC,
	[RequestUid] ASC,
	[UserId] ASC
)
INCLUDE ( 	[ClinicalResultUid],
	[TestCode],
	[ResultImportDateTimeOffset],
	[RequestDateTimeOffset],
	[ReportDateTimeOffset],
	[NormalResultIndicator],
	[CollectionDateTimeOffset],
	[FacilityAddressBookId],
	[Reviewed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ClinicalResult_Covering2]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalResult_Covering2] ON [dbo].[ClinicalResult]
(
	[EhrUid] ASC,
	[FacilityType] ASC,
	[ClinicalResultUid] ASC,
	[UserId] ASC
)
INCLUDE ( 	[ResultImportDateTimeOffset],
	[RequestDateTimeOffset],
	[Removed],
	[ReportDateTimeOffset],
	[NormalResultIndicator],
	[RequestedTests],
	[CollectionDateTimeOffset],
	[FacilityAddressBookId],
	[Reviewed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ClinicalResult_Covering3]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalResult_Covering3] ON [dbo].[ClinicalResult]
(
	[FacilityType] ASC,
	[RequestUid] ASC,
	[ClinicalResultUid] ASC,
	[UserId] ASC
)
INCLUDE ( 	[ResultImportDateTimeOffset],
	[RequestDateTimeOffset],
	[Removed],
	[ReportDateTimeOffset],
	[NormalResultIndicator],
	[RequestedTests],
	[CollectionDateTimeOffset],
	[FacilityAddressBookId],
	[Reviewed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ClinicalResult_FacilityType_UserId_Reviewed]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalResult_FacilityType_UserId_Reviewed] ON [dbo].[ClinicalResult]
(
	[FacilityType] ASC,
	[UserId] ASC,
	[Reviewed] ASC
)
INCLUDE ( 	[ClinicalResultUid],
	[RunDateTimeOffset],
	[RequestCompleted],
	[RequestUid],
	[Removed],
	[OriginalPatientName],
	[OriginalDOB],
	[UrgentRequestIndicator],
	[CollectionDateTimeOffset],
	[EhrUid],
	[FacilityAddressBookId],
	[ManualMatchUserId],
	[ManualMatchDateTimeOffset],
	[ReferringDoctorName],
	[ReferringDoctorProviderNo],
	[RequestDateTimeOffset],
	[ReportDateTimeOffset],
	[ConfidentialityIndicator],
	[NormalResultIndicator]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ClinicalResult_Reviewed]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalResult_Reviewed] ON [dbo].[ClinicalResult]
(
	[Reviewed] ASC
)
INCLUDE ( 	[RequestDateTimeOffset],
	[FacilityType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ClinicalResult_UserId_Reviewed]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalResult_UserId_Reviewed] ON [dbo].[ClinicalResult]
(
	[UserId] ASC,
	[Reviewed] ASC
)
INCLUDE ( 	[RequestDateTimeOffset],
	[FacilityType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_ClinicalResultAtomic_LOINCIdentifier]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalResultAtomic_LOINCIdentifier] ON [dbo].[ClinicalResultAtomic]
(
	[LOINCIdentifier] ASC
)
INCLUDE ( 	[ClinicalResultUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Condition_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Condition_EncounterUid] ON [dbo].[Condition]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Condition_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Condition_statUserId] ON [dbo].[Condition]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Condition_DateExpired]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Condition_DateExpired] ON [dbo].[Condition]
(
	[DateExpired] ASC
)
INCLUDE ( 	[ConditionUid],
	[ICPCCode],
	[ICPCTermCode],
	[OriginalConditionUid],
	[CreatedDateTimeOffset],
	[EncounterUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Condition_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Condition_EncounterUid] ON [dbo].[Condition]
(
	[EncounterUid] ASC
)
INCLUDE ( 	[ConditionUid],
	[ICPCCode],
	[ICPCTermCode],
	[Description],
	[DateCommenced],
	[DateExpired],
	[LastReviewedDateTimeOffset],
	[OriginalConditionUid],
	[CreatedDateTimeOffset],
	[Notes],
	[stat_UserId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Condition_ICPCCode_ICPCTermCodeDateExpired]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Condition_ICPCCode_ICPCTermCodeDateExpired] ON [dbo].[Condition]
(
	[ICPCCode] ASC,
	[ICPCTermCode] ASC,
	[DateExpired] ASC
)
INCLUDE ( 	[ConditionUid],
	[OriginalConditionUid],
	[CreatedDateTimeOffset],
	[EncounterUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [CopyDoctor_ParentUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [CopyDoctor_ParentUid] ON [dbo].[CopyDoctor]
(
	[ParentUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_Alerts]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_Alerts] ON [dbo].[Correspondence]
(
	[DraftStatus] ASC,
	[CorrespondenceUid] ASC
)
INCLUDE ( 	[CreatedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Correspondence_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_Covering] ON [dbo].[Correspondence]
(
	[DocumentType] ASC,
	[EncounterUid] ASC,
	[stat_UserId] ASC
)
INCLUDE ( 	[CorrespondenceUid],
	[Description],
	[stat_OutgoingRecipientAddressBookId],
	[CreatedDateTimeOffset],
	[DraftStatus],
	[ShowOutsideClinical],
	[Incoming],
	[ReviewRequired]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_DocumentType]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_DocumentType] ON [dbo].[Correspondence]
(
	[DocumentType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_EhrUid] ON [dbo].[Correspondence]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_EncounterUid] ON [dbo].[Correspondence]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_ManuscriptUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_ManuscriptUid] ON [dbo].[Correspondence]
(
	[ManuscriptUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Correspondence_ReviewOutgoingList]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_ReviewOutgoingList] ON [dbo].[Correspondence]
(
	[Incoming] ASC,
	[DraftStatus] ASC,
	[VersionNumber] ASC,
	[stat_DraftNextActionUserId] ASC,
	[CorrespondenceUid] ASC,
	[stat_OwnerId] ASC,
	[stat_EditedByUserId] ASC
)
INCLUDE ( 	[EhrUid],
	[OriginalCorrespondenceUid],
	[Description],
	[ShowOutsideClinical],
	[DocumentType],
	[ReviewRequired],
	[CreatedDateTimeOffset],
	[IsEditableInExternalEditorOnly]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_ReviewRequired]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_ReviewRequired] ON [dbo].[Correspondence]
(
	[ReviewRequired] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_Revisions]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_Revisions] ON [dbo].[Correspondence]
(
	[OriginalCorrespondenceUid] ASC,
	[CorrespondenceUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_statReviewNextActionUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_statReviewNextActionUserId] ON [dbo].[Correspondence]
(
	[stat_DraftNextActionUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Correspondence_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Correspondence_statUserId] ON [dbo].[Correspondence]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Correspondence_DraftStatus]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_DraftStatus] ON [dbo].[Correspondence]
(
	[DraftStatus] ASC
)
INCLUDE ( 	[OriginalCorrespondenceUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Correspondence_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_EhrUid] ON [dbo].[Correspondence]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Correspondence_EncounterUid_DocumentType]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_EncounterUid_DocumentType] ON [dbo].[Correspondence]
(
	[EncounterUid] ASC,
	[DocumentType] ASC
)
INCLUDE ( 	[CorrespondenceUid],
	[OriginalCorrespondenceUid],
	[VersionNumber],
	[Description],
	[stat_IncomingRecipientUserId],
	[ReviewRequired],
	[ReviewFinalized],
	[Removed],
	[stat_OwnerId],
	[stat_UserId],
	[Incoming],
	[ShowOutsideClinical],
	[CreatedDateTimeOffset],
	[stat_OutgoingRecipientAddressBookId],
	[DraftStatus],
	[stat_EditedByUserId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Correspondence_Incoming]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_Incoming] ON [dbo].[Correspondence]
(
	[Incoming] ASC
)
INCLUDE ( 	[CorrespondenceUid],
	[EhrUid],
	[OriginalCorrespondenceUid],
	[VersionNumber],
	[Description],
	[DocumentType],
	[DraftStatus],
	[stat_DraftNextActionUserId],
	[stat_EditedByUserId],
	[ReviewRequired],
	[stat_OwnerId],
	[ShowOutsideClinical],
	[CreatedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Correspondence_Incoming_CreatedDateTimeOffset]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_Incoming_CreatedDateTimeOffset] ON [dbo].[Correspondence]
(
	[Incoming] ASC,
	[CreatedDateTimeOffset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Correspondence_Incoming2]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_Incoming2] ON [dbo].[Correspondence]
(
	[Incoming] ASC
)
INCLUDE ( 	[VersionNumber],
	[CreatedDateTimeOffset],
	[stat_IncomingRecipientUserId],
	[ReviewRequired],
	[ReviewFinalized],
	[Removed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Correspondence_Incoming3]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_Incoming3] ON [dbo].[Correspondence]
(
	[Incoming] ASC
)
INCLUDE ( 	[CorrespondenceUid],
	[VersionNumber],
	[DocumentType],
	[stat_IncomingRecipientUserId],
	[ReviewRequired],
	[ReviewFinalized],
	[Removed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Correspondence_IncomingDraftStatus]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Correspondence_IncomingDraftStatus] ON [dbo].[Correspondence]
(
	[Incoming] ASC,
	[DraftStatus] ASC
)
INCLUDE ( 	[VersionNumber],
	[CreatedDateTimeOffset],
	[stat_DraftNextActionUserId],
	[Removed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [CurrentMedication_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [CurrentMedication_EhrUid] ON [dbo].[CurrentMedication]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_CurrentMedication_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_CurrentMedication_EhrUid] ON [dbo].[CurrentMedication]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_CurrentMedication_EhrUid_VersionNumber]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_CurrentMedication_EhrUid_VersionNumber] ON [dbo].[CurrentMedication]
(
	[EhrUid] ASC,
	[VersionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_CurrentMedication_VersionNumber_ProdCode_FormCode_ToBePrescribedPackCode]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_CurrentMedication_VersionNumber_ProdCode_FormCode_ToBePrescribedPackCode] ON [dbo].[CurrentMedication]
(
	[VersionNumber] ASC,
	[ProdCode] ASC,
	[FormCode] ASC,
	[ToBePrescribed] ASC,
	[PackCode] ASC
)
INCLUDE ( 	[EhrUid],
	[LastPrescribedDateTimeOffset],
	[CurrentPeriod]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_CurrentMedication_VersionNumber_ToBePrescribedProdCode_FormCode_PackCode]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_CurrentMedication_VersionNumber_ToBePrescribedProdCode_FormCode_PackCode] ON [dbo].[CurrentMedication]
(
	[VersionNumber] ASC,
	[ToBePrescribed] ASC,
	[ProdCode] ASC,
	[FormCode] ASC,
	[PackCode] ASC
)
INCLUDE ( 	[EhrUid],
	[LastPrescribedDateTimeOffset],
	[CurrentPeriod]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_CurrentMedicationSchedule_CurrentMedicationUid_VersionNumber]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_CurrentMedicationSchedule_CurrentMedicationUid_VersionNumber] ON [dbo].[CurrentMedicationSchedule]
(
	[CurrentMedicationUid] ASC,
	[VersionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_DiabetesCare_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_DiabetesCare_EhrUid] ON [dbo].[DiabetesCare]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Encounter_6_405576483__K1_K11]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Encounter_6_405576483__K1_K11] ON [dbo].[Encounter]
(
	[EncounterUid] ASC,
	[stat_ProviderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Encounter_6_405576483__K11_K13_K12]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Encounter_6_405576483__K11_K13_K12] ON [dbo].[Encounter]
(
	[stat_ProviderId] ASC,
	[TentativeEncounter] ASC,
	[Removed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Encounter_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Encounter_Covering] ON [dbo].[Encounter]
(
	[EhrUid] ASC,
	[stat_Committer_Id] ASC,
	[EncounterUid] ASC
)
INCLUDE ( 	[StartDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Encounter_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Encounter_EhrUid] ON [dbo].[Encounter]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Encounter_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Encounter_EhrUid] ON [dbo].[Encounter]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [EncounterNotes_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [EncounterNotes_Covering] ON [dbo].[EncounterNotes]
(
	[EncounterUid] ASC,
	[NotesUid] ASC,
	[stat_UserId] ASC,
	[ManuscriptUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [EncounterNotes_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [EncounterNotes_EncounterUid] ON [dbo].[EncounterNotes]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [EncounterNotes_ManuscriptUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [EncounterNotes_ManuscriptUid] ON [dbo].[EncounterNotes]
(
	[ManuscriptUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [EncounterNotes_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [EncounterNotes_statUserId] ON [dbo].[EncounterNotes]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_EncounterNotes_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_EncounterNotes_EncounterUid] ON [dbo].[EncounterNotes]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [HealthIndicators_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [HealthIndicators_EhrUid] ON [dbo].[HealthIndicators]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [HeightWeights_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [HeightWeights_EhrUid] ON [dbo].[HeightWeights]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [HeightWeights_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [HeightWeights_EncounterUid] ON [dbo].[HeightWeights]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [HeightWeights_Inactive]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [HeightWeights_Inactive] ON [dbo].[HeightWeights]
(
	[Inactive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [HeightWeights_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [HeightWeights_statUserId] ON [dbo].[HeightWeights]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_HeightWeights_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_HeightWeights_EhrUid] ON [dbo].[HeightWeights]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_IncomingReview_ClinicalResultUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_IncomingReview_ClinicalResultUid] ON [dbo].[IncomingReview]
(
	[ClinicalResultUid] ASC
)
INCLUDE ( 	[UnreviewDateTimeOffset],
	[ReviewDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_IncomingReview_CorrespondenceUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_IncomingReview_CorrespondenceUid] ON [dbo].[IncomingReview]
(
	[CorrespondenceUid] ASC
)
INCLUDE ( 	[IncomingReviewUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_IncomingReview_IncomingReviewType]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_IncomingReview_IncomingReviewType] ON [dbo].[IncomingReview]
(
	[IncomingReviewType] ASC
)
INCLUDE ( 	[IncomingReviewUid],
	[CorrespondenceUid],
	[ClinicalResultUid],
	[ReviewNumberType],
	[ReviewDateTimeOffset],
	[UnreviewDateTimeOffset],
	[ReviewedByUserId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Lactation_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Lactation_EhrUid] ON [dbo].[Lactation]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Manuscript_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Manuscript_EhrUid] ON [dbo].[Manuscript]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Manuscript_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Manuscript_EncounterUid] ON [dbo].[Manuscript]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Manuscript_ManuscriptAttachmentUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Manuscript_ManuscriptAttachmentUid] ON [dbo].[Manuscript]
(
	[ManuscriptAttachmentUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Manuscript_OriginalUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Manuscript_OriginalUid] ON [dbo].[Manuscript]
(
	[OriginalUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ManuscriptAnswer_ManuscriptUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ManuscriptAnswer_ManuscriptUid] ON [dbo].[ManuscriptAnswer]
(
	[ManuscriptUid] ASC
)
INCLUDE ( 	[ManuscriptAnswerUid],
	[SnippetUid],
	[AnswerString],
	[AnswerInt1],
	[AnswerInt2],
	[AnswerDateTime],
	[AnswerBool]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [MedicalTest_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [MedicalTest_EhrUid] ON [dbo].[MedicalTest]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [MedicalTest_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [MedicalTest_EncounterUid] ON [dbo].[MedicalTest]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [PathologyRequest_RequestUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [PathologyRequest_RequestUid] ON [dbo].[PathologyRequest]
(
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PathologyRequestTest_RequestUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_PathologyRequestTest_RequestUid] ON [dbo].[PathologyRequestTest]
(
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [PathologyRequestTest_RequestUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [PathologyRequestTest_RequestUid] ON [dbo].[PathologyRequestTest]
(
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_PregnancyCalculation_VersionNumber_DeliveredNotCompleted_CompletePregnantMethod]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_PregnancyCalculation_VersionNumber_DeliveredNotCompleted_CompletePregnantMethod] ON [dbo].[PregnancyCalculation]
(
	[VersionNumber] ASC,
	[DeliveredNotCompleted] ASC,
	[Complete] ASC,
	[PregnantMethod] ASC
)
INCLUDE ( 	[EhrUid],
	[CalculationDate],
	[ScanDays]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Prescription_6_645577338__K2_K1_K27_15]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Prescription_6_645577338__K2_K1_K27_15] ON [dbo].[Prescription]
(
	[EncounterUid] ASC,
	[PrescriptionUid] ASC,
	[PrintedDateTimeOffset] ASC
)
INCLUDE ( 	[DrugCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_Prescription_6_645577338__K2_K1_K27_3_5_6_7_8_9_10_11_12_13_14_15_16_17_22_23_24_25_26_28]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Prescription_6_645577338__K2_K1_K27_3_5_6_7_8_9_10_11_12_13_14_15_16_17_22_23_24_25_26_28] ON [dbo].[Prescription]
(
	[EncounterUid] ASC,
	[PrescriptionUid] ASC,
	[PrintedDateTimeOffset] ASC
)
INCLUDE ( 	[stat_UserId],
	[PrescriptionNumber],
	[Authority],
	[AuthorityPrescriptionNumber],
	[AuthorityApprovalType],
	[AuthorityCode],
	[AuthorityIndication],
	[AuthorityIndicationId],
	[PBS],
	[RPBS],
	[BrandSubstitutionNotPermitted],
	[DrugCount],
	[SingleDrug],
	[ErxId],
	[ErxSendStatus],
	[ErxSendMessage],
	[ErxSendPayload],
	[CTGAnnotation],
	[ErxInitialSendAttemptDateTimeOffset],
	[SentToErxDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Prescription_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Prescription_EncounterUid] ON [dbo].[Prescription]
(
	[EncounterUid] ASC
)
INCLUDE ( 	[PrescriptionUid],
	[PrintedDateTimeOffset],
	[PrescriptionNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Prescription_ErxId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Prescription_ErxId] ON [dbo].[Prescription]
(
	[ErxId] ASC
)
INCLUDE ( 	[PrescriptionUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Prescription_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Prescription_Covering] ON [dbo].[Prescription]
(
	[EncounterUid] ASC,
	[stat_UserId] ASC,
	[PrescriptionUid] ASC
)
INCLUDE ( 	[PrintedDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Prescription_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Prescription_statUserId] ON [dbo].[Prescription]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_PrescriptionDrug_6_661577395__K2_K1_K4_3_5_6_7_8_9_10_11_12_18_19]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_PrescriptionDrug_6_661577395__K2_K1_K4_3_5_6_7_8_9_10_11_12_18_19] ON [dbo].[PrescriptionDrug]
(
	[PrescriptionUid] ASC,
	[PrescriptionDrugUid] ASC,
	[ProdCode] ASC
)
INCLUDE ( 	[PrescriptionDrugSequence],
	[FormCode],
	[PackCode],
	[DrugDescription],
	[Quantity],
	[Dosage],
	[Repeats],
	[Reg24],
	[S8],
	[Removed],
	[s11]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PrescriptionDrug_Covering]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [PrescriptionDrug_Covering] ON [dbo].[PrescriptionDrug]
(
	[PrescriptionUid] ASC
)
INCLUDE ( 	[PrescriptionDrugUid],
	[DrugDescription],
	[Quantity],
	[Dosage]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RadiologyRequestTest_RequestUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_RadiologyRequestTest_RequestUid] ON [dbo].[RadiologyRequestTest]
(
	[RequestUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RenalFunction_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RenalFunction_EhrUid] ON [dbo].[RenalFunction]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RenalFunction_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RenalFunction_EncounterUid] ON [dbo].[RenalFunction]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RenalFunction_Inactive]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RenalFunction_Inactive] ON [dbo].[RenalFunction]
(
	[Inactive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RenalFunction_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RenalFunction_statUserId] ON [dbo].[RenalFunction]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_RespiratoryFunction_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_RespiratoryFunction_EhrUid] ON [dbo].[RespiratoryFunction]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RespiratoryFunction_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RespiratoryFunction_EhrUid] ON [dbo].[RespiratoryFunction]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RespiratoryFunction_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RespiratoryFunction_EncounterUid] ON [dbo].[RespiratoryFunction]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RespiratoryFunction_Inactive]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RespiratoryFunction_Inactive] ON [dbo].[RespiratoryFunction]
(
	[Inactive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [RespiratoryFunction_statUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [RespiratoryFunction_statUserId] ON [dbo].[RespiratoryFunction]
(
	[stat_UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Result_6_1202871402__K2_K1_10_11_20_24]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Result_6_1202871402__K2_K1_10_11_20_24] ON [dbo].[Result]
(
	[EhrUid] ASC,
	[ClinicalResultUid] ASC
)
INCLUDE ( 	[MessageReceivedDateTimeOffset],
	[MessageWrittenDateTimeOffset],
	[RequestDateTimeOffset],
	[CollectionDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Result_6_1682821057__K29_K25_K26_20]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_Result_6_1682821057__K29_K25_K26_20] ON [dbo].[Result]
(
	[Reviewed] ASC,
	[RecipientUserId] ASC,
	[SendingOrganisationAddressBookId] ASC
)
INCLUDE ( 	[RequestDateTimeOffset]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ClinicalResult_EhrUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalResult_EhrUid] ON [dbo].[Result]
(
	[EhrUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ClinicalResult_Reviewed]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ClinicalResult_Reviewed] ON [dbo].[Result]
(
	[Reviewed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_ClinicalResult_Reviewed]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_ClinicalResult_Reviewed] ON [dbo].[Result]
(
	[Reviewed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Result_RecipientUserId]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Result_RecipientUserId] ON [dbo].[Result]
(
	[RecipientUserId] ASC
)
INCLUDE ( 	[ClinicalResultUid],
	[SendingOrganisationAddressBookId],
	[Reviewed],
	[Removed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Result_RequestUidFacilityType]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Result_RequestUidFacilityType] ON [dbo].[Result]
(
	[RequestUid] ASC,
	[FacilityType] ASC
)
INCLUDE ( 	[ClinicalResultUid],
	[MessageReceivedDateTimeOffset],
	[MessageWrittenDateTimeOffset],
	[RequestDateTimeOffset],
	[IsAbnormal],
	[RequestedTests],
	[CollectionDateTimeOffset],
	[RecipientUserId],
	[SendingOrganisationAddressBookId],
	[Reviewed],
	[Removed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ResultAtomic_6_1218871459__K2_K6_1_3_4_5_7_8_9_10_11_12_13_14_15_16_17]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ResultAtomic_6_1218871459__K2_K6_1_3_4_5_7_8_9_10_11_12_13_14_15_16_17] ON [dbo].[ResultAtomic]
(
	[ClinicalResultUid] ASC,
	[LabResultCode] ASC
)
INCLUDE ( 	[ClinicalResultAtomicUid],
	[SetID],
	[ValueType],
	[LOINCIdentifier],
	[ObservationValue],
	[NumericValue],
	[Units],
	[ReferenceRange],
	[AbnormalFlags],
	[NatureOfAbnormalTest],
	[ObservationResultStatus],
	[LastNormalObservationDateTimeOffset],
	[PathologyLabAnalysisDateTimeOffset],
	[EncodingType],
	[CodingSystem]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ResultAtomic_6_1218871459__K5_K2_1_3_4_6_7_8_9_10_11_12_13_14_15_16_17]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [_dta_index_ResultAtomic_6_1218871459__K5_K2_1_3_4_6_7_8_9_10_11_12_13_14_15_16_17] ON [dbo].[ResultAtomic]
(
	[LOINCIdentifier] ASC,
	[ClinicalResultUid] ASC
)
INCLUDE ( 	[ClinicalResultAtomicUid],
	[SetID],
	[ValueType],
	[LabResultCode],
	[ObservationValue],
	[NumericValue],
	[Units],
	[ReferenceRange],
	[AbnormalFlags],
	[NatureOfAbnormalTest],
	[ObservationResultStatus],
	[LastNormalObservationDateTimeOffset],
	[PathologyLabAnalysisDateTimeOffset],
	[EncodingType],
	[CodingSystem]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Vaccination_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Vaccination_EncounterUid] ON [dbo].[Vaccination]
(
	[EncounterUid] ASC
)
INCLUDE ( 	[VaccinationUid],
	[VaccineUid],
	[GivenDateTimeOffset],
	[BatchNumber],
	[Administration],
	[Site],
	[Notes],
	[stat_UserIdVaccinated],
	[UserIdOnBehalfOf],
	[AcirClaimId],
	[DoseNumber],
	[BirthHepB],
	[GivenElsewhere],
	[Removed],
	[HoldAcir],
	[AcirError]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [ix_Vaccination_Removed]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Vaccination_Removed] ON [dbo].[Vaccination]
(
	[Removed] ASC
)
INCLUDE ( 	[EncounterUid],
	[GivenDateTimeOffset],
	[VaccineUid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Vaccination_UserIdOnBehalfOf_PrivateVaccineDateGiven]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_Vaccination_UserIdOnBehalfOf_PrivateVaccineDateGiven] ON [dbo].[Vaccination]
(
	[UserIdOnBehalfOf] ASC,
	[PrivateVaccine] ASC,
	[GivenDateTimeOffset] ASC
)
INCLUDE ( 	[VaccinationUid],
	[EncounterUid],
	[VaccineUid],
	[NilKnown],
	[BatchNumber],
	[Administration],
	[Site],
	[Notes],
	[stat_UserIdVaccinated],
	[AcirClaimId],
	[DoseNumber],
	[BirthHepB],
	[GivenElsewhere],
	[Removed],
	[HoldAcir],
	[AcirError]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [Vaccination_EncounterUid]    Script Date: 9/04/2019 12:40:18 AM ******/
CREATE NONCLUSTERED INDEX [Vaccination_EncounterUid] ON [dbo].[Vaccination]
(
	[EncounterUid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AddressBook_Document] ADD  CONSTRAINT [DF_AddressBook_Document_AddressBookDocumentUid]  DEFAULT (newid()) FOR [AddressBookDocumentUid]
GO
ALTER TABLE [dbo].[BloodPressure] ADD  CONSTRAINT [DF_BloodPressure_Origin]  DEFAULT ((0)) FOR [Origin]
GO
ALTER TABLE [dbo].[BloodPressure] ADD  CONSTRAINT [DF_BloodPressure_PositionId]  DEFAULT ((0)) FOR [PositionId]
GO
ALTER TABLE [dbo].[BloodPressure] ADD  CONSTRAINT [DF_BloodPressure_HeartbeatType]  DEFAULT ((0)) FOR [HeartbeatType]
GO
ALTER TABLE [dbo].[ClinicalRequest] ADD  CONSTRAINT [DF_ClinicalRequest_Completed]  DEFAULT ((0)) FOR [Completed]
GO
ALTER TABLE [dbo].[ClinicalRequestCopyDoctor] ADD  CONSTRAINT [DF_ClinicalRequestCopyDoctor_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[Correspondence] ADD  CONSTRAINT [DF_Correspondence_IsEditableInExternalEditorOnly]  DEFAULT ((0)) FOR [IsEditableInExternalEditorOnly]
GO
ALTER TABLE [dbo].[CurrentMedication] ADD  CONSTRAINT [DF_CurrentMedication_CurrentMedicationUid]  DEFAULT (newid()) FOR [CurrentMedicationUid]
GO
ALTER TABLE [dbo].[CurrentMedicationSchedule] ADD  CONSTRAINT [DF_CurrentMedicationSchedule_CurrentMedicationScheduleUid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[CurrentMedicationSchedule] ADD  CONSTRAINT [DF_CurrentMedicationSchedule_DoNotInclude]  DEFAULT ((0)) FOR [DoNotInclude]
GO
ALTER TABLE [dbo].[Encounter] ADD  CONSTRAINT [DF_Encounter_EncounterUid]  DEFAULT (newid()) FOR [EncounterUid]
GO
ALTER TABLE [dbo].[HealthIndicators] ADD  CONSTRAINT [DF_HealthIndicators_Uid]  DEFAULT (newid()) FOR [Uid]
GO
ALTER TABLE [dbo].[Manuscript] ADD  CONSTRAINT [DF_Manuscript_AttachmentSize]  DEFAULT ((0)) FOR [AttachmentSize]
GO
ALTER TABLE [dbo].[MedicalTest] ADD  CONSTRAINT [DF_MedicalTest_TestUid]  DEFAULT (newid()) FOR [TestUid]
GO
ALTER TABLE [dbo].[PathologyRequestTest] ADD  CONSTRAINT [DF_PathologyRequestTest_PathologyRequestTestId]  DEFAULT (newid()) FOR [PathologyRequestTestUid]
GO
ALTER TABLE [dbo].[PregnancyAneuploidyScreening] ADD  CONSTRAINT [DF_PregnancyAneuploidyScreening_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyCalculation] ADD  CONSTRAINT [DF_PregnancyCalculation_CycleLength]  DEFAULT ((28)) FOR [CycleLength]
GO
ALTER TABLE [dbo].[PregnancyCalculation] ADD  CONSTRAINT [DF_PregnancyCalculation_DeliveredNotCompleted]  DEFAULT ((0)) FOR [DeliveredNotCompleted]
GO
ALTER TABLE [dbo].[PregnancyCalculation] ADD  CONSTRAINT [DF_PregnancyCalculation_Complete]  DEFAULT ((0)) FOR [Complete]
GO
ALTER TABLE [dbo].[PregnancyCalculation] ADD  CONSTRAINT [DF_PregnancyCalculation_PregnancyInactive]  DEFAULT ((0)) FOR [PregnancyInactive]
GO
ALTER TABLE [dbo].[PregnancyFetusGender] ADD  CONSTRAINT [DF_PregnancyFetusGender__DoesNotWishToKnow]  DEFAULT ((0)) FOR [DoesNotWishToKnow]
GO
ALTER TABLE [dbo].[PregnancyFetusGender] ADD  CONSTRAINT [DF_PregnancyFetusGender_Inactive]  DEFAULT ((0)) FOR [Removed]
GO
ALTER TABLE [dbo].[PregnancyInvestigation] ADD  CONSTRAINT [DF_PregnancyInvestigation_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyNeonatalRecord] ADD  CONSTRAINT [DF_PregnancyNeonatalRecord_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyNeonatalRecord] ADD  CONSTRAINT [DF_PregnancyNeonatalRecord_Removed]  DEFAULT ((0)) FOR [Removed]
GO
ALTER TABLE [dbo].[PregnancyOutcome] ADD  CONSTRAINT [DF_PregnancyOutcome_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyOutcome] ADD  CONSTRAINT [DF_PregnancyOutcome_Inactive]  DEFAULT ((0)) FOR [Removed]
GO
ALTER TABLE [dbo].[PregnancyOutcomeMaternal] ADD  CONSTRAINT [DF_PregnancyOutcomeMaternal_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyPhysicalExam] ADD  CONSTRAINT [DF_PregnancyPhysicalExam_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyPostnatal] ADD  CONSTRAINT [DF_PregnancyPostnatal_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyReminderItem] ADD  CONSTRAINT [DF_PregnancyReminderItem_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyReminderItem] ADD  CONSTRAINT [DF_PregnancyReminderItem_IsChecked]  DEFAULT ((0)) FOR [IsChecked]
GO
ALTER TABLE [dbo].[PregnancyScreeningUltrasound] ADD  CONSTRAINT [DF_PregnancyScreeningUltrasound_VersionNumber]  DEFAULT ((0)) FOR [VersionNumber]
GO
ALTER TABLE [dbo].[PregnancyUltrasound] ADD  CONSTRAINT [DF_PregnancyUltrasound_Inactive]  DEFAULT ((0)) FOR [Removed]
GO
ALTER TABLE [dbo].[PregnancyVisit] ADD  CONSTRAINT [DF_PregnancyVisit_Inactive]  DEFAULT ((0)) FOR [Removed]
GO
ALTER TABLE [dbo].[Prescription] ADD  CONSTRAINT [DF_Prescription_PrescriptionUid]  DEFAULT (newid()) FOR [PrescriptionUid]
GO
ALTER TABLE [dbo].[PrescriptionDrug] ADD  CONSTRAINT [DF_PrescriptionDrug_PrescriptionDrugUid]  DEFAULT (newid()) FOR [PrescriptionDrugUid]
GO
ALTER TABLE [dbo].[PrescriptionDrug] ADD  CONSTRAINT [DF_PrescriptionDrug_Removed]  DEFAULT ((0)) FOR [Removed]
GO
ALTER TABLE [dbo].[Result] ADD  CONSTRAINT [DF_PathologyResult_PathologyResultUid]  DEFAULT (newid()) FOR [ClinicalResultUid]
GO
ALTER TABLE [dbo].[Result] ADD  CONSTRAINT [DF_PathologyResult_Reviewed]  DEFAULT ((0)) FOR [Reviewed]
GO
ALTER TABLE [dbo].[ResultAtomic] ADD  CONSTRAINT [DF_PathologyResultAtomic_PathologyResultAtomicUid]  DEFAULT (newid()) FOR [ClinicalResultAtomicUid]
GO
ALTER TABLE [dbo].[AddressBook_Document]  WITH CHECK ADD  CONSTRAINT [FK_AddressBook_Document_Manuscript] FOREIGN KEY([ManuscriptUid])
REFERENCES [dbo].[Manuscript] ([ManuscriptUid])
GO
ALTER TABLE [dbo].[AddressBook_Document] CHECK CONSTRAINT [FK_AddressBook_Document_Manuscript]
GO
ALTER TABLE [dbo].[ClinicalRequestCopyDoctor]  WITH CHECK ADD  CONSTRAINT [FK_ClinicalRequestCopyDoctor_ClinicalRequest] FOREIGN KEY([RequestUid])
REFERENCES [dbo].[ClinicalRequest] ([RequestUid])
GO
ALTER TABLE [dbo].[ClinicalRequestCopyDoctor] CHECK CONSTRAINT [FK_ClinicalRequestCopyDoctor_ClinicalRequest]
GO
ALTER TABLE [dbo].[CurrentMedicationSchedule]  WITH CHECK ADD  CONSTRAINT [FK_CurrentMedicationSchedule_CurrentMedication] FOREIGN KEY([CurrentMedicationUid])
REFERENCES [dbo].[CurrentMedication] ([CurrentMedicationUid])
GO
ALTER TABLE [dbo].[CurrentMedicationSchedule] CHECK CONSTRAINT [FK_CurrentMedicationSchedule_CurrentMedication]
GO
ALTER TABLE [dbo].[EncounterNotes]  WITH CHECK ADD  CONSTRAINT [FK_EncounterNotes_Attachment] FOREIGN KEY([ManuscriptUid])
REFERENCES [dbo].[Manuscript] ([ManuscriptUid])
GO
ALTER TABLE [dbo].[EncounterNotes] CHECK CONSTRAINT [FK_EncounterNotes_Attachment]
GO
ALTER TABLE [dbo].[EncounterNotes]  WITH CHECK ADD  CONSTRAINT [FK_EncounterNotes_Encounter] FOREIGN KEY([EncounterUid])
REFERENCES [dbo].[Encounter] ([EncounterUid])
GO
ALTER TABLE [dbo].[EncounterNotes] CHECK CONSTRAINT [FK_EncounterNotes_Encounter]
GO
ALTER TABLE [dbo].[IncomingReview]  WITH CHECK ADD  CONSTRAINT [FK_IncomingReview_Correspondence] FOREIGN KEY([CorrespondenceUid])
REFERENCES [dbo].[Correspondence] ([CorrespondenceUid])
GO
ALTER TABLE [dbo].[IncomingReview] CHECK CONSTRAINT [FK_IncomingReview_Correspondence]
GO
ALTER TABLE [dbo].[IncomingReview]  WITH CHECK ADD  CONSTRAINT [FK_IncomingReview_Result] FOREIGN KEY([ClinicalResultUid])
REFERENCES [dbo].[Result] ([ClinicalResultUid])
GO
ALTER TABLE [dbo].[IncomingReview] CHECK CONSTRAINT [FK_IncomingReview_Result]
GO
ALTER TABLE [dbo].[Manuscript]  WITH CHECK ADD  CONSTRAINT [FK_Manuscript_Encounter] FOREIGN KEY([EncounterUid])
REFERENCES [dbo].[Encounter] ([EncounterUid])
GO
ALTER TABLE [dbo].[Manuscript] CHECK CONSTRAINT [FK_Manuscript_Encounter]
GO
ALTER TABLE [dbo].[Manuscript]  WITH CHECK ADD  CONSTRAINT [FK_Manuscript_ManuscriptAttachment] FOREIGN KEY([ManuscriptAttachmentUid])
REFERENCES [dbo].[ManuscriptAttachment] ([ManuscriptAttachmentUid])
GO
ALTER TABLE [dbo].[Manuscript] CHECK CONSTRAINT [FK_Manuscript_ManuscriptAttachment]
GO
ALTER TABLE [dbo].[Manuscript]  WITH CHECK ADD  CONSTRAINT [FK_Manuscript_ManuscriptAttachmentPDF] FOREIGN KEY([PDFManuscriptAttachmentUid])
REFERENCES [dbo].[ManuscriptAttachment] ([ManuscriptAttachmentUid])
GO
ALTER TABLE [dbo].[Manuscript] CHECK CONSTRAINT [FK_Manuscript_ManuscriptAttachmentPDF]
GO
ALTER TABLE [dbo].[ManuscriptAnswer]  WITH CHECK ADD  CONSTRAINT [FK_ManuscriptAnswer_Manuscript] FOREIGN KEY([ManuscriptUid])
REFERENCES [dbo].[Manuscript] ([ManuscriptUid])
GO
ALTER TABLE [dbo].[ManuscriptAnswer] CHECK CONSTRAINT [FK_ManuscriptAnswer_Manuscript]
GO
ALTER TABLE [dbo].[PathologyRequestTest]  WITH CHECK ADD  CONSTRAINT [FK_PathologyRequestTest_PathologyRequest] FOREIGN KEY([RequestUid])
REFERENCES [dbo].[PathologyRequest] ([RequestUid])
GO
ALTER TABLE [dbo].[PathologyRequestTest] CHECK CONSTRAINT [FK_PathologyRequestTest_PathologyRequest]
GO
ALTER TABLE [dbo].[PregnancyAneuploidyScreening]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyAneuploidyScreening_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyAneuploidyScreening] CHECK CONSTRAINT [FK_PregnancyAneuploidyScreening_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyCalculation]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyCalculation_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyCalculation] CHECK CONSTRAINT [FK_PregnancyCalculation_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyFetusGender]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyFetusGender_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyFetusGender] CHECK CONSTRAINT [FK_PregnancyFetusGender_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyInvestigation]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyInvestigation_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyInvestigation] CHECK CONSTRAINT [FK_PregnancyInvestigation_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyNeonatalRecord]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyNeonatalRecord_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyNeonatalRecord] CHECK CONSTRAINT [FK_PregnancyNeonatalRecord_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyNeonatalRecord]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyNeonatalRecord_PregnancyOutcome] FOREIGN KEY([OutcomeUid])
REFERENCES [dbo].[PregnancyOutcome] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyNeonatalRecord] CHECK CONSTRAINT [FK_PregnancyNeonatalRecord_PregnancyOutcome]
GO
ALTER TABLE [dbo].[PregnancyOutcome]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyOutcome_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyOutcome] CHECK CONSTRAINT [FK_PregnancyOutcome_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyOutcomeMaternal]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyOutcomeMaternal_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyOutcomeMaternal] CHECK CONSTRAINT [FK_PregnancyOutcomeMaternal_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyPhysicalExam]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyPhysicalExam_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyPhysicalExam] CHECK CONSTRAINT [FK_PregnancyPhysicalExam_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyPostnatal]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyPostnatal_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyPostnatal] CHECK CONSTRAINT [FK_PregnancyPostnatal_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyReminderItem]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyReminderItem_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyReminderItem] CHECK CONSTRAINT [FK_PregnancyReminderItem_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyScreeningUltrasound]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyScreeningUltrasound_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyScreeningUltrasound] CHECK CONSTRAINT [FK_PregnancyScreeningUltrasound_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancySummary]  WITH CHECK ADD  CONSTRAINT [FK_PregnancySummary_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancySummary] CHECK CONSTRAINT [FK_PregnancySummary_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyUltrasound]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyUltrasound_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyUltrasound] CHECK CONSTRAINT [FK_PregnancyUltrasound_PregnancyNew]
GO
ALTER TABLE [dbo].[PregnancyVisit]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyVisit_BloodPressure] FOREIGN KEY([BloodPressureUid])
REFERENCES [dbo].[BloodPressure] ([BloodPressureUid])
GO
ALTER TABLE [dbo].[PregnancyVisit] CHECK CONSTRAINT [FK_PregnancyVisit_BloodPressure]
GO
ALTER TABLE [dbo].[PregnancyVisit]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyVisit_HeightWeights] FOREIGN KEY([HeightWeightUid])
REFERENCES [dbo].[HeightWeights] ([HeightWeightsUid])
GO
ALTER TABLE [dbo].[PregnancyVisit] CHECK CONSTRAINT [FK_PregnancyVisit_HeightWeights]
GO
ALTER TABLE [dbo].[PregnancyVisit]  WITH CHECK ADD  CONSTRAINT [FK_PregnancyVisit_PregnancyNew] FOREIGN KEY([PregnancyUid])
REFERENCES [dbo].[PregnancyNew] ([Uid])
GO
ALTER TABLE [dbo].[PregnancyVisit] CHECK CONSTRAINT [FK_PregnancyVisit_PregnancyNew]
GO
ALTER TABLE [dbo].[Prescription]  WITH CHECK ADD  CONSTRAINT [FK_Prescription_Encounter] FOREIGN KEY([EncounterUid])
REFERENCES [dbo].[Encounter] ([EncounterUid])
GO
ALTER TABLE [dbo].[Prescription] CHECK CONSTRAINT [FK_Prescription_Encounter]
GO
ALTER TABLE [dbo].[PrescriptionDrug]  WITH CHECK ADD  CONSTRAINT [FK_PrescriptionDrug_Prescription] FOREIGN KEY([PrescriptionUid])
REFERENCES [dbo].[Prescription] ([PrescriptionUid])
GO
ALTER TABLE [dbo].[PrescriptionDrug] CHECK CONSTRAINT [FK_PrescriptionDrug_Prescription]
GO
ALTER TABLE [dbo].[PrescriptionDrugErxNotification]  WITH CHECK ADD  CONSTRAINT [FK_PrescriptionDrugErxNotification_PrescriptionDrug] FOREIGN KEY([PrescriptionDrugUid])
REFERENCES [dbo].[PrescriptionDrug] ([PrescriptionDrugUid])
GO
ALTER TABLE [dbo].[PrescriptionDrugErxNotification] CHECK CONSTRAINT [FK_PrescriptionDrugErxNotification_PrescriptionDrug]
GO
ALTER TABLE [dbo].[Result]  WITH CHECK ADD  CONSTRAINT [FK_Result_ClinicalRequest] FOREIGN KEY([RequestUid])
REFERENCES [dbo].[ClinicalRequest] ([RequestUid])
GO
ALTER TABLE [dbo].[Result] CHECK CONSTRAINT [FK_Result_ClinicalRequest]
GO
ALTER TABLE [dbo].[ResultAtomic]  WITH CHECK ADD  CONSTRAINT [FK_ResultAtomic_Result] FOREIGN KEY([ClinicalResultUid])
REFERENCES [dbo].[Result] ([ClinicalResultUid])
GO
ALTER TABLE [dbo].[ResultAtomic] CHECK CONSTRAINT [FK_ResultAtomic_Result]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates whether the Clinical Request is completed. NotCompleted = 0, AutomatchCompleted = 1, UserCompleted = 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClinicalRequest', @level2type=N'COLUMN',@level2name=N'Completed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the table in Stat to whic teh ID of the committer belongs - probably the User table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Encounter', @level2type=N'COLUMN',@level2name=N'CommitterType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the table in Stat to which th Composer Id belongs - could be Provider, or conceivableUser or Patient' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Encounter', @level2type=N'COLUMN',@level2name=N'ComposerType'
GO
USE [master]
GO
ALTER DATABASE [StatClinical] SET  READ_WRITE 
GO
