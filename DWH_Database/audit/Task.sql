CREATE TABLE [audit].[Task](
	[ETLTaskID]			INT NOT NULL,
	[ETLTaskName]		NVARCHAR (255) NOT NULL,
	[ETLPackageID]		INT NOT NULL,
	[Start]				DATETIME NOT NULL,
	[End]				DATETIME NULL,
	[Record Count]		INT NULL,
	[Test Result]		NVARCHAR (20) NULL,
	[Input]				NVARCHAR(1000) NULL,
	[Output]			NVARCHAR (1000) NULL
)
GO
