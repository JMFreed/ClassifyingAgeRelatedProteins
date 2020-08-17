
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblProteinsNumberAgeRelatedPartners' )
DROP TABLE tblProteinsNumberAgeRelatedPartners

CREATE TABLE tblProteinsNumberAgeRelatedPartners
(
UniprotID VARCHAR(20),
NumberAgeRelatedPartners INT DEFAULT 0
)

INSERT INTO tblProteinsNumberAgeRelatedPartners (UniprotID)
SELECT UniprotID
FROM tblProteins
WHERE UniprotID LIKE '%HUMAN'
ORDER BY UniprotID

UPDATE tblProteinsNumberAgeRelatedPartners
SET NumberAgeRelatedPartners = 
	(
	SELECT COUNT(UniprotID2) 
	FROM tblProteinProteinInteractions
	WHERE tblProteinProteinInteractions.UniprotID1 = tblProteinsNumberAgeRelatedPartners.UniprotID
	AND UniprotID2 IN
		(
		SELECT UniprotID
		FROM genage_human
		)
	)