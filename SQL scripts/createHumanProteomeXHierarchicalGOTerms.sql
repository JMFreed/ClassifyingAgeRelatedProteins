
--declare variables
DECLARE @UniprotID VARCHAR(20)
DECLARE @GOTermID VARCHAR(10)
DECLARE @AncestorGOTermID VARCHAR(10)


--if exists, drop table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='tblHumanProteomeXHierarchicalGOTerms' )
DROP TABLE tblHumanProteomeXHierarchicalGOTerms

--create table
CREATE TABLE tblHumanProteomeXHierarchicalGOTerms
( 
UniprotID VARCHAR(20) NOT NULL,
GOTermID VARCHAR(10) NOT NULL,
ProteinHasGOTerm INT DEFAULT 0
)

-- insert all human UniprotIDs X all GO terms commonly found in age-related proteins and their ancestors
INSERT INTO tblHumanProteomeXHierarchicalGOTerms (UniprotID, GOTermID)
SELECT a.UniprotID, b.GOTermID FROM tblProteins a
CROSS JOIN tblUniqueHierarchicalGOTerms b
WHERE a.UniprotID LIKE '%HUMAN'


-- create index on table
CREATE INDEX idx_HumanProteomeXHierarchicalGOTerms
ON tblHumanProteomeXHierarchicalGOTerms (UniprotID, GOTermID)


DECLARE cursor1 CURSOR FOR
	(
	SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
	WHERE UniprotID LIKE '%HUMAN'
	AND GOTermID IN
		(
		SELECT DISTINCT GOTermID
		FROM tblHumanProteomeXHierarchicalGOTerms
		)
	)
ORDER BY UniprotID, GOTermID


OPEN cursor1;

FETCH NEXT FROM cursor1 INTO @UniprotID, @GOTermID

WHILE @@FETCH_STATUS=0 BEGIN
	
	-- if 
	UPDATE tblHumanProteomeXHierarchicalGOTerms
	SET ProteinHasGOTerm = 1
	WHERE UniprotID = @UniprotID
	AND GOTermID = @GOTermID
	
	FETCH NEXT FROM cursor1 INTO @UniprotID, @GOTermID
	END;
	
CLOSE cursor1;
DEALLOCATE cursor1;


DECLARE cursor2 CURSOR FOR 
	(
	SELECT a.UniprotID, a.GOTermID, b.AncestorGOTermID FROM tblProteinsXGOTerms a
	JOIN tblGOTermXAncestralGOTerms b ON b.GOTermID = a.GOTermID
	WHERE a.UniprotID LIKE '%HUMAN'
	)
ORDER BY a.UniprotID, a.GOTermID


OPEN cursor2;

FETCH NEXT FROM cursor2 INTO @UniprotID, @GOTermID, @AncestorGOTermID

WHILE @@FETCH_STATUS=0 BEGIN
	
	IF EXISTS 
		( 
		SELECT UniprotID, GOTermID
		FROM tblHumanProteomeXHierarchicalGOTerms
		WHERE UniprotID = @UniprotID
		AND GOTermID = @AncestorGOTermID
		)
		BEGIN
	
		IF EXISTS
			(
			SELECT UniprotID, GOTermID
			FROM tblHumanProteomeXHierarchicalGOTerms
			WHERE UniprotID = @UniprotID
			AND GOTermID = @GOTermID
			AND ProteinHasGOTerm = 1
			)
			BEGIN
			
				UPDATE tblHumanProteomeXHierarchicalGOTerms
				SET ProteinHasGOTerm = 1
				WHERE UniprotID = @UniprotID
				AND GOTermID = @AncestorGOTermID
			END;
		END;
		
		FETCH NEXT FROM cursor2 INTO @UniprotID, @GOTermID, @AncestorGOTermID;
	
	END;
	
CLOSE cursor2;
DEALLOCATE cursor2;