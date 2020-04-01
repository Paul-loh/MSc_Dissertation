/* 
	Author:			Paul Loh
	Date:			20200317

	Description: 
		Create new environment by copying the environment variables and values from an existing environment. 
		Can also be used to update environment variable values, and apply updated values to an existing environment.
		https://www.mssqltips.com/sqlservertip/5924/copy-or-duplicate-sql-server-integration-services-ssis-environments-using-tsql/
*/


DECLARE
	 @FOLDER_NAME             NVARCHAR(128) = N'DWH'
	,@FOLDER_ID               BIGINT
	,@TARGET_ENVIRONMENT_NAME NVARCHAR(128) = N'UAT'		-- Environment you want to create or update
	,@ENVIRONMENT_ID          INT
	,@VARIABLE_NAME           NVARCHAR(128)
	,@VARIABLE_VALUE          NVARCHAR(1024)
	,@VARIABLE_DESCRIPTION    NVARCHAR(1024)

DECLARE @ENVIRONMENT_VARIABLES TABLE (
										  [name]        NVARCHAR(128)
										, [value]       NVARCHAR(1024)
										, [description] NVARCHAR(1024)
									);	



--	Load Environment Variables and Values into a Table Variable
INSERT @ENVIRONMENT_VARIABLES
SELECT [name], [value], [description]
FROM (
  VALUES
  --
  -- PASTE the TVC from CopyEnvironmentVariables script HERE
  --	Remove leading comma in the first line of values
  --
		('Test','Test','Test')        
  --
  --
) AS v([name], [value], [description]);
 
SELECT * FROM @ENVIRONMENT_VARIABLES;  -- debug output		



--	Create Folder (if necessary)
IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[folders] WHERE name = @FOLDER_NAME)
    EXEC [SSISDB].[catalog].[create_folder] @folder_name=@FOLDER_NAME, @folder_id=@FOLDER_ID OUTPUT
ELSE
    SET @FOLDER_ID = (SELECT folder_id FROM [SSISDB].[catalog].[folders] WHERE name = @FOLDER_NAME)	



--	Create Environment (if necessary)
IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[environments] WHERE folder_id = @FOLDER_ID AND
               name = @TARGET_ENVIRONMENT_NAME)
    EXEC [SSISDB].[catalog].[create_environment]
     @environment_name=@TARGET_ENVIRONMENT_NAME,
     @folder_name=@FOLDER_NAME

-- get the environment id
SET @ENVIRONMENT_ID = (SELECT environment_id FROM [SSISDB].[catalog].[environments] 
WHERE folder_id = @FOLDER_ID and name = @TARGET_ENVIRONMENT_NAME)		



--	Create or Update Environment Variables and Values

	--	Iterate through @ENVIRONMENT_VARIABLES table variable and check if environment variable exists in environment. 
	--	If environment variable does not exist, create it; otherwise update environment variable value.

SELECT TOP 1
 @VARIABLE_NAME = [name]
,@VARIABLE_VALUE = [value]
,@VARIABLE_DESCRIPTION = [description]
FROM @ENVIRONMENT_VARIABLES
WHILE @VARIABLE_NAME IS NOT NULL
BEGIN
   PRINT @VARIABLE_NAME
    -- create environment variable if it doesn't exist
   IF NOT EXISTS (
      SELECT 1 FROM [SSISDB].[catalog].[environment_variables] 
      WHERE environment_id = @ENVIRONMENT_ID AND name = @VARIABLE_NAME
   )
      EXEC [SSISDB].[catalog].[create_environment_variable]
        @variable_name=@VARIABLE_NAME
      , @sensitive=0
      , @description=@VARIABLE_DESCRIPTION
      , @environment_name=@TARGET_ENVIRONMENT_NAME
      , @folder_name=@FOLDER_NAME
      , @value=@VARIABLE_VALUE
      , @data_type=N'String'
   ELSE
    -- update environment variable value if it exists
      EXEC [SSISDB].[catalog].[set_environment_variable_value]
        @folder_name = @FOLDER_NAME
      , @environment_name = @TARGET_ENVIRONMENT_NAME
      , @variable_name = @VARIABLE_NAME
      , @value = @VARIABLE_VALUE
   DELETE TOP (1) FROM @ENVIRONMENT_VARIABLES
   SET @VARIABLE_NAME = null
   SELECT TOP 1
     @VARIABLE_NAME = [name]
    ,@VARIABLE_VALUE = [value]
    ,@VARIABLE_DESCRIPTION = [description]
    FROM @ENVIRONMENT_VARIABLES
END















