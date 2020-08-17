/*
Gene Ontology provides a .obo file containing all known GO terms
The .obo file is saved as a .txt file using beuatifulsoup4 in Python
The text is then imported into SQL, each line as a row in an SQL table GeneOntology_raw_data
mergeGOTermAncestors merged all information about a GO term into a single line
information such as synosyms, definitions and subsets are removed
tblGOTermAncestorsMerged contains a row for each GOTerm with its respective information
*/

-- drop table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGOTermAncestorsMerged' )
DROP TABLE tblGOTermAncestorsMerged

CREATE TABLE tblGOTermAncestorsMerged
(
LineID INT NOT NULL PRIMARY KEY IDENTITY,
LineText NVARCHAR(MAX)
)

-- delete unwanted rows from GeneOntology_raw_data
DELETE GeneOntology_raw_data WHERE ID BETWEEN 1 AND 28
DELETE GeneOntology_raw_data WHERE Field1 LIKE 'def: %'
DELETE GeneOntology_raw_data WHERE Field1 LIKE 'synonym: %'
DELETE GeneOntology_raw_data WHERE Field1 LIKE 'xref: %'
DELETE GeneOntology_raw_data WHERE Field1 LIKE 'subset: %'

DECLARE @nextLine NVARCHAR(MAX)
DECLARE @mergedLine NVARCHAR(MAX)
DECLARE myCursor CURSOR
FOR 
( SELECT * FROM
	( SELECT TOP 99999999999 Field1 
		FROM GeneOntology_raw_data
		ORDER BY ID ) AS tempTable
)
		

OPEN myCursor;

FETCH NEXT FROM myCursor INTO
@mergedLine;

WHILE @@FETCH_STATUS=0
	BEGIN
	
	FETCH NEXT FROM myCursor INTO
	@nextLine;
	
	IF @nextLine = '[Term]'
		BEGIN
		FETCH NEXT FROM myCursor INTO
		@nextLine;
		END
	
	IF @nextLine NOT LIKE 'id: GO:%'
		BEGIN
		-- 5 semicolons will be used as delimiter for splits
		SET @mergedLine = @mergedLine + ';;;;; ' + @nextLine
		END;
		
	ELSE
		BEGIN
		INSERT INTO tblGOTermAncestorsMerged VALUES ( @mergedLine )
		SET @mergedLine = @nextLine
		END;
		
	END;
	
	
CLOSE myCursor;
DEALLOCATE myCursor;