
UPDATE tblProteinsXGOTerms
SET GOTermID = 
	(
	SELECT TOP 1 ReplacementGOTermID
	FROM tblGOTermXReplacementGOTerms
	WHERE tblProteinsXGOTerms.GOTermID = tblGOTermXReplacementGOTerms.GOTermID
	)
WHERE GOTermID IN
	(
	SELECT GOTermID
	FROM tblGOTermXReplacementGOTerms
	)