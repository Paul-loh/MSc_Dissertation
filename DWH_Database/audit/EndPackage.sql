CREATE PROC [audit].[EndPackage] (
									@ETLPackageID		INT, 
									@ErrorMessage	NVARCHAR (MAX) 
								)
WITH EXECUTE AS OWNER 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

	   DECLARE @now DATETIME = GETDATE();

       UPDATE	[audit].[Package]
       SET		[End]				=	@now
				,[Error Message]	=	@ErrorMessage 
		WHERE	ETLPackageID		=	@ETLPackageID;
		
END

