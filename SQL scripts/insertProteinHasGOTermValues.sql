
DECLARE myCursor CURSOR FOR
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

DECLARE @UniprotID VARCHAR(20)
DECLARE @GOTermID VARCHAR(10)

OPEN myCursor;

FETCH NEXT FROM myCursor INTO @UniprotID, @GOTermID

WHILE @@FETCH_STATUS=0 BEGIN

	UPDATE tblHumanProteomeXHierarchicalGOTerms
	SET ProteinHasGOTerm = 1
	WHERE UniprotID = @UniprotID
	AND GOTermID = @GOTermID
	
	FETCH NEXT FROM myCursor INTO @UniprotID, @GOTermID
	END;
	
CLOSE myCursor;
DEALLOCATE myCursor;