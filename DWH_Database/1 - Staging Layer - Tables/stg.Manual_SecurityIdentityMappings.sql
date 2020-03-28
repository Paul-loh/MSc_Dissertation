CREATE TABLE [stg].[Manual_SecurityIdentityMappings]
(
	[ID]									INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	

	[In_LeadSystemCode]						VARCHAR(100) NULL,
	[In_LeadSystemSecurityCode]				VARCHAR(100) NULL,
	[In_PartnerSystemCode001]				VARCHAR(100) NULL,
	[In_PartnerSystemSecurityCode001]		VARCHAR(100) NULL,
	[In_PartnerSystemCode002]				VARCHAR(100) NULL,
	[In_PartnerSystemSecurityCode002]		VARCHAR(100) NULL,
	[In_PartnerSystemCode003]				VARCHAR(100) NULL,
	[In_PartnerSystemSecurityCode003]		VARCHAR(100) NULL,
	[In_PartnerSystemCode004]				VARCHAR(100) NULL,
	[In_PartnerSystemSecurityCode004]		VARCHAR(100) NULL,
	[In_PartnerSystemCode005]				VARCHAR(100) NULL,
	[In_PartnerSystemSecurityCode005]		VARCHAR(100) NULL,
	
	[Out_LeadSystemCode]					NVARCHAR(100) NULL,
	[Out_LeadSystemSecurityCode]			NVARCHAR(100) NULL,
	[Out_PartnerSystemCode001]				NVARCHAR(100) NULL,
	[Out_PartnerSystemSecurityCode001]		NVARCHAR(100) NULL,
	[Out_PartnerSystemCode002]				NVARCHAR(100) NULL,
	[Out_PartnerSystemSecurityCode002]		NVARCHAR(100) NULL,
	[Out_PartnerSystemCode003]				NVARCHAR(100) NULL,
	[Out_PartnerSystemSecurityCode003]		NVARCHAR(100) NULL,
	[Out_PartnerSystemCode004]				NVARCHAR(100) NULL,
	[Out_PartnerSystemSecurityCode004]		NVARCHAR(100) NULL,
	[Out_PartnerSystemCode005]				NVARCHAR(100) NULL,
	[Out_PartnerSystemSecurityCode005]		NVARCHAR(100) NULL,
	
	[Meta_ETLProcessID]						INT	NULL,		
	[Meta_RecordSource]						NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]						DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]			DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]				DATETIME2 NULL,
	[Meta_EffectToDateTime]					DATETIME2 NULL,	
	[Meta_ActiveRow]						BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)

