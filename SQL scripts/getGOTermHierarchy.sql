SELECT DISTINCT
a.ChildGOTermID, 
b.GOTermName,
c.ChildGOTermID,
d.GOTermName,
e.ChildGOTermID,
f.GOTermName,
g.ChildGOTermID,
h.GOTermName,
i.ChildGOTermID,
j.GOTermName,
k.ChildGOTermID,
l.GOTermName,
m.ChildGOTermID,
n.GOTermName,
o.ChildGOTermID,
p.GOTermName,
q.ChildGOTermID,
r.GOTermName,
s.ChildGOTermID,
t.GOTermName,
u.ChildGOTermID,
v.GOTermName,
w.ChildGOTermID,
x.GOTermName,
y.ChildGOTermID,
z.GOTermName,
aa.ChildGOTermID,
ab.GOTermName,
ac.ChildGOTermID,
ad.GOTermName,
ae.ChildGOTermID,
af.GOTermName

FROM tblGOTermXAncestralGOTerms a

FULL OUTER JOIN tblGeneOntologyGOTerms b ON b.GOTermID = a.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms c ON c.ChildGOTermID = a.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms d ON d.GOTermID = c.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms e ON e.ChildGOTermID = c.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms f ON f.GOTermID = e.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms g ON g.ChildGOTermID = e.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms h ON h.GOTermID = g.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms i ON i.ChildGOTermID = g.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms j ON j.GOTermID = i.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms k ON k.ChildGOTermID = i.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms l ON l.GOTermID = k.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms m ON m.ChildGOTermID = k.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms n ON n.GOTermID = m.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms o ON o.ChildGOTermID = m.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms p ON p.GOTermID = o.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms q ON q.ChildGOTermID = o.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms r ON r.GOTermID = q.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms s ON s.ChildGOTermID = q.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms t ON t.GOTermID = s.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms u ON u.ChildGOTermID = s.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms v ON v.GOTermID = u.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms w ON w.ChildGOTermID = u.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms x ON x.GOTermID = w.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms y ON y.ChildGOTermID = w.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms z ON z.GOTermID = y.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms aa ON aa.ChildGOTermID = y.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms ab ON ab.GOTermID = aa.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms ac ON ac.ChildGOTermID = aa.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms ad ON ad.GOTermID = ac.ChildGOTermID
FULL OUTER JOIN tblGOTermXAncestralGOTerms ae ON ae.ChildGOTermID = ac.ParentGOTermID
FULL OUTER JOIN tblGeneOntologyGOTerms af ON af.GOTermID = ae.ChildGOTermID

WHERE a.ChildGOTermID IN 
	( 
	SELECT DISTINCT GOTermID FROM tblProteinsXGOTerms
	-- CONDITION: protein must be age-related
	WHERE UniprotID IN 
		( 
		SELECT UniprotID 
		FROM uniprots_GenAge_MGI
		)

	-- CONDITION: GO term must be a biological process and appear in the DNA repair
	-- proteins a certain number of times
	AND GOTermID IN
		(
		SELECT GOTermID
		FROM tblGeneOntologyGOTerms
		WHERE GOTermType='biological_process'
		)
	GROUP BY GOTermID
	HAVING COUNT(UniprotID) > 6
	)