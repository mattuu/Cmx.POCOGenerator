SELECT 
	dbo.ufn_GetEntity([name]) AS Entity,
	dbo.ufn_GetEFMapping([name]) AS Mapping
FROM sys.tables 
WHERE schema_id = SCHEMA_ID('dbo')
AND [name] <> '__RefactorLog'
