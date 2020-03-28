CREATE TABLE [audit].[Process]
(
	[ETLProcessID]		INT NOT NULL,
	[ETLProcessName]	NVARCHAR (255) NOT NULL,
	[Start]				DATETIME NOT NULL,
	[End]				DATETIME NULL
) 
GO


