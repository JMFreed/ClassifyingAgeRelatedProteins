DECLARE @Line NVARCHAR(MAX);
DECLARE @ccp VARCHAR(20)
DECLARE @depth VARCHAR(20)
DECLARE @split VARCHAR(20)
DECLARE @leaf VARCHAR(20)

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGridSearchCVParamsDT')
DROP TABLE tblGridSearchCVParamsDT;

CREATE TABLE tblGridSearchCVParamsDT
(
ID INT NOT NULL IDENTITY PRIMARY KEY,
ccp_alpha DECIMAL(18,5),
max_depth INT,
min_samples_leaf INT,
min_samples_split INT
)

DECLARE myCursor CURSOR FOR 
(
SELECT * FROM GridSearchCV_best_params_DT
)

OPEN myCursor;

FETCH NEXT FROM myCursor INTO @Line;

WHILE @@FETCH_STATUS=0 BEGIN

	IF @Line LIKE 'Best parameters%' BEGIN

		PRINT @Line;
		SET @ccp = SUBSTRING(@Line, CHARINDEX('ccp_alpha', @Line), LEN(@Line))
		SET @depth = SUBSTRING(@Line, CHARINDEX('max_depth', @Line), LEN(@Line))
		SET @leaf = SUBSTRING(@Line, CHARINDEX('min_samples_leaf', @Line), LEN(@Line))
		SET @split = SUBSTRING(@Line, CHARINDEX('min_samples_split', @Line) +2, LEN(@Line))

		SET @ccp = REPLACE(REPLACE(@ccp, 'ccp_alpha'': ', ''), ',', '')
		SET @depth = REPLACE(REPLACE(REPLACE(REPLACE(@depth, 'max_depth'': ', ''), '''min', ''), ',', ''), ' _', '')
		SET @leaf = REPLACE(@leaf, 'min_samples_leaf'': ', '')
		SET @split = REPLACE(REPLACE(@split, 'n_samples_split'': ', ''), '}', '')

		IF @ccp = '1e-05 ''' BEGIN
			SET @ccp = '0.00001'
			END;

		PRINT @ccp
		PRINT @depth
		PRINT @leaf
		PRINT @split

		INSERT INTO tblGridSearchCVParamsDT
		VALUES
		(@ccp, @depth, @leaf, @split)

	END;

FETCH NEXT FROM myCursor INTO @Line;
END;

CLOSE myCursor;
DEALLOCATE myCursor;

UPDATE tblGridSearchCVParamsDT
SET min_samples_leaf = 10
WHERE min_samples_leaf = 1