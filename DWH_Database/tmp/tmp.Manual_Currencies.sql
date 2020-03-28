CREATE TABLE [tmp].[MANUAL_Currencies]
(
	[CcyCode] [varchar](100) NULL,
	[SSCCode] [varchar](100) NULL,
	[CurrencyName] [varchar](100) NULL,
	[Group] [varchar](100) NULL, 
    [Meta_ETLProcessID] INT NULL,
	[Meta_LoadDateTime] DATETIME2 NULL
)	ON [PRIMARY]

