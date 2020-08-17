SELECT DISTINCT max_depth, COUNT(max_depth) FROM tblGridSearchCVParamsDT

GROUP BY max_depth


SELECT DISTINCT min_samples_split, COUNT(min_samples_split) FROM tblGridSearchCVParamsDT

GROUP BY min_samples_split


SELECT DISTINCT min_samples_leaf, COUNT(min_samples_leaf) FROM tblGridSearchCVParamsDT

GROUP BY min_samples_leaf


SELECT DISTINCT ccp_alpha, COUNT(ccp_alpha) FROM tblGridSearchCVParamsDT

GROUP BY ccp_alpha