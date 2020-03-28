CREATE VIEW [InfoMartFinRep].[DimSecurityMapping]
	AS 

	--	Author:				Paul Loh	
	--	Creation Date:		20191025
	--	Description:		Mapping dimension table in Finrep (Financial Reporting) Information Mart.
	--						
	--						Conforming securities between Lead System (Pacer) and Partner Custodian System (HSBC.Net) 
	--
	--						Grain: Security ID | Load DateTime
			
		SELECT			
					--HASHBYTES	(	N'SHA1',
					--				CONCAT_WS	(	
					--								N'|',
					--								rsm.LeadSystemCode, 
					--								rsm.LeadSystemSecurityCode, 
					--								rsm.PartnerSystemCode001, 
					--								rsm.PartnerSystemSecurityCode001, 
					--								CONVERT( NVARCHAR(30), rsm.Meta_LoadDateTime, 126 )
					--							)
					--			)													AS SecurityMappingKey						

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
							
					, CAST( 
							HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														hs.SecID,														
														CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
													)
									) AS NCHAR(10) 									
							)															AS DimSecurityID				
							
					, CAST(
							HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														hcs.ISIN  ,														
														CONVERT( NVARCHAR(30), scs.Meta_LoadDateTime, 126 )
													)
									)				
							AS NCHAR(10) ) 												AS DimCustodianSecurityID							

						,CAST( rsm.Meta_LoadDateTime AS SMALLDATETIME)					AS Meta_Mapping_LoadDateTime
						-- ,rsm.Meta_LoadEndDateTime

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


		LEFT JOIN		dv.HubCustodianSecurities		hcs
		ON				rsm.PartnerSystemSecurityCode001	=	hcs.ISIN
		AND				rsm.PartnerSystemCode001			=	N'HSBCNET'

		LEFT JOIN		dv.SatCustodianSecurities		scs
		ON				hcs.HKeyCustodianSecurity		=	scs.HKeyCustodianSecurity

		;

