## Incorporate IUPAC, InChl, and SMILES keys into Ingalls Standards csv.

Ingalls_Lab_Standards_AllPubChem <- Ingalls_Lab_Standards_ChEBI %>%
  left_join(Full_PubChem) %>% 
  unique() %>%
  mutate(IUPAC_Code = ifelse(is.na(IUPAC_Code)==TRUE & is.na(IUPAC.Name)==FALSE, IUPAC.Name,
                         ifelse(is.na(IUPAC_Code)==FALSE & is.na(IUPAC.Name)==TRUE, IUPAC_Code,
                                ifelse(IUPAC.Name == IUPAC_Code, IUPAC_Code, IUPAC_Code)))) %>%
  mutate(InChI_Key_Code = ifelse(is.na(InChI_Key_Code)==TRUE & is.na(InChI.Key.Name)==FALSE, InChI.Key.Name,
                             ifelse(is.na(InChI_Key_Code)==FALSE & is.na(InChI.Key.Name)==TRUE, InChI_Key_Code,
                                    ifelse(InChI.Key.Name == InChI_Key_Code, InChI_Key_Code, InChI_Key_Code)))) %>%
  mutate(Canon_SMILES_Code = ifelse(is.na(Canon_SMILES_Code)==TRUE & is.na(Canon.SMILES.Name)==FALSE, Canon.SMILES.Name,
                                 ifelse(is.na(Canon_SMILES_Code)==FALSE & is.na(Canon.SMILES.Name)==TRUE, Canon_SMILES_Code, 
                                        ifelse(Canon.SMILES.Name == Canon_SMILES_Code, Canon_SMILES_Code, Canon_SMILES_Code)))) %>%
  select(-c("IUPAC.Name", "InChI.Key.Name", "Canon.SMILES.Name"))
