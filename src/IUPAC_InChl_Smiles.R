## Incorporate IUPAC, InChl, and SMILES keys into Ingalls Standards csv.

# could modify the path with a loop using the chemical formulas

path <- "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/1,2,3,4,5/property/MolecularFormula,CanonicalSMILES/CSV"
path <- "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/Acetylcarnitine/property/MolecularFormula,CanonicalSMILES/CSV"

r <- GET(url = path) 
status_code(r)
content(r)

All_Standards <- Ingalls_Lab_Standards_ChEBI

IUPAC.InChl.SMILES <- read.csv("data_extra/Ingalls_Lab_Standards_Alt_Names.csv") %>%
  select(Column, Compound.Name, IUPAC.Name, InChI.Key.Name, Canon.SMILES.Name) %>%
  mutate_if(is.character, list(~na_if(., ""))) %>%
  #group_by(Column, Compound.Name) %>%
  left_join(All_Standards, by = c("Compound.Name", "Column")) %>%
  unique()


Ingalls_Lab_Standards_IUPAC.InCHI.SMILES <- IUPAC.InChl.SMILES