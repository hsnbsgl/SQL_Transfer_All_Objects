SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[spTransfer_All_DB_Objects]
	@argProcessFirstResultSet BIT=1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @lcDB_Name VARCHAR(200), @lcSQL NVARCHAR(MAX)

	TRUNCATE TABLE dbo.All_DB_Objects
	TRUNCATE TABLE dbo.All_Object_Columns

	DECLARE curDatabases CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT name 
	FROM sys.databases
	WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
	ORDER BY name ASC

	OPEN curDatabases
	FETCH NEXT FROM curDatabases INTO @lcDB_Name
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		--DB Objects
		SET @lcSQL = 'USE [' + @lcDB_Name + ']; ' + 
					'SELECT DB_ID() AS DatabaseId, DB_NAME() AS DatabaseName, SCHEMA_NAME(O.schema_id) AS SchemaName, O.object_id AS ObjectId, O.name AS ObjectName, 
						O.[type] AS ObjectType, O.type_desc AS ObjectTypeDesc, O.create_date, O.modify_date, PO.name, NULL, OBJECTPROPERTY(O.object_id, ''IsSchemaBound'')
					FROM sys.objects O WITH (NOLOCK)
						LEFT JOIN sys.objects PO WITH (NOLOCK) ON O.parent_object_id = PO.object_id
					WHERE O.is_ms_shipped=0
					ORDER BY O.name'
		
		INSERT INTO dbo.All_DB_Objects
		EXEC (@lcSQL)

		--Object Columns
		SET @lcSQL = 'USE [' + @lcDB_Name + ']; ' + 
					'SELECT DB_ID() AS DatabaseId, DB_NAME() AS DatabaseName, C.object_id, C.column_id, C.name, C.system_type_id, C.max_length, C.precision, C.scale, C.is_nullable, C.is_identity, C.is_computed 
					FROM sys.columns C
						JOIN sys.objects O ON C.object_id = O.object_id
					WHERE O.is_ms_shipped=0
					ORDER BY C.object_id, C.column_id'
		INSERT INTO dbo.All_Object_Columns
		EXEC (@lcSQL)

		
		FETCH NEXT FROM curDatabases INTO @lcDB_Name
	END
	CLOSE curDatabases
	DEALLOCATE curDatabases

	UPDATE O SET Fields = CAST('<Fields>' + (SELECT C.name
											FROM dbo.All_Object_Columns C WITH (NOLOCK) 
											WHERE C.DatabaseId = O.DatabaseId AND C.object_id = O.ObjectId
											ORDER BY C.name
											FOR XML PATH('FieldInfo')) + '</Fields>' AS XML)
	FROM dbo.All_DB_Objects O ;
	
	
	IF ISNULL(@argProcessFirstResultSet,1) =0 
		RETURN
			
	DROP TABLE IF EXISTS #tmpfirst_result_set;
 
	CREATE TABLE #tmpfirst_result_set(
	[is_hidden] [bit] NULL,
	[column_ordinal] [int] NULL,
	[name] [nvarchar](128) NULL,
	[is_nullable] [bit] NULL,
	[system_type_id] [int] NULL,
	[system_type_name] [nvarchar](128) NULL,
	[max_length] [smallint] NULL,
	[precision] [tinyint] NULL,
	[scale] [tinyint] NULL,
	[collation_name] [nvarchar](128) NULL,
	[user_type_id] [int] NULL,
	[user_type_database] [nvarchar](128) NULL,
	[user_type_schema] [nvarchar](128) NULL,
	[user_type_name] [nvarchar](128) NULL,
	[assembly_qualified_type_name] [nvarchar](4000) NULL,
	[xml_collection_id] [int] NULL,
	[xml_collection_database] [nvarchar](128) NULL,
	[xml_collection_schema] [nvarchar](128) NULL,
	[xml_collection_name] [nvarchar](128) NULL,
	[is_xml_document] [bit] NULL,
	[is_case_sensitive] [bit] NULL,
	[is_fixed_length_clr_type] [bit] NULL,
	[source_server] [nvarchar](128) NULL,
	[source_database] [nvarchar](128) NULL,
	[source_schema] [nvarchar](128) NULL,
	[source_table] [nvarchar](128) NULL,
	[source_column] [nvarchar](128) NULL,
	[is_identity_column] [bit] NULL,
	[is_part_of_unique_key] [bit] NULL,
	[is_updateable] [bit] NULL,
	[is_computed_column] [bit] NULL,
	[is_sparse_column_set] [bit] NULL,
	[ordinal_in_order_by_list] [smallint] NULL,
	[order_by_list_length] [smallint] NULL,
	[order_by_is_descending] [bit] NULL,
	[tds_type_id] [int] NULL,
	[tds_length] [int] NULL,
	[tds_collation_id] [int] NULL,
	[tds_collation_sort_id] [tinyint] NULL
	)  

	DECLARE  @lcObjectParametre NVARCHAR(MAX)
		
	DECLARE @lcSPName NVARCHAR(MAX),@lcSchemaName VARCHAR(50),@lcDBId SMALLINT,@lcObject_id INT

	DECLARE curObjects CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT DatabaseId,DatabaseName,ObjectId,SchemaName,ObjectName FROM All_DB_Objects WHERE ObjectType='P' 
	OPEN curObjects
	FETCH NEXT FROM curObjects INTO @lcDBId,@lcDB_Name,@lcObject_id,@lcSchemaName,@lcSPName
	WHILE @@FETCH_STATUS=0
	BEGIN
	
	BEGIN TRY
		
		TRUNCATE TABLE #tmpfirst_result_set;

		SET @lcObjectParametre = @lcSchemaName + N'.'+ @lcSPName
		
		PRINT @lcObjectParametre

		SET @lcSQL ='USE ' + QUOTENAME(@lcDB_Name)+';'+
						'INSERT INTO #tmpfirst_result_set
						EXEC sp_describe_first_result_set  @lcObjectParametre, null, 1 ;'
		
		EXEC sp_executesql @lcSQL, N'@lcObjectParametre NVARCHAR(MAX)', @lcObjectParametre
		
		INSERT INTO All_Object_Columns	
		SELECT @lcDBId,@lcDB_Name,@lcObject_id,column_ordinal, name,system_type_id,max_length,precision,scale,is_nullable,is_identity_column,is_computed_column
		FROM #tmpfirst_result_set WHERE is_hidden=0 AND name IS NOT null

	END TRY
	BEGIN CATCH
		
	END CATCH
	
	FETCH NEXT FROM curObjects INTO @lcDBId,@lcDB_Name,@lcObject_id,@lcSchemaName,@lcSPName
	END
	CLOSE curObjects
	DEALLOCATE curObjects
	
END


GO

