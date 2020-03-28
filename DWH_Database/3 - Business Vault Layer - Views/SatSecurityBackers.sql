CREATE VIEW [bv].[SatSecurityBackers]
	AS 


	SELECT		lsb.HKeySecurityBacker
				, lsb.BackerCode
				, lsb.SecID
				
				
	FROM		dv.LinkSecurityBackers	lsb

	INNER JOIN	dv.HubSecurities		hs
	ON			lsb.HKeySecurity		=	hs.HKeySecurity
	
	INNER JOIN	dv.SatSecurities		ss
	ON			hs.HKeySecurity			=	ss.HKeySecurity

	INNER JOIN	dv.HubBackers			hb
	ON			lsb.HKeyBacker			=	hb.HKeyBacker
