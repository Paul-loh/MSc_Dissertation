CREATE VIEW [InfoMartFinRep].[DimPortfolios]
AS 

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Portfolios (Subordinates) Dimension Table in Finrep (Financial Reporting) Information Mart.  
	--
	--						Grain: 
	--								Portfolio | Load DateTime
		
	SELECT		
						CAST(
								HASHBYTES	(	N'SHA1',
												CONCAT_WS	(	
																N'|',
																hp.PortfCode,			
																CASE WHEN sp.Meta_LoadDateTime IS NULL 
																THEN 
																	N''
																ELSE																
																	CONVERT( NVARCHAR(30), sp.Meta_LoadDateTime, 126 )
																END
															)
											)	AS NCHAR(10)  
							)												AS DimPortfolioID  
						
						, CAST( sp.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Portf_LoadDateTime
						,hp.PortfCode

						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE 
								sp.PortfName
							END											AS PortfName
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE 
								sp.PortfStatus
							END											AS PortfStatus
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE 
								sp.PortfType
							END											AS PortfType
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE 
								sp.ResidenceCtry
							END											AS ResidenceCtry
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE 
								sp.ResidenceRegion
							END											AS ResidenceRegion
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.LotIndicator
							END											AS LotIndicator
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.InitDate
							END											AS InitDate
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.AccountExec
							END											AS AccountExec
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.AccountNumber
							END											AS AccountNumber
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.Address1
							END											AS Address1
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.Address2
							END											AS Address2
						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE	
								sp.BaseCcy
							END											AS BaseCcy

						,sp.BookCost
						,sp.CumulGain
						,sp.CustAcctNumber
						,sp.CustodianCode
						,sp.MarketValue
						,sp.ObjectiveCode

						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE								
								sp.[Permissions]
							END											AS [Permissions]

						,sp.PersysFlag
						,sp.SettlementAcct

						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE			
								sp.TaxType
							END											AS TaxType

						,	CASE WHEN sp.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE			
								sp.ValuationDate						
							END											AS ValuationDate						

						-- Master Pool Portfolio 
						,pmp.MasterPortfolioCode		AS PoolMasterPortfolioCode	
						,pmp.MasterPortfolioName		AS PoolMasterPortfolioName 
						
						-- Master Entity Portfolio 
						,pme.MasterPortfolioCode		AS EntityMasterPortfolioCode	
						,pme.MasterPortfolioName		AS EntityMasterPortfolioName 
						
		FROM			dv.HubPortfolios	hp

		LEFT JOIN		dv.SatPortfolios	sp
		ON				hp.HKeyPortfolio				=		sp.HKeyPortfolio

				
		--	Add Master Pool portfolio code and name 
		LEFT JOIN 
		(
				SELECT			spm.MasterType
								, lpms.HKeyLinkPortfolioMasterSubsidiary
								, lpms.HKeyMasterPortfolioCode		
								, lpms.HKeySubsidiaryPortfolioCode							
								, lpms.MasterPortfolioCode			
								, lpms.SubsidiaryPortfolioCode	
								, sp.PortfName						AS MasterPortfolioName
								, lpms.Meta_LoadDateTime			AS MasterSubLink_Meta_LoadDateTime
								, spm.Meta_LoadDateTime				AS MasterType_Meta_LoadDateTime
								, spm.Meta_LoadEndDateTime			AS MasterType_Meta_LoadEndDateTime
							
				FROM			dv.LinkPortfolioMasterSubsidiary	lpms
		
				INNER JOIN		dv.SatPortfolioMasterType			spm
				ON				lpms.HKeyMasterPortfolioCode		=		spm.HKeyPortfolio
				AND				spm.MasterType						IN		(N'POOL')

				INNER JOIN		dv.SatPortfolios					sp
				ON				lpms.HKeyMasterPortfolioCode		=		sp.HKeyPortfolio

				AND				sp.Meta_LoadDateTime				BETWEEN		spm.Meta_LoadDateTime
																	AND			spm.Meta_LoadEndDateTime
				
		) pmp

		ON		hp.HKeyPortfolio		=			pmp.HKeySubsidiaryPortfolioCode
		AND		sp.Meta_LoadDateTime	BETWEEN		pmp.MasterType_Meta_LoadDateTime
										AND			pmp.MasterType_Meta_LoadEndDateTime


		--	Add Master Entity portfolio code and name 
		LEFT JOIN 
		(
				SELECT			spm.MasterType
								, lpms.HKeyLinkPortfolioMasterSubsidiary
								, lpms.HKeyMasterPortfolioCode		
								, lpms.HKeySubsidiaryPortfolioCode							
								, lpms.MasterPortfolioCode			
								, lpms.SubsidiaryPortfolioCode	
								, sp.PortfName						AS MasterPortfolioName
								, lpms.Meta_LoadDateTime			AS MasterSubLink_Meta_LoadDateTime
								, spm.Meta_LoadDateTime				AS MasterType_Meta_LoadDateTime
								, spm.Meta_LoadEndDateTime			AS MasterType_Meta_LoadEndDateTime
															
				FROM			dv.LinkPortfolioMasterSubsidiary	lpms
		
				INNER JOIN		dv.SatPortfolioMasterType			spm
				ON				lpms.HKeyMasterPortfolioCode		=		spm.HKeyPortfolio
				AND				spm.MasterType						IN		(N'ENTITY')
				
				INNER JOIN		dv.SatPortfolios					sp
				ON				lpms.HKeyMasterPortfolioCode		=		sp.HKeyPortfolio

				AND				sp.Meta_LoadDateTime				BETWEEN		spm.Meta_LoadDateTime
																	AND			spm.Meta_LoadEndDateTime
				
		) pme

		ON		hp.HKeyPortfolio		=		pme.HKeySubsidiaryPortfolioCode
		AND		sp.Meta_LoadDateTime	BETWEEN		pme.MasterType_Meta_LoadDateTime
										AND			pme.MasterType_Meta_LoadEndDateTime
		;
			