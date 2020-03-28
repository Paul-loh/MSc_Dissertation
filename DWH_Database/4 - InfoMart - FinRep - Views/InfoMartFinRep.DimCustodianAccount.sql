CREATE VIEW [InfoMartFinRep].[DimCustodianAccount]
AS 

	--	Author:				Paul Loh	
	--	Creation Date:		20191024
	--	Description:		Custodian Accounts Dimension Table in Finrep (Financial Reporting) Information Mart.
	--
	--						Grain: Account Code | Load DateTime
			
	SELECT			
						HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														ha.SecuritiesAccountNumber,														
														CONVERT( NVARCHAR(30), sa.Meta_LoadDateTime, 126 )
													)
									)										AS SecurityAccountNumberKey

						, CAST( sa.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Cust_Acc_LoadDateTime

						-- ,sa.Meta_LoadEndDateTime
						,sa.HKeyCustodianAccount
						,ha.SecuritiesAccountNumber

						,sa.AccountName
						,sa.AccountCurrency
						
		FROM			dv.HubCustodianAccounts		ha

		INNER JOIN		dv.SatCustodianAccounts		sa
		ON				ha.HKeyCustodianAccount		=		sa.HKeyCustodianAccount
;

			