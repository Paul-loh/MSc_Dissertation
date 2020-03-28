CREATE TABLE [dv].[LinkSecurityBackers]
(
	[HKeySecurityBacker]						BINARY(20) NOT NULL,
	[Meta_LoadDateTime]						DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]					DATETIME2 NOT NULL,					-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]						NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]						INT	NOT NULL,						-- FK to ID of import batch audit table	?
	
	[HKeySecurity]							BINARY(20) NOT NULL,				
	[HKeyBacker]							BINARY(20) NOT NULL,				

	[SecID]									NVARCHAR (100) NOT NULL,			--	UIX
	[BackerCode]							NVARCHAR (100) NOT NULL,			--	UIX

	CONSTRAINT [PK_LinkSecurityBackers]	PRIMARY KEY NONCLUSTERED ( [HKeySecurityBacker] ),
	CONSTRAINT [UIX_LinkSecurityBackers]	UNIQUE CLUSTERED ( [SecID] ASC, [BackerCode] ASC )		-- Good practice to add a unique index constraint on Business Key columns
)
