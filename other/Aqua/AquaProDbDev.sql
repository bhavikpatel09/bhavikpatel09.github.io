USE [master]
GO
/****** Object:  Database [AquaProDbDev]    Script Date: 26-08-2019 06:17:02 PM ******/
CREATE DATABASE [AquaProDbDev]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AquaProDbDev', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQL2016\MSSQL\DATA\AquaProDbDev.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AquaProDbDev_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQL2016\MSSQL\DATA\AquaProDbDev_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [AquaProDbDev] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AquaProDbDev].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AquaProDbDev] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AquaProDbDev] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AquaProDbDev] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AquaProDbDev] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AquaProDbDev] SET ARITHABORT OFF 
GO
ALTER DATABASE [AquaProDbDev] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [AquaProDbDev] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AquaProDbDev] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AquaProDbDev] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AquaProDbDev] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AquaProDbDev] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AquaProDbDev] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AquaProDbDev] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AquaProDbDev] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AquaProDbDev] SET  DISABLE_BROKER 
GO
ALTER DATABASE [AquaProDbDev] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AquaProDbDev] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AquaProDbDev] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AquaProDbDev] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AquaProDbDev] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AquaProDbDev] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AquaProDbDev] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AquaProDbDev] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [AquaProDbDev] SET  MULTI_USER 
GO
ALTER DATABASE [AquaProDbDev] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AquaProDbDev] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AquaProDbDev] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AquaProDbDev] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [AquaProDbDev] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [AquaProDbDev] SET QUERY_STORE = OFF
GO
USE [AquaProDbDev]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [AquaProDbDev]
GO
/****** Object:  UserDefinedTableType [dbo].[ModulePermissions]    Script Date: 26-08-2019 06:17:03 PM ******/
CREATE TYPE [dbo].[ModulePermissions] AS TABLE(
	[ApplicationModuleId] [int] NULL,
	[ModuleMasterId] [int] NULL,
	[ParentApplicationModuleId] [int] NULL,
	[ModuleMasterName] [nvarchar](100) NULL,
	[ModuleLevel] [int] NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[fnColumnDescription]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnColumnDescription](@TableName varchar(100), @ColumnName varchar(100))  
RETURNS varchar(max)
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @description varchar(max);  
	select @description = CONVERT(varchar(max),sep.value) from sys.tables st inner join sys.columns sc on st.object_id = sc.object_id 
        left join sys.extended_properties sep on st.object_id = sep.major_id
                                         and sc.column_id = sep.minor_id 
                                         and sep.name = 'MS_Description' where sep.value IS NOT NULL and st.name = @TableName and sc.name = @ColumnName
    RETURN @description;  
END;  
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetParentName]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetParentName] 
(
 @ParentApplicationModuleId int
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @ParentName nvarchar(50)

	Select 
			@ParentName=MM.ModuleMasterName 
	from 
			ModuleMasters(nolock) MM
			INNER JOIN ApplicationModules(nolock) AM ON AM.ModuleMasterId=MM.ModuleMasterId
	WHERE 
			AM.ApplicationModuleId =@ParentApplicationModuleId
			AND
			MM.IsRoot=0

	Return  ISNULL('['+@ParentName+']','') 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnIsColumnPrimaryKey]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnIsColumnPrimaryKey](@TableName varchar(100), @ColumnName varchar(100))  
RETURNS bit
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @isPrimaryKey bit; 
	DECLARE @constrainName varchar(max); 
	SELECT @constrainName = A.CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS A, INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE B 
WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND A.CONSTRAINT_NAME = B.CONSTRAINT_NAME  and A.TABLE_NAME  = @TableName and b.COLUMN_NAME = @ColumnName
ORDER BY A.TABLE_NAME
    IF(@constrainName IS NULL)
	set @isPrimaryKey = 0;
	else
	  set @isPrimaryKey = 1;
	  return @isPrimaryKey;
END;  
GO
/****** Object:  UserDefinedFunction [dbo].[fnTableDescription]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnTableDescription](@TableName varchar(100))  
RETURNS varchar(max)
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @description varchar(max);  
		select @description = CONVERT(varchar(max), sep.value) from sys.tables st 
			inner join sys.extended_properties sep on st.object_id = sep.major_id 
			and sep.name = 'MS_Description' 
			where sep.value IS  NOT NULL and sep.minor_id = 0 and st.name = @TableName
			RETURN @description;  
END;  
GO
/****** Object:  Table [dbo].[Users]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[EmailId] [nvarchar](100) NOT NULL,
	[Password] [binary](132) NULL,
	[Salt] [binary](140) NULL,
	[FirstName] [varchar](100) NOT NULL,
	[LastName] [varchar](100) NULL,
	[DateOfBirth] [date] NULL,
	[GenderId] [int] NULL,
	[Address] [varchar](250) NULL,
	[City] [varchar](50) NULL,
	[ZipCode] [varchar](15) NULL,
	[PhoneNumber] [varchar](20) NULL,
	[VerificationCode] [uniqueidentifier] NULL,
	[ApplicationTimeZoneId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [smalldatetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [smalldatetime] NULL,
	[StatusId] [int] NOT NULL,
	[MaximumEventsLimit] [int] NULL,
	[Country] [varchar](50) NULL,
	[State] [varchar](50) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationObjects]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationObjects](
	[ApplicationObjectId] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationObjectTypeId] [int] NOT NULL,
	[ApplicationObjectName] [varchar](100) NOT NULL,
	[IsActive] [int] NULL,
 CONSTRAINT [PK_ApplicationObjects] PRIMARY KEY CLUSTERED 
(
	[ApplicationObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 26-08-2019 06:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vUsers]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vUsers]
AS
SELECT
    U.UserId
   ,R.RoleName
   ,EmailId
   ,Salt
   ,FirstName
   ,LastName
   ,DateOfBirth
   ,G.ApplicationObjectName AS Gender
   ,Address
   ,City
   ,Country
   ,ZipCode
   ,PhoneNumber
   ,U.IsActive
   ,CreatedBy
   ,CreatedOn
   ,ModifiedBy
   ,ModifiedOn
   ,S.ApplicationObjectName AS Status
   ,MaximumEventsLimit
   ,[State]
FROM Users U
INNER JOIN Roles R
    ON R.RoleId = U.RoleId
LEFT JOIN ApplicationObjects G
    ON G.ApplicationObjectId = U.GenderId
LEFT JOIN ApplicationObjects S
    ON S.ApplicationObjectId = U.StatusId
WHERE StatusId IN (1, 2)



GO
/****** Object:  View [dbo].[vUserRecords]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




  
  
CREATE VIEW [dbo].[vUserRecords]  
AS
SELECT
    UserId
   ,RoleId
   ,EmailId
   ,FirstName
   ,LastName
   ,DateOfBirth
   ,GenderId
   ,Address
   ,City
   ,Country
   ,ZipCode
   ,PhoneNumber
   ,VerificationCode
   ,ApplicationTimeZoneId
   ,IsActive
   ,CreatedBy
   ,CreatedOn
   ,ModifiedBy
   ,ModifiedOn
   ,StatusId
   ,MaximumEventsLimit
   ,[State]
FROM Users U



GO
/****** Object:  Table [dbo].[ApplicationExceptionLogs]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationExceptionLogs](
	[ApplicationExceptionLogId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ApplicationTimeZoneId] [int] NULL,
	[ApplicationModuleId] [int] NULL,
	[Url] [varchar](200) NOT NULL,
	[RequestMethod] [varchar](10) NULL,
	[Message] [varchar](max) NOT NULL,
	[ExceptionType] [varchar](max) NOT NULL,
	[ExceptionSource] [varchar](max) NOT NULL,
	[StackTrace] [varchar](max) NOT NULL,
	[InnerException] [varchar](max) NOT NULL,
	[ExceptionDate] [date] NOT NULL,
 CONSTRAINT [PK_ApplicationExceptionLog] PRIMARY KEY CLUSTERED 
(
	[ApplicationExceptionLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationModules]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationModules](
	[ApplicationModuleId] [int] IDENTITY(1,1) NOT NULL,
	[ModuleMasterId] [int] NOT NULL,
	[ParentApplicationModuleId] [int] NULL,
	[VisibleActionItem] [varchar](1) NOT NULL,
 CONSTRAINT [PK_ApplicationModules] PRIMARY KEY CLUSTERED 
(
	[ApplicationModuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationObjectTypes]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationObjectTypes](
	[ApplicationObjectTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationObjectTypeName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ApplicationObjectTypes] PRIMARY KEY CLUSTERED 
(
	[ApplicationObjectTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationTimeZones]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationTimeZones](
	[ApplicationTimeZoneId] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[ApplicationTimeZoneName] [varchar](100) NOT NULL,
	[Comment] [varchar](200) NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_TimeZones] PRIMARY KEY CLUSTERED 
(
	[ApplicationTimeZoneId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationUserTokens]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationUserTokens](
	[ApplicationUserTokenId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[SecurityKey] [binary](32) NOT NULL,
	[JwtToken] [varchar](max) NOT NULL,
	[TokenIssuer] [varchar](50) NOT NULL,
	[AccessedPlatform] [varchar](100) NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[ExpiresAt] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IPAddress] [varchar](50) NULL,
	[PlatformId] [int] NULL,
	[BrowserName] [varchar](50) NULL,
	[AppVersion] [varchar](10) NULL,
	[DeviceName] [varchar](50) NULL,
	[DeviceOSVersion] [varchar](10) NULL,
	[DeviceID] [varchar](50) NULL,
 CONSTRAINT [PK_ApplicationUserTokens] PRIMARY KEY CLUSTERED 
(
	[ApplicationUserTokenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditRecordDetails]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditRecordDetails](
	[AuditRecordDetailId] [int] IDENTITY(1,1) NOT NULL,
	[AuditRecordId] [int] NOT NULL,
	[ColumnName] [varchar](50) NOT NULL,
	[OldValue] [nvarchar](max) NULL,
	[NewValue] [nvarchar](max) NULL,
	[ReferenceTableName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_AuditRecordDetails] PRIMARY KEY CLUSTERED 
(
	[AuditRecordDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditRecords]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditRecords](
	[AuditRecordId] [int] IDENTITY(1,1) NOT NULL,
	[AuditRequestId] [int] NULL,
	[EventType] [varchar](9) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[RecordId] [varchar](100) NOT NULL,
	[RecordName] [nvarchar](max) NOT NULL,
	[OldValue] [nvarchar](max) NULL,
	[NewValue] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_AuditRecords] PRIMARY KEY CLUSTERED 
(
	[AuditRecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditRequests]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditRequests](
	[AuditRequestId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ApplicationModuleId] [int] NOT NULL,
	[ApplicationTimeZoneId] [int] NOT NULL,
	[MainRecordId] [varchar](100) NOT NULL,
	[Uri] [varchar](max) NOT NULL,
	[RequestMethod] [varchar](20) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AuditRequests] PRIMARY KEY CLUSTERED 
(
	[AuditRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CacheCollections]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CacheCollections](
	[CacheCollectionId] [int] IDENTITY(1,1) NOT NULL,
	[CacheCollectionKey] [varchar](50) NOT NULL,
	[Data] [varbinary](max) NULL,
	[StringData] [nvarchar](max) NULL,
 CONSTRAINT [PK_CacheContents] PRIMARY KEY CLUSTERED 
(
	[CacheCollectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CacheKeys]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CacheKeys](
	[CacheKeyId] [int] IDENTITY(1,1) NOT NULL,
	[CacheKeyName] [varchar](50) NOT NULL,
	[KeyId] [varchar](100) NOT NULL,
 CONSTRAINT [PK_CacheKeys_1] PRIMARY KEY CLUSTERED 
(
	[CacheKeyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConfigurationContents]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConfigurationContents](
	[ConfigurationContentId] [int] IDENTITY(1,1) NOT NULL,
	[ConfigurationContentName] [varchar](max) NOT NULL,
	[En] [varchar](max) NOT NULL,
	[Fr] [nvarchar](max) NULL,
 CONSTRAINT [PK_ConfigurationContents] PRIMARY KEY CLUSTERED 
(
	[ConfigurationContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Countries]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countries](
	[CountryId] [int] IDENTITY(1,1) NOT NULL,
	[DefaultLanguageId] [int] NOT NULL,
	[CountryName] [varchar](50) NOT NULL,
	[CountryCode] [varchar](50) NOT NULL,
	[DateFormat] [varchar](50) NULL,
	[DateFormatSeperator] [varchar](50) NULL,
	[CurrencyFormat] [nvarchar](20) NULL,
	[DecimalSeperator] [varchar](50) NULL,
	[PhoneFormat] [varchar](50) NULL,
	[PostalCodeFormat] [varchar](50) NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GlobalSettings]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GlobalSettings](
	[ConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[RecordLock] [bit] NOT NULL,
	[LockDuration] [varchar](10) NULL,
	[ApplicationTimeZoneId] [int] NOT NULL,
	[LanguageId] [int] NOT NULL,
	[RequestLogging] [bit] NOT NULL,
	[SocialAuth] [bit] NOT NULL,
	[TwoFactorAuthentication] [bit] NOT NULL,
	[AutoTranslation] [bit] NOT NULL,
 CONSTRAINT [PK_GlobalSettings] PRIMARY KEY CLUSTERED 
(
	[ConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LanguageContents]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LanguageContents](
	[LanguageContentId] [int] IDENTITY(1,1) NOT NULL,
	[LanguageContentName] [varchar](50) NOT NULL,
	[ContentType] [varchar](50) NULL,
	[En] [varchar](max) NULL,
	[Fr] [nvarchar](max) NULL,
 CONSTRAINT [PK_LanguageContents] PRIMARY KEY CLUSTERED 
(
	[LanguageContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Languages]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Languages](
	[LanguageId] [int] IDENTITY(1,1) NOT NULL,
	[LanguageName] [varchar](100) NOT NULL,
	[LanguageCode] [varchar](2) NOT NULL,
	[Active] [bit] NOT NULL,
	[AutoTranslate] [bit] NULL,
 CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED 
(
	[LanguageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LockRecords]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LockRecords](
	[LockRecordId] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationModuleId] [int] NOT NULL,
	[UserName] [varchar](100) NOT NULL,
	[RecordId] [int] NOT NULL,
	[ChildModuleName] [varchar](100) NULL,
	[ExpiresAt] [datetime] NOT NULL,
 CONSTRAINT [PK_LockRecords] PRIMARY KEY CLUSTERED 
(
	[LockRecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ModuleContents]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModuleContents](
	[ModuleContentId] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationModuleId] [int] NOT NULL,
	[LanguageContentId] [int] NOT NULL,
	[LanguageContentType] [varchar](20) NULL,
	[ServerMessageId] [int] NULL,
	[Action] [varchar](10) NOT NULL,
	[En] [varchar](max) NULL,
	[Fr] [nvarchar](max) NULL,
 CONSTRAINT [PK_ModuleProperties] PRIMARY KEY CLUSTERED 
(
	[ModuleContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ModuleMasters]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModuleMasters](
	[ModuleMasterId] [int] IDENTITY(1,1) NOT NULL,
	[ModuleMasterName] [varchar](100) NOT NULL,
	[IsRolePermissionItem] [bit] NULL,
	[IsRoot] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_ModuleMasters] PRIMARY KEY CLUSTERED 
(
	[ModuleMasterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RequestLogs]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RequestLogs](
	[RequestLogId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[ApplicationModuleId] [int] NULL,
	[RecordId] [varchar](100) NULL,
	[RequestMethod] [varchar](10) NOT NULL,
	[ServiceUri] [varchar](100) NOT NULL,
	[ClientIPAddress] [varchar](50) NULL,
	[BrowserName] [varchar](200) NULL,
	[RequestTime] [datetime] NOT NULL,
	[TotalDuration] [time](7) NOT NULL,
	[Parameters] [nvarchar](max) NOT NULL,
	[ContentLength] [int] NULL,
	[Cookies] [varchar](max) NULL,
	[AuthorizationHeader] [varchar](max) NULL,
	[ResponseStatusCode] [int] NOT NULL,
 CONSTRAINT [PK_RequestLogs] PRIMARY KEY CLUSTERED 
(
	[RequestLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RolePermissions]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RolePermissions](
	[RolePermissionId] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[ApplicationModuleId] [int] NOT NULL,
	[CanView] [bit] NOT NULL,
	[CanAdd] [bit] NOT NULL,
	[CanEdit] [bit] NOT NULL,
	[CanDelete] [bit] NOT NULL,
 CONSTRAINT [PK_RolePermissions] PRIMARY KEY CLUSTERED 
(
	[RolePermissionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMTPConfigurations]    Script Date: 26-08-2019 06:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMTPConfigurations](
	[SmtpConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[FromEmail] [varchar](200) NOT NULL,
	[DefaultCredentials] [bit] NULL,
	[EnableSSL] [bit] NULL,
	[Host] [varchar](100) NOT NULL,
	[UserName] [varchar](200) NULL,
	[Password] [varchar](100) NULL,
	[Port] [int] NOT NULL,
	[DeliveryMethod] [varchar](100) NULL,
	[SendIndividually] [bit] NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_EmailConfiguration] PRIMARY KEY CLUSTERED 
(
	[SmtpConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[ApplicationModules] ON 

INSERT [dbo].[ApplicationModules] ([ApplicationModuleId], [ModuleMasterId], [ParentApplicationModuleId], [VisibleActionItem]) VALUES (1, 1, NULL, N'F')
INSERT [dbo].[ApplicationModules] ([ApplicationModuleId], [ModuleMasterId], [ParentApplicationModuleId], [VisibleActionItem]) VALUES (2, 1, 1, N'F')
INSERT [dbo].[ApplicationModules] ([ApplicationModuleId], [ModuleMasterId], [ParentApplicationModuleId], [VisibleActionItem]) VALUES (3, 2, NULL, N'F')
INSERT [dbo].[ApplicationModules] ([ApplicationModuleId], [ModuleMasterId], [ParentApplicationModuleId], [VisibleActionItem]) VALUES (4, 3, 3, N'F')
SET IDENTITY_INSERT [dbo].[ApplicationModules] OFF
SET IDENTITY_INSERT [dbo].[ApplicationObjects] ON 

INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (1, 1, N'Active', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (2, 1, N'InActive', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (3, 1, N'Delete', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (4, 2, N'Male', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (5, 2, N'Female', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (6, 2, N'Other', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (7, 3, N'Alphanumeric', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (8, 3, N'Numeric', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (14, 4, N'View', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (15, 4, N'Edit', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (16, 6, N'Imported', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (17, 6, N'Manual', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (18, 7, N'Attended', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (19, 7, N'Absent', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (20, 8, N'QRScan', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (21, 8, N'Manual', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (22, 5, N'Upcoming', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (23, 5, N'Completed', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (24, 5, N'Cancelled', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (25, 9, N'MarkEventsCompletedAfterEventDate', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (26, 10, N'TotalEvents', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (27, 10, N'TotalGuests', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (28, 10, N'EventGuests', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (29, 10, N'ManuallyRegisteredVsScannedGuests', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (30, 10, N'TotalEventOrganizers', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (31, 11, N'Web', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (32, 11, N'Android', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (33, 12, N'Email', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (34, 12, N'Message', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (35, 13, N'Invite', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (36, 13, N'GuestPlacement', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (37, 13, N'SurveyUrl', 1)
INSERT [dbo].[ApplicationObjects] ([ApplicationObjectId], [ApplicationObjectTypeId], [ApplicationObjectName], [IsActive]) VALUES (38, 9, N'SendSurveyUrlMailAfterEventDate', 1)
SET IDENTITY_INSERT [dbo].[ApplicationObjects] OFF
SET IDENTITY_INSERT [dbo].[ApplicationObjectTypes] ON 

INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (1, N'Status')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (2, N'Gender')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (3, N'CustomFieldType')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (4, N'AccessType')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (5, N'Event Status')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (6, N'Guest Type')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (7, N'Attendance Status')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (8, N'Attendance Method')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (9, N'Scheduler Type')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (10, N'Report Type')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (11, N'Platform')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (12, N'Communication Type')
INSERT [dbo].[ApplicationObjectTypes] ([ApplicationObjectTypeId], [ApplicationObjectTypeName]) VALUES (13, N'Communication Content Type')
SET IDENTITY_INSERT [dbo].[ApplicationObjectTypes] OFF
SET IDENTITY_INSERT [dbo].[ApplicationTimeZones] ON 

INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (1, 160, N'Europe/Andorra', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (2, 15, N'Pacific/Port_Moresby', N'Papua New Guinea (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (3, 233, N'Pacific/Gambier', N'Gambier Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (4, 233, N'Pacific/Marquesas', N'Marquesas Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (5, 233, N'Pacific/Tahiti', N'Society Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (6, 17, N'America/Lima', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (7, 14, N'America/Panama', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (8, 10, N'Asia/Muscat', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (9, 2, N'Pacific/Chatham', N'Chatham Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (10, 2, N'Pacific/Auckland', N'New Zealand (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (11, 6, N'Pacific/Niue', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (12, 15, N'Pacific/Bougainville', N'Bougainville', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (13, 32, N'Pacific/Nauru', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (14, 9, N'Europe/Oslo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (15, 31, N'Europe/Amsterdam', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (16, 3, N'America/Managua', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (17, 5, N'Africa/Lagos', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (18, 7, N'Pacific/Norfolk', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (19, 4, N'Africa/Niamey', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (20, 29, N'Pacific/Noumea', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (21, 59, N'Africa/Windhoek', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (22, 57, N'Africa/Maputo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (23, 40, N'Asia/Kuching', N'Sabah, Sarawak', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (24, 60, N'Asia/Kathmandu', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (25, 18, N'Asia/Manila', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (26, 11, N'Asia/Karachi', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (27, 20, N'Europe/Warsaw', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (28, 26, N'Europe/Samara', N'MSK+01 - Samara, Udmurtia', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (29, 26, N'Europe/Ulyanovsk', N'MSK+01 - Ulyanovsk', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (30, 26, N'Europe/Saratov', N'MSK+01 - Saratov', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (31, 26, N'Europe/Astrakhan', N'MSK+01 - Astrakhan', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (32, 26, N'Europe/Kirov', N'MSK+00 - Kirov', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (33, 26, N'Europe/Volgograd', N'MSK+00 - Volgograd', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (34, 26, N'Europe/Simferopol', N'MSK+00 - Crimea', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (35, 26, N'Europe/Moscow', N'MSK+00 - Moscow area', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (36, 26, N'Europe/Kaliningrad', N'MSK-01 - Kaliningrad', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (37, 96, N'Europe/Belgrade', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (38, 25, N'Europe/Bucharest', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (39, 24, N'Indian/Reunion', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (40, 23, N'Asia/Qatar', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (41, 16, N'America/Asuncion', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (42, 12, N'Pacific/Palau', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (43, 21, N'Atlantic/Azores', N'Azores', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (44, 21, N'Atlantic/Madeira', N'Madeira Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (45, 21, N'Europe/Lisbon', N'Portugal (mainland)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (46, 13, N'Asia/Hebron', N'West Bank', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (47, 13, N'Asia/Gaza', N'Gaza Strip', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (48, 22, N'America/Puerto_Rico', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (49, 19, N'Pacific/Pitcairn', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (50, 115, N'America/Miquelon', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (51, 40, N'Asia/Kuala_Lumpur', N'Malaysia (peninsula)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (52, 26, N'Asia/Yekaterinburg', N'MSK+02 - Urals', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (53, 49, N'America/Bahia_Banderas', N'Central Time - Bahia de Banderas', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (54, 49, N'America/Hermosillo', N'Mountain Standard Time - Sonora', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (55, 54, N'Europe/Podgorica', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (56, 51, N'Europe/Chisinau', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (57, 52, N'Europe/Monaco', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (58, 56, N'Africa/Casablanca', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (59, 61, N'Africa/Tripoli', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (60, 214, N'Europe/Riga', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (61, 35, N'Europe/Luxembourg', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (62, 34, N'Europe/Vilnius', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (63, 185, N'Africa/Maseru', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (64, 124, N'Africa/Monrovia', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (65, 114, N'America/Marigot', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (66, 108, N'Asia/Colombo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (67, 112, N'America/St_Lucia', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (68, 125, N'Asia/Beirut', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (69, 213, N'Asia/Vientiane', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (70, 206, N'Asia/Oral', N'West Kazakhstan', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (71, 206, N'Asia/Atyrau', N'Atyrau/Atirau/Gur''yev', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (72, 206, N'Asia/Aqtau', N'Mangghystau/Mankistau', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (73, 206, N'Asia/Aqtobe', N'Aqtobe/Aktobe', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (74, 206, N'Asia/Qyzylorda', N'Qyzylorda/Kyzylorda/Kzyl-Orda', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (75, 206, N'Asia/Almaty', N'Kazakhstan (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (76, 134, N'America/Cayman', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (77, 33, N'Europe/Vaduz', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (78, 38, N'Indian/Antananarivo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (79, 44, N'Pacific/Majuro', N'Marshall Islands (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (80, 44, N'Pacific/Kwajalein', N'Kwajalein', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (81, 49, N'America/Ojinaga', N'Mountain Time US - Chihuahua (US border)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (82, 49, N'America/Chihuahua', N'Mountain Time - Chihuahua (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (83, 49, N'America/Mazatlan', N'Mountain Time - Baja California Sur, Nayarit, Sinaloa', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (84, 49, N'America/Matamoros', N'Central Time US - Coahuila, Nuevo Leon, Tamaulipas (US border)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (85, 49, N'America/Monterrey', N'Central Time - Durango; Coahuila, Nuevo Leon, Tamaulipas (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (86, 49, N'America/Merida', N'Central Time - Campeche, Yucatan', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (87, 49, N'America/Cancun', N'Eastern Standard Time - Quintana Roo', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (88, 49, N'America/Mexico_City', N'Central Time', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (89, 39, N'Africa/Blantyre', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (90, 41, N'Indian/Maldives', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (91, 47, N'Indian/Mauritius', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (92, 43, N'Europe/Malta', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (93, 55, N'America/Montserrat', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (94, 46, N'Africa/Nouakchott', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (95, 45, N'America/Martinique', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (96, 8, N'Pacific/Saipan', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (97, 36, N'Asia/Macau', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (98, 53, N'Asia/Choibalsan', N'Dornod, Sukhbaatar', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (99, 53, N'Asia/Hovd', N'Bayan-Olgiy, Govi-Altai, Hovd, Uvs, Zavkhan', 1)
GO
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (100, 53, N'Asia/Ulaanbaatar', N'Mongolia (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (101, 58, N'Asia/Yangon', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (102, 42, N'Africa/Bamako', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (103, 37, N'Europe/Skopje', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (104, 49, N'America/Tijuana', N'Pacific Time US - Baja California', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (105, 211, N'Asia/Kuwait', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (106, 26, N'Asia/Omsk', N'MSK+03 - Omsk', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (107, 26, N'Asia/Barnaul', N'MSK+04 - Altai', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (108, 78, N'America/North_Dakota/Beulah', N'Central - ND (Mercer)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (109, 78, N'America/North_Dakota/New_Salem', N'Central - ND (Morton rural)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (110, 78, N'America/North_Dakota/Center', N'Central - ND (Oliver)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (111, 78, N'America/Menominee', N'Central - MI (Wisconsin border)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (112, 78, N'America/Indiana/Knox', N'Central - IN (Starke)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (113, 78, N'America/Indiana/Tell_City', N'Central - IN (Perry)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (114, 78, N'America/Chicago', N'Central (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (115, 78, N'America/Indiana/Vevay', N'Eastern - IN (Switzerland)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (116, 78, N'America/Indiana/Petersburg', N'Eastern - IN (Pike)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (117, 78, N'America/Indiana/Marengo', N'Eastern - IN (Crawford)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (118, 78, N'America/Denver', N'Mountain (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (119, 78, N'America/Indiana/Winamac', N'Eastern - IN (Pulaski)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (120, 78, N'America/Indiana/Indianapolis', N'Eastern - IN (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (121, 78, N'America/Kentucky/Monticello', N'Eastern - KY (Wayne)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (122, 78, N'America/Kentucky/Louisville', N'Eastern - KY (Louisville area)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (123, 78, N'America/Detroit', N'Eastern - MI (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (124, 78, N'America/New_York', N'Eastern (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (125, 80, N'Pacific/Wake', N'Wake Island', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (126, 80, N'Pacific/Midway', N'Midway Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (127, 75, N'Africa/Kampala', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (128, 76, N'Europe/Zaporozhye', N'Zaporozh''ye/Zaporizhia; Lugansk/Luhansk (east)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (129, 76, N'Europe/Uzhgorod', N'Ruthenia', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (130, 78, N'America/Indiana/Vincennes', N'Eastern - IN (Da, Du, K, Mn)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (131, 78, N'America/Boise', N'Mountain - ID (south); OR (east)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (132, 78, N'America/Phoenix', N'MST - Arizona (except Navajo)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (133, 78, N'America/Los_Angeles', N'Pacific', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (134, 104, N'Africa/Johannesburg', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (135, 48, N'Indian/Mayotte', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (136, 90, N'Asia/Aden', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (137, 30, N'Pacific/Apia', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (138, 88, N'Pacific/Wallis', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (139, 82, N'Pacific/Efate', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (140, 85, N'Asia/Ho_Chi_Minh', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (141, 87, N'America/St_Thomas', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (142, 86, N'America/Tortola', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (143, 84, N'America/Caracas', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (144, 116, N'America/St_Vincent', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (145, 83, N'Europe/Vatican', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (146, 81, N'Asia/Tashkent', N'Uzbekistan (east)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (147, 81, N'Asia/Samarkand', N'Uzbekistan (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (148, 79, N'America/Montevideo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (149, 78, N'Pacific/Honolulu', N'Hawaii', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (150, 78, N'America/Adak', N'Aleutian Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (151, 78, N'America/Nome', N'Alaska (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (152, 78, N'America/Yakutat', N'Alaska - Yakutat', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (153, 78, N'America/Metlakatla', N'Alaska - Annette Island', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (154, 78, N'America/Sitka', N'Alaska - Sitka area', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (155, 78, N'America/Juneau', N'Alaska - Juneau area', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (156, 78, N'America/Anchorage', N'Alaska (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (157, 76, N'Europe/Kiev', N'Ukraine (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (158, 26, N'Asia/Novosibirsk', N'MSK+04 - Novosibirsk', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (159, 64, N'Africa/Dar_es_Salaam', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (160, 74, N'Pacific/Funafuti', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (161, 110, N'Atlantic/St_Helena', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (162, 99, N'Asia/Singapore', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (163, 121, N'Europe/Stockholm', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (164, 117, N'Africa/Khartoum', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (165, 97, N'Indian/Mahe', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (166, 102, N'Pacific/Guadalcanal', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (167, 63, N'Asia/Riyadh', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (168, 27, N'Africa/Kigali', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (169, 26, N'Asia/Anadyr', N'MSK+09 - Bering Sea', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (170, 26, N'Asia/Kamchatka', N'MSK+09 - Kamchatka', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (171, 101, N'Europe/Ljubljana', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (172, 26, N'Asia/Srednekolymsk', N'MSK+08 - Sakha (E); North Kuril Is', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (173, 26, N'Asia/Magadan', N'MSK+08 - Magadan', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (174, 26, N'Asia/Ust-Nera', N'MSK+07 - Oymyakonsky', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (175, 26, N'Asia/Vladivostok', N'MSK+07 - Amur River', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (176, 26, N'Asia/Khandyga', N'MSK+06 - Tomponsky, Ust-Maysky', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (177, 26, N'Asia/Yakutsk', N'MSK+06 - Lena River', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (178, 26, N'Asia/Chita', N'MSK+06 - Zabaykalsky', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (179, 26, N'Asia/Irkutsk', N'MSK+05 - Irkutsk, Buryatia', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (180, 26, N'Asia/Krasnoyarsk', N'MSK+04 - Krasnoyarsk area', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (181, 26, N'Asia/Novokuznetsk', N'MSK+04 - Kemerovo', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (182, 26, N'Asia/Tomsk', N'MSK+04 - Tomsk', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (183, 26, N'Asia/Sakhalin', N'MSK+08 - Sakhalin Island', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (184, 119, N'Arctic/Longyearbyen', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (185, 100, N'Europe/Bratislava', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (186, 98, N'Africa/Freetown', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (187, 69, N'America/Port_of_Spain', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (188, 71, N'Europe/Istanbul', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (189, 68, N'Pacific/Tongatapu', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (190, 70, N'Africa/Tunis', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (191, 72, N'Asia/Ashgabat', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (192, 219, N'Asia/Dili', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (193, 67, N'Pacific/Fakaofo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (194, 91, N'Asia/Dushanbe', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (195, 65, N'Asia/Bangkok', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (196, 66, N'Africa/Lome', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (197, 234, N'Indian/Kerguelen', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (198, 136, N'Africa/Ndjamena', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (199, 73, N'America/Grand_Turk', N'', 1)
GO
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (200, 120, N'Africa/Mbabane', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (201, 122, N'Asia/Damascus', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (202, 113, N'America/Lower_Princes', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (203, 222, N'America/El_Salvador', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (204, 92, N'Africa/Sao_Tome', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (205, 106, N'Africa/Juba', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (206, 118, N'America/Paramaribo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (207, 103, N'Africa/Mogadishu', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (208, 95, N'Africa/Dakar', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (209, 62, N'Europe/San_Marino', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (210, 93, N'Asia/Taipei', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (211, 210, N'Asia/Seoul', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (212, 209, N'Asia/Pyongyang', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (213, 111, N'America/St_Kitts', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (214, 156, N'America/Manaus', N'Amazonas (east)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (215, 156, N'America/Boa_Vista', N'Roraima', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (216, 156, N'America/Porto_Velho', N'Rondonia', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (217, 156, N'America/Santarem', N'Para (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (218, 156, N'America/Cuiaba', N'Mato Grosso', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (219, 156, N'America/Campo_Grande', N'Mato Grosso do Sul', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (220, 156, N'America/Sao_Paulo', N'Brazil (southeast: GO, DF, MG, ES, RJ, SP, PR, SC, RS)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (221, 156, N'America/Bahia', N'Bahia', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (222, 156, N'America/Maceio', N'Alagoas, Sergipe', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (223, 156, N'America/Araguaina', N'Tocantins', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (224, 156, N'America/Eirunepe', N'Amazonas (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (225, 156, N'America/Recife', N'Pernambuco', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (226, 156, N'America/Belem', N'Para (east); Amapa', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (227, 156, N'America/Noronha', N'Atlantic islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (228, 133, N'America/Kralendijk', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (229, 181, N'America/La_Paz', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (230, 153, N'Asia/Brunei', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (231, 179, N'Atlantic/Bermuda', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (232, 109, N'America/St_Barthelemy', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (233, 178, N'Africa/Porto-Novo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (234, 128, N'Africa/Bujumbura', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (235, 172, N'Asia/Bahrain', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (236, 156, N'America/Fortaleza', N'Brazil (northeast: MA, PI, CE, RN, PB)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (237, 156, N'America/Rio_Branco', N'Acre', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (238, 171, N'America/Nassau', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (239, 180, N'Asia/Thimphu', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (240, 131, N'America/Cambridge_Bay', N'Mountain - NU (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (241, 131, N'America/Edmonton', N'Mountain - AB; BC (E); SK (W)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (242, 131, N'America/Swift_Current', N'CST - SK (midwest)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (243, 131, N'America/Regina', N'CST - SK (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (244, 131, N'America/Rankin_Inlet', N'Central - NU (central)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (245, 131, N'America/Resolute', N'Central - NU (Resolute)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (246, 131, N'America/Rainy_River', N'Central - ON (Rainy R, Ft Frances)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (247, 131, N'America/Winnipeg', N'Central - ON (west); Manitoba', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (248, 131, N'America/Atikokan', N'EST - ON (Atikokan); NU (Coral H)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (249, 131, N'America/Pangnirtung', N'Eastern - NU (Pangnirtung)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (250, 131, N'America/Iqaluit', N'Eastern - NU (most east areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (251, 131, N'America/Thunder_Bay', N'Eastern - ON (Thunder Bay)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (252, 131, N'America/Nipigon', N'Eastern - ON, QC (no DST 1967-73)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (253, 131, N'America/Toronto', N'Eastern - ON, QC (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (254, 131, N'America/Blanc-Sablon', N'AST - QC (Lower North Shore)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (255, 131, N'America/Goose_Bay', N'Atlantic - Labrador (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (256, 131, N'America/Moncton', N'Atlantic - New Brunswick', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (257, 131, N'America/Glace_Bay', N'Atlantic - NS (Cape Breton)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (258, 131, N'America/Halifax', N'Atlantic - NS (most areas); PE', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (259, 131, N'America/St_Johns', N'Newfoundland; Labrador (southeast)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (260, 177, N'America/Belize', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (261, 175, N'Europe/Minsk', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (262, 183, N'Africa/Gaborone', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (263, 126, N'Europe/Sofia', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (264, 131, N'America/Yellowknife', N'Mountain - NT (central)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (265, 127, N'Africa/Ouagadougou', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (266, 173, N'Asia/Dhaka', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (267, 165, N'America/Argentina/Tucuman', N'Tucuman (TM)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (268, 165, N'America/Argentina/Jujuy', N'Jujuy (JY)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (269, 165, N'America/Argentina/Salta', N'Salta (SA, LP, NQ, RN)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (270, 165, N'America/Argentina/Cordoba', N'Argentina (most areas: CB, CC, CN, ER, FM, MN, SE, SF)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (271, 165, N'America/Argentina/Buenos_Aires', N'Buenos Aires (BA, CF)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (272, 163, N'Antarctica/Vostok', N'Vostok', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (273, 163, N'Antarctica/Troll', N'Troll', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (274, 163, N'Antarctica/Syowa', N'Syowa', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (275, 163, N'Antarctica/Rothera', N'Rothera', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (276, 163, N'Antarctica/Palmer', N'Palmer', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (277, 165, N'America/Argentina/Catamarca', N'Catamarca (CT); Chubut (CH)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (278, 163, N'Antarctica/Mawson', N'Mawson', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (279, 163, N'Antarctica/Davis', N'Davis', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (280, 163, N'Antarctica/Casey', N'Casey', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (281, 163, N'Antarctica/McMurdo', N'New Zealand time - McMurdo, South Pole', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (282, 161, N'Africa/Luanda', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (283, 166, N'Asia/Yerevan', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (284, 158, N'Europe/Tirane', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (285, 162, N'America/Anguilla', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (286, 164, N'America/Antigua', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (287, 1, N'Asia/Kabul', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (288, 77, N'Asia/Dubai', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (289, 163, N'Antarctica/DumontDUrville', N'Dumont-d''Urville', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (290, 165, N'America/Argentina/La_Rioja', N'La Rioja (LR)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (291, 165, N'America/Argentina/San_Juan', N'San Juan (SJ)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (292, 165, N'America/Argentina/Mendoza', N'Mendoza (MZ)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (293, 174, N'America/Barbados', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (294, 182, N'Europe/Sarajevo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (295, 170, N'Asia/Baku', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (296, 157, N'Europe/Mariehamn', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (297, 167, N'America/Aruba', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (298, 168, N'Australia/Eucla', N'Western Australia (Eucla)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (299, 168, N'Australia/Perth', N'Western Australia (most areas)', 1)
GO
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (300, 168, N'Australia/Darwin', N'Northern Territory', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (301, 168, N'Australia/Adelaide', N'South Australia', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (302, 168, N'Australia/Lindeman', N'Queensland (Whitsunday Islands)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (303, 168, N'Australia/Brisbane', N'Queensland (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (304, 168, N'Australia/Broken_Hill', N'New South Wales (Yancowinna)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (305, 168, N'Australia/Sydney', N'New South Wales (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (306, 168, N'Australia/Melbourne', N'Victoria', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (307, 168, N'Australia/Currie', N'Tasmania (King Island)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (308, 168, N'Australia/Hobart', N'Tasmania (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (309, 168, N'Antarctica/Macquarie', N'Macquarie Island', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (310, 168, N'Australia/Lord_Howe', N'Lord Howe Island', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (311, 169, N'Europe/Vienna', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (312, 28, N'Pacific/Pago_Pago', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (313, 165, N'America/Argentina/Ushuaia', N'Tierra del Fuego (TF)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (314, 165, N'America/Argentina/Rio_Gallegos', N'Santa Cruz (SC)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (315, 165, N'America/Argentina/San_Luis', N'San Luis (SL)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (316, 176, N'Europe/Brussels', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (317, 131, N'America/Inuvik', N'Mountain - NT (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (318, 131, N'America/Creston', N'MST - BC (Creston)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (319, 131, N'America/Dawson_Creek', N'MST - BC (Dawson Cr, Ft St John)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (320, 190, N'America/Tegucigalpa', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (321, 191, N'Asia/Hong_Kong', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (322, 188, N'America/Guyana', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (323, 215, N'Africa/Bissau', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (324, 245, N'Pacific/Guam', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (325, 218, N'America/Guatemala', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (326, 105, N'Atlantic/South_Georgia', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (327, 241, N'Europe/Athens', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (328, 223, N'Africa/Malabo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (329, 244, N'America/Guadeloupe', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (330, 148, N'Europe/Zagreb', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (331, 217, N'Africa/Conakry', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (332, 242, N'America/Thule', N'Thule/Pituffik', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (333, 242, N'America/Scoresbysund', N'Scoresbysund/Ittoqqortoormiit', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (334, 242, N'America/Danmarkshavn', N'National Park (east coast)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (335, 242, N'America/Godthab', N'Greenland (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (336, 240, N'Europe/Gibraltar', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (337, 239, N'Africa/Accra', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (338, 246, N'Europe/Guernsey', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (339, 232, N'America/Cayenne', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (340, 237, N'Asia/Tbilisi', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (341, 243, N'America/Grenada', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (342, 236, N'Africa/Banjul', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (343, 189, N'America/Port-au-Prince', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (344, 192, N'Europe/Budapest', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (345, 195, N'Asia/Jakarta', N'Java, Sumatra', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (346, 142, N'Indian/Comoro', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (347, 208, N'Pacific/Kiritimati', N'Line Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (348, 208, N'Pacific/Enderbury', N'Phoenix Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (349, 208, N'Pacific/Tarawa', N'Gilbert Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (350, 129, N'Asia/Phnom_Penh', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (351, 212, N'Asia/Bishkek', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (352, 207, N'Africa/Nairobi', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (353, 203, N'Asia/Tokyo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (354, 205, N'Asia/Amman', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (355, 202, N'America/Jamaica', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (356, 204, N'Europe/Jersey', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (357, 201, N'Europe/Rome', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (358, 193, N'Atlantic/Reykjavik', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (359, 196, N'Asia/Tehran', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (360, 197, N'Asia/Baghdad', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (361, 155, N'Indian/Chagos', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (362, 194, N'Asia/Kolkata', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (363, 199, N'Europe/Isle_of_Man', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (364, 200, N'Asia/Jerusalem', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (365, 198, N'Europe/Dublin', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (366, 195, N'Asia/Jayapura', N'New Guinea (West Papua / Irian Jaya); Malukus/Moluccas', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (367, 195, N'Asia/Makassar', N'Borneo (east, south); Sulawesi/Celebes, Bali, Nusa Tengarra; Timor (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (368, 195, N'Asia/Pontianak', N'Borneo (west, central)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (369, 184, N'Europe/London', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (370, 235, N'Africa/Libreville', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (371, 231, N'Europe/Paris', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (372, 228, N'Atlantic/Faroe', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (373, 150, N'America/Curacao', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (374, 132, N'Atlantic/Cape_Verde', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (375, 149, N'America/Havana', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (376, 146, N'America/Costa_Rica', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (377, 141, N'America/Bogota', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (378, 138, N'Asia/Urumqi', N'Xinjiang Time', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (379, 138, N'Asia/Shanghai', N'Beijing Time', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (380, 130, N'Africa/Douala', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (381, 137, N'Pacific/Easter', N'Easter Island', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (382, 137, N'America/Punta_Arenas', N'Region of Magallanes', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (383, 137, N'America/Santiago', N'Chile (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (384, 145, N'Pacific/Rarotonga', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (385, 147, N'Africa/Abidjan', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (386, 94, N'Europe/Zurich', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (387, 144, N'Africa/Brazzaville', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (388, 135, N'Africa/Bangui', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (389, 143, N'Africa/Lubumbashi', N'Dem. Rep. of Congo (east)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (390, 143, N'Africa/Kinshasa', N'Dem. Rep. of Congo (west)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (391, 140, N'Indian/Cocos', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (392, 131, N'America/Dawson', N'Pacific - Yukon (north)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (393, 131, N'America/Whitehorse', N'Pacific - Yukon (south)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (394, 131, N'America/Vancouver', N'Pacific - BC (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (395, 131, N'America/Fort_Nelson', N'MST - BC (Ft Nelson)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (396, 139, N'Indian/Christmas', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (397, 123, N'Africa/Lusaka', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (398, 151, N'Asia/Nicosia', N'Cyprus (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (399, 152, N'Europe/Prague', N'', 1)
GO
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (400, 50, N'Pacific/Kosrae', N'Kosrae', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (401, 50, N'Pacific/Pohnpei', N'Pohnpei/Ponape', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (402, 50, N'Pacific/Chuuk', N'Chuuk/Truk, Yap', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (403, 227, N'Atlantic/Stanley', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (404, 229, N'Pacific/Fiji', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (405, 230, N'Europe/Helsinki', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (406, 226, N'Africa/Addis_Ababa', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (407, 107, N'Atlantic/Canary', N'Canary Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (408, 107, N'Africa/Ceuta', N'Ceuta, Melilla', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (409, 107, N'Europe/Madrid', N'Spain (mainland)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (410, 224, N'Africa/Asmara', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (411, 89, N'Africa/El_Aaiun', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (412, 221, N'Africa/Cairo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (413, 225, N'Europe/Tallinn', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (414, 220, N'Pacific/Galapagos', N'Galapagos Islands', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (415, 220, N'America/Guayaquil', N'Ecuador (mainland)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (416, 159, N'Africa/Algiers', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (417, 187, N'America/Santo_Domingo', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (418, 216, N'America/Dominica', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (419, 154, N'Europe/Copenhagen', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (420, 186, N'Africa/Djibouti', N'', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (421, 238, N'Europe/Busingen', N'Busingen', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (422, 238, N'Europe/Berlin', N'Germany (most areas)', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (423, 151, N'Asia/Famagusta', N'Northern Cyprus', 1)
INSERT [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId], [CountryId], [ApplicationTimeZoneName], [Comment], [Active]) VALUES (424, 247, N'Africa/Harare', N'', 1)
SET IDENTITY_INSERT [dbo].[ApplicationTimeZones] OFF
SET IDENTITY_INSERT [dbo].[ConfigurationContents] ON 

INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (1, N'spinner.loadingText', N'Loading... Changes', N'Loading... Changes BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (2, N'dataOperation.post', N'Data added successfully', N'Data added successfully BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (3, N'dataOperation.put', N'Data updated successfully', N'Data updated successfully BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (4, N'dataOperation.delete', N'Data deleted successfully', N'Data deleted successfully BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (5, N'dialog.okText', N'Ok', N'Ok BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (6, N'dialog.cancelText', N'Cancel', N'Cancel BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (7, N'dialog.confirmation.okText', N'Yes', N'Yes BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (8, N'dialog.confirmation.cancelText', N'No', N'No BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (9, N'dialog.confirmation.title', N'Please confirm!', N'Please confirm! BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (10, N'dialog.confirmation.messageType.delete', N'Are you sure you want to delete ''{0}'' ?', N'Are you sure you want to delete ''{0}'' ? BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (11, N'dialog.confirmation.messageType.inactive', N'are you sure you want to inactive ''{0}'' ?', N'are you sure you want to inactive ''{0}'' ? BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (12, N'dialog.confirmation.messageType.active', N'Are you sure you want to active ''{0}'' ?', N'Are you sure you want to active ''{0}'' ? BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (13, N'dialog.alert.okText', N'Ok', N'Ok BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (14, N'dialog.alert.title', N'Alert!', N'Alert! BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (15, N'dialog.saveConfirmation.title', N'Data lost confirmation!', N'Data lost confirmation! BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (16, N'dialog.saveConfirmation.saveText', N'Save', N'Save BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (17, N'dialog.saveConfirmation.dontSaveText', N'Don''t Save', N'Don''t Save BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (18, N'placeholder.text', N'Pleaseter the value of', N'Pleaseter the value of BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (19, N'placeholder.select', N'Please select the value of', N'Please select the value of BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (20, N'placeholder.checkbox', N'Please choose the value of', N'Please choose the value of BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (21, N'placeholder.radio', N'Please choose the value of', N'Please choose the value of BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (22, N'placeholder.file', N'Please upload', N'Please upload BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (23, N'validation.message.default.required', N'You can''t leave this empty', N'You can''t leave this empty BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (24, N'validation.message.default.minlength', N'Minimum #n# characters required', N'Minimum #n# characters required BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (25, N'validation.message.default.maxlength', N'More than #n# characters are not permitted', N'More than #n# characters are not permitted BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (26, N'validation.message.default.pattern', N'The specified input format is not recognized', N'The specified input format is not recognized BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (27, N'validation.message.default.compare', N'The specified values of ''#field1#'' and ''#field2#'' must be the same', N'The specified values of ''#field1#'' and ''#field2#'' must be the same BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (28, N'validation.message.default.contains', N'The specified value must ''#value#'' in the input', N'The specified value must ''#value#'' in the input BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (29, N'validation.message.default.alpha', N'You can use letters and periods only', N'You can use letters and periods only BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (30, N'validation.message.default.alphanumeric', N'You can use letters, numbers and periods only', N'You can use letters, numbers and periods only BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (31, N'validation.message.default.range', N'You need toter appropriate value in this field', N'You need toter appropriate value in this field BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (32, N'control.rxTag.message.maxSelection', N'You can only select {maxSelection items', N'You can only select {maxSelection items BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (33, N'popup.validationFailed.title', N'Validation Failed', N'Validation Failed BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (34, N'popup.validationFailed.ok', N'Ok', N'Ok BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (35, N'popup.unauthorized.oops', N'Oops', N'Oops BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (36, N'popup.unauthorized.message', N'You don''t have access right of this item', N'You don''t have access right of this item BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (37, N'popup.unauthorized.ok', N'Ok', N'Ok BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (38, N'placeholder.password', N'Pleaseter the value of', N'Pleaseter the value of BA')
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (1039, N'internationalization.currencyCode', N'INR', NULL)
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (1040, N'internationalization.date.format', N'dmy', NULL)
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (1041, N'internationalization.date.seperator', N'/', NULL)
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (1042, N'placeholder.textarea', N'Please enter the value of', NULL)
INSERT [dbo].[ConfigurationContents] ([ConfigurationContentId], [ConfigurationContentName], [En], [Fr]) VALUES (1043, N'placeholder.email', N'Please enter the value of', NULL)
SET IDENTITY_INSERT [dbo].[ConfigurationContents] OFF
SET IDENTITY_INSERT [dbo].[Countries] ON 

INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (1, 1, N'Afghanistan', N'AF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (2, 1, N'New Zealand', N'NZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (3, 1, N'Nicaragua', N'NI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (4, 1, N'Niger', N'NE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (5, 1, N'Nigeria', N'NG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (6, 1, N'Niue', N'NU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (7, 1, N'Norfolk Island', N'NF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (8, 1, N'Northern Mariana Islands', N'MP', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (9, 1, N'Norway', N'NO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (10, 1, N'Oman', N'OM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (11, 1, N'Pakistan', N'PK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (12, 1, N'Palau', N'PW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (13, 1, N'Palestine', N'PS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (14, 1, N'Panama', N'PA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (15, 1, N'Papua New Guinea', N'PG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (16, 1, N'Paraguay', N'PY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (17, 1, N'Peru', N'PE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (18, 1, N'Philippines', N'PH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (19, 1, N'Pitcairn', N'PN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (20, 1, N'Poland', N'PL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (21, 1, N'Portugal', N'PT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (22, 1, N'Puerto Rico', N'PR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (23, 1, N'Qatar', N'QA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (24, 1, N'Réunion', N'RE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (25, 1, N'Romania', N'RO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (26, 1, N'Russia', N'RU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (27, 1, N'Rwanda', N'RW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (28, 1, N'Samoa (American)', N'AS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (29, 1, N'New Caledonia', N'NC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (30, 1, N'Samoa (western)', N'WS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (31, 1, N'Netherlands', N'NL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (32, 1, N'Nauru', N'NR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (33, 1, N'Liechtenstein', N'LI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (34, 1, N'Lithuania', N'LT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (35, 1, N'Luxembourg', N'LU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (36, 1, N'Macau', N'MO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (37, 1, N'Macedonia', N'MK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (38, 1, N'Madagascar', N'MG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (39, 1, N'Malawi', N'MW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (40, 1, N'Malaysia', N'MY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (41, 1, N'Maldives', N'MV', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (42, 1, N'Mali', N'ML', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (43, 1, N'Malta', N'MT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (44, 1, N'Marshall Islands', N'MH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (45, 1, N'Martinique', N'MQ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (46, 1, N'Mauritania', N'MR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (47, 1, N'Mauritius', N'MU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (48, 1, N'Mayotte', N'YT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (49, 1, N'Mexico', N'MX', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (50, 1, N'Micronesia', N'FM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (51, 1, N'Moldova', N'MD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (52, 1, N'Monaco', N'MC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (53, 1, N'Mongolia', N'MN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (54, 1, N'Montenegro', N'ME', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (55, 1, N'Montserrat', N'MS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (56, 1, N'Morocco', N'MA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (57, 1, N'Mozambique', N'MZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (58, 1, N'Myanmar (Burma)', N'MM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (59, 1, N'Namibia', N'NA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (60, 1, N'Nepal', N'NP', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (61, 1, N'Libya', N'LY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (62, 1, N'San Marino', N'SM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (63, 1, N'Saudi Arabia', N'SA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (64, 1, N'Tanzania', N'TZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (65, 1, N'Thailand', N'TH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (66, 1, N'Togo', N'TG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (67, 1, N'Tokelau', N'TK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (68, 1, N'Tonga', N'TO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (69, 1, N'Trinidad & Tobago', N'TT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (70, 1, N'Tunisia', N'TN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (71, 1, N'Turkey', N'TR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (72, 1, N'Turkmenistan', N'TM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (73, 1, N'Turks & Caicos Is', N'TC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (74, 1, N'Tuvalu', N'TV', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (75, 1, N'Uganda', N'UG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (76, 1, N'Ukraine', N'UA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (77, 1, N'United Arab Emirates', N'AE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (78, 1, N'United States', N'US', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (79, 1, N'Uruguay', N'UY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (80, 1, N'US minor outlying islands', N'UM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (81, 1, N'Uzbekistan', N'UZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (82, 1, N'Vanuatu', N'VU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (83, 1, N'Vatican City', N'VA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (84, 1, N'Venezuela', N'VE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (85, 1, N'Vietnam', N'VN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (86, 1, N'Virgin Islands (UK)', N'VG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (87, 1, N'Virgin Islands (US)', N'VI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (88, 1, N'Wallis & Futuna', N'WF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (89, 1, N'Western Sahara', N'EH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (90, 1, N'Yemen', N'YE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (91, 1, N'Tajikistan', N'TJ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (92, 1, N'Sao Tome & Principe', N'ST', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (93, 1, N'Taiwan', N'TW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (94, 1, N'Switzerland', N'CH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (95, 1, N'Senegal', N'SN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (96, 1, N'Serbia', N'RS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (97, 1, N'Seychelles', N'SC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (98, 1, N'Sierra Leone', N'SL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (99, 1, N'Singapore', N'SG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
GO
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (100, 1, N'Slovakia', N'SK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (101, 1, N'Slovenia', N'SI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (102, 1, N'Solomon Islands', N'SB', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (103, 1, N'Somalia', N'SO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (104, 1, N'South Africa', N'ZA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (105, 1, N'South Georgia & the South Sandwich Islands', N'GS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (106, 1, N'South Sudan', N'SS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (107, 1, N'Spain', N'ES', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (108, 1, N'Sri Lanka', N'LK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (109, 1, N'St Barthelemy', N'BL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (110, 1, N'St Helena', N'SH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (111, 1, N'St Kitts & Nevis', N'KN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (112, 1, N'St Lucia', N'LC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (113, 1, N'St Maarten (Dutch)', N'SX', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (114, 1, N'St Martin (French)', N'MF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (115, 1, N'St Pierre & Miquelon', N'PM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (116, 1, N'St Vincent', N'VC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (117, 1, N'Sudan', N'SD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (118, 1, N'Suriname', N'SR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (119, 1, N'Svalbard & Jan Mayen', N'SJ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (120, 1, N'Swaziland', N'SZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (121, 1, N'Sweden', N'SE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (122, 1, N'Syria', N'SY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (123, 1, N'Zambia', N'ZM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (124, 1, N'Liberia', N'LR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (125, 1, N'Lebanon', N'LB', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (126, 1, N'Bulgaria', N'BG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (127, 1, N'Burkina Faso', N'BF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (128, 1, N'Burundi', N'BI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (129, 1, N'Cambodia', N'KH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (130, 1, N'Cameroon', N'CM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (131, 1, N'Canada', N'CA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (132, 1, N'Cape Verde', N'CV', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (133, 1, N'Caribbean NL', N'BQ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (134, 1, N'Cayman Islands', N'KY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (135, 1, N'Central African Rep.', N'CF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (136, 1, N'Chad', N'TD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (137, 1, N'Chile', N'CL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (138, 1, N'China', N'CN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (139, 1, N'Christmas Island', N'CX', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (140, 1, N'Cocos (Keeling) Islands', N'CC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (141, 1, N'Colombia', N'CO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (142, 1, N'Comoros', N'KM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (143, 1, N'Congo (Dem. Rep.)', N'CD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (144, 1, N'Congo (Rep.)', N'CG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (145, 1, N'Cook Islands', N'CK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (146, 1, N'Costa Rica', N'CR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (147, 1, N'Côte d''Ivoire', N'CI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (148, 1, N'Croatia', N'HR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (149, 1, N'Cuba', N'CU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (150, 1, N'Curaçao', N'CW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (151, 1, N'Cyprus', N'CY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (152, 1, N'Czech Republic', N'CZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (153, 1, N'Brunei', N'BN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (154, 1, N'Denmark', N'DK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (155, 1, N'British Indian Ocean Territory', N'IO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (156, 1, N'Brazil', N'BR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (157, 1, N'Åland Islands', N'AX', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (158, 1, N'Albania', N'AL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (159, 1, N'Algeria', N'DZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (160, 1, N'Andorra', N'AD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (161, 1, N'Angola', N'AO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (162, 1, N'Anguilla', N'AI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (163, 1, N'Antarctica', N'AQ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (164, 1, N'Antigua & Barbuda', N'AG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (165, 1, N'Argentina', N'AR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (166, 1, N'Armenia', N'AM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (167, 1, N'Aruba', N'AW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (168, 1, N'Australia', N'AU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (169, 1, N'Austria', N'AT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (170, 1, N'Azerbaijan', N'AZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (171, 1, N'Bahamas', N'BS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (172, 1, N'Bahrain', N'BH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (173, 1, N'Bangladesh', N'BD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (174, 1, N'Barbados', N'BB', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (175, 1, N'Belarus', N'BY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (176, 1, N'Belgium', N'BE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (177, 1, N'Belize', N'BZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (178, 1, N'Benin', N'BJ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (179, 1, N'Bermuda', N'BM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (180, 1, N'Bhutan', N'BT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (181, 1, N'Bolivia', N'BO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (182, 1, N'Bosnia & Herzegovina', N'BA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (183, 1, N'Botswana', N'BW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (184, 1, N'Britain (UK)', N'GB', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (185, 1, N'Lesotho', N'LS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (186, 1, N'Djibouti', N'DJ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (187, 1, N'Dominican Republic', N'DO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (188, 1, N'Guyana', N'GY', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (189, 1, N'Haiti', N'HT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (190, 1, N'Honduras', N'HN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (191, 1, N'Hong Kong', N'HK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (192, 1, N'Hungary', N'HU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (193, 1, N'Iceland', N'IS', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (194, 1, N'India', N'IN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (195, 1, N'Indonesia', N'ID', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (196, 1, N'Iran', N'IR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (197, 1, N'Iraq', N'IQ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (198, 1, N'Ireland', N'IE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (199, 1, N'Isle of Man', N'IM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
GO
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (200, 1, N'Israel', N'IL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (201, 1, N'Italy', N'IT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (202, 1, N'Jamaica', N'JM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (203, 1, N'Japan', N'JP', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (204, 1, N'Jersey', N'JE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (205, 1, N'Jordan', N'JO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (206, 1, N'Kazakhstan', N'KZ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (207, 1, N'Kenya', N'KE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (208, 1, N'Kiribati', N'KI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (209, 1, N'Korea (North)', N'KP', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (210, 1, N'Korea (South)', N'KR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (211, 1, N'Kuwait', N'KW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (212, 1, N'Kyrgyzstan', N'KG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (213, 1, N'Laos', N'LA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (214, 1, N'Latvia', N'LV', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (215, 1, N'Guinea-Bissau', N'GW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (216, 1, N'Dominica', N'DM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (217, 1, N'Guinea', N'GN', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (218, 1, N'Guatemala', N'GT', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (219, 1, N'East Timor', N'TL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (220, 1, N'Ecuador', N'EC', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (221, 1, N'Egypt', N'EG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (222, 1, N'El Salvador', N'SV', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (223, 1, N'Equatorial Guinea', N'GQ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (224, 1, N'Eritrea', N'ER', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (225, 1, N'Estonia', N'EE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (226, 1, N'Ethiopia', N'ET', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (227, 1, N'Falkland Islands', N'FK', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (228, 1, N'Faroe Islands', N'FO', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (229, 1, N'Fiji', N'FJ', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (230, 1, N'Finland', N'FI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (231, 1, N'France', N'FR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (232, 1, N'French Guiana', N'GF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (233, 1, N'French Polynesia', N'PF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (234, 1, N'French Southern & Antarctic Lands', N'TF', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (235, 1, N'Gabon', N'GA', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (236, 1, N'Gambia', N'GM', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (237, 1, N'Georgia', N'GE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (238, 1, N'Germany', N'DE', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (239, 1, N'Ghana', N'GH', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (240, 1, N'Gibraltar', N'GI', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (241, 1, N'Greece', N'GR', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (242, 1, N'Greenland', N'GL', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (243, 1, N'Grenada', N'GD', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (244, 1, N'Guadeloupe', N'GP', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (245, 1, N'Guam', N'GU', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (246, 1, N'Guernsey', N'GG', NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Countries] ([CountryId], [DefaultLanguageId], [CountryName], [CountryCode], [DateFormat], [DateFormatSeperator], [CurrencyFormat], [DecimalSeperator], [PhoneFormat], [PostalCodeFormat], [Active]) VALUES (247, 1, N'Zimbabwe', N'ZW', NULL, NULL, NULL, NULL, NULL, NULL, 0)
SET IDENTITY_INSERT [dbo].[Countries] OFF
SET IDENTITY_INSERT [dbo].[LanguageContents] ON 

INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (1, N'AlreadyExits', N'Server Message Key', N'Record already exists', N'Record already exists')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (2, N'CannotBeDeleted', N'Server Messages Key', N'Can Not be Deleted', N'Can Not be Deleted')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (3, N'InvalidUserNamePassword', N'Server Messages Key', N'Email address or password are invalid', N'Username or password are invalid')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (4, N'UserNotExist', N'Server Messages Key', N'User with this email address does not exist', N'User does not exist')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (5, N'EmailAlreadyExists', N'Server Message Key', N'Email address is already registered', N'Email address is already registered')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (6, N'PasswordPatternValidation', N'Server Message Key', N'Password must be eight or more characters and should contain alphanumeric and special characters', N'Password must be eight or more characters and should contain alphanumeric and special characters')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (7, N'ConfirmPasswordValidation', N'Server Message Key', N'Password does not match the confirm password', N'Password does not match the confirm password')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (8, N'InvalidEmailPassword', N'Server Message Key', N'Invalid credentials', N'Invalid credentials')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (9, N'UserInactivated', N'Server Message Key', N'User is not activated', N'User is not activated')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (10, N'ResetPasswordLink', N'Server Message Key', N'Password reset link has been sent to your email', N'Password reset link has been sent to your email')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (11, N'ChangePassword', N'Server Message Key', N'Your password has been changed successfully', N'Your password has been changed successfully')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (12, N'OldNewPasswordValidation', N'Server Message Key', N'Values for old and new password are same', N'Values for old and new password are same')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (13, N'OldPasswordValidation', N'Server Message Key', N'Old password is wrong', N'Old password is wrong')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (14, N'UserValidation', N'Server Message Key', N'User already exists	User already exists', N'User already exists	User already exists')
INSERT [dbo].[LanguageContents] ([LanguageContentId], [LanguageContentName], [ContentType], [En], [Fr]) VALUES (15, N'ValidateDateOfBirth', N'Server Message Key', N'Enter valid date of birth', N'Enter valid date of birth')
SET IDENTITY_INSERT [dbo].[LanguageContents] OFF
SET IDENTITY_INSERT [dbo].[Languages] ON 

INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (1, N'English', N'en', 1, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (2, N'Afar', N'aa', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (3, N'Abkhazian', N'ab', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (4, N'Afrikaans', N'af', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (5, N'Amharic', N'am', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (6, N'Arabic', N'ar', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (7, N'Assamese', N'as', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (8, N'Aymara', N'ay', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (9, N'Azerbaijani', N'az', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (10, N'Bashkir', N'ba', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (11, N'Belarusian', N'be', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (12, N'Bulgarian', N'bg', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (13, N'Bihari', N'bh', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (14, N'Bislama', N'bi', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (15, N'Bengali/Bangla', N'bn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (16, N'Tibetan', N'bo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (17, N'Breton', N'br', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (18, N'Catalan', N'ca', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (19, N'Corsican', N'co', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (20, N'Czech', N'cs', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (21, N'Welsh', N'cy', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (22, N'Danish', N'da', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (23, N'German', N'de', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (24, N'Bhutani', N'dz', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (25, N'Greek', N'el', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (26, N'Esperanto', N'eo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (27, N'Spanish', N'es', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (28, N'Estonian', N'et', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (29, N'Basque', N'eu', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (30, N'Persian', N'fa', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (31, N'Finnish', N'fi', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (32, N'Fiji', N'fj', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (33, N'Faeroese', N'fo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (34, N'French', N'fr', 1, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (35, N'Frisian', N'fy', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (36, N'Irish', N'ga', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (37, N'Scots/Gaelic', N'gd', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (38, N'Galician', N'gl', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (39, N'Guarani', N'gn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (40, N'Gujarati', N'gu', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (41, N'Hausa', N'ha', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (42, N'Hindi', N'hi', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (43, N'Croatian', N'hr', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (44, N'Hungarian', N'hu', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (45, N'Armenian', N'hy', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (46, N'Interlingua', N'ia', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (47, N'Interlingue', N'ie', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (48, N'Inupiak', N'ik', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (49, N'Indonesian', N'in', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (50, N'Icelandic', N'is', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (51, N'Italian', N'it', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (52, N'Hebrew', N'iw', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (53, N'Japanese', N'ja', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (54, N'Yiddish', N'ji', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (55, N'Javanese', N'jw', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (56, N'Georgian', N'ka', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (57, N'Kazakh', N'kk', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (58, N'Greenlandic', N'kl', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (59, N'Cambodian', N'km', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (60, N'Kannada', N'kn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (61, N'Korean', N'ko', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (62, N'Kashmiri', N'ks', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (63, N'Kurdish', N'ku', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (64, N'Kirghiz', N'ky', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (65, N'Latin', N'la', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (66, N'Lingala', N'ln', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (67, N'Laothian', N'lo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (68, N'Lithuanian', N'lt', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (69, N'Latvian/Lettish', N'lv', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (70, N'Malagasy', N'mg', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (71, N'Maori', N'mi', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (72, N'Macedonian', N'mk', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (73, N'Malayalam', N'ml', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (74, N'Mongolian', N'mn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (75, N'Moldavian', N'mo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (76, N'Marathi', N'mr', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (77, N'Malay', N'ms', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (78, N'Maltese', N'mt', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (79, N'Burmese', N'my', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (80, N'Nauru', N'na', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (81, N'Nepali', N'ne', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (82, N'Dutch', N'nl', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (83, N'Norwegian', N'no', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (84, N'Occitan', N'oc', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (85, N'(Afan)/Oromoor/Oriya', N'om', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (86, N'Punjabi', N'pa', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (87, N'Polish', N'pl', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (88, N'Pashto/Pushto', N'ps', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (89, N'Portuguese', N'pt', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (90, N'Quechua', N'qu', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (91, N'Rhaeto-Romance', N'rm', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (92, N'Kirundi', N'rn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (93, N'Romanian', N'ro', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (94, N'Russian', N'ru', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (95, N'Kinyarwanda', N'rw', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (96, N'Sanskrit', N'sa', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (97, N'Sindhi', N'sd', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (98, N'Sangro', N'sg', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (99, N'Serbo-Croatian', N'sh', 0, NULL)
GO
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (100, N'Singhalese', N'si', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (101, N'Slovak', N'sk', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (102, N'Slovenian', N'sl', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (103, N'Samoan', N'sm', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (104, N'Shona', N'sn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (105, N'Somali', N'so', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (106, N'Albanian', N'sq', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (107, N'Serbian', N'sr', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (108, N'Siswati', N'ss', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (109, N'Sesotho', N'st', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (110, N'Sundanese', N'su', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (111, N'Swedish', N'sv', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (112, N'Swahili', N'sw', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (113, N'Tamil', N'ta', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (114, N'Telugu', N'te', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (115, N'Tajik', N'tg', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (116, N'Thai', N'th', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (117, N'Tigrinya', N'ti', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (118, N'Turkmen', N'tk', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (119, N'Tagalog', N'tl', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (120, N'Setswana', N'tn', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (121, N'Tonga', N'to', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (122, N'Turkish', N'tr', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (123, N'Tsonga', N'ts', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (124, N'Tatar', N'tt', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (125, N'Twi', N'tw', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (126, N'Ukrainian', N'uk', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (127, N'Urdu', N'ur', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (128, N'Uzbek', N'uz', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (129, N'Vietnamese', N'vi', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (130, N'Volapuk', N'vo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (131, N'Wolof', N'wo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (132, N'Xhosa', N'xh', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (133, N'Yoruba', N'yo', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (134, N'Chinese', N'zh', 0, NULL)
INSERT [dbo].[Languages] ([LanguageId], [LanguageName], [LanguageCode], [Active], [AutoTranslate]) VALUES (135, N'Zulu', N'zu', 0, NULL)
SET IDENTITY_INSERT [dbo].[Languages] OFF
SET IDENTITY_INSERT [dbo].[ModuleMasters] ON 

INSERT [dbo].[ModuleMasters] ([ModuleMasterId], [ModuleMasterName], [IsRolePermissionItem], [IsRoot], [Active]) VALUES (1, N'Login', 0, 0, 1)
INSERT [dbo].[ModuleMasters] ([ModuleMasterId], [ModuleMasterName], [IsRolePermissionItem], [IsRoot], [Active]) VALUES (2, N'Annonymous', 0, 1, 1)
INSERT [dbo].[ModuleMasters] ([ModuleMasterId], [ModuleMasterName], [IsRolePermissionItem], [IsRoot], [Active]) VALUES (3, N'Users', 1, 1, 1)
SET IDENTITY_INSERT [dbo].[ModuleMasters] OFF
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([RoleId], [RoleName], [Status]) VALUES (1, N'Admin', 1)
SET IDENTITY_INSERT [dbo].[Roles] OFF
SET IDENTITY_INSERT [dbo].[SMTPConfigurations] ON 

INSERT [dbo].[SMTPConfigurations] ([SmtpConfigurationId], [FromEmail], [DefaultCredentials], [EnableSSL], [Host], [UserName], [Password], [Port], [DeliveryMethod], [SendIndividually], [IsActive]) VALUES (1, N'testdotnet@mailtest.radixweb.net', 1, 1, N'mail.mailtest.radixweb.net', N'testdotnet@mailtest.radixweb.net', N'deep70', 587, N'0', 0, 1)
SET IDENTITY_INSERT [dbo].[SMTPConfigurations] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserId], [RoleId], [EmailId], [Password], [Salt], [FirstName], [LastName], [DateOfBirth], [GenderId], [Address], [City], [ZipCode], [PhoneNumber], [VerificationCode], [ApplicationTimeZoneId], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [StatusId], [MaximumEventsLimit], [Country], [State]) VALUES (2, 1, N'bhavik.patel@radixweb.com', 0x00C7F3C145631CD0F1A5596697BBED038142AEE4659C531F0C6E65570159981F7483B95054A07B4036D005941ADFDB671F29796515439EDE529680E51F671FF0887D00C828CEDD46840675566A59AD7B8C384900C0B399E15B95752F2496C9266F459462C7798260C154E5E76E551C9024E779C8914CEC15675EF1EA1FE1A70A3172DDBD, 0x454353354200000001A99EC6C1B71A736791DBB6CC7E5E18C0EF706DB86810844D063353E8102FD8384D9AD5DB0D451DA874ED776BF70CB0F4C2B5C9ABD760096D9E20FCC1F4944F11A401A77666AFDB2811957B06075BE2096118042F59839499B6A8E361D425DE807D1DD85A49A4E5CEE9D9903D638A3069D06AFCC075F5C23DA421952FCB2C5875CD13E3, N'Bhavik', N'Patel', CAST(N'2019-06-11' AS Date), 4, N'19, Madhukunj, Dattapada Road,', N'Ahmedabad', N'84596', N'9854663623', NULL, 1, 0, 1, CAST(N'2019-08-08T13:40:00' AS SmallDateTime), 1, CAST(N'2019-08-08T13:40:00' AS SmallDateTime), 1, NULL, N'India', N'Gujarat')
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[RolePermissions] ADD  CONSTRAINT [DF__RolePermi__NoAcc__114A936A]  DEFAULT ((0)) FOR [CanView]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  CONSTRAINT [DF__RolePermi__Reado__123EB7A3]  DEFAULT ((0)) FOR [CanAdd]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  CONSTRAINT [DF_RolePermissions_AllowView]  DEFAULT ((0)) FOR [CanEdit]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  CONSTRAINT [DF__RolePermi__FullA__1332DBDC]  DEFAULT ((0)) FOR [CanDelete]
GO
ALTER TABLE [dbo].[ApplicationModules]  WITH CHECK ADD  CONSTRAINT [FK_ApplicationModules_ModuleMasters] FOREIGN KEY([ModuleMasterId])
REFERENCES [dbo].[ModuleMasters] ([ModuleMasterId])
GO
ALTER TABLE [dbo].[ApplicationModules] CHECK CONSTRAINT [FK_ApplicationModules_ModuleMasters]
GO
ALTER TABLE [dbo].[AuditRecordDetails]  WITH CHECK ADD  CONSTRAINT [FK_AuditRecordDetails_AuditRecords] FOREIGN KEY([AuditRecordId])
REFERENCES [dbo].[AuditRecords] ([AuditRecordId])
GO
ALTER TABLE [dbo].[AuditRecordDetails] CHECK CONSTRAINT [FK_AuditRecordDetails_AuditRecords]
GO
ALTER TABLE [dbo].[AuditRecords]  WITH CHECK ADD  CONSTRAINT [FK_AuditRecords_AuditRequests] FOREIGN KEY([AuditRequestId])
REFERENCES [dbo].[AuditRequests] ([AuditRequestId])
GO
ALTER TABLE [dbo].[AuditRecords] CHECK CONSTRAINT [FK_AuditRecords_AuditRequests]
GO
ALTER TABLE [dbo].[GlobalSettings]  WITH CHECK ADD  CONSTRAINT [FK_GlobalSettings_ApplicationTimeZones] FOREIGN KEY([ApplicationTimeZoneId])
REFERENCES [dbo].[ApplicationTimeZones] ([ApplicationTimeZoneId])
GO
ALTER TABLE [dbo].[GlobalSettings] CHECK CONSTRAINT [FK_GlobalSettings_ApplicationTimeZones]
GO
ALTER TABLE [dbo].[GlobalSettings]  WITH CHECK ADD  CONSTRAINT [FK_GlobalSettings_Languages] FOREIGN KEY([LanguageId])
REFERENCES [dbo].[Languages] ([LanguageId])
GO
ALTER TABLE [dbo].[GlobalSettings] CHECK CONSTRAINT [FK_GlobalSettings_Languages]
GO
ALTER TABLE [dbo].[ModuleContents]  WITH CHECK ADD  CONSTRAINT [FK_ModuleContents_ApplicationModules] FOREIGN KEY([ApplicationModuleId])
REFERENCES [dbo].[ApplicationModules] ([ApplicationModuleId])
GO
ALTER TABLE [dbo].[ModuleContents] CHECK CONSTRAINT [FK_ModuleContents_ApplicationModules]
GO
ALTER TABLE [dbo].[ModuleContents]  WITH CHECK ADD  CONSTRAINT [FK_ModuleContents_LanguageContents] FOREIGN KEY([LanguageContentId])
REFERENCES [dbo].[LanguageContents] ([LanguageContentId])
GO
ALTER TABLE [dbo].[ModuleContents] CHECK CONSTRAINT [FK_ModuleContents_LanguageContents]
GO
ALTER TABLE [dbo].[RolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_RolePermissions_ApplicationModules] FOREIGN KEY([ApplicationModuleId])
REFERENCES [dbo].[ApplicationModules] ([ApplicationModuleId])
GO
ALTER TABLE [dbo].[RolePermissions] CHECK CONSTRAINT [FK_RolePermissions_ApplicationModules]
GO
ALTER TABLE [dbo].[RolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_RolePermissions_Roles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([RoleId])
GO
ALTER TABLE [dbo].[RolePermissions] CHECK CONSTRAINT [FK_RolePermissions_Roles]
GO
ALTER TABLE [dbo].[Roles]  WITH CHECK ADD  CONSTRAINT [FK_Roles_ApplicationObjects] FOREIGN KEY([Status])
REFERENCES [dbo].[ApplicationObjects] ([ApplicationObjectId])
GO
ALTER TABLE [dbo].[Roles] CHECK CONSTRAINT [FK_Roles_ApplicationObjects]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_ApplicationObjects] FOREIGN KEY([StatusId])
REFERENCES [dbo].[ApplicationObjects] ([ApplicationObjectId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_ApplicationObjects]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Roles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([RoleId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Roles]
GO
/****** Object:  StoredProcedure [dbo].[spApplicationModules]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC spApplicationModules 1  
CREATE PROCEDURE [dbo].[spApplicationModules] (@UserId int)  
AS  
BEGIN  
  SELECT   
    AM.ApplicationModuleId,   
    MM.ModuleMasterName +  ' ' + dbo.fnGetParentName(AM.ParentApplicationModuleId) ApplicationModuleName  
    ,AM.ParentApplicationModuleId,AM.VisibleActionItem,MM.IsRolePermissionItem  
  FROM  
    ModuleMasters(nolock) MM  
    INNER JOIN ApplicationModules(nolock) AM ON   
    AM.ModuleMasterId=MM.ModuleMasterId  
  WHERE   
    MM.Active = 1 AND AM.ParentApplicationModuleId is not null  
    ORDER BY MM.ModuleMasterName  
END  
       
GO
/****** Object:  StoredProcedure [dbo].[spAuditLogs]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spAuditLogs 0,0,'',NULL,NULL
CREATE PROCEDURE [dbo].[spAuditLogs]
(	
	@UserId				INT=0,
	@ApplicationModuleId INT=0,
	@RequestMethod nvarchar(10),
	@StartDate			DATETime,
	@EndDate			DATETime
)
AS
BEGIN
   If(@StartDate<='1801-01-01')
   BEGIN
		SET @StartDate=NULL
   END

   If(@EndDate>='9000-12-31')
   BEGIN
		SET @EndDate=NULL
   END 
	DECLARE @dynSql NVARCHAR(MAX) = '',	@conSql NVARCHAR(MAX) = ''

	IF(@UserId>0)
	BEGIN
		SET @conSql=@conSql+ ' AND AR.UserId="' + Cast(@UserId as nvarchar(10)) +'"'
	END	

	IF(@ApplicationModuleId>0)
	BEGIN
		SET @conSql=@conSql+ ' AND AR.ApplicationModuleId="' + Cast(@ApplicationModuleId as nvarchar(10)) +'"'
	END	

	IF(LEN(ltrim(rtrim(@RequestMethod)))>0)
	BEGIN
		SET @conSql=@conSql+ ' AND AR.RequestMethod LIKE "%' + ltrim(rtrim(@RequestMethod))+'%"'
	END	

	IF(@StartDate IS NOT NULL AND @EndDate IS NOT NULL)
	BEGIN
		SET @conSql=@conSql+ ' AND CONVERT(DATE,AR.CreatedDate) BETWEEN "' + CONVERT(nvarchar(20),@StartDate) + '" 
		AND "' + CONVERT(nvarchar(20),@EndDate) + '" '
	END	
	Else IF(@StartDate IS NOT NULL)
	BEGIN
		SET @conSql=@conSql+ ' AND CONVERT(DATE,AR.CreatedDate) >= "' + CONVERT(nvarchar(20),@StartDate) + '" '
	END	
	Else IF(@EndDate IS NOT NULL)
	BEGIN
		SET @conSql=@conSql+ ' AND CONVERT(DATE,AR.CreatedDate) <= "' + CONVERT(nvarchar(20),@EndDate) + '" '
	END	

	set @dynSql='SELECT AR.AuditRequestId,AR.Uri,AR.CreatedDate,MM.ModuleMasterName, ATZ.ApplicationTimeZoneName + '' ('' + C.CountryName + '') '' AS ApplicationTimeZoneName,
U.FirstName + '' '' + U.LastName as Name,
(CASE WHEN (AR.RequestMethod = ''POST'') THEN ''Add''
	  WHEN (AR.RequestMethod = ''PUT'') THEN ''Update''
	  WHEN (AR.RequestMethod = ''DELETE'') THEN ''Delete''
	  WHEN (AR.RequestMethod = ''GET'') THEN ''Get''  END)  as RequestMethod

FROM            dbo.AuditRequests(NOLOCK) AS AR LEFT OUTER JOIN
                         dbo.Users(NOLOCK) AS U ON AR.UserId = U.UserId LEFT OUTER JOIN
                         dbo.ApplicationModules(NOLOCK) AS AM ON AR.ApplicationModuleId = AM.ApplicationModuleId LEFT OUTER JOIN
                         dbo.ModuleMasters(NOLOCK) AS MM ON AM.ModuleMasterId = MM.ModuleMasterId INNER JOIN
                         dbo.ApplicationTimeZones(NOLOCK) AS ATZ ON AR.ApplicationTimeZoneId = ATZ.ApplicationTimeZoneId INNER JOIN
						 dbo.Countries(NOLOCK) as C ON ATZ.CountryId = C.CountryId
 WHERE 1=1'

		SET @dynSql=@dynSql + ' ' + @conSql
		SET @dynsql=replace(@dynsql,'"','''')				
		PRINT @dynSql
		EXEC (@dynSql)


END
GO
/****** Object:  StoredProcedure [dbo].[spAuditRecords]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spAuditRecords 2,3,3,'Modified',NULL,NULL

CREATE PROCEDURE [dbo].[spAuditRecords] (
@ApplicationModuleId int, 
@UserId int, 
@MainRecordId int, 
@RequestMethod nvarchar(10)='',
@StartDate Date=NULL,
@EndDate Date=NULL)
AS
BEGIN
		--SELECT 
		--		AuditRequestId, 
		--		ISNULL(Us.FirstName,'') + ' ' + ISNULL(US.LastName,'') as UserName,
		--		CASE RequestMethod WHEN 'POST' then 'Added'
		--		WHEN 'PUT' then 'Modified'
		--		WHEN 'Delete' then 'Deleted'
		--		Else 'Modified'
		--		end as EventType, 
		--		CreatedDate as Date 
		--FROM 
		--		AuditRequests(nolock) ARQ
		--		INNER JOIN Users(nolock) US ON US.UserId=ARQ.UserId 
		--WHERE 
		--		MainRecordId=@MainRecordId 
		--		AND ApplicationModuleId=@ApplicationModuleId
		--		AND ARQ.UserId=(CASE @UserId WHEN 0 THEN ARQ.UserId ELSE @UserId END)
		--		AND RequestMethod=
		--						(
		--							CASE 
		--										@RequestMethod WHEN '' 
		--									THEN 
		--										RequestMethod 											
		--									ELSE 
		--										 CASE @RequestMethod WHEN 'Added' THEN 'Post' 
		--															 When 'Modified' THEN 'Put' 
		--															 When 'Deleted' THEN 'Delete' 
		--															 Else 'Put' END 
		--							END
		--						)
		--		AND CreatedDate 
		--				BETWEEN
		--				(
		--				  CASE WHEN @StartDate IS NULL THEN CreatedDate ELSE @StartDate END
		--				) 
		--				AND
		--				(
		--				  CASE WHEN @EndDate IS NULL THEN CreatedDate ELSE @EndDate END
		--				)
		DECLARE @SQL VARCHAR(MAX)
		SET @SQL = 'SELECT AuditRequestId, ISNULL(Us.FirstName,'''') + '' '' + ISNULL(US.LastName,'''') as UserName, CASE RequestMethod WHEN ''POST'' then ''Added'' WHEN ''PUT'' then ''Modified'' WHEN ''Delete'' then ''Deleted'' Else ''Modified'' end as EventType, CreatedDate as Date FROM AuditRequests(nolock) ARQ INNER JOIN Users(nolock) US ON US.UserId=ARQ.UserId WHERE ApplicationModuleId= ' + CAST(@ApplicationModuleId AS varchar(200)) + ' AND ARQ.UserId=(CASE ' +  CAST(@UserId AS varchar(200)) + ' WHEN 0 THEN ARQ.UserId ELSE ' + CAST(@UserId AS varchar(200)) + ' END)' 
		IF(LEN(ltrim(rtrim(@RequestMethod)))>0)    
			SET @SQL += 'AND RequestMethod = CASE ''' + @RequestMethod + ''' WHEN ''Added'' THEN ''Post'' When ''Modified'' THEN ''Put'' When ''Deleted'' THEN ''Delete'' Else ''Put'' END'
		IF(@StartDate IS NOT NULL AND @EndDate IS NOT NULL)    
			BEGIN    
				SET @SQL=@SQL+ ' AND CONVERT(DATE,CreatedDate) BETWEEN "' + CONVERT(nvarchar(20),@StartDate) + '" AND "' + CONVERT(nvarchar(20),@EndDate) + '" '    
			END     
		Else IF(@StartDate IS NOT NULL)    
			BEGIN    
				SET @SQL=@SQL+ ' AND CONVERT(DATE, CreatedDate) >= "' + CONVERT(nvarchar(20),@StartDate) + '" '    
			END     
		Else IF(@EndDate IS NOT NULL)    
			BEGIN    
				SET @SQL=@SQL+ ' AND CONVERT(DATE,CreatedDate) <= "' + CONVERT(nvarchar(20),@EndDate) + '" '    
			END     
		IF(@MainRecordId > 0)  
			BEGIN
				SET @SQL += ' AND MainRecordId=' + CAST(@MainRecordId AS VARCHAR(200))
			END
		PRINT @SQL
		SET @SQL=replace(@SQL,'"','''')     
		EXEC (@SQL)
END						
GO
/****** Object:  StoredProcedure [dbo].[spCanDeleteRecord]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC spCanDeleteRecord 'Accounts',7
--EXEC spCanDeleteRecord 'Roles',1
CREATE PROCEDURE [dbo].[spCanDeleteRecord](@TableName nvarchar(50), @RecordId int)
AS
BEGIN
			--DECLARE @RecordId INT=1
			--DECLARE @TableName nvarchar(50)='ApplicationModules'

			DECLARE @FkName nvarchar(250)
			DECLARE @ParentTable nvarchar(100)
			DECLARE @KeyName nvarchar(100)
			DECLARE @ReferenceTable nvarchar(100)

			DECLARE @DynSql nvarchar(max)
			DECLARE @ReturnValue bit = 0
			CREATE TABLE #myTable(Cnt int)

			DECLARE RefCursor Cursor FOR
							SELECT
								    fk.name 'FkName',
								    tp.name 'ParentTable',
								    cp.name 'KeyName', 
									tr.name 'RefrenceTable'
							FROM 
									sys.foreign_keys fk
									INNER JOIN 
									    sys.tables tp ON fk.parent_object_id = tp.object_id
									INNER JOIN 
										sys.tables tr ON fk.referenced_object_id = tr.object_id
									INNER JOIN 
										sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
									INNER JOIN 
										sys.columns cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
									INNER JOIN 
										sys.columns cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
							WHERE 
									tr.name=@TableName
									and tp.name!='Addresses' --To be removed once actual implementation done with Archi. 14-07-2017

			OPEN RefCursor
			FETCH NEXT FROM RefCursor INTO @FkName, @ParentTable, @KeyName, @ReferenceTable
			WHILE @@FETCH_STATUS=0
			BEGIN
					--SELECT 	@FkName, @ParentTable, @KeyName, @ReferenceTable
					SET @DynSql	='	SELECT COUNT(*) Cnt FROM '  + @ParentTable + '  WHERE ' + @KeyName + ' = ' + Cast(@RecordId as nvarchar(5))

					INSERT INTO #myTable(Cnt)
					EXEC (@DynSQL)  

					IF EXISTS(Select CNT from #myTable WHERE CNT>0)
					BEGIN
							SET @ReturnValue =1
							BREAK;
					END
					SET @DynSql=''		
					FETCH NEXT FROM RefCursor INTO @FkName, @ParentTable, @KeyName, @ReferenceTable
			END
			CLOSE RefCursor
			Deallocate RefCursor			
			DROP TABLE #myTable
			SELECT 1 as Id,  @ReturnValue as Result

END


GO
/****** Object:  StoredProcedure [dbo].[spConfigurationContents]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spConfigurationContents](@ColumnName nvarchar(50)='English')
AS
BEGIN
	
	DECLARE @SQL nvarchar(max)
	SET @SQL = 'SELECT  
							CCS.ConfigurationContentId Id,
							CCS.ConfigurationContentName as [Name], 
							CCS.'+ @ColumnName + ' as [Text] 
				FROM 
							ConfigurationContents CCS'

    SET @SQL= Replace(@SQL,'"','''')
	EXEC (@SQL)
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteRecord]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteRecord](@TableName nvarchar(50), @KeyName nvarchar(50), @KeyValue nvarchar(50))
as
BEGIN
	DECLARE @DynSql nvarchar(200)
	SET @DynSql='DELETE FROM ' + @TableName + ' Where ' + @KeyName + ' = ' + @KeyValue
	--PRINT @DynSql
	EXEC (@DynSql)
	select 1 as Id, @KeyValue as KeyValue
END
GO
/****** Object:  StoredProcedure [dbo].[spExceptionLogs]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spExceptionLogs 1,0,NULL,NULL,0,''    
--spExceptionLogs 0,0,NULL,NULL    
--spExceptionLogs 1,1,NULL,NULL    
CREATE PROCEDURE [dbo].[spExceptionLogs]    
(     
 @UserId    INT=0,    
 @ApplicationModuleId INT=0,    
 @StartDate   DATETime,    
 @EndDate   DATETime   
 --@ApplicationExceptionLogId INT=0,    
 --@RequestMethod nvarchar(10)    
)    
AS    
BEGIN    
   If(@StartDate<='1801-01-01')    
   BEGIN    
  SET @StartDate=NULL    
   END    
    
   If(@EndDate>='9000-12-31')    
   BEGIN    
  SET @EndDate=NULL    
   END     
 DECLARE @dynSql NVARCHAR(MAX) = '', @conSql NVARCHAR(MAX) = ''    
    
 IF(@UserId>0)    
 BEGIN    
  SET @conSql=@conSql+ ' AND ApplicationExceptionLogs.UserId="' + Cast(@UserId as nvarchar(10)) +'"'    
 END     
    
 --IF(@RequestMethod <> '')    
 --BEGIN    
 -- SET @conSql=@conSql+ ' AND ApplicationExceptionLogs.RequestMethod="' + @RequestMethod+ '"'    
 --END     
    
    
 --IF(@ApplicationExceptionLogId>0)    
 --BEGIN    
 -- SET @conSql=@conSql+ ' AND ApplicationExceptionLogs.ApplicationExceptionLogId="' + Cast(@ApplicationExceptionLogId as nvarchar(10)) +'"'    
 --END     
    
 IF(@ApplicationModuleId>0)    
 BEGIN    
  SET @conSql=@conSql+ ' AND ApplicationModules.ApplicationModuleId="' + Cast(@ApplicationModuleId as nvarchar(10)) +'"'    
 END     
    
    
 IF(@StartDate IS NOT NULL AND @EndDate IS NOT NULL)    
 BEGIN    
  SET @conSql=@conSql+ ' AND CONVERT(DATE,ApplicationExceptionLogs.ExceptionDate) BETWEEN "' + CONVERT(nvarchar(20),@StartDate) + '"     
  AND "' + CONVERT(nvarchar(20),@EndDate) + '" '    
 END     
 Else IF(@StartDate IS NOT NULL)    
 BEGIN    
  SET @conSql=@conSql+ ' AND CONVERT(DATE,ApplicationExceptionLogs.ExceptionDate) >= "' + CONVERT(nvarchar(20),@StartDate) + '" '    
 END     
 Else IF(@EndDate IS NOT NULL)    
 BEGIN    
  SET @conSql=@conSql+ ' AND CONVERT(DATE,ApplicationExceptionLogs.ExceptionDate) <= "' + CONVERT(nvarchar(20),@EndDate) + '" '    
 END     
    
    
    
 set @dynSql='SELECT dbo.ApplicationExceptionLogs.ApplicationExceptionLogId,     
    dbo.ApplicationExceptionLogs.Message, dbo.Users.FirstName + '' '' + dbo.Users.LastName as FullName , dbo.ModuleMasters.ModuleMasterName    
    FROM dbo.ApplicationExceptionLogs(NOLOCK) LEFT OUTER JOIN dbo.Users(NOLOCK) ON dbo.ApplicationExceptionLogs.UserId = dbo.Users.UserId LEFT OUTER JOIN    
    dbo.ApplicationModules(NOLOCK) ON dbo.ApplicationExceptionLogs.ApplicationModuleId = dbo.ApplicationModules.ApplicationModuleId LEFT OUTER JOIN dbo.ModuleMasters(NOLOCK) ON dbo.ApplicationModules.ModuleMasterId = dbo.ModuleMasters.ModuleMasterId WHERE
  
    
 1=1'    
    
  SET @dynSql=@dynSql + ' ' + @conSql    
  SET @dynsql=replace(@dynsql,'"','''')        
  PRINT @dynSql    
  EXEC (@dynSql)    
    
    
END    
    
GO
/****** Object:  StoredProcedure [dbo].[SpGetColumnValue]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @ColumnValue nvarchar(100)
EXEC uspGetColumnValue 'Departments', 'DepartmentId','DepartmentName',1, @ColumnValue OUTPUT
SELECT @ColumnValue
*/
CREATE PROCEDURE [dbo].[SpGetColumnValue](@TableName nvarchar(20),  @ColumnIdName nvarchar(50), @ColumnValueName nvarchar(50), @KeyId int,   @ColumnValue nvarchar(100) OUTPUT)
AS
BEGIN
		DECLARE @SQL nvarchar(200)
		SET @SQL='SELECT @ColumnValue=' + @ColumnValueName + ' FROM ' + @TableName + ' (nolock) WHERE ' + @ColumnIdName + '= ' + CAST(@KeyId as nvarchar(5))
		EXECUTE sp_executesql @SQL, N'@ColumnValue nvarchar(100) OUTPUT', @ColumnValue=@ColumnValue  OUTPUT
END

GO
/****** Object:  StoredProcedure [dbo].[spGetRootApplicaitonModuleId]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[spGetRootApplicaitonModuleId](@ApplicationModuleId int, @RootApplicationModuleId int output)
AS
BEGIN
		
	;With Modules1 As 
										( 
													SELECT 
															AM.ApplicationModuleId,
															AM.ModuleMasterId,
															AM.ParentApplicationModuleId

													FROM 

															ApplicationModules(nolock) AM 
													WHERE 
															AM.ApplicationModuleId= @ApplicationModuleId
											Union  ALL
						
													SELECT 
															AM2.ApplicationModuleId,
															AM2.ModuleMasterId,
															AM2.ParentApplicationModuleId
													FROM 
															ApplicationModules(nolock) AM2
															 Join Modules1 
														On am2.ApplicationModuleId = Modules1.ParentApplicationModuleId --FOR JSON PATH
										)  
										SELECT @RootApplicationModuleId =ApplicationModuleId FROM Modules1 WHERE ParentApplicationModuleId IS NULL
END
GO
/****** Object:  StoredProcedure [dbo].[spLanguageContents]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spLanguageContents](@ApplicationModuleId int, @Action varchar(4), @LanguageName nvarchar(50)='English')  
AS  
BEGIN  
   
 DECLARE @SQL nvarchar(max)  
 IF @Action = 'view'
 BEGIN
	SET @Action = 'List' 
 END 
 SET @SQL = 'SELECT    
       MCS.ModuleContentId Id,  
       LanguageContentType as Type,  
       LanguageContentName as [Name],   
       CASE WHEN MCS.'+ @LanguageName + ' IS NULL THEN    
       LCS.'+ @LanguageName + '  
       ELSE MCS.'+ @LanguageName + ' END  as [Text]   
    FROM   
       LanguageContents(nolock) LCS INNER JOIN   
       ModuleContents(nolock) MCS ON  
       LCS.LanguageContentId=MCS.LanguageContentId  
    WHERE   
       ApplicationModuleId="'+ Cast(@ApplicationModuleId as nvarchar(5)) +'"   
       AND MCS.Action="'+@Action+'" order by Type asc'  
  
    SET @SQL= Replace(@SQL,'"','''')  
 EXEC (@SQL)  

  END
GO
/****** Object:  StoredProcedure [dbo].[spPermissionDetails]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spPermissionDetails](@ModulePermissions ModulePermissions READONLY, @RoleId int, @ModuleMasterId int)
as
BEGIN
SELECT 1 as Id,
					(
							SELECT 
								MS1.ApplicationModuleId as applicationModuleId,
								MS1.ModuleMasterId as moduleMasterId,
								MS1.ModuleMasterName as moduleName,
								--Sub Module Starts
								(
								SELECT 
										MS2.ApplicationModuleId as applicationModuleId, 
										MS2.ModuleMasterId as submoduleId,	
										MS2.ModuleMasterName as submoduleName, 
										RP2.RolePermissionId as rolePermissionId,
										(
											SELECT 
													canAdd, 
													canEdit, 
													canDelete, 
													canView  
											FROM  
													RolePermissions(nolock) RP1 
											WHERE 
													RP1.ApplicationModuleId=MS2.ApplicationModuleId
													AND RP1.RoleId=(CASE WHEN @RoleID>0 THEN @RoleID ELSE RP1.RoleId END) for json path
										) accessItems,
										--Section starts
										(
														SELECT 
																MS3.ApplicationModuleId as applicationModuleId, 
																MS3.ModuleMasterId as sectionId,	
																MS3.ModuleMasterName as sectionName, 
																RP3.RolePermissionId as rolePermissionId,
																(
																SELECT 
																		canAdd, 
																		canEdit, 
																		canDelete, 
																		canView  
																FROM  
																		RolePermissions(nolock) RP1 
																WHERE 
																		ApplicationModuleId=MS3.ApplicationModuleId
																		AND RP1.RoleId=(CASE WHEN @RoleID>0 THEN @RoleID ELSE RP1.RoleId END)												
																		for json path) accessItems 
															FROM 
																		@ModulePermissions  MS3  
																		INNER JOIN RolePermissions(nolock) RP3 
																		ON RP3.ApplicationModuleId=ms3.ApplicationModuleId
															WHERE 
																		MS3.ModuleLevel=3 and MS3.ParentApplicationModuleId= MS2.ApplicationModuleId
																		AND RP3.RoleId=(Case WHEN @RoleId>0 THEN @RoleId ELSE RP3.RoleId END)
																		for json path
											) as 'Sections'
											--Section Ends
								FROM
																		@ModulePermissions  MS2  
																		INNER JOIN RolePermissions(nolock) RP2 
																		ON RP2.ApplicationModuleId=ms2.ApplicationModuleId
															WHERE 
																		MS2.ModuleLevel=2 and MS2.ParentApplicationModuleId= MS1.ApplicationModuleId
																		AND RP2.RoleId=(Case WHEN @RoleId>0 THEN @RoleId ELSE RP2.RoleId END)
																		For json path
								) as 'SubModules'
								--Sub Module ends
								FROM
																		@ModulePermissions  MS1  
								WHERE 
																		MS1.ModuleLevel=1 --and MS2.ParentModuleMasterId= 2--Rp.ApplicationModuleId
									FOR JSON PATH
					) as ModuleAccess
END
GO
/****** Object:  StoredProcedure [dbo].[spPermissions]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SpPermissions 1,1
--exec SpPermissions 1,0
--exec SpPermissions 1,23
--exec SpPermissions 1,31
--exec SpPermissions 1,50
CREATE PROCEDURE [dbo].[spPermissions](@RoleId int, @ApplicationModuleId int=0)
AS 
BEGIN
			/**/
			--DECLARE @ApplicationModuleId int=16
			DECLARE @ModuleMasterId int=0
			DECLARE @RootApplicationModuleId INT
			If(@ApplicationModuleId>0)
			BEGIN
				EXEC spGetRootApplicaitonModuleId @ApplicationModuleId, @RootApplicationModuleId output
				SET @ModuleMasterId=ISNULL(@RootApplicationModuleId,0)
			END
			--SELECT @ModuleMasterId
			/**/
		--	DECLARE @RoleID int=1
		--	DECLARE @ModuleMasterId int=0
			DECLARE @ParentApplicationModuleId int=0

			DECLARE @ModulePermissions ModulePermissions
			
			IF(@ModuleMasterId>0)
			BEGIN
				SELECT @ParentApplicationModuleId=ApplicationModuleId FROM ApplicationModules(nolock) WHERE ApplicationModuleId=@ModuleMasterId
			END
			--SELECT @ParentApplicationModuleId Parent
				IF (@ModuleMasterId=0)
				BEGIN
							;With Modules As 
							( 
										SELECT 
												AM.ApplicationModuleId,
												MM.ModuleMasterId,
												AM.ParentApplicationModuleId,
												MM.ModuleMasterName, 
												1 as level
										FROM 
												ModuleMasters(nolock) MM 
												INNER JOIN ApplicationModules(nolock) AM ON MM.ModuleMasterId=AM.ModuleMasterId
										WHERE 
												AM.ParentApplicationModuleId is NULL
								Union  ALL
						
										SELECT 
												AM2.ApplicationModuleId,
												MM2.ModuleMasterId,
												AM2.ParentApplicationModuleId,
												MM2.ModuleMasterName, 
												Modules.level+1 as level
										FROM 
												ModuleMasters(nolock) MM2 
												INNER JOIN ApplicationModules(nolock) AM2 ON MM2.ModuleMasterId=AM2.ModuleMasterId
												Join Modules 
											On am2.ParentApplicationModuleId = Modules.ApplicationModuleId --FOR JSON PATH
						
							) 
							INSERT INTO @ModulePermissions(ApplicationModuleId, ModuleMasterId, ParentApplicationModuleId, ModuleMasterName, ModuleLevel)
							SELECT ApplicationModuleId, ModuleMasterId, ParentApplicationModuleId, ModuleMasterName, [level] FROM Modules MS
							EXEC spPermissionDetails @ModulePermissions,@RoleId, @ModuleMasterId
				END
				ELSE
				BEGIN
							;With Modules As 
										( 
													SELECT 
															AM.ApplicationModuleId,
															MM.ModuleMasterId,
															AM.ParentApplicationModuleId,
															MM.ModuleMasterName, 
															1 as level
													FROM 
															ModuleMasters(nolock) MM 
															INNER JOIN ApplicationModules(nolock) AM ON MM.ModuleMasterId=AM.ModuleMasterId
													WHERE 
															AM.ApplicationModuleId= (CASE @ParentApplicationModuleId WHEN 0 THEN AM.ApplicationModuleId ELSE @ParentApplicationModuleId end)
											Union  ALL
						
													SELECT 
															AM2.ApplicationModuleId,
															MM2.ModuleMasterId,
															AM2.ParentApplicationModuleId,
															MM2.ModuleMasterName, 
															Modules.level+1 as level
													FROM 
															ModuleMasters(nolock) MM2 
															INNER JOIN ApplicationModules(nolock) AM2 ON MM2.ModuleMasterId=AM2.ModuleMasterId
															Join Modules 
														On am2.ParentApplicationModuleId = Modules.ApplicationModuleId --FOR JSON PATH
						
										)  
							INSERT INTO @ModulePermissions(ApplicationModuleId, ModuleMasterId, ParentApplicationModuleId, ModuleMasterName, ModuleLevel)
							SELECT ApplicationModuleId, ModuleMasterId, ParentApplicationModuleId, ModuleMasterName, [level] FROM Modules MS
							EXEC spPermissionDetails @ModulePermissions,@RoleId, @ModuleMasterId
				END
END
GO
/****** Object:  StoredProcedure [dbo].[spRequestLogs]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spRequestLogs 1,0,NULL,NULL  
CREATE PROCEDURE [dbo].[spRequestLogs]  
(   
 @UserId    INT=0,  
 @ApplicationModuleId INT=0,  
 @StartDate   DATETime,  
 @EndDate   DATETime  
)  
AS  
BEGIN  
   If(@StartDate<='1801-01-01')  
   BEGIN  
  SET @StartDate=NULL  
   END  
  
   If(@EndDate>='9000-12-31')  
   BEGIN  
  SET @EndDate=NULL  
   END   
 DECLARE @dynSql NVARCHAR(MAX) = '', @conSql NVARCHAR(MAX) = ''  
  
 IF(@UserId>0)  
 BEGIN  
  SET @conSql=@conSql+ ' AND RequestLogs.UserId="' + Cast(@UserId as nvarchar(10)) +'"'  
 END   
  
 IF(@ApplicationModuleId>0)  
 BEGIN  
  SET @conSql=@conSql+ ' AND RequestLogs.ApplicationModuleId="' + Cast(@ApplicationModuleId as nvarchar(10)) +'"'  
 END   
  
   
 IF(@StartDate IS NOT NULL AND @EndDate IS NOT NULL)  
 BEGIN  
  SET @conSql=@conSql+ ' AND CONVERT(DATE,RequestLogs.RequestTime) BETWEEN "' + CONVERT(nvarchar(20),@StartDate) + '"   
  AND "' + CONVERT(nvarchar(20),@EndDate) + '" '  
 END   
 Else IF(@StartDate IS NOT NULL)  
 BEGIN  
  SET @conSql=@conSql+ ' AND CONVERT(DATE,RequestLogs.RequestTime) >= "' + CONVERT(nvarchar(20),@StartDate) + '" '  
 END   
 Else IF(@EndDate IS NOT NULL)  
 BEGIN  
  SET @conSql=@conSql+ ' AND CONVERT(DATE,RequestLogs.RequestTime) <= "' + CONVERT(nvarchar(20),@EndDate) + '" '  
 END   
  
 set @dynSql='SELECT dbo.RequestLogs.RequestLogId, dbo.RequestLogs.ClientIPAddress, dbo.RequestLogs.RequestTime, dbo.RequestLogs.TotalDuration,  dbo.ModuleMasters.ModuleMasterName, dbo.Users.FirstName + '' '' + dbo.Users.LastName as FullName  
FROM dbo.RequestLogs(NOLOCK) LEFT OUTER JOIN  
 dbo.ApplicationModules(NOLOCK) ON dbo.RequestLogs.ApplicationModuleId = dbo.ApplicationModules.ApplicationModuleId LEFT OUTER JOIN  
 dbo.ModuleMasters(NOLOCK) ON dbo.ApplicationModules.ModuleMasterId = dbo.ModuleMasters.ModuleMasterId LEFT OUTER JOIN  
 dbo.Users(NOLOCK) ON dbo.RequestLogs.UserId = dbo.Users.UserId  
 WHERE 1=1'  
  
  SET @dynSql=@dynSql + ' ' + @conSql  
  SET @dynsql=replace(@dynsql,'"','''')      
  PRINT @dynSql  
  EXEC (@dynSql)  
  
  
END
GO
/****** Object:  StoredProcedure [dbo].[spServerMessages]    Script Date: 26-08-2019 06:17:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC spServerMessages 139, 1
CREATE PROCEDURE [dbo].[spServerMessages](@LanguageContentId int,@LanguageId int)
AS
BEGIN
	DECLARE @LanguageName nvarchar(50)
	Select  @LanguageName = LanguageCode from Languages where LanguageId=@LanguageId
	DECLARE @DynSql nvarchar(max)
	SET @DynSql= '
				SELECT 
						LanguageContentId as ServerMessageId, ISNULL('+
						  @LanguageName + ' ,"abd") as Message 
				FROM
						LanguageContents(nolock)
				Where	
						LanguageContentId=' + CAST(@LanguageContentId as nvarchar(10))
	SET @DynSql=REPLACE(@DynSql,'"','''')
	EXEC (@DynSql)
END

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'set url ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApplicationExceptionLogs', @level2type=N'COLUMN',@level2name=N'Url'
GO
EXEC sys.sp_addextendedproperty @name=N'author', @value=N'varix' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApplicationExceptionLogs'
GO
EXEC sys.sp_addextendedproperty @name=N'objective', @value=N'this table does xyz' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApplicationExceptionLogs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parent Application Module' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApplicationModules', @level2type=N'COLUMN',@level2name=N'ParentApplicationModuleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Main Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApplicationObjects', @level2type=N'COLUMN',@level2name=N'ApplicationObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Application Objects is used Application wide' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApplicationObjects'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Record Details' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AuditRecordDetails', @level2type=N'COLUMN',@level2name=N'AuditRecordDetailId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This is Only Used for Server Message Or Server side keys operations.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LanguageContents', @level2type=N'COLUMN',@level2name=N'ContentType'
GO
USE [master]
GO
ALTER DATABASE [AquaProDbDev] SET  READ_WRITE 
GO
