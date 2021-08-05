## Classyfire IDs

Full_Classyfire <- Full_Classyfire %>%
  rename(InChI_Key_Code = key,
         Classyfire_new = Classyfire)

Ingalls_Lab_Standards_Classyfire <- Ingalls_Lab_Standards_AllPubChem %>%
  left_join(Full_Classyfire, by = "InChI_Key_Code") %>%
  mutate(Classyfire = ifelse(is.na(Classyfire_new)==TRUE & is.na(Classyfire)==FALSE, Classyfire,
                             ifelse(is.na(Classyfire_new)==FALSE & is.na(Classyfire)==TRUE, Classyfire_new,
                                    ifelse(Classyfire == Classyfire_new, Classyfire_new, Classyfire_new)))) %>%
  select(-Classyfire_new)
  
