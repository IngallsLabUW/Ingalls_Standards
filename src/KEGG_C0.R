library(data.table)
library(httr)
library(tidyverse)

## Load pre-saved KEGG scrape and drop all brackets
all_kegg_IDs <- read.csv("data_extra/Kegg_C0_info.csv") %>%
  rename(C0 = cmpd)

# Import standards and isolate compound names, drop internal standards that have no KEGG ID.
standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Type, Compound.Name, C0) %>%
  unique() %>%
  filter(!str_detect(Compound.Type, "Internal"))

# Checks and matches most of the standards
all_potential_matches <- all_kegg_IDs %>%
  separate_rows(name, sep = ";")
all_potential_matches$name <- trimws(all_potential_matches$name, which = c("both"))
all_potential_matches <- all_potential_matches %>%
  filter(str_detect(all_potential_matches$name, str_c(standards$Compound.Name, collapse="|"))) 

# Identify which standards have been matched with a KEGG compound
Match_Check <- do.call(rbind.data.frame,
             lapply(unique(standards$Compound.Name),
                    function(i){
                      output <- print(i %in% all_potential_matches$name)
                      return(output)})) %>%
  rename(Has_KEGG_Match = 1)

# Add names to the matches
Name_Check <- do.call(rbind.data.frame,
             lapply(unique(standards$Compound.Name),
                    function(i){
                      name <- print(i)
                      return(name)})) %>%
  rename(Compound.Name = 1)

# Combine matches with old and new names/IDs
Mid_Check <- Match_Check %>% 
  cbind(Name_Check) %>%
  left_join(standards %>% select(Compound.Name, C0)) %>%
  rename(Standards_C0 = C0)

# Compare any upated C0s from latest kegg download
Full_Check <- Mid_Check %>%
  left_join(all_potential_matches %>% rename(Compound.Name = name)) %>%
  mutate(Same_C0 = ifelse(Standards_C0 != C0, FALSE, TRUE)) %>%
  filter(is.na(Same_C0) | Same_C0 == FALSE)


## Pull down data from KEGG (try not to run too often or it crashes)
# path <- "http://rest.kegg.jp/list/compound"
# raw_content <- GET(url = path) %>%
#   content()
# all_kegg_IDs <- read.csv(text = gsub("\t\n", "", raw_content), sep = "\t", 
#               header = FALSE, col.names = c("cmpd", "name"))


##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))
