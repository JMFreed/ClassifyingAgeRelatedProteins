-- if protein has certain number of interactions, then it is a key PPI partner
DECLARE myCursor CURSOR FOR
	(
	SELECT UniprotID1 FROM tblProteinProteinInteractions
	WHERE UniprotID2 IN
		(
		SELECT UniprotID
		FROM uniprots_GenAge_MGI
		)
	GROUP BY UniprotID1
	HAVING COUNT(UniprotID2) > 19
	)
ORDER BY UniprotID1

DECLARE @UniprotID NVARCHAR(255)
DECLARE @sql NVARCHAR(MAX)

-- drop table
IF EXISTS 
	( 
	SELECT TABLE_NAME 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_NAME='[GenAgeMGIBinaryProteinInteractionsThreshold=20]' 
	)
DROP TABLE [GenAgeMGIBinaryProteinInteractionsThreshold=20]


-- create tblHumanGenesXGOTermsBinary
CREATE TABLE [GenAgeMGIBinaryProteinInteractionsThreshold=20]
(
UniprotID NVARCHAR(50) NOT NULL PRIMARY KEY,
[AgeRelatedFlag (GenAge)] INT NOT NULL DEFAULT 0
)


-- insert all human gene uniprotIDs into first column
INSERT INTO [GenAgeMGIBinaryProteinInteractionsThreshold=20] (UniprotID)
	( 
	SELECT DISTINCT UniprotID 
	FROM tblProteins
	WHERE UniprotID LIKE '%HUMAN'
	)

-- update AgeRelatedFlags
UPDATE [GenAgeMGIBinaryProteinInteractionsThreshold=20] 
SET [GenAgeMGIBinaryProteinInteractionsThreshold=20].[AgeRelatedFlag (GenAge)] = 1
WHERE UniprotID IN 
	( 
	SELECT UniprotID 
	FROM uniprots_GenAge_MGI 
	)


OPEN myCursor;

FETCH NEXT FROM myCursor INTO @UniprotID;

WHILE @@FETCH_STATUS = 0 BEGIN

	SET @sql = 'ALTER TABLE [GenAgeMGIBinaryProteinInteractionsThreshold=20] ADD [interacts_with_' + @UniprotID + '] INT NOT NULL DEFAULT 0'
	EXEC sp_executesql @sql;
	
	-- change value to 1 if the protein has that GO term
	SET @sql = 'UPDATE [GenAgeMGIBinaryProteinInteractionsThreshold=20]
			SET [interacts_with_' + @UniprotID + '] = 1 
			WHERE EXISTS ( 
			SELECT 
			tblProteinProteinInteractions.UniprotID1, 
			tblProteinProteinInteractions.UniprotID2
			FROM tblProteinProteinInteractions
			WHERE tblProteinProteinInteractions.UniprotID1 = ''' + @UniprotID + '''
			AND tblProteinProteinInteractions.UniprotID2 = [GenAgeMGIBinaryProteinInteractionsThreshold=20].UniprotID 
			)'

	EXEC sp_executesql @sql
	
	FETCH NEXT FROM myCursor INTO @UniprotID;

END;
	
CLOSE myCursor;
DEALLOCATE myCursor;