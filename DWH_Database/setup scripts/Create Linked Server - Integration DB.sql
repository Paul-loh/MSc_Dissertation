USE [master]
GO

	--	CHECK IF LINKED SERVER EXISTS AND DELETE 
	IF NOT EXISTS (
						SELECT	* 
						FROM	sys.servers 
						WHERE	name = N'.'
						AND		is_linked = 1
					)
	BEGIN 

		/****** Object:  LinkedServer [.]    Script Date: 28/03/2020 14:24:33 ******/
		EXEC master.dbo.sp_addlinkedserver @server = N'.', @srvproduct=N'SQL Server'
	
		/* For security reasons the linked server remote logins password is changed with ######## */
		EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'.',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL;

		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'collation compatible', @optvalue=N'false'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'data access', @optvalue=N'true'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'dist', @optvalue=N'false'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'pub', @optvalue=N'false'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'rpc', @optvalue=N'false'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'rpc out', @optvalue=N'false'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'sub', @optvalue=N'false'
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'connect timeout', @optvalue=N'0';
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'collation name', @optvalue=null
	
		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'lazy schema validation', @optvalue=N'false'

		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'query timeout', @optvalue=N'0'

		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'use remote collation', @optvalue=N'true'

		EXEC master.dbo.sp_serveroption @server=N'.', @optname=N'remote proc transaction promotion', @optvalue=N'true';

	END

USE [DWH];
GO