CREATE PROCEDURE [InfoMartFinRep].[GetDimBrokers]	@AsOfDateTime	DATETIME2 =	NULL														
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20200226
	--	Description:		Brokers Dimension table in Finrep (Financial Reporting) Information Mart.	
	--
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where parameter is <= Meta_LoadEndDateTime													
	--						Grain: 
	--								Broker | Load DateTime

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;
					
	SELECT			
					CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															h.BrokerCode,
															CASE	WHEN s.Meta_LoadDateTime IS NULL 
																	THEN 
																		N''
																	ELSE	
																		CONVERT( NVARCHAR(30), s.Meta_LoadDateTime, 126 )
																	END
														)
										)	AS NCHAR(10) 
						)												AS DimBrokerID						
					, h.BrokerCode
					
					, CASE WHEN s.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE
								s.BrokerName
							END											AS BrokerName
					
					, TRIM( s.Meta_RecordSource )						AS Meta_Broker_RecordSource
					, CAST( s.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Broker_LoadDateTime

	FROM			dv.HubBrokers				h				
	LEFT JOIN		dv.SatBrokers				s
	ON				h.HKeyBroker				=		s.HKeyBroker
	AND				s.Meta_LoadEndDateTime	=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.[SatBrokers]
						WHERE	HKeyBroker					=				s.HKeyBroker				
						AND		@AsOfDateTime				BETWEEN			Meta_LoadDateTime	
															AND				Meta_LoadEndDateTime
					)
	;




