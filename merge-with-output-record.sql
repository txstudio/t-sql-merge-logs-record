/*
	進行 dbo.StockList 與 dbo.StockList_Target 資料表 merge 指令碼
*/
BEGIN TRANSACTION

SET NOCOUNT ON

SET IDENTITY_INSERT [dbo].[StockList_Target] ON

DECLARE @LogTable TABLE
(
	[No]					INT IDENTITY(1,1),
	[Action]				CHAR(6),

	[SourceNo]				INT,	
	[SourceSchema]			CHAR(4),
	[SourceISINCode]		CHAR(12),
	[SourcePublishDate]		DATE,
	[SourceName]			NVARCHAR(10),
	[SourceCategory]		NVARCHAR(10),
	[SourceIndustry]		NVARCHAR(20),
	[SourceCFICode]			VARCHAR(6),

	[TargetNo]				INT,	
	[TargetSchema]			CHAR(4),
	[TargetISINCode]		CHAR(12),
	[TargetPublishDate]		DATE,
	[TargetName]			NVARCHAR(10),
	[TargetCategory]		NVARCHAR(10),
	[TargetIndustry]		NVARCHAR(20),
	[TargetCFICode]			VARCHAR(6),

	[whenCreate]			DATETIME DEFAULT (GETDATE()),
	
	PRIMARY KEY ([No])
)

INSERT INTO @LogTable (
	[Action],
	[SourceNo],	
	[SourceSchema],
	[SourceISINCode],
	[SourcePublishDate],
	[SourceName],
	[SourceCategory],
	[SourceIndustry],
	[SourceCFICode],
	[TargetNo],	
	[TargetSchema],
	[TargetISINCode],
	[TargetPublishDate],
	[TargetName],
	[TargetCategory],
	[TargetIndustry],
	[TargetCFICode]	
)
SELECT [Action],
	[SourceNo],	
	[SourceSchema],
	[SourceISINCode],
	[SourcePublishDate],
	[SourceName],
	[SourceCategory],
	[SourceIndustry],
	[SourceCFICode],
	[TargetNo],	
	[TargetSchema],
	[TargetISINCode],
	[TargetPublishDate],
	[TargetName],
	[TargetCategory],
	[TargetIndustry],
	[TargetCFICode]
FROM
(
	MERGE [dbo].[StockList_Target] AS TARGET
	USING [dbo].[StockList] AS SOURCE
		ON (TARGET.[Schema] = SOURCE.[Schema])
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (
			[No]
			,[Schema]
			,[ISINCode]
			,[PublishDate]
			,[Name]
			,[Category]
			,[Industry]
			,[CFICode]
		) VALUES (
			SOURCE.[No]
			,SOURCE.[Schema]
			,SOURCE.[ISINCode]
			,SOURCE.[PublishDate]
			,SOURCE.[Name]
			,SOURCE.[Category]
			,SOURCE.[Industry]
			,SOURCE.[CFICode]
		)
	WHEN MATCHED AND TARGET.[ISINCode] <> SOURCE.[ISINCode]
			OR TARGET.[PublishDate] <> SOURCE.[PublishDate]
			OR TARGET.[Name] <> SOURCE.[Name]
			OR TARGET.[Category] <> SOURCE.[Category]
			OR TARGET.[Industry] <> SOURCE.[Industry]
			OR TARGET.[CFICode] <> SOURCE.[CFICode]
		THEN
			UPDATE SET TARGET.[ISINCode] = SOURCE.[ISINCode]
				,TARGET.[PublishDate] = SOURCE.[PublishDate]
				,TARGET.[Name] = SOURCE.[Name]
				,TARGET.[Category] = SOURCE.[Category]
				,TARGET.[Industry] = SOURCE.[Industry]
				,TARGET.[CFICode] = SOURCE.[CFICode]
	WHEN NOT MATCHED BY SOURCE
		THEN DELETE
	OUTPUT $action [Action]
		, inserted.[No] [SourceNo]
		, inserted.[Schema] [SourceSchema]
		, inserted.[ISINCode] [SourceISINCode]
		, inserted.[PublishDate] [SourcePublishDate]
		, inserted.[Name] [SourceName]
		, inserted.[Category] [SourceCategory]
		, inserted.[Industry] [SourceIndustry]
		, inserted.[CFICode] [SourceCFICode]
		, deleted.[No] [TargetNo]
		, deleted.[Schema] [TargetSchema]
		, deleted.[ISINCode] [TargetISINCode]
		, deleted.[PublishDate] [TargetPublishDate]
		, deleted.[Name] [TargetName]
		, deleted.[Category] [TargetCategory]
		, deleted.[Industry] [TargetIndustry]
		, deleted.[CFICode] [TargetCFICode]
) AS Changes (
	[Action],
	[SourceNo],	
	[SourceSchema],
	[SourceISINCode],
	[SourcePublishDate],
	[SourceName],
	[SourceCategory],
	[SourceIndustry],
	[SourceCFICode],
	[TargetNo],	
	[TargetSchema],
	[TargetISINCode],
	[TargetPublishDate],
	[TargetName],
	[TargetCategory],
	[TargetIndustry],
	[TargetCFICode]	
);

SET IDENTITY_INSERT [dbo].[StockList_Target] OFF

DECLARE @InsertCount SMALLINT
DECLARE @UpdateCount SMALLINT
DECLARE @DeleteCount SMALLINT
DECLARE @Logs XML
DECLARE @EventName NVARCHAR(50)

SET @InsertCount = (SELECT COUNT([No]) FROM @LogTable WHERE [Action] = 'INSERT')
SET @UpdateCount = (SELECT COUNT([No]) FROM @LogTable WHERE [Action] = 'UPDATE')
SET @DeleteCount = (SELECT COUNT([No]) FROM @LogTable WHERE [Action] = 'DELETE')
SET @Logs = (SELECT * FROM @LogTable [Log] FOR XML AUTO, ROOT('Logs'))
SET @EventName = 'dbo.StockList_Target'

INSERT INTO [dbo].[MergeRecords] (
	[EventName]
	,[InsertCount]
	,[UpdateCount]
	,[DeleteCount]
	,[Logs]
) VALUES (
	@EventName
	,@InsertCount
	,@UpdateCount
	,@DeleteCount
	,@Logs
)

SELECT * FROM [dbo].[MergeRecords] a with (nolock)

ROLLBACK TRANSACTION