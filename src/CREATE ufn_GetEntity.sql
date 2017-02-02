IF OBJECT_ID('dbo.ufn_GetEntity', 'FN') IS NOT NULL
	DROP FUNCTION dbo.ufn_GetEntity
GO

CREATE FUNCTION [dbo].[ufn_GetEntity] 
(
	@entityName VARCHAR(255)
)
RETURNS VARCHAR(MAX)

BEGIN	

	DECLARE @excludedColumns TABLE (
		columnName VARCHAR(100)
	)

	INSERT INTO @excludedColumns (columnName) VALUES ('CreatedBy')
	INSERT INTO @excludedColumns (columnName) VALUES ('CreatedOn')
	INSERT INTO @excludedColumns (columnName) VALUES ('ModifiedBy')
	INSERT INTO @excludedColumns (columnName) VALUES ('ModifiedOn')

	DECLARE @code VARCHAR(MAX)
	SET @code = 'public class ' + @entityName + ' : EntityBase
{
'
	SELECT @code = @code +
		'	public ' +
		CASE s.name 
			WHEN 'datetime' THEN 'DateTime' 
			WHEN 'date' THEN 'DateTime' 
			WHEN 'varchar' THEN 'string'
			WHEN 'nvarchar' THEN 'string'
			WHEN 'bit' THEN 'bool'
			WHEN 'smallint' THEN 'byte'
			WHEN 'tinyint' THEN 'byte'
			WHEN 'money' THEN 'decimal'
			WHEN 'timestamp' THEN 'DateTime'	
			WHEN 'time' THEN 'TimeSpan'
			ELSE s.name END +
		CASE WHEN (s.name NOT IN ('varchar','nvarchar') AND c.is_nullable = 1) THEN '?' ELSE '' END +
		' ' +
		c.name + ' { get; set; }' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	FROM sys.columns c
	JOIN sys.types s ON s.system_type_id = c.system_type_id AND s.name <> 'sysname'
	WHERE c.object_id = object_id('dbo.' + @entityName, 'U')
	AND c.name NOT IN (SELECT columnName FROM @excludedColumns)
	ORDER BY c.column_id

	SET @code = @code + '}'

	RETURN @code;
END
GO

DECLARE @mappingSQL VARCHAR(MAX) = ''



-- example usage:
SELECT 
	dbo.ufn_GetEntity([name]) AS Entity
FROM sys.tables 
WHERE schema_id = SCHEMA_ID('dbo')
AND [name] <> '__RefactorLog'
