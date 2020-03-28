CREATE PROCEDURE [etl].[INITIAL_LOAD_Clear_All_DWH_Tables]	
WITH EXECUTE AS OWNER 
AS

--	Author:				Paul Loh	
--	Creation Date:		20200203
--	Description:		DWH Initial Load 
--						
--						Clear down all DWH tables before the initial load starts.


	DECLARE @SQL				NVARCHAR(4000), 
			@SCH_OBJ_NAME		NVARCHAR(400),
			@TBL_OBJ_ID			INT,
			@TBL_OBJ_NAME		NVARCHAR(400),		
			@MSG				NVARCHAR(400)
			
	PRINT N'--------		CLEAR DOWN ALL DWH TABLES	--------';  

	DECLARE DWH_table_cursor CURSOR FOR 
	SELECT		t.object_id AS Table_ID, s.name AS Schema_Name, t.name AS Table_Name
	FROM		sys.tables t
	INNER JOIN	sys.schemas s
	ON			t.schema_id		=	s.schema_id
	WHERE		t.type = N'U'
	AND			EXISTS 
				(		
						SELECT schema_id
						FROM	sys.schemas s
						WHERE	s.NAME IN (N'InfoMartFinRep', N'etl', N'dv', N'bv', N'stg', N'tmp', N'ref') 
						AND		s.schema_id		=		t.schema_id 
				)
	;
	
	OPEN DWH_table_cursor  
	  
	FETCH NEXT FROM DWH_table_cursor   
	INTO @TBL_OBJ_ID, @SCH_OBJ_NAME, @TBL_OBJ_NAME		 

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		PRINT N' '  
		SELECT	@MSG = N'----- Clearing table: ' + @SCH_OBJ_NAME + N'.' + @TBL_OBJ_NAME;
		PRINT @MSG  
		
		--	Define dynamic SQL 		
		SET @SQL	=	N'TRUNCATE TABLE ' + @SCH_OBJ_NAME + N'.' + @TBL_OBJ_NAME
		
		PRINT @SQL	
		
		EXEC sp_executesql @SQL

		PRINT N' '  

			-- Get the next vendor.  
		FETCH NEXT FROM DWH_table_cursor   
		INTO  @TBL_OBJ_ID, @SCH_OBJ_NAME, @TBL_OBJ_NAME	  		
	END
	CLOSE DWH_table_cursor;  
	DEALLOCATE DWH_table_cursor

;  
	
