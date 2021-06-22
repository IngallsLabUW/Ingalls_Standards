## Incorporate IUPAC, InChl, and SMILES keys into Ingalls Standards csv.

All_Standards <- Ingalls_Lab_Standards_ChEBI

IUPAC.InChl.SMILES <- read.csv("data_extra/Ingalls_Lab_Standards_Alt_Names.csv") %>%
  select(Column, Compound.Name, IUPAC.Name, InChI.Key.Name, Canon.SMILES.Name) %>%
  mutate_if(is.character, list(~na_if(., ""))) %>%
  #group_by(Column, Compound.Name) %>%
  left_join(All_Standards, by = c("Compound.Name", "Column")) %>%
  unique()


Ingalls_Lab_Standards_IUPAC.InCHI.SMILES <- IUPAC.InChl.SMILES