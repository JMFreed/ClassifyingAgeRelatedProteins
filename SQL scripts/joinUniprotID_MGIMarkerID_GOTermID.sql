USE DissertationDB

SELECT DISTINCT

f.UniprotID,
h.UniprotID,
e.MarkerSymbol,
a.MGIMarkerID, 
a.MPID, 
b.MPTerm,
c.GOTermID,
d.GOTermName

FROM MGIMarkerIDXMammalianPhenotypeID a

JOIN MGI_Phenotypes b ON b.MPID = a.MPID

JOIN MGIMarkerXGOTerms c ON c.MGIMarkerAccessionID = a.MGIMarkerID

JOIN tblGeneOntologyGOTerms d ON d.GOTermID = c.GOTermID

JOIN MRK_SwissProt e ON e.MGIMarkerAccessionID = a.MGIMarkerID

JOIN uniprot_mus_musculus f ON f.SwissProtID = e.SwissProtAccessionID

JOIN tblHumanMouseHomologs g ON g.uniprotIDMouse = f.UniprotID

JOIN genage_human h ON h.UniprotID = g.uniprotIDHuman

ORDER BY f.UniprotID