CREATE TABLE [audit].[Package]
(
	[ETLPackageID]			INT NOT NULL,
	[ETLPackageName]		NVARCHAR (255) NOT NULL,
	[ETLProcessID]		INT NOT NULL,
	[Start]			DATETIME NOT NULL,
	[End]			DATETIME NULL,
	[Error Message] NVARCHAR (MAX) NULL
) 
GO