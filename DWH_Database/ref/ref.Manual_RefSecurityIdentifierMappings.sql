CREATE TABLE [ref].[RefSecurityIdentifierMappings]
(	
	[Meta_LoadDateTime]						DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]					DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_SrcSysExportDateTime]				DATETIME2 NULL, 
	[Meta_RecordSource]						NVARCHAR (1000) NOT NULL,	-- Primarily should be SQL Server MDS
	[Meta_ETLProcessID]						INT	NOT NULL,				-- FK to ID of import batch audit table	
	[LeadSystemCode]						NVARCHAR (100) NOT NULL,	-- Initially Pacer 
	[LeadSystemSecurityCode]				NVARCHAR (100) NOT NULL,	
	[PartnerSystemCode001]					NVARCHAR (100) NOT NULL,	-- Initially HSBC.Net Client View
	[PartnerSystemSecurityCode001]			NVARCHAR (100) NOT NULL,
	[PartnerSystemCode002]					NVARCHAR (100) NULL,		-- LP Analyst?
	[PartnerSystemSecurityCode002]			NVARCHAR (100) NULL,
	[PartnerSystemCode003]					NVARCHAR (100) NULL,		-- Spare
	[PartnerSystemSecurityCode003]			NVARCHAR (100) NULL,
	[PartnerSystemCode004]					NVARCHAR (100) NULL,		-- Spare
	[PartnerSystemSecurityCode004]			NVARCHAR (100) NULL,
	[PartnerSystemCode005]					NVARCHAR (100) NULL,		-- Spare
	[PartnerSystemSecurityCode005]			NVARCHAR (100) NULL,

	CONSTRAINT [UIX_refSecurityID_Mappings]	UNIQUE CLUSTERED	( 
																	[LeadSystemCode] ASC, 
																	[LeadSystemSecurityCode] ASC,  
																	[PartnerSystemCode001] ASC, 
																	[PartnerSystemSecurityCode001] ASC,
																	[Meta_LoadDateTime] ASC														
																), 
    CONSTRAINT [PK_RefSecurityIdentifierMappings] PRIMARY KEY	(		
																	[Meta_LoadDateTime], 
																	[LeadSystemCode], 
																	[LeadSystemSecurityCode]											
																)	
)
