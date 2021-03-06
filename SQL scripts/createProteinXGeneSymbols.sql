
DECLARE @UniprotID NVARCHAR(255)
DECLARE @Line NVARCHAR(MAX)
DECLARE @Split NVARCHAR(255)

DECLARE myCursor CURSOR FOR (SELECT UniprotID FROM tblProteins)

IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblProteinsXGeneSymbols' )
DROP TABLE tblProteinsXGeneSymbols

CREATE TABLE tblProteinsXGeneSymbols (
UniprotID nvarchar(255) NOT NULL,
GeneSymbol nvarchar(255) NOT NULL )

OPEN myCursor;

FETCH NEXT FROM myCursor INTO @UniprotID;

WHILE @@FETCH_STATUS=0 BEGIN
	
	PRINT @UniprotID
	SET @Line = ( SELECT GeneSymbol FROM tblProteins WHERE UniprotID = @UniprotID ) + ','
	SET @Line = REPLACE(@Line, ' ', ',')
	PRINT @Line
	WHILE @Line != ',' BEGIN
		IF CHARINDEX(',', @Line, 1) = 1 BEGIN
			SET @Line = SUBSTRING(@Line, 2, LEN(@Line))
			END;
		SET @Split = LEFT(@Line, PATINDEX('%,%', @Line) -1)
		PRINT @Split
		IF NOT EXISTS ( SELECT UniprotID, GeneSymbol FROM tblProteinsXGeneSymbols
						WHERE UniprotID=@UniprotID AND GeneSymbol=@Split ) BEGIN
			INSERT INTO tblProteinsXGeneSymbols VALUES (@UniprotID, @Split)
			END;
		SET @Line = REPLACE(@Line, @Split, '')	
		END;

	FETCH NEXT FROM myCursor INTO @UniprotID
	END;

CLOSE myCursor;
DEALLOCATE myCursor;