USE DissertationDB

SELECT a.UniprotID, COUNT(b.UniprotID2) FROM tblProteins a
FULL OUTER JOIN tblProteinProteinInteractions b ON b.UniprotID1 = a.UniprotID

WHERE a.UniprotID LIKE '%HUMAN'
-- AND [AgeRelatedFlag (GenAge) 2] = 1

GROUP BY a.UniprotID
ORDER BY a.UniprotID