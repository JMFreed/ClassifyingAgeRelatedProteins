-- drop table if exists
IF EXISTS 
	( 
	SELECT TABLE_NAME 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_NAME = '[GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7]' 
	)
DROP TABLE [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7]

-- create table
CREATE TABLE [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7]
(
UniprotID VARCHAR(50),
[AgeRelatedFlag (GenAge)] INT DEFAULT 0,
GOTermID VARCHAR(10),
ProteinHasGOTerm INT DEFAULT 0
)

-- cross join all human uniprotIDs with all unique GO terms above threshold and their parent GO terms
INSERT INTO [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7] ( UniprotID, GOTermID )
SELECT a.UniprotID, b.GOTermID FROM tblProteins a
CROSS JOIN [GenAgeMGIUniqueGOTermsThreshold=7] b
WHERE a.UniprotID LIKE '%HUMAN'
AND b.GOTermID != 'NULL'
ORDER BY a.UniprotID, b.GOTermID

-- set AgeRelatedFlag = 1 for all uniprotIDs found in GenAge dataset
UPDATE [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7]
SET [AgeRelatedFlag (GenAge)] = 1
WHERE UniprotID IN
	(
	SELECT UniprotID
	FROM uniprots_GenAge_MGI
	)
	
-- set ProteinHasGOTerm = 1 WHERE the combination of UniprotID and GOTerm / ParentGOTerm exists
UPDATE [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7]
SET ProteinHasGOTerm = 1
WHERE EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID1
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID1 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID2
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID2 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID3
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID3 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID4
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID4 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID5
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID5 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID6
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID6 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID7
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID7 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID8
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID8 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID9
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID9 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID10
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID10 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID11
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID11 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID12
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID12 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID13
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID13 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID14
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID14 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID15
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID15 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)
OR EXISTS
	(
	SELECT 
	[GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID, 
	[GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID16
	FROM [GenAgeMGIProteinsXGOTermsThreshold=7]
	WHERE [GenAgeMGIProteinsXGOTermsThreshold=7].UniprotID = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].UniprotID
	AND [GenAgeMGIProteinsXGOTermsThreshold=7].ChildGOTermID16 = [GenAgeMGIBinaryProteinsXGOTermsXParentGOTermsThreshold=7].GOTermID
	)