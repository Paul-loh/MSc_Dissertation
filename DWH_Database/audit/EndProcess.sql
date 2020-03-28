CREATE PROC [audit].[EndProcess] ( @ETLProcessID INT )
WITH EXECUTE AS OWNER 
AS
BEGIN
       SET NOCOUNT ON;

	   DECLARE @now DATETIME = GETDATE();

              UPDATE audit.Process 
              SET	[End]			=	@now
              WHERE ETLProcessID	=	@ETLProcessID;
END

GO


