

-- All Hash functions except SHA2_256 + SHA2_512 deprecated
	
USE CAL_JBETL;
GO

-- Transactions 
SELECT HASHBYTES('SHA2_256', TRANNUM + ENTRDATE + ENTRTIME) AS Hashkey, * FROM [tmp].[Transactions]; 


-- Valuations 
SELECT * FROM [tmp].[Valuations]; 

SELECT HASHBYTES('SHA2_256', PORTCD + SECID + VALDATE + BOKFXC) AS Hashkey, * FROM [tmp].[Valuations]; 









