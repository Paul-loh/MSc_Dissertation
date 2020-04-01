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
	    ,@TARGET_ENVIRONMENT_NAME NVARCHAR(128) = N'DEV'		-- Environment you want to create or update
	    ,@ENVIRONMENT_ID          INT
	    ,@VARIABLE_NAME           NVARCHAR(128)
	    ,@VARIABLE_VALUE          NVARCHAR(1024)
	    ,@VARIABLE_DESCRIPTION    NVARCHAR(1024);

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

	 ('EmailServer','smtp.caledonia.com','Name of email server')
    ,('EmailSSL','0','Use SSL Flag: 0=False, 1=True')
    ,('EmailUser','paul.loh@caledonia.com','Email account of sender')
    ,('FailureEmailBody','SSIS Package Failure','Default text in package failure email')
    ,('FailureEmailPriority','1','1=High; 2=Normal (default); 3=Low')
    ,('FailureEmailSend','1','Send integration failure email. 0 = No \ 1 = Yes')
    ,('FailureEmailSubject','SSIS Package Failure','Text in Email Subject Line')
    ,('FailureEmailTo','paul.loh@caledonia.com','Recipient of integration failure emails')
    ,('FileIn_LPANALYST_DWCAPA','D:\systems\Integration\Dev\InputFiles\LPANALYST\DWH\DWCapitalAccounts.csv','Record source code: LPANALYST.CAPACC. LP Analyst Capital Accounts.')
    ,('FileIn_LPANALYST_DWCASH','D:\systems\Integration\Dev\InputFiles\LPANALYST\DWH\DWCashFlowData.csv','Record source code: LPANALYST.CASHFLOW. LP Analyst Cash Flow Data.')
    ,('FileIn_LPANALYST_DWCOMP','D:\systems\Integration\Dev\InputFiles\LPANALYST\DWH\DWCompanyData.csv','Record source code: LPANALYST.COMPDAT. LP Analyst Company Data.')
    ,('FileIn_LPANALYST_DWFUND','D:\systems\Integration\Dev\InputFiles\LPANALYST\DWH\DWFunds.csv','Record source code: LPANALYST.FUNDS. LP Analyst Funds.')
    ,('FileIn_MANUAL_DWCLDR_CUS','D:\systems\Integration\Dev\InputFiles\Manual\DWH\DWcldr.cus','Record source code: MANUAL.CALEND. Master Data: Manually maintained calendar.')
    ,('FileIn_MANUAL_DWCURR_CUS','D:\systems\Integration\Dev\InputFiles\Manual\DWH\dwcurr.cus','Record source code: MANUAL.CURRENC. Master data: Manually maintained currencies file (enriched Pacer export)')
    ,('FileIn_MANUAL_DWSMAP_CUS','D:\systems\Integration\Dev\InputFiles\Manual\DWH\DWsmap.cus','Record source code: MANUAL.SECIDNMAP. Master Data: Manually maintained system security identifier mapping source file')
    ,('FileIn_MANUAL_DWSRCE_CUS','D:\systems\Integration\Dev\InputFiles\Manual\DWH\DWsrce.cus','Record source code: MANUAL.PRCSRC. Master Data: Manually maintained price source file')
    ,('FileIn_MANUAL_DWTRMP_CUS','D:\systems\Integration\Dev\InputFiles\Manual\DWH\DWtrmp.cus','Record source code: MANUAL.TRANMAP. Master Data: Manually maintained transaction bucket mappings source file')
    ,('FileIn_PACER_DWBROK_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\DWbrok.cus','Record source code: PACER.BROKERS. Master data: Pacer IMS brokers file')
    ,('FileIn_PACER_DWCLA1_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwcla1.cus','Record source code: PACER.REGHIER. Master data: Pacer IMS Regions Hierarchy file')
    ,('FileIn_PACER_DWCLA2_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwcla2.cus','Record source code: PACER.ASSHIER. Master data: Pacer IMS Asset Types Hierarchy file')
    ,('FileIn_PACER_DWCLAS_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwclas.cus','Record source code: PACER.INDHIER. Master data: Pacer IMS Industry Sector Hierarchy file')
    ,('FileIn_PACER_DWCRNC_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwcrnc.cus','Record source code: PACER.FXRATES. FX Rates data: Pacer IMS FX Rates file')
    ,('FileIn_PACER_DWPAMT_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\DWpamt.cus','Record source code: PACER.MSTPRTTYP. Master Data: Pacer IMS Master Portfolios files')
    ,('FileIn_PACER_DWPGRP_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\DWpgrp.cus','Record source code: PACER.MSTPRTSUB. Master Data: Pacer IMS Master Portfolio Subsidiaries files')
    ,('FileIn_PACER_DWPRIC_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwpric.cus','Record source code: PACER.PRICES. Price data: Pacer IMS prices file')
    ,('FileIn_PACER_DWPTAB_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwptab.cus','Record source code: PACER.PORTF. Master Data: Pacer Portfolio data: Pacer IMS Portfolio file')
    ,('FileIn_PACER_DWSAIS_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\DWsais.cus','Record source code: PACER.SECBACK. Master data: Pacer IMS securities to backers link file')
    ,('FileIn_PACER_DWSBAR_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\DWsbar.cus','Record source code: PACER.BACKERS. Master data: Pacer IMS backers file')
    ,('FileIn_PACER_DWSERE_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwsere.cus','Record source code: PACER.SEC. Master data: Pacer IMS securities file')
    ,('FileIn_PACER_DWTREP_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwtrep.cus','Record source code: PACER.TRANS. Transactions data: Pacer IMS transactions file')
    ,('FileIn_PACER_DWTREPX_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwtrepx.cus','Record source code: PACER.SECCLASS. Master data: Pacer IMS security - hierarchy level mappings file')
    ,('FileIn_PACER_DWVALU_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\dwvalu.cus','Record source code: PACER.VALU. Pacer Valuations data: Pacer IMS Valuations file')
    ,('FileIn_PACER_DWWRCL_CUS','D:\systems\Integration\Dev\InputFiles\Pacer\DWH\DWwrcl.cus','Record source code: PACER.SECCLASS. Master data: Pacer IMS security - hierarchy level mappings file')
    ,('PathArchive_HSBCNET','D:\systems\Integration\Dev\Archive\HSBCNET\','Source System code: HSBCNET. Archive directory.')
    ,('PathArchive_LPANALYST','D:\systems\Integration\Dev\Archive\LPANALYST\','Source System code: LPANALYST. Archive directory.')
    ,('PathArchive_MANUAL','D:\systems\Integration\Dev\Archive\MANUAL\','Source System code: MANUAL. Archive directory.')
    ,('PathArchive_PACER','D:\systems\Integration\Dev\Archive\PACER\','Source System code: PACER. Archive directory.')
    ,('PathInputFolder_HSBC_NET_POSITIONS','D:\Systems\Integration\Dev\InputFiles\HSBCNet\PositionStatement\','Record source code: HSBCNET.POS. HSBC.NET Client View Positions Report landing folder for DWH import')       
  --
  --
) AS v([name], [value], [description]);


SELECT * FROM @ENVIRONMENT_VARIABLES;  -- debug output		
GO


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















