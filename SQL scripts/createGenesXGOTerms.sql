/*
RUNTIME VERY LONG
NEEDS OPTIMIZING
*/

USE DissertationDB

DECLARE @uniprotID nvarchar(255)
DECLARE @geneName nvarchar(MAX)
DECLARE @geneSymbol nvarchar(MAX)
DECLARE @bioProcess nvarchar(MAX)
DECLARE @cellCompt nvarchar(MAX)
DECLARE @molecFunct nvarchar(MAX)

DECLARE @split nvarchar(MAX)
DECLARE @GOID nvarchar(MAX)
DECLARE @GOName nvarchar(MAX)

-- create cursor
DECLARE myCursor cursor FOR ( SELECT [UniprotID] FROM uniprot_mus_musculus )

-- drop tables	

--IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGOTerms' )
--DROP TABLE tblGOTerms

--IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblProteins' )
--DROP TABLE tblProteins

--IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblProteinsXGOTerms' )
--DROP TABLE tblProteinsXGOTerms


-- create table containing unique GO terms
--CREATE TABLE tblGOTerms (
--GOTermID nvarchar(255) NOT NULL PRIMARY KEY,
--GOTermName nvarchar(MAX) NOT NULL,
--GOTermType nvarchar(255) NOT NULL )


-- create table containing genes
--CREATE TABLE tblProteins (
--UniprotID nvarchar(255) NOT NULL PRIMARY KEY,
--GeneName nvarchar(MAX) NULL,
--GeneSymbol nvarchar(MAX) NULL )

-- create link table of gene uniprotIDs - GOTermIDs
--CREATE TABLE tblProteinsXGOTerms (
--UniprotID nvarchar(255) NOT NULL,
--GOTermID nvarchar(255) NOT NULL )


OPEN myCursor;

FETCH NEXT FROM myCursor INTO @uniprotID;

WHILE @@FETCH_STATUS=0 BEGIN
	
		SET @geneName = ( SELECT [ProteinNames] FROM uniprot_mus_musculus WHERE [UniprotID] = @uniprotID )
		SET @geneSymbol = ( SELECT [GeneSymbols] FROM uniprot_mus_musculus WHERE [UniprotID] = @uniprotID )
		
		IF NOT EXISTS ( SELECT UniprotID, GeneName, GeneSymbol FROM tblProteins 
						WHERE UniprotID = @uniprotID AND GeneName = @geneName AND GeneSymbol = @geneSymbol ) BEGIN
			INSERT INTO tblProteins VALUES (@uniprotID, @geneName, @geneSymbol)
		END;
		
		-- grab unique GO biological processes
		SET @bioProcess = ( SELECT [GO (biological process)] FROM uniprot_mus_musculus
							WHERE [UniprotID] = @uniprotID ) + ';'
		IF @bioProcess IS NOT NULL BEGIN
			WHILE LEN(@bioProcess)>0 BEGIN
				SET @split = left(@bioProcess, PATINDEX('%;%', @bioProcess))
				SET @GOID = LTRIM(RTRIM(left(right(@split, 12),10)))
				SET @GOName = LTRIM(RTRIM(left(@split, (PATINDEX('%GO:%', @split)) -3)))
				
				--IF NOT EXISTS ( SELECT GOTermID, GOTermName FROM tblGeneOntologyGOTerms 
				--				WHERE GOTermID=@GOID AND GOTermName=@GOName ) BEGIN
				--	INSERT INTO tblGeneOntologyGOTerms VALUES (@GOID, @GOName, 'biological process', 0, NULL)
				--END;
				
				IF NOT EXISTS ( SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
								WHERE UniprotID=@uniprotID AND GOTermID=@GOID ) BEGIN
					INSERT INTO tblProteinsXGOTerms VALUES (@uniprotID, @GOID)
				END;
				
				SET @bioProcess = REPLACE(@bioProcess, @split, '')
				
			END;
		END;	
		
		-- grab unique GO cellular components	
		SET @cellCompt = ( SELECT [GO (cellular component)] FROM uniprot_mus_musculus
		WHERE [UniprotID] = @uniprotID ) + ';'
		IF @cellCompt IS NOT NULL BEGIN
			WHILE LEN(@cellCompt)>0 BEGIN
				SET @split = left(@cellCompt, PATINDEX('%;%', @cellCompt))
				SET @GOID = LTRIM(RTRIM(left(right(@split, 12),10)))
				SET @GOName = LTRIM(RTRIM(left(@split, (PATINDEX('%GO:%', @split)) -3)))
				
				--IF NOT EXISTS (SELECT GOTermID, GOTermName FROM tblGeneOntologyGOTerms 
				--				WHERE GOTermID=@GOID AND GOTermName=@GOName) BEGIN
				--	INSERT INTO tblGeneOntologyGOTerms VALUES (@GOID, @GOName, 'cellular component', 0, NULL)
				--END;
				
				IF NOT EXISTS ( SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
								WHERE UniprotID=@uniprotID AND GOTermID=@GOID ) BEGIN
					INSERT INTO tblProteinsXGOTerms VALUES (@uniprotID, @GOID)
				END;
				
				SET @cellCompt = REPLACE(@cellCompt, @split, '')
			END;
		END;
		
		-- grab unique GO molecular functions	
		SET @molecFunct = ( SELECT [GO (molecular function)] FROM uniprot_mus_musculus
		WHERE [UniprotID] = @uniprotID ) + ';'
		IF @molecFunct IS NOT NULL BEGIN
			WHILE LEN(@molecFunct)>0 BEGIN
				SET @split = left(@molecFunct, PATINDEX('%;%', @molecFunct))
				SET @GOID = LTRIM(RTRIM(left(right(@split, 12),10)))
				SET @GOName = LTRIM(RTRIM(left(@split, (PATINDEX('%GO:%', @split)) -3)))
				
				--IF NOT EXISTS (SELECT GOTermID, GOTermName FROM tblGeneOntologyGOTerms 
				--				WHERE GOTermID=@GOID AND GOTermName=@GOName) BEGIN
				--	INSERT INTO tblGeneOntologyGOTerms VALUES (@GOID, @GOName, 'molecular function', 0, NULL)
				--END;
				
				IF NOT EXISTS ( SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
								WHERE UniprotID=@uniprotID AND GOTermID=@GOID ) BEGIN
					INSERT INTO tblProteinsXGOTerms VALUES (@uniprotID, @GOID)
				END;
				
				SET @molecFunct = REPLACE(@molecFunct, @split, '')
				
			END;
		END;	
		
		FETCH NEXT FROM myCursor INTO
			@uniprotID
	END;

CLOSE myCursor;
DEALLOCATE myCursor;