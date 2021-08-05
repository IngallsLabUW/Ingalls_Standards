## Script to update KEGG codes and names
All_KEGG_IDs <- All_KEGG_IDs %>%
  rename(KEGG_Code = cmpd)

## Import standards and isolate compound names, drop internal standards that have no KEGG ID.
Standards_NoInt <- Ingalls_Lab_Standards_SQL %>%
  rename(KEGG_Code = C0) %>%
  select(Compound.Type, Compound.Name, KEGG_Code) %>%
  unique() %>%
  filter(!str_detect(Compound.Type, "Internal"))

## Check and match most of the standards
Potential_Matches <- All_KEGG_IDs %>%
  separate_rows(name, sep = ";") %>%
  mutate(name = str_trim(name, side = "both")) %>%
  filter(str_detect(name, str_c(Standards_NoInt$Compound.Name, collapse = "|"))) 

## Create TRUE/FALSE check for which standards have been matched with a KEGG compound
Binary_Check <- do.call(rbind.data.frame,
             lapply(unique(Standards_NoInt$Compound.Name),
                    function(i){
                      output <- i %in% Potential_Matches$name
                      return(output)})) %>%
  rename(Has_KEGG_Match = 1)

## Isolate names to add to the binary matches
Standards_Names <- do.call(rbind.data.frame,
             lapply(unique(Standards_NoInt$Compound.Name),
                    function(i){
                      name <- i
                      return(name)})) %>%
  rename(Compound.Name = 1)

## Combine names and binary checks, and add standards with old and new names/IDs
## Check for changes since the latest KEGG download.
Full_Match_Check <- Binary_Check %>% 
  cbind(Standards_Names) %>%
  left_join(Standards_NoInt %>% select(Compound.Name, KEGG_Code)) %>%
  rename(Standards_KEGG_Code = KEGG_Code) %>%
  left_join(Potential_Matches %>% rename(Compound.Name = name)) %>%
  mutate(Same_KEGG_Code = ifelse(Standards_KEGG_Code != KEGG_Code, FALSE, TRUE)) 

Changed_Code <- which(Full_Match_Check$Same_KEGG_Code == FALSE)

## Manually fix incorrect KEGG codes that can't be automated.
## Update the KEGGNAME column so 
Ingalls_Lab_Standards_KEGG <- Ingalls_Lab_Standards_SQL %>%
  rename(KEGG_Code = C0) %>%
  mutate(KEGG_Code = ifelse(Compound.Name == "Cys-Gly, oxidized", "cpd:C01419", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "2-keto-4-methylthiobutyric acid", "cpd:C01180", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Ophthalmic acid", "cpd:C21016", KEGG_Code), 
         KEGG_Code = ifelse(Compound.Name == "Malic acid", "cpd:C00149", KEGG_Code), 
         KEGG_Code = ifelse(Compound.Name == "Threonic acid", "cpd:C01620", KEGG_Code), 
         KEGG_Code = ifelse(Compound.Name == "Methylphosphonic acid", "cpd:C20396", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "3-Phosphoglycerate", "cpd:C00597", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "(R)-2,3-Dihydroxypropane-1-sulfonate", "cpd:C19675", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Caffeic acid", "cpd:C01197", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "beta-Cyclocitral", "cpd:C20425", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Camalexin", "cpd:C21721", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "N-(4-Coumaroyl)-L-homoserine lactone", "cpd:C20677", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "N-(3-Oxohexanoyl)homoserine lactone", "cpd:C11839", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "N-(3-Oxooctanoyl)homoserine lactone", "cpd:C11841", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "2-(3,5-Dichlorophenylcarbamoyl)-1,2-dimethylcyclopropane-1-carboxylic acid", "cpd:C15249", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "5-(2-Hydroxyethyl)-4-methylthiazole", "cpd:C04294", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Monesin", "cpd:C06693", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "2-Heptyl-4(1H)-quinolone", "cpd:C20643", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Butyrylcarnitine", "cpd:C02862", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "beta-Ionine", "cpd:C12287", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Methyl indole-3-acetate", "cpd:C20635", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "Coenzyme Q1", "cpd:C00399", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "D-Glucosamine", "cpd:C00329", KEGG_Code),
         KEGG_Code = ifelse(Compound.Name == "3-Sulfolactate", "cpd:C16069", KEGG_Code)) %>%
  mutate(Compound.Name = ifelse(Compound.Name == "beta-Ionine", "beta-Ionone", Compound.Name)) %>%
  left_join(All_KEGG_IDs, by = "KEGG_Code") %>%
  select(-KEGGNAME) %>%
  rename(KEGG_Names = name)
 
 