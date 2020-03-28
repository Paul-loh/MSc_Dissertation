CREATE PROCEDURE [etl].[INITIAL_LOAD_Create_Ghost_Records]
WITH EXECUTE AS OWNER 
AS

--		Author:			Paul Loh
--		Date:			20200203 
--		Description:	Create 'Ghost' records records in Data Vault Hub tables

-- HUB CURRENCIES
	DELETE 
	FROM		[dv].[HubCurrencies] 
	WHERE		[HKeyCurrency] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubCurrencies] 
			(
				[HKeyCurrency]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
				,[CurrencyCode]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
;


-- HUB SECURITIES
	DELETE 
	FROM		[dv].[HubSecurities] 
	WHERE		[HKeySecurity] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubSecurities] 
			(
				[HKeySecurity]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
				,[SecID]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
	;


-- HUB PORTFOLIOS
	DELETE 
	FROM		[dv].[HubPortfolios] 
	WHERE		[HKeyPortfolio] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubPortfolios] 
			(
				[HKeyPortfolio]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
				,[PortfCode]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)	
	;


-- HUB VALUATIONS
	DELETE 
	FROM		[dv].[HubValuations] 
	WHERE		[HKeyValuation] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubValuations] 
			(
				[HKeyValuation]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]				
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
			)
	;


-- HUB BACKERS
	DELETE 
	FROM		[dv].[HubBackers] 
	WHERE		[HKeyBacker] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubBackers] 
			(
				[HKeyBacker]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]				
				,[BackerCode]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
	;



-- HUB BROKERS
	DELETE 
	FROM		[dv].[HubBrokers] 
	WHERE		[HKeyBroker] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubBrokers] 
			(
				[HKeyBroker]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]				
				,[BrokerCode]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
	;



---- HUB INDUSTRY HIERARCHY LEVELS
	DELETE 
	FROM		[dv].[HubIndustryHierarchyLevel]
	WHERE		[HKeyIndustryHierarchyLevel] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubIndustryHierarchyLevel] 
			(
				[HKeyIndustryHierarchyLevel]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]				
				,[Code]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
	;

---- HUB REGION HIERARCHY LEVELS
	DELETE 
	FROM		[dv].[HubRegionHierarchyLevel]
	WHERE		[HKeyRegionHierarchyLevel] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubRegionHierarchyLevel] 
			(
				[HKeyRegionHierarchyLevel]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]				
				,[Code]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
	;
	
---- HUB ASSET HIERARCHY LEVELS
	DELETE 
	FROM		[dv].[HubAssetHierarchyLevel]
	WHERE		[HKeyAssetHierarchyLevel] IN ( 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222)
	;

	INSERT INTO [dv].[HubAssetHierarchyLevel] 
			(
				[HKeyAssetHierarchyLevel]
				,[Meta_LoadDateTime]
				,[Meta_LastSeenDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]				
				,[Code]
			)
	VALUES	(
				0x1111111111111111111111111111111111111111
				,N'1900-01-01'
				,N'9999-12-31'
				,N'DWH.GhostRecords'
				,-1
				,N'MISSING_BK'
			)
	;



