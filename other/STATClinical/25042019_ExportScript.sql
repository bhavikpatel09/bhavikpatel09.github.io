

--sp_configure 'show advanced options', 1;
--GO
--RECONFIGURE;
--GO
--sp_configure 'Ole Automation Procedures', 1;
--GO
--RECONFIGURE;
--GO

DECLARE @outPutPath varchar(50) = 'D:\Files\Downloaded'
, @i bigint
, @init int
, @data varbinary(max) 
, @fPath varchar(max)  
, @folderPath  varchar(max) 
 
--Get Data into temp Table variable so that we can iterate over it 
DECLARE @Doctable TABLE (id int identity(1,1), [Doc_Num]  varchar(100) ,[FolderName] varchar(50), [FileName]  varchar(100), [Doc_Content] varBinary(max) )
 
INSERT INTO @Doctable([Doc_Num] , FolderName, [FileName],[Doc_Content])
Select fileid, FolderName, REPLACE([FileName],'.zip',''),FileData FROM  Attachments 
 
--SELECT * FROM @table

SELECT @i = COUNT(1) FROM @Doctable
 
WHILE @i >= 1
BEGIN 

	SELECT 
	 @data = [Doc_Content],
	 --@fPath = @outPutPath + '\'+ [Doc_Num] + '\' +[FileName],
	 @fPath = @outPutPath + '\'+ [FolderName] + '\' + [FileName] + '.zip' ,
	 @folderPath = @outPutPath + '\'+ [FolderName]
	FROM @Doctable WHERE id = @i
 
  --Create folder first
  EXEC  [dbo].[CreateFolder]  @folderPath
  
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