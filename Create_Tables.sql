
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[All_DB_Objects](
	[DatabaseId] [smallint] NOT NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[SchemaName] [nvarchar](128) NULL,
	[ObjectId] [int] NOT NULL,
	[ObjectName] [sysname] NOT NULL,
	[ObjectType] [char](2) NOT NULL,
	[ObjectTypeDesc] [nvarchar](60) NULL,
	[CreateDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[On_Object] [varchar](128) NULL,
	[Fields] [xml] NULL,
	[SchemaBound] [bit] NULL,
 CONSTRAINT [PK_All_DB_Objects] PRIMARY KEY NONCLUSTERED 
(
	[DatabaseId] ASC,
	[ObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE CLUSTERED INDEX [IX_All_DB_Objects_DatabaseName_ObjectName] ON [dbo].[All_DB_Objects]
(
	[DatabaseName] ASC,
	[ObjectName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[All_Object_Columns](
	[DatabaseId] [smallint] NOT NULL,
	[DatabaseName] [nvarchar](128) NOT NULL,
	[object_id] [int] NOT NULL,
	[column_id] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[system_type_id] [tinyint] NOT NULL,
	[max_length] [smallint] NOT NULL,
	[precision] [tinyint] NOT NULL,
	[scale] [tinyint] NOT NULL,
	[is_nullable] [bit] NOT NULL,
	[is_identity] [bit] NOT NULL,
	[is_computed] [bit] NOT NULL,
 CONSTRAINT [PK_All_Object_Columns] PRIMARY KEY CLUSTERED 
(
	[DatabaseId] ASC,
	[object_id] ASC,
	[column_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_All_Object_Columns_DatabaseName_Object_id_Name] ON [dbo].[All_Object_Columns]
(
	[DatabaseName] ASC,
	[object_id] ASC,
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO


