USE DissertationDB

SELECT DISTINCT
a.Gene,
b.UniprotID AS uniprotIDMouse,
c.uniprotIDHuman,
d.GeneName,
e.GOTermID,
f.GOTermName

FROM premature_aging_genes a

LEFT OUTER JOIN tblProteinsXGeneSymbols b ON b.GeneSymbol = a.Gene

LEFT OUTER JOIN tblHumanMouseHomologs c ON c.uniprotIDMouse = b.UniprotID

LEFT OUTER JOIN tblProteins d ON d.UniprotID = b.UniprotID

LEFT OUTER JOIN tblProteinsXGOTerms e ON e.UniprotID = b.UniprotID

LEFT OUTER JOIN tblGeneOntologyGOTerms f ON f.GOTermID = e.GOTermID

WHERE b.UniprotID LIKE '%MOUSE'

ORDER BY a.Gene