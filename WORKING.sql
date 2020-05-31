USE [DWH]
GO


select * 
from audit.Package
ORDER BY Start desc;

select * 
from audit.Task
ORDER BY Start desc;


SELECT DISTINCT ReportDate
from DV.LinkCustodianPositions
;

SELECT CAST( 0x1111111111111111111111111111111111111111 AS NCHAR(10) ) 	
--	Ghost record of unmatched hash key 


SELECT * FROM ref.RefSecurityIdentifierMappings rsm
WHERE	rsm.PartnerSystemSecurityCode001 = N'GB0004270301'
AND		rsm.PartnerSystemCode001			=	N'HSBCNET' 
;


SELECT		* 
FROM		dv.LinkCustodianPositions
;


		LEFT JOIN		ref.RefSecurityIdentifierMappings	rsm
		ON				rsm.PartnerSystemCode001			=	N'HSBCNET' 
		AND				rsm.PartnerSystemSecurityCode001	=	lcp.ISIN
		AND				lcp.Meta_LoadDateTime				BETWEEN rsm.Meta_LoadDateTime AND rsm.Meta_LoadEndDateTime


SELECT * FROM dv.LinkCustodianPositions	lcp

select * from bv.LinkPortfolioSecuritySummary

select * from dv.SatSecurities
where SecID IN
(
	'4852832',
	'B4WFW71',
	'311900104',
	'0286941',
	'0237400'
)
;


select * from dv.SatSecurities
where SecID IN
(
	'4852832',
	'B4WFW71',
	'311900104',
	'0286941',
	'0237400'
)
;





DECLARE @RC int
DECLARE @AsOfDateTime datetime2(7)
DECLARE @YearsHistory int

-- TODO: Set parameter values here.
SET		@AsOfDateTime = '2020-05-28 23:59:59'  --	28/05/2020 23:59:59
SET		@YearsHistory = 1

-- See logical + physical reads 
SET STATISTICS IO ON;

EXECUTE @RC = [InfoMartFinRep].[GetFactCustodianSecurityPosition] 
   @AsOfDateTime
GO



EXECUTE @RC = [InfoMartFinRep].[GetFactPrices] 
   @AsOfDateTime
  ,@YearsHistory
GO


EXECUTE @RC = [InfoMartFinRep].[GetFactFXRates] 
   @AsOfDateTime
  ,@YearsHistory
GO


EXECUTE @RC = [InfoMartFinRep].[GetFactTransaction] 
   @AsOfDateTime
GO





-- 1.	5,32 MINS







