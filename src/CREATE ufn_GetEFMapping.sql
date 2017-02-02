IF OBJECT_ID('dbo.ufn_GetEFMapping', 'FN') IS NOT NULL
	DROP FUNCTION dbo.ufn_GetEFMapping
GO

CREATE FUNCTION [dbo].[ufn_GetEFMapping] 
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
	SET @code = 'public class ' + @entityName + 'Map : EntityTypeConfiguration<' +  @entityName + '>
{
'
	SELECT @code = @code +
		'	public ' + @entityName + 'Map()
	{
		Map(cfg => cfg.ToTable("' + @entityName + '", Schemas.Dbo));
		
		HasKey(' + SUBSTRING(LOWER(@entityName), 1, 1) + ' => ' + SUBSTRING(LOWER(@entityName), 1, 1) + '.' + @entityName + 'Id);' 

	SET @code = @code + '
	}
}'

	RETURN @code;
END
GO

-- example usage:
SELECT 
	dbo.ufn_GetEFMapping([name]) AS Entity
FROM sys.tables 
WHERE schema_id = SCHEMA_ID('dbo')
AND [name] <> '__RefactorLog'


