CREATE PROCEDURE [InfoMartFinRep].[GetDimCustodianAccount]	@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Custodian Accounts Dimension Table in Finrep (Financial Reporting) Information Mart.
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

	SELECT			CAST(
							HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														ha.SecuritiesAccountNumber,														
														CONVERT( NVARCHAR(30), sa.Meta_LoadDateTime, 126 )
													)
										)	AS NCHAR(10) 
						)												AS DimCustodianAccountID
					
					, CAST( sa.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Cust_Acc_LoadDateTime
					,ha.SecuritiesAccountNumber
					,sa.AccountName
					,sa.AccountCurrency
						
		FROM			dv.HubCustodianAccounts		ha

		INNER JOIN		dv.SatCustodianAccounts		sa
		ON				ha.HKeyCustodianAccount		=		sa.HKeyCustodianAccount
		AND				@AsOfDateTime				<=		sa.Meta_LoadEndDateTime
		--AND			(
		--				@AsOfDateTime				BETWEEN	sa.Meta_LoadDateTime	
		--											AND		sa.Meta_LoadEndDateTime
		--			)
;

			







