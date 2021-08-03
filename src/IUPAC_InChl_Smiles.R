## Incorporate IUPAC, InChl, and SMILES keys into Ingalls Standards csv.
All_Standards <- Ingalls_Lab_Standards_ChEBI

Ingalls_Lab_Standards_AllPubChem <- All_Standards %>%
  left_join(Full_IUPAC) %>% 
  unique()