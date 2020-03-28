CREATE PROC [audit].[EndTask] ( 
								@ETLTaskID		INT,
								@TestResult		INT, 
								@RecordCount	INT
								) 
WITH EXECUTE AS OWNER 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

	   DECLARE @now DATETIME = GETDATE();

              UPDATE audit.Task 
              SET [End]			=	@now,
              [Test Result]		=	@TestResult,
			  [Record Count]	=	@RecordCount
              WHERE	ETLTaskID	=	@ETLTaskID;
END



