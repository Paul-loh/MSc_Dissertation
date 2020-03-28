CREATE TABLE [dv].[LinkPortfolioMasterSubsidiary]
(
	[HKeyLinkPortfolioMasterSubsidiary]		BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]						DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]					DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]						NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]						INT NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HKeyMasterPortfolioCode]				BINARY(20) NOT NULL,			
	[HKeySubsidiaryPortfolioCode]			BINARY(20) NOT NULL,		

	[MasterPortfolioCode]					NVARCHAR (100) NULL,		
	[SubsidiaryPortfolioCode]				NVARCHAR (100) NOT NULL,		
			
	CONSTRAINT [PK_LinkPortfolioMasterSubsidiary]	PRIMARY KEY NONCLUSTERED ( [HKeyLinkPortfolioMasterSubsidiary] ),		
	CONSTRAINT [UIX_LinkPortfolioMasterSubsidiary]	UNIQUE CLUSTERED ( [MasterPortfolioCode], [SubsidiaryPortfolioCode] )	-- Good practice to add unique index constraint on Business Key columns

)
