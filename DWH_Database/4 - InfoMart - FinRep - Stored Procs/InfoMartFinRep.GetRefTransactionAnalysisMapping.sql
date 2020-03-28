CREATE PROCEDURE [InfoMartFinRep].[GetRefTransactionAnalysisMapping]	@AsOfDateTime	DATETIME2	=	NULL																	
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Transaction mappings reference table in Finrep (Financial Reporting) Information Mart.
	--
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where parameter between Meta_LoadDateTime and Meta_LoadEndDateTime
	--						Grain: 
	--								From_TransType | From_FootNote | From_TradeType | From_PrimaryType | Load DateTime

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;
	
	SELECT	
			rtm.From_TransType
			,rtm.From_FootNote
			,rtm.From_TradeType
			,rtm.From_PrimaryType
			,rtm.To_Trans_Category
			,rtm.To_Unit_Category
			,rtm.To_Cash_Category
			
			,rtm.Meta_LoadDateTime AS Meta_MappingLoadDateTime
			
	FROM	ref.RefTransactionAnalysisMapping	rtm

	WHERE 	@AsOfDateTime		BETWEEN		rtm.Meta_LoadDateTime	
								AND			rtm.Meta_LoadEndDateTime				
;
   
