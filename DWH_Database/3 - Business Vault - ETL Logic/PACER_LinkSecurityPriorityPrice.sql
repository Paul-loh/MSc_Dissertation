CREATE VIEW [bv].[LinkSecurityPriorityPrice]
AS

/* 
--	Author:					Paul Loh
--	Business Rule Ref:		?????
--	Description:			Select the highest priority price for each security on each day 
			
		Grain:				Security \ Day 
*/

		-- N'BR001|v.Alpha|Pacer Portfolio\Security Lvl Financial Summary';


	SELECT		*
	FROM		ref.RefPriceSources
	
	
	--SELECT		*
	--FROM		ref.RefCalendar
	--;



	

