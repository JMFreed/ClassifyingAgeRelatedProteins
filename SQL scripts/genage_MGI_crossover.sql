SELECT DISTINCT a.Gene, b.UniprotID, c.uniprotIDHuman, d.GenAgeID FROM tblMousePrematureAgingGenes a
JOIN tblProteinsXGeneSymbols b ON b.GeneSymbol = a.Gene
LEFT OUTER JOIN tblHumanMouseHomologs c ON c.uniprotIDMouse = b.UniprotID
LEFT OUTER JOIN genage_human d ON d.UniprotID = c.uniprotIDHuman
WHERE b.UniprotID LIKE '%MOUSE'