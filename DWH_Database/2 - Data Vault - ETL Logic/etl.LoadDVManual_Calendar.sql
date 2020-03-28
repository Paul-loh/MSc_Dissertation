CREATE PROCEDURE [etl].[MANUAL_LoadDVCalendar]	(
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS

--	Load reference table
	 
	INSERT INTO		[ref].[RefCalendar]
			(				
				[DateKey]						--	PK
				,[Meta_LoadDateTime]			--	PK / UIX	
				,[Meta_LoadEndDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]

				,[CalendarDate]					--	UIX	
				,[Day]
				,[Month]
				,[Year]
				,[Quarter]
				,[DayOfWeek]
				,[DayOccInMonth]
				,[DayOfQuarter]
				,[DayOfYear]
				,[WeekNumISO]
				,[MonthOfQuarter]
				,[StartOfMonth]
				,[EndOfMonth]
				,[StartOfQuarter]
				,[EndOfQuarter]
				,[StartOfCalYear]
				,[EndOfCalYear]
				,[StartOfFinYear]
				,[EndOfFinYear]
				,[d]
				,[dd]
				,[ddd]
				,[dddd]
				,[m]
				,[mm]
				,[mmm]
				,[mmmm]
				,[q]
				,[qqqq]
				,[yy]
				,[yyyy]
				,[FY_m]
				,[FY_mm]
				,[FY_q]
				,[FY_qqqq]
				,[FY_yy]
				,[FY_yyyy]
				,[IsWeekDay]
				,[IsHolidayUK]
				,[HolidayUK]
			)

	SELECT 	
				[Out_DateKey]

				,[Meta_LoadDateTime]
				,CAST( N'9999-12-31' AS DATETIME2)	
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
			
				,[Out_CalendarDate]
				,[Out_Day]
				,[Out_Month]
				,[Out_Year]
				,[Out_Quarter]
				,[Out_DayOfWeek]
				,[Out_DayOccInMonth]
				,[Out_DayOfQuarter]
				,[Out_DayOfYear]
				,[Out_WeekNumISO]
				,[Out_MonthOfQuarter]
				,[Out_StartOfMonth]
				,[Out_EndOfMonth]
				,[Out_StartOfQuarter]
				,[Out_EndOfQuarter]
				,[Out_StartOfCalYear]
				,[Out_EndOfCalYear]
				,[Out_StartOfFinYear]
				,[Out_EndOfFinYear]
				,[Out_d]
				,[Out_dd]
				,[Out_ddd]
				,[Out_dddd]
				,[Out_m]
				,[Out_mm]
				,[Out_mmm]
				,[Out_mmmm]
				,[Out_q]
				,[Out_qqqq]
				,[Out_yy]
				,[Out_yyyy]
				,[Out_FY_m]
				,[Out_FY_mm]
				,[Out_FY_q]
				,[Out_FY_qqqq]
				,[Out_FY_yy]
				,[Out_FY_yyyy]
				,[Out_IsWeekDay]
				,[Out_IsHolidayUK]
				,[Out_HolidayUK]
		
	FROM		stg.MANUAL_Calendar		t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 
	;
	
-- End Dating of Previous Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[ref].[refCalendar] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	[ref].[refCalendar]  z
													WHERE	z.Meta_LoadDateTime >	s.Meta_LoadDateTime
													-- AND		z.DateKey			=	s.DateKey													
												)
	FROM	[ref].[refCalendar] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	--AND	EXISTS	(
	--				SELECT  * 
	--				FROM	stg.MANUAL_Calendar t
	--				WHERE	Meta_LoadDateTime			=	@LoadDateTime		
	--				AND		t.Out_DateKey				=	s.DateKey
	--			)
	;

GO


