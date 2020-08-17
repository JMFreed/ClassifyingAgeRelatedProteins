SELECT 
COUNT(a.importance) AS 'n_counts' , 
AVG(a.importance) AS 'importance',
CASE
WHEN b.GOTermName IS NULL
THEN a.feature
ELSE (a.feature + ' : ' + b.GOTermName)
END AS 'feature'
FROM xgboost_rf_feature_selection a
LEFT OUTER JOIN tblGeneOntologyGOTerms b ON b.GOTermID = a.feature
GROUP BY a.feature, b.GOTermName
ORDER BY 'n_counts' DESC, 'importance' DESC