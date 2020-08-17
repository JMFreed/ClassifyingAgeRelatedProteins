IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblProteinProteinInteractions' )
DROP TABLE tblProteinProteinInteractions

CREATE TABLE tblProteinProteinInteractions
(
GeneSymbol1 VARCHAR(20) NOT NULL,
UniprotID1 VARCHAR(20) NOT NULL,
[AgeRelatedFlag (GenAge) 1] INT DEFAULT 0,
GeneSymbol2 VARCHAR(20) NOT NULL,
UniprotID2 VARCHAR(20) NOT NULL,
[AgeRelatedFlag (GenAge) 2] INT DEFAULT 0
)

INSERT INTO tblProteinProteinInteractions (GeneSymbol1, UniprotID1, GeneSymbol2, UniprotID2)

SELECT DISTINCT a.SymbolA, b.UniprotID, a.SymbolB, c.UniprotID 
FROM Biogrid_Homo_sapiens a
JOIN tblProteinsXGeneSymbols b ON b.GeneSymbol = a.SymbolA
JOIN tblProteinsXGeneSymbols c ON c.GeneSymbol = a.SymbolB
WHERE b.UniprotID LIKE '%HUMAN'
AND c.UniprotID LIKE '%HUMAN'
ORDER BY b.UniprotID, c.UniprotID

UPDATE tblProteinProteinInteractions
SET [AgeRelatedFlag (GenAge) 1] = 1
WHERE UniprotID1 IN
	(
	SELECT UniprotID
	FROM genage_human
	)

UPDATE tblProteinProteinInteractions
SET [AgeRelatedFlag (GenAge) 2] = 1
WHERE UniprotID2 IN
	(
	SELECT UniprotID
	FROM genage_human
	)

