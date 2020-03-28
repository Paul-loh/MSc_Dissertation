
CREATE PROC		[audit].[StartProcess]	(
											@ETLProcessName	NVARCHAR(500), 
											@ETLProcessID	INT OUT 
										)
WITH EXECUTE AS OWNER 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

	   BEGIN TRAN

			DECLARE @now DATETIME = GETDATE();

			SET @ETLProcessID	= ISNULL((SELECT MAX(ETLProcessID) + 1 FROM [audit].Process), 1);

            INSERT INTO audit.Process 
				(ETLProcessID, ETLProcessName, [Start])

            VALUES 
				(@ETLProcessID, @ETLProcessName, @now);
				
		COMMIT
END
GO


