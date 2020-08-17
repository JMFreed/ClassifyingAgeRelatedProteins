/*
uses uniprot_homo_sapiens and uniprot_mus_musculus
Creates table containing unique UniprotID, ProteinName and GeneSymbols
GOTerms for each protein are extracted
tblProteinsXGOTerms is a link table giving each row a uniprotID and a respective GOTerm
*/

-- create Gene Ontology GOTerms table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGeneOntologyGOTerms' )
DROP TABLE tblGeneOntologyGOTerms

CREATE TABLE tblGeneOntologyGOTerms
(
GOTermID NVARCHAR(50) NOT NULL PRIMARY KEY,
GOTermName NVARCHAR(255) NOT NULL,
GOTermType NVARCHAR(255) NOT NULL,
ObseleteFlag INT DEFAULT 0
)

-- create GOTerm X AncestralGOTerm table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGOTermXAncestralGOTerms' )
DROP TABLE tblGOTermXAncestralGOTerms

CREATE TABLE tblGOTermXAncestralGOTerms
(
ChildGOTermID NVARCHAR(50) NOT NULL,
ParentGOTermID NVARCHAR(50) NOT NULL
)

-- create GOTerm X Alternate GOTerm table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGOTermXAltGOTerms' )
DROP TABLE tblGOTermXAltGOTerms

CREATE TABLE tblGOTermXAltGOTerms
(
GOTermID NVARCHAR(50) NOT NULL,
AlternativeGOTermID NVARCHAR(50) NOT NULL
)

-- create GOTerm X Replacement GOTerm table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGOTermXReplacementGOTerms' )
DROP TABLE tblGOTermXReplacementGOTerms

CREATE TABLE tblGOTermXReplacementGOTerms
(
GOTermID NVARCHAR(50) NOT NULL,
ReplacementGOTermID NVARCHAR(50) NOT NULL
)


-- create GOTerm X Related GOTerm table
IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGOTermXRelatedGOTerms' )
DROP TABLE tblGOTermXRelatedGOTerms

CREATE TABLE tblGOTermXRelatedGOTerms
(
GOTermID NVARCHAR(50) NOT NULL,
RelatedGOTermID NVARCHAR(50) NOT NULL,
Relationship NVARCHAR(MAX) NULL
)

DECLARE @line NVARCHAR(MAX)
DECLARE @split NVARCHAR(MAX)
DECLARE @GOTermID NVARCHAR(50)
DECLARE @GOTermName NVARCHAR(255)
DECLARE @GOTermType NVARCHAR(255)
DECLARE @ObseleteFlag INT
DECLARE @Comment NVARCHAR(MAX)
DECLARE @AltGOTermID NVARCHAR(50)
DECLARE @IsAString NVARCHAR(MAX)
DECLARE @AncestorGOTermID NVARCHAR(50)
DECLARE @AncestorGOTermName NVARCHAR(255)
DECLARE @ReplacementGOTermID NVARCHAR(50)
DECLARE @RelatedGOTerm NVARCHAR(MAX)
DECLARE @RelatedGOTermID NVARCHAR(50)
DECLARE @Relationship NVARCHAR(MAX)


DECLARE myCursor CURSOR FOR
( SELECT LineText FROM tblGOTermAncestorsMerged )

OPEN myCursor;

FETCH NEXT FROM myCursor INTO
@line;

WHILE @@FETCH_STATUS=0 BEGIN
	SET @line = @line + ';;;;;'
	SET @ObseleteFlag = 0
	SET @Comment = NULL
	
	WHILE @line != ';;;;' BEGIN
		SET @split = left(@line, PATINDEX('%;;;;;%', @line))
		
		IF @split LIKE 'id: GO:%' BEGIN
			SET @GOTermID = LTRIM(RTRIM(SUBSTRING(@split,5, 10)))
			PRINT 'GoTermID: ' + @GOTermID
		END;
		
		ELSE IF @split LIKE '%name: %' BEGIN
			SET @GOTermName = LTRIM(RTRIM(SUBSTRING(@split, 12, len(@split)-12)))
			PRINT 'GOTermName: ' + @GOTermName
		END;
		
		ELSE IF @split LIKE '%namespace: %' BEGIN
			SET @GOTermType = LTRIM(RTRIM(SUBSTRING(@split, 17, LEN(@split)-17)))
			PRINT 'GOTermType: ' + @GOTermType 
		END;
		
		ELSE IF @split LIKE '%alt_id: %' BEGIN
			SET @AltGOTermID = LTRIM(RTRIM(SUBSTRING(@split, 14, LEN(@split)-14)))
			PRINT 'AlternateGOTermID: ' + @AltGOTermID
			INSERT INTO tblGOTermXAltGOTerms VALUES ( @GOTermID, @AltGOTermID )
		END;
		
		ELSE IF @split LIKE '%is_a: %' BEGIN
			SET @IsAString = LTRIM(RTRIM(SUBSTRING(@split, 12, LEN(@split)-12)))
			SET @AncestorGOTermID = LTRIM(RTRIM(SUBSTRING(@IsAString, 0, 11)))
			PRINT 'AncestorGOTermID: ' + @AncestorGOTermID
			SET @AncestorGOTermName = LTRIM(RTRIM(SUBSTRING(@IsAString, 14, LEN(@IsAString)-13)))
			PRINT 'AncestorGOTermName: ' + @AncestorGOTermName
			INSERT INTO tblGOTermXAncestralGOTerms VALUES ( @GOTermID, @AncestorGOTermID )
		END;
		
		ELSE IF @split LIKE '%is_obsolete: true%' BEGIN
			SET @ObseleteFlag = 1
		END;
		
		ELSE IF @split LIKE '%comment: %' BEGIN
			SET @Comment = LTRIM(RTRIM(SUBSTRING(@split, 11, LEN(@split)-11)))
		END;
		
		ELSE IF @split LIKE '%consider: %' BEGIN
			SET @ReplacementGOTermID = LTRIM(RTRIM(SUBSTRING(@split, 15, LEN(@split)-15)))
			PRINT 'ReplacementGOTermID: ' + @ReplacementGOTermID
			INSERT INTO tblGOTermXReplacementGOTerms VALUES ( @GOTermID, @ReplacementGOTermID )
		END;
		
		ELSE IF @split LIKE '%relationship: %' BEGIN
			SET @RelatedGOTerm = LTRIM(RTRIM(SUBSTRING(@split, 20, LEN(@split)-20)))
			PRINT 'RelatedGOTermAndRelationship: ' + @RelatedGOTerm
			SET @RelatedGOTermID = LTRIM(RTRIM(left(@RelatedGOTerm, PATINDEX('%!%', @RelatedGOTerm)-2)))
			SET @RelatedGOTermID = LTRIM(RTRIM(right(@RelatedGOTermID, PATINDEX('%GO:%', @RelatedGOTermID)+1)))
			-- pick out crap from RelatedGOTermID
			SET @RelatedGOTermID = REPLACE(@RelatedGOTermID, 's ', '')
			SET @RelatedGOTermID = REPLACE(@RelatedGOTermID, 'ly_regulate', '')
			SET @RelatedGOTermID = REPLACE(@RelatedGOTermID, 'ly_regulates ', '')
			SET @RelatedGOTermID = REPLACE(@RelatedGOTermID, 'n ', '')
			PRINT 'RelatedGOTermID: ' + @RelatedGOTermID
			SET @Relationship = LTRIM(RTRIM(left(@RelatedGOTerm, PATINDEX('%!%', @RelatedGOTerm)-2)))
			SET @Relationship = LTRIM(RTRIM(left(@Relationship, PATINDEX('%GO:%', @Relationship) -1)))
			PRINT 'Relationship: ' + @Relationship
			INSERT INTO tblGOTermXRelatedGOTerms VALUES ( @GOTermID, @RelatedGOTermID, @Relationship )
		END;
		
		SET @line = REPLACE(@line, @split, '')
			
	END;
	
	INSERT INTO tblGeneOntologyGOTerms VALUES ( @GOTermID, @GOTermName, @GOTermType, @ObseleteFlag )
	
	FETCH NEXT FROM myCursor INTO
	@line;
	
END;
	
CLOSE myCursor;
DEALLOCATE myCursor;