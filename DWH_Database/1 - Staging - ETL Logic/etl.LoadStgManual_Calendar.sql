CREATE PROCEDURE [etl].[MANUAL_LoadStgCalendar]		(
														@LoadDateTime	DATETIME2
													)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2020-01-28
			Description:	Load manually managed Calendar master data to Staging Layer							
			Changes:								
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;


		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[MANUAL_Calendar] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[MANUAL_Calendar] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		
		FROM		[stg].[MANUAL_Calendar] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[MANUAL_Calendar] 
				(
					[In_DateKey]				,
					[In_CalendarDate]			,
					[In_Day] ,
					[In_Month] ,
					[In_Year] ,
					[In_Quarter] ,
					[In_DayOfWeek] ,
					[In_DayOccInMonth] ,
					[In_DayOfQuarter] ,
					[In_DayOfYear] ,
					[In_WeekNumISO] ,
					[In_MonthOfQuarter] ,
					[In_StartOfMonth] ,
					[In_EndOfMonth] ,
					[In_StartOfQuarter] ,
					[In_EndOfQuarter] ,
					[In_StartOfCalYear] ,
					[In_EndOfCalYear] ,
					[In_StartOfFinYear] ,
					[In_EndOfFinYear] ,
					[In_d] ,
					[In_dd] ,
					[In_ddd] ,
					[In_dddd] ,
					[In_m] ,
					[In_mm] ,
					[In_mmm] ,
					[In_mmmm] ,
					[In_q] ,
					[In_qqqq] ,
					[In_yy] ,
					[In_yyyy] ,
					[In_FY_m] ,
					[In_FY_mm]					,
					[In_FY_q]					,
					[In_FY_qqqq]				,
					[In_FY_yy]					,
					[In_FY_yyyy]				,
					[In_IsWeekday]				,
					[In_IsHolidayUK]			,
					[In_HolidayUK]				,

					-- META DATA
					[Meta_ETLProcessID]
					,[Meta_RecordSource]
					,[Meta_LoadDateTime]
					,[Meta_SourceSysExportDateTime]
					,[Meta_EffectFromDateTime]
					,[Meta_EffectToDateTime]
					,[Meta_ActiveRow]					
				 )

		SELECT 	

			-- INPUTS
				TRIM([Datekey])				
				,TRIM([CalendarDate])			
				,TRIM([Day])
				,TRIM([Month]) 
				,TRIM([Year])
				,TRIM([Quarter])
				,TRIM([DayOfWeek])
				,TRIM([DayOccInMonth])
				,TRIM([DayOfQuarter])
				,TRIM([DayOfYear])
				,TRIM([WeekNumISO])
				,TRIM([MonthOfQuarter])
				,TRIM([StartOfMonth])
				,TRIM([EndOfMonth])
				,TRIM([StartOfQuarter])
				,TRIM([EndOfQuarter])
				,TRIM([StartOfCalYear])
				,TRIM([EndOfCalYear])
				,TRIM([StartOfFinYear])
				,TRIM([EndOfFinYear])
				,TRIM([d])
				,TRIM([dd])
				,TRIM([ddd])
				,TRIM([dddd])
				,TRIM([m])
				,TRIM([mm])
				,TRIM([mmm])
				,TRIM([mmmm])
				,TRIM([q])
				,TRIM([qqqq])
				,TRIM([yy])
				,TRIM([yyyy])
				,TRIM([FY_m])
				,TRIM([FY_mm])
				,TRIM([FY_q])
				,TRIM([FY_qqqq])
				,TRIM([FY_yy])
				,TRIM([FY_yyyy])
				,TRIM([IsWeekday])
				,TRIM([IsHolidayUK])
				,TRIM([HolidayUK])
																	
				,[Meta_ETLProcessID]
				,N'MANUAL.CALEND' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]
		FROM	tmp.MANUAL_Calendar
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 

		-- UPDATE STAGING OUTPUTS				
		UPDATE		[stg].[MANUAL_Calendar] 
		SET			[Out_DateKey]				=	CAST( [In_DateKey] AS INT ),
					[Out_CalendarDate]			=	CAST( [In_CalendarDate] AS DATETIME2 ),
					[Out_Day]					=	CAST( [In_Day] AS INT ),
					[Out_Month]					=	CAST( [In_Month] AS INT ),
					[Out_Year]					=	CAST( [In_Year] AS INT ),
					[Out_Quarter]				=	CAST( [In_Quarter] AS INT ),
					[Out_DayOfWeek]				=	CAST( [In_DayOfWeek] AS INT ),
					[Out_DayOccInMonth]			=	CAST( [In_DayOccInMonth] AS INT ),
					[Out_DayOfQuarter]			=	CAST( [In_DayOfQuarter] AS INT ),
					[Out_DayOfYear]				=	CAST( [In_DayOfYear] AS INT ),
					[Out_WeekNumISO]			=	CAST( [In_WeekNumISO] AS INT ),
					[Out_MonthOfQuarter]		=	CAST( [In_MonthOfQuarter] AS INT ),
					[Out_StartOfMonth]			=	CAST( [In_StartOfMonth] AS DATETIME2 ),
					[Out_EndOfMonth]			=	CAST( [In_EndOfMonth] AS DATETIME2 ),
					[Out_StartOfQuarter]		=	CAST( [In_StartOfQuarter] AS DATETIME2 ),
					[Out_EndOfQuarter]			=	CAST( [In_EndOfMonth] AS DATETIME2 ),
					[Out_StartOfCalYear]		=	CAST( [In_StartOfCalYear] AS DATETIME2 ),
					[Out_EndOfCalYear]			=	CAST( [In_EndOfCalYear] AS DATETIME2 ),
					[Out_StartOfFinYear]		=	CAST( [In_StartOfFinYear] AS DATETIME2 ),
					[Out_EndOfFinYear]			=	CAST( [In_EndOfFinYear] AS DATETIME2 ),
					[Out_d]						=	CAST( [In_d] AS NVARCHAR(2) ),
					[Out_dd]					=	CAST( [In_dd] AS NCHAR(2) ),
					[Out_ddd]					=	CAST( [In_ddd] AS NCHAR(3) ),
					[Out_dddd]					=	CAST( [In_dddd] AS NVARCHAR(9) ),
					[Out_m]						=	CAST( [In_m] AS NVARCHAR(2) ),
					[Out_mm]					=	CAST( [In_mm] AS NCHAR(2) ),
					[Out_mmm]					=	CAST( [In_mmm] AS NCHAR(3) ),
					[Out_mmmm]					=	CAST( [In_mmmm] AS NVARCHAR(9) ),
					[Out_q]						=	CAST( [In_q] AS NCHAR(2) ),
					[Out_qqqq]					=	CAST( [In_qqqq] AS NVARCHAR(6) ),
					[Out_yy]					=	CAST( [In_yy] AS NCHAR(2) ),
					[Out_yyyy]					=	CAST( [In_yyyy] AS NCHAR(4) ),
					[Out_FY_m]					=	CAST( [In_FY_m] AS NVARCHAR(2) ),
					[Out_FY_mm]					=	CAST( [In_FY_mm] AS NCHAR(2) ),
					[Out_FY_q]					=	CAST( [In_FY_q] AS NCHAR(1) ),
					[Out_FY_qqqq]				=	CAST( [In_FY_qqqq] AS NCHAR(6) ),
					[Out_FY_yy]					=	CAST( [In_FY_yy] AS NCHAR(2) ),
					[Out_FY_yyyy]				=	CAST( [In_FY_yyyy] AS NCHAR(4) ),
					[Out_IsWeekDay]				=	CAST( [In_IsWeekDay] AS BIT ),
					[Out_IsHolidayUK]			=	CAST( [In_IsHolidayUK] AS BIT ),
					[Out_HolidayUK]				=	CAST( [In_HolidayUK] AS NVARCHAR(100) )

		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
		
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.MANUAL_LoadStgCalendar : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


