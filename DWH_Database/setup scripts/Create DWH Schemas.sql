--USE DWH;
--GO

CREATE SCHEMA [etl] 
	AUTHORIZATION [dbo];
GO 

CREATE SCHEMA [tmp] 
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [stg] 
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [dv] 
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [bv] 
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [ref] 
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [finrep] 
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [InfoMartFinRep]
	AUTHORIZATION [dbo];
GO

CREATE SCHEMA [audit] 
	AUTHORIZATION [dbo];
GO
	
--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'etl' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [etl] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'tmp' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [tmp] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'stg' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [stg] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'dv' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [dv] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'bv' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [bv] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'ref' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [ref] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'finrep' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [finrep] AUTHORIZATION [dbo]'  
--	END ;
--GO

--IF NOT EXISTS (
--				SELECT  schema_name
--				FROM    information_schema.schemata
--				WHERE   schema_name = 'audit' 
--				) 
--	BEGIN
--		EXEC sp_executesql N'CREATE SCHEMA [audit] AUTHORIZATION [dbo]'  
--	END ;
--GO






