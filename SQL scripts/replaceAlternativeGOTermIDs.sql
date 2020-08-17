

UPDATE tblProteinsXGOTerms
SET GOTermID = 
	(
	SELECT GOTermID
	FROM tblGOTermXAlternativeGOTerms
	WHERE tblProteinsXGOTerms.GOTermID = tblGOTermXAlternativeGOTerms.AlternativeGOTermID
	)
WHERE GOTermID IN
	(
	SELECT AlternativeGOTermID
	FROM tblGOTermXAlternativeGOTerms
	)