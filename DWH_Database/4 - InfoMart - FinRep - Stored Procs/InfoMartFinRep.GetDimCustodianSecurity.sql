CREATE PROCEDURE [InfoMartFinRep].[GetDimCustodianSecurity]		@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20200130
	--	Description:		Custodian Securities Dimension Table in Finrep (Financial Reporting) Information Mart.
	--
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where the parameter is between 
	--													Meta_LoadDateTime + Meta_LoadEndDateTime													
	--						Grain: 
	--								Account Code | Load DateTime
	--			

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;
		
	SELECT									
						CAST(
								HASHBYTES	(	N'SHA1',
												CONCAT_WS	(	
																N'|',
																hs.ISIN,														
																CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
															)
											)	AS NCHAR(10) 
							)												AS DimCustodianSecurityID

						, CAST( ss.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Cust_LoadDateTime

						,hs.ISIN
						,ss.SecurityDescription
						,ss.SEDOL
						,ss.IssueType
						,ss.IssueTypeDescription
						,ss.SecurityCurrency
						
		FROM			dv.HubCustodianSecurities		hs

		INNER JOIN		dv.SatCustodianSecurities		ss
		ON				hs.HKeyCustodianSecurity		=		ss.HKeyCustodianSecurity
		AND				@AsOfDateTime					<=		ss.Meta_LoadEndDateTime
;


