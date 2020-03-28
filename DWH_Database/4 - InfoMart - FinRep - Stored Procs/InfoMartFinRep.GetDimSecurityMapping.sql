CREATE PROCEDURE [InfoMartFinRep].[GetDimSecurityMapping]	@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Securities Mappings Dimension Table in Finrep (Financial Reporting) Information Mart.
--						
--						Conforming securities between Lead System (Pacer) and Partner Custodian System (HSBC.Net) 
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter is between 
--													Meta_LoadDateTime + Meta_LoadEndDateTime	
--
--						Grain: Security | Load DateTime


	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;

	SELECT			
				-- Type 2 Dimension PKs 
				CAST(  					
						HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														rsm.LeadSystemCode, 
														rsm.LeadSystemSecurityCode, 
														rsm.PartnerSystemCode001, 
														rsm.PartnerSystemSecurityCode001, 
														CONVERT( NVARCHAR(30), rsm.Meta_LoadDateTime, 126 )
													)
									)	AS NCHAR(10) 
						) 															AS DimSecurityMappingID
							
				--	If no security record exists on the Pacer side default to Ghost record 
				, CAST( 
						HASHBYTES	(	N'SHA1',

									CASE	WHEN hs.SecID IS NULL
											THEN
												CONCAT_WS	(	
																N'|',
																0x1111111111111111111111111111111111111111,														
																CONVERT( NVARCHAR(30), CAST(N'9999-12-31' AS DATETIME2)) 
															)											
											ELSE
												CONCAT_WS	(	
																N'|',
																hs.SecID,														
																CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
															)
											END 
								) AS NCHAR(10) 									
						)															AS DimSecurityID				
							
				,hs.SecID
				,ss.Meta_LoadDateTime												AS Meta_SecID_LoadDateTime

				, CAST(
						HASHBYTES	(	N'SHA1',
									CASE	WHEN hcs.ISIN IS NULL
											THEN
												CONCAT_WS	(	
																N'|',
																0x1111111111111111111111111111111111111111,														
																CONVERT( NVARCHAR(30), CAST(N'9999-12-31' AS DATETIME2)) 
															)											
											ELSE
												CONCAT_WS	(	
																N'|',
																hcs.ISIN  ,														
																CONVERT( NVARCHAR(30), scs.Meta_LoadDateTime, 126 )
															)
											END
									)				
								AS NCHAR(10) 
						) 															AS DimCustodianSecurityID							

					, hcs.ISIN  														
					, scs.Meta_LoadDateTime											AS	Meta_ISIN_LoadDateTime

					,CAST( rsm.Meta_LoadDateTime AS SMALLDATETIME)					AS Meta_Mapping_LoadDateTime
					
					,rsm.LeadSystemCode				
					,rsm.LeadSystemSecurityCode
					,rsm.PartnerSystemCode001
					,rsm.PartnerSystemSecurityCode001
						
					, LEFT( TRIM( rsm.Meta_RecordSource ), 20 )						AS Tran_Meta_RecordSource
						
	FROM			ref.RefSecurityIdentifierMappings	rsm
	
	-- For Type 2 Dimension PKs 
	--		Include all matching Security and Custodian Security dimensions keys that exist
	--		within load \ load end datetimes of each mapping record.
	--		These are used to map the Holdings from each operational system , i.e. Pacer + HSBC, 
	LEFT JOIN		dv.HubSecurities				hs
	ON				rsm.LeadSystemSecurityCode		=	hs.SecID
	AND				rsm.LeadSystemCode				=	N'PACER'
				
	LEFT JOIN		dv.SatSecurities				ss
	ON				hs.HKeySecurity					=	ss.HKeySecurity
	--AND				@AsOfDateTime					<=	ss.Meta_LoadEndDateTime
	AND				ss.Meta_LoadEndDateTime	=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.SatSecurities
						WHERE	HKeySecurity				=				ss.HKeySecurity				
						AND		@AsOfDateTime				BETWEEN			dv.SatSecurities.Meta_LoadDateTime	
															AND				dv.SatSecurities.Meta_LoadEndDateTime
					)	
	
	LEFT JOIN		dv.HubCustodianSecurities		hcs
	ON				rsm.PartnerSystemSecurityCode001	=	hcs.ISIN
	AND				rsm.PartnerSystemCode001			=	N'HSBCNET'


	LEFT JOIN		dv.SatCustodianSecurities		scs
	ON				hcs.HKeyCustodianSecurity		=	scs.HKeyCustodianSecurity
	--AND				@AsOfDateTime					<=	scs.Meta_LoadEndDateTime
	AND				scs.Meta_LoadEndDateTime		=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.SatCustodianSecurities
						WHERE	HKeyCustodianSecurity		=				scs.HKeyCustodianSecurity				
						AND		@AsOfDateTime				BETWEEN			dv.SatCustodianSecurities.Meta_LoadDateTime	
															AND				dv.SatCustodianSecurities.Meta_LoadEndDateTime
					)	
					

	WHERE 	@AsOfDateTime		BETWEEN		rsm.Meta_LoadDateTime	
								AND			rsm.Meta_LoadEndDateTime				
	;


