USE DissertationDB

DECLARE @uniprotID nvarchar(255)
DECLARE @bioProcess nvarchar(MAX)
DECLARE @cellCompt nvarchar(MAX)
DECLARE @molecFunct nvarchar(MAX)

DECLARE @split nvarchar(MAX)
DECLARE @GOID nvarchar(MAX)
DECLARE @GOName nvarchar(MAX)

DECLARE myCursor cursor FOR ( SELECT [UniprotID] FROM uniprot_homo_sapiens )

IF EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblProteinsXGOTerms' )
DROP TABLE tblProteinsXGOTerms

CREATE TABLE tblProteinsXGOTerms (
UniprotID NVARCHAR(255) NOT NULL,
GOTermID NVARCHAR(255) NOT NULL)

OPEN myCursor;

FETCH NEXT FROM myCursor INTO @uniprotID;

WHILE @@FETCH_STATUS=0 BEGIN

	SET @bioProcess = ( SELECT [GO (biological process)] FROM uniprot_homo_sapiens
						WHERE [UniprotID] = @uniprotID ) + ';'
	IF @bioProcess IS NOT NULL BEGIN
		WHILE LEN(@bioProcess)>0 BEGIN
			SET @split = LEFT(@bioProcess, PATINDEX('%;%', @bioProcess))
			SET @GOID = LTRIM(RTRIM(LEFT(RIGHT(@split, 12),10)))
			SET @GOName = LTRIM(RTRIM(LEFT(@split, (PATINDEX('%GO:%', @split)) -3)))
				
			IF NOT EXISTS ( SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
							WHERE UniprotID=@uniprotID AND GOTermID=@GOID ) BEGIN
				INSERT INTO tblProteinsXGOTerms VALUES (@uniprotID, @GOID)
			END;
			
		SET @bioProcess = REPLACE(@bioProcess, @split, '')
				
		END;
	END;
	
		
	SET @cellCompt = ( SELECT [GO (cellular component)] FROM uniprot_homo_sapiens
						WHERE [UniprotID] = @uniprotID ) + ';'
	IF @cellCompt IS NOT NULL BEGIN
		WHILE LEN(@cellCompt)>0 BEGIN
			SET @split = LEFT(@cellCompt, PATINDEX('%;%', @cellCompt))
			SET @GOID = LTRIM(RTRIM(LEFT(RIGHT(@split, 12),10)))
			SET @GOName = LTRIM(RTRIM(LEFT(@split, (PATINDEX('%GO:%', @split)) -3)))
			
			IF NOT EXISTS ( SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
							WHERE UniprotID=@uniprotID AND GOTermID=@GOID ) BEGIN
				INSERT INTO tblProteinsXGOTerms VALUES (@uniprotID, @GOID)
			END;
				
		SET @cellCompt = REPLACE(@cellCompt, @split, '')
		
		END;
	END;
		
	
	SET @molecFunct = ( SELECT [GO (molecular function)] FROM uniprot_homo_sapiens
						WHERE [UniprotID] = @uniprotID ) + ';'
	IF @molecFunct IS NOT NULL BEGIN
		WHILE LEN(@molecFunct)>0 BEGIN
			SET @split = LEFT(@molecFunct, PATINDEX('%;%', @molecFunct))
			SET @GOID = LTRIM(RTRIM(LEFT(RIGHT(@split, 12),10)))
			SET @GOName = LTRIM(RTRIM(LEFT(@split, (PATINDEX('%GO:%', @split)) -3)))

				
			IF NOT EXISTS ( SELECT UniprotID, GOTermID FROM tblProteinsXGOTerms
							WHERE UniprotID=@uniprotID AND GOTermID=@GOID ) BEGIN
				INSERT INTO tblProteinsXGOTerms VALUES (@uniprotID, @GOID)
			END;
				
		SET @molecFunct = REPLACE(@molecFunct, @split, '')
				
		END;
	END;	
		
		FETCH NEXT FROM myCursor INTO @uniprotID
	END;

CLOSE myCursor;
DEALLOCATE myCursor;