
USE DWH;
GO

SELECT		
			pr.ETLProcessID, 
			pr.ETLProcessName, 
			pr.[Start], 
			pr.[End],
			CASE	WHEN 
						SUM( CASE WHEN ISNULL( pa.[Error Message], N'' ) = N'' THEN 0 ELSE 1 END ) > 0 
						OR pr.[End] IS NULL 
					THEN 1 
					ELSE 0 
					END 			AS Error

FROM		[audit].[Process]		pr

LEFT JOIN	[audit].[Package]		pa
ON			pr.ETLProcessID		=	pa.ETLProcessID

GROUP BY	pr.ETLProcessID, 
			pr.ETLProcessName,
			pr.[Start], 
			pr.[End]

ORDER BY	pr.ETLProcessID DESC
;



SELECT * FROM [audit].[Process] ORDER BY [ETLProcessID] DESC;

SELECT * FROM [audit].[Package] ORDER BY [ETLProcessID] DESC, [ETLPackageID] DESC;

SELECT * FROM [audit].[Process] ORDER BY [ETLProcessID] DESC;

SELECT * FROM [audit].[Package] ORDER BY [ETLProcessID] DESC, [ETLPackageID] DESC;

SELECT * FROM [audit].[Task] ORDER BY [ETLTaskID] DESC, [ETLPackageID] ASC;



SELECT CONVERT(date, GETDATE() , 112)

SELECT DATEADD( GETDATE() 



SELECT		
			pr.ETLProcessID, pr.ETLProcessName, pr.Start, pr.End , COUNT( CASE WHEN ISNULL(pa.[Error Message] ) AS 

FROM		[audit].[Process]		pr

LEFT JOIN	[audit].[Package]		pa
ON			pr.ETLProcessID		=	pa.ETLProcessID









-- View called via DirectQuery to monitor near time status of DW jobs 

SELECT		* 
FROM		[audit].[Process]		pr

LEFT JOIN	[audit].[Package]		pa
ON			pr.ETLProcessID		=	pa.ETLProcessID

LEFT JOIN	[audit].[Task]			ta
ON			ta.ETLPackageID		=	pa.ETLPackageID

ORDER BY	pr.[ETLProcessID]	DESC
			,pa.[ETLPackageID]	ASC 
			,ta.[ETLTaskID]		ASC
			;





SELECT * FROM [audit].[Package] ORDER BY [ETLProcessID] DESC, [ETLPackageID] DESC;
SELECT * FROM [audit].[Task] ORDER BY [ETLTaskID] DESC, [ETLPackageID] ASC;



















