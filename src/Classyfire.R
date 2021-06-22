## Classyfire IDs


All_Standards <- Ingalls_Lab_Standards_IUPAC.InCHI.SMILES

Classyfire <- read.csv("data_extra/classyfire_stds.csv") 
Classyfire$Compound.Name <- gsub("_", " ", Classyfire$Compound.Name)

Combined.Classyfire <- Classyfire %>%
  unite(Combined, c("Level", "Classification"), sep = ": ") %>%
  arrange(Compound.Name) %>%
  unique() %>%
  group_by(Compound.Name) %>%
  mutate("Classyfire" = paste(Combined, collapse = "; ")) %>%
  select(-Combined) %>%
  unique() %>%
  as.data.frame()


Ingalls_Lab_Standards_Classyfire <- Ingalls_Lab_Standards %>%
  left_join(Combined.Classyfire, by = "Compound.Name") 
