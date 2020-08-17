
-- drop table
IF EXISTS 
	( 
	SELECT TABLE_NAME 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_NAME='[GenAgeMGIBinaryProteinsXGOTermsThreshold=7]' 
	)
DROP TABLE [GenAgeMGIBinaryProteinsXGOTermsThreshold=7]

-- create table
CREATE TABLE [GenAgeMGIBinaryProteinsXGOTermsThreshold=7]
(
UniprotID NVARCHAR(50) NOT NULL PRIMARY KEY,
[AgeRelatedFlag (GenAge)] INT NOT NULL DEFAULT 0
)

-- add all human uniprotIDs
INSERT INTO [GenAgeMGIBinaryProteinsXGOTermsThreshold=7](UniprotID)
	( 
	SELECT UniprotID 
	FROM tblProteins 
	WHERE UniprotID LIKE '%HUMAN' 
	)

-- update AgeRelatedFlags
UPDATE [GenAgeMGIBinaryProteinsXGOTermsThreshold=7]
SET [AgeRelatedFlag (GenAge)] = 1
WHERE UniprotID IN 
	( 
	SELECT UniprotID 
	FROM uniprots_GenAge_MGI 
	)

DECLARE @GOTermID VARCHAR(10)
DECLARE @sql NVARCHAR(MAX)

-- get subset of unique GO terms
DECLARE myCursor CURSOR FOR
	(
	SELECT DISTINCT GOTermID 
	FROM [GenAgeMGIUniqueGOTermsThreshold=7]
	WHERE GOTermID BETWEEN 'GO:0043255' AND 'GO:2001243'
	)
ORDER BY GOTermID

OPEN myCursor;

FETCH NEXT FROM myCursor INTO @GOTermID;

WHILE @@FETCH_STATUS = 0 BEGIN
	
	-- add GO term column name to table
	SET @sql = 'ALTER TABLE [GenAgeMGIBinaryProteinsXGOTermsThreshold=7] ADD [' + @GOTermID + '] INT NOT NULL DEFAULT 0'
	EXEC sp_executesql @sql

	-- change value to 1 if the protein has that GO term
	SET @sql = 'UPDATE [GenAgeMGIBinaryProteinsXGOTermsThreshold=7]
				SET [' + @GOTermID + '] = 1 
				WHERE EXISTS ( 
				SELECT 
				[GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID, 
				[GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID 
				FROM [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7]
				WHERE [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID = ''' + @GOTermID + '''
				AND [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsThreshold=7].UniprotID
				AND [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].ProteinHasGOTerm = 1
				)'

	EXEC sp_executesql @sql

	FETCH NEXT FROM myCursor INTO @GOTermID;
	END;
	
CLOSE myCursor;
DEALLOCATE myCursor;