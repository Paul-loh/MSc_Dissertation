CREATE PROC [audit].[StartPackage]	(
										@ETLProcessID		INT,
										@ETLPackageName		NVARCHAR(255),
										@ETLPackageID		INT OUT 
									)
WITH EXECUTE AS OWNER 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

	   BEGIN TRAN
	   
		   DECLARE @now DATETIME = GETDATE();

		   SET @ETLPackageID = ISNULL((	SELECT MAX(ETLPackageID) + 1 FROM [audit].Package), 1);	

		   INSERT INTO [audit].[Package]
			   (
				ETLPackageID
			   ,ETLPackageName
			   ,ETLProcessID
			   ,Start
			   )
		  VALUES
			   (@ETLPackageID, @ETLPackageName, @ETLProcessID, @now);
			   
	   COMMIT 
END
