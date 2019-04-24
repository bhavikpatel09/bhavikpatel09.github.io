--https://www.garykessler.net/library/file_sigs.html
--https://www.yohz.com/sbe_details.htm
--https://www.jitendrazaa.com/blog/sql/sqlserver/export-documents-saved-as-blob-binary-from-sql-server/
CREATE FUNCTION [dbo].[GetFileExt]
(
	-- Add the parameters for the function here
	@FileData varbinary(max)
)
RETURNS varchar(50)
AS
BEGIN
	Declare @Ext varchar(50)
	Set @Ext = (CASE WHEN @FileData >= 0x25504446  AND @FileData <= 0x25504447 THEN '.pdf' 
		WHEN @FileData >=0x3C21646F63747970 AND @FileData<=0x3D21646F63747970 THEN '.html'
		WHEN @FileData >= 0x47494638 AND @FileData <= 0x47494639 THEN '.gif'
		WHEN @FileData >=0xFFD8FFE0  AND @FileData < 0xFFD8FFE1 THEN '.jfif'
		WHEN @FileData >=0xFFD8FFE1  AND @FileData <= 0xFFD8FFE9 THEN '.jpg'
		WHEN @FileData >=0x89504E47 AND @FileData <= 0x89504E48 THEN '.png'
		WHEN @FileData >=0x50726F6A65 AND @FileData <=0x50726F6A66 THEN '.csv'
		WHEN @FileData>=0x5261646978 AND @FileData<=0x5261646979 THEN '.txt'
		WHEN @FileData>=0xD0CF11E0A1B11AE1 AND @FileData<=0xE0CF11E0A1B11AE1 THEN '.xls'
		WHEN @FileData>=0x504B03041400060008000000210064 AND @FileData<=0x504B030414000600080000002100DF THEN '.xlsx'
		WHEN @FileData>=0x504B03041400060008000000210017 AND @FileData <= 0x504B03041400060008000000210064  THEN '.docx'
		ELSE ''
		END) 
	-- Return the result of the function
	RETURN @Ext

END
