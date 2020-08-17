IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblXGBoostDTResults' )
DROP TABLE tblXGBoostDTResults

CREATE TABLE tblXGBoostDTResults
(
ID INT IDENTITY PRIMARY KEY,
Threshold DECIMAL(18,4),
N_features INT,
Accuracy DECIMAL(18,3),
[Precision] DECIMAL(18,3),
Recall DECIMAL(18,3),
F1_score DECIMAL(18,3),
AUROC_score DECIMAL(18,3)
)

DECLARE @Threshold VARCHAR(30)
DECLARE @Nfeatures VARCHAR(20)
DECLARE @Performance VARCHAR(30)

DECLARE myCursor CURSOR FOR 
(
	SELECT Threshold, n_features, performance_score FROM xgboost_thresholds_DecisionTreeClassifier
)

OPEN myCursor;

FETCH NEXT FROM myCursor INTO @Threshold, @Nfeatures, @Performance

WHILE @@FETCH_STATUS = 0 BEGIN
	
	SET @Threshold = LTRIM(RTRIM(REPLACE(@Threshold, 'Thresh=', '')))
	SET @Nfeatures = LTRIM(RTRIM(REPLACE(@Nfeatures, 'n=', '')))
	
	-- put unique threshold and n_features into table
	IF NOT EXISTS
		(
		SELECT Threshold, N_features FROM tblXGBoostDTResults
		WHERE Threshold = @Threshold
		AND N_features = @Nfeatures
		)
		BEGIN
			INSERT INTO tblXGBoostDTResults
			(Threshold, N_features)
			VALUES
			(@Threshold, @Nfeatures)
		END

	IF @Performance LIKE '%Accuracy%' BEGIN
		SET @Performance = LTRIM(RTRIM(REPLACE(@Performance, 'Accuracy: ', '')))
		UPDATE tblXGBoostDTResults 
		SET Accuracy = @Performance
		WHERE Threshold = @Threshold
		AND N_features = @Nfeatures
		END;
	IF @Performance LIKE '%Precision%' BEGIN
		SET @Performance = LTRIM(RTRIM(REPLACE(@Performance, 'Precision: ', '')))
		UPDATE tblXGBoostDTResults 
		SET [Precision] = @Performance
		WHERE Threshold = @Threshold
		AND N_features = @Nfeatures
		END;
	IF @Performance LIKE '%Recall%' BEGIN
		SET @Performance = LTRIM(RTRIM(REPLACE(@Performance, 'Recall: ', '')))
		UPDATE tblXGBoostDTResults 
		SET Recall = @Performance
		WHERE Threshold = @Threshold
		AND N_features = @Nfeatures
		END;
	IF @Performance LIKE '%F1 score%' BEGIN
		SET @Performance = LTRIM(RTRIM(REPLACE(@Performance, 'F1 score: ', '')))
		UPDATE tblXGBoostDTResults 
		SET F1_score = @Performance
		WHERE Threshold = @Threshold
		AND N_features = @Nfeatures
		END;
	IF @Performance LIKE '%AUROC score%' BEGIN
		SET @Performance = LTRIM(RTRIM(REPLACE(@Performance, 'AUROC score: ', '')))
		UPDATE tblXGBoostDTResults 
		SET AUROC_score = @Performance
		WHERE Threshold = @Threshold
		AND N_features = @Nfeatures
		END;

	FETCH NEXT FROM myCursor INTO @Threshold, @Nfeatures, @Performance;
	END;

CLOSE myCursor;
DEALLOCATE myCursor;