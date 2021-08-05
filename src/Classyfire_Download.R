## Script to download the latest Classyfire data.
## Remember this script can take hours!! 

Names_for_Classyfire <- Ingalls_Lab_Standards_AllPubChem %>%
  select(Compound.Name, InChI_Key_Code)

Classyfire_Download <- high_class(Names_for_Classyfire) 

Combined_Classyfire <- Classyfire_Download %>%
  unite(Combined, c("Level", "Classification"), sep = ": ") %>%
  arrange(key) %>%
  group_by(key) %>%
  mutate("Classyfire" = paste(Combined, collapse = "; ")) %>%
  select(-Combined, - CHEMONT) %>%
  unique() %>%
  as.data.frame()
