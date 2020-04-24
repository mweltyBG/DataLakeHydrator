-- =============================================
-- Author:      David Barnhart
-- Create Date: 2020-04-23
-- Description: Using a supplied string that contains one or more tokens and TaskAuditKey, substitute literal values for each token
-- =============================================
CREATE FUNCTION etl.PerformTokenSubstitution
(
    @StringWithToken NVARCHAR(2000),
	@TaskAuditKey INT
)
RETURNS NVARCHAR(2000)
AS
BEGIN
	DECLARE @interprettedLiteralString NVARCHAR(2000) = @StringWithToken

	DECLARE @ErrorMessage NVARCHAR(2048)
	DECLARE @nextOpenCurlyBracketIndex INT, @nextClosedCurlyBracketIndex INT
	SET @nextOpenCurlyBracketIndex = CHARINDEX('{', @StringWithToken)
	SET @nextClosedCurlyBracketIndex = CHARINDEX('}', @StringWithToken)

	-- perform the token replacement until all curly brackets are gone
	WHILE @nextOpenCurlyBracketIndex > 0 AND @nextClosedCurlyBracketIndex > @nextOpenCurlyBracketIndex
	BEGIN
		DECLARE @tokenValue NVARCHAR(2000) = SUBSTRING(@interprettedLiteralString, @nextOpenCurlyBracketIndex, @nextClosedCurlyBracketIndex - @nextOpenCurlyBracketIndex + 1)
		SET @tokenValue = REPLACE(REPLACE(@tokenValue, '{', ''), '}', '')

		DECLARE @literalValue NVARCHAR(2000)
		SET @literalValue = (SELECT TOP 1 LiteralValue FROM etl.GetLiteralFromToken(@TaskAuditKey) WHERE Token = @tokenValue)
		IF @literalValue IS NULL
		BEGIN
			-- wish we could throw an error here but we can't. instead just set the entire return value to the error message and hope that something downstream catches this pretty quickly
			SET @interprettedLiteralString =  'Error: Cannot substitute literal value for token "' + @tokenValue + '". Confirm that this token is correct. Check the etl.GetLiteralFromToken table-valued function.';
		END
		ELSE
			SET @interprettedLiteralString = REPLACE(@interprettedLiteralString, '{' + @tokenValue + '}', @literalValue)

		SET @nextOpenCurlyBracketIndex = CHARINDEX('{', @interprettedLiteralString)
		SET @nextClosedCurlyBracketIndex = CHARINDEX('}', @interprettedLiteralString)

	END

    -- Return the result of the function
    RETURN @interprettedLiteralString
END