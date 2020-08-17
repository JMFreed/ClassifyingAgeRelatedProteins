/*
tblProteins contains UniprotIDs from the human and mouse proteome
tblHumanMouseHomologs links proteins by their UniprotIDs
*/
USE DissertationDB

DECLARE @uniprotIDHuman NVARCHAR(255)
DECLARE @uniprotIDMouse NVARCHAR(255)
DECLARE @geneName NVARCHAR(MAX)
DECLARE @geneSymbol NVARCHAr(255)
DECLARE @split NVARCHAR(255)

DECLARE myCursor cursor FOR 
( SELECT UniprotID FROM tblProteins
WHERE UniprotID LIKE '%HUMAN' AND UniprotID IS NOT NULL )

-- drop table

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblHumanMouseHomologs')
DROP TABLE tblHumanMouseHomologs

CREATE TABLE tblHumanMouseHomologs
( uniprotIDHuman NVARCHAR(255) NULL,
uniprotIDMouse NVARCHAR(255) NULL,
geneName NVARCHAR(MAX) NULL,
geneSymbol NVARCHAR(255) NULL )

OPEN myCursor;

FETCH NEXT FROM myCursor INTO
	@uniprotIDHuman;

WHILE @@FETCH_STATUS=0
	BEGIN
		SET @split = left(@uniprotIDHuman, PATINDEX('%_HUMAN', @uniprotIDHuman))
		PRINT @split
		SET @uniprotIDMouse = ( SELECT UniprotID FROM tblProteins WHERE UniprotID LIKE @split + '%' AND UniprotID LIKE '%MOUSE')
		SET @geneName = ( SELECT GeneName FROM tblProteins WHERE UniprotID = @uniprotIDHuman )
		SET @geneSymbol = ( SELECT GeneSymbol FROM tblProteins WHERE UniprotID = @uniprotIDHuman )
		
		INSERT INTO tblHumanMouseHomologs VALUES ( @uniprotIDHuman, @uniprotIDMouse, @geneName, @geneSymbol )
	
	FETCH NEXT FROM myCursor INTO
			@uniprotIDHuman
	END;

CLOSE myCursor;
DEALLOCATE myCursor;