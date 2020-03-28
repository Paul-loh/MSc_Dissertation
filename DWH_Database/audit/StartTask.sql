CREATE PROC [audit].[StartTask]  (
									@ETLPackageID	INT,
									@ETLTaskName	NVARCHAR(255), 
									@Input			NVARCHAR(1000),
									@Output			NVARCHAR(1000), 
									@ETLTaskID		INT OUT 
								) 
WITH EXECUTE AS OWNER 
AS 
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

	   BEGIN TRAN

		   DECLARE @now DATETIME = GETDATE();

		   SET @ETLTaskID = ISNULL(( SELECT MAX(ETLTaskID) + 1 FROM [audit].[Task]), 1);

		   INSERT INTO [audit].[Task]
			   (
				ETLTaskID
			   ,ETLTaskName
			   ,ETLPackageID
			   ,[Start]
			   ,[Input]
			   ,[Output]
			   )
			VALUES
			  ( @ETLTaskID, @ETLTaskName, @ETLPackageID, @now, @Input, @Output );
		   
		COMMIT
END
GO


