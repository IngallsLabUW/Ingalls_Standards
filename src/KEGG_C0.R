## Will's code
#########################################################
library(data.table)
library(httr)
library(tidyverse)

## Load pre-saved KEGG scrape and drop all brackets
all_kegg_IDs <- read.csv("data_extra/Kegg_C0_info.csv") %>%
  rename(C0 = cmpd)
all_kegg_IDs$name <- gsub("\\[|\\]", "", all_kegg_IDs$name) # remove brackets

# Import standards and isolate compound names, drop internal standards that have no KEGG ID.
standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Type, Compound.Name, C0) %>%
  unique() %>%
  filter(!str_detect(Compound.Type, "Internal"))

## Mostly working but isn't getting everything
all_potential_matches <- all_kegg_IDs %>%
  separate_rows(name, sep = ";")
all_potential_matches$name <- trimws(all_potential_matches$name, which = c("both"))
all_potential_matches <- all_potential_matches %>%
  filter(str_detect(all_potential_matches$name, str_c(standards$Compound.Name, collapse="|"))) 

Match_Check <- do.call(rbind.data.frame,
             lapply(unique(standards$Compound.Name),
                    function(i){
                      output <- print(i %in% all_potential_matches$name)
                      return(output)})) %>%
  rename(Has_Match = 1)

Name_Check <- do.call(rbind.data.frame,
             lapply(unique(standards$Compound.Name),
                    function(i){
                      name <- print(i)
                      return(name)})) %>%
  rename(Compound.Name = 1)

check <- Match_Check %>% 
  cbind(Name_Check) %>%
  filter(Has_Match == FALSE) %>%
  left_join(standards %>% select(Compound.Name, C0)) %>%
  rename(Standards_C0 = C0) 


# Everything in the "test" value is a standard and can be given the gold.
test <- all_potential_matches %>%
  filter(name %in% standards$Compound.Name)

missing_values <- anti_join(standards, test) %>%
  filter(Compound.Type != "Internal Standard")


### OTHER OPTIONS

## Pull down data from KEGG (try not to run too often or it crashes)
# path <- "http://rest.kegg.jp/list/compound"
# raw_content <- GET(url = path) %>%
#   content()
# all_kegg_IDs <- read.csv(text = gsub("\t\n", "", raw_content), sep = "\t", 
#               header = FALSE, col.names = c("cmpd", "name"))


## Attempted loop.

## For individual standards, one at a time
single_compound <- all_kegg_IDs[all_kegg_IDs[["name"]] %like% "Choline", ]
kegg_short <- all_kegg_IDs[1:100, ]
for(i in standards_names_only) {
  print(kegg_short[kegg_short[["name"]] %like% i, ])
}

## Same as above but looped. Seems to missing a lot.
kegg_matches <- do.call(rbind.data.frame, lapply(unique(standards$Compound.Name), function(i) {
  test <- kegg_short[kegg_short[["name"]] %like% i, ]
  return(test)
}))

#standards_names_only <- standards[["Compound.Name"]]


##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))
