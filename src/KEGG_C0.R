## Will's code
#########################################################
library(data.table)
library(httr)
library(tidyverse)

## Load pre-saved KEGG scrape and drop all brackets
all_kegg_IDs <- read.csv("data_extra/Kegg_C0_info.csv") %>%
  rename(C0 = cmpd)
all_kegg_IDs$name <- gsub("\\[|\\]", "", all_kegg_IDs$name)

# Import standards and isolate compound names
standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Type, Compound.Name, C0) %>%
  unique()


## Seems like it should be working but has way too many matches.
all_potential_matches <- all_kegg_IDs %>%
  filter(str_detect(all_kegg_IDs$name, str_c(standards$Compound.Name, collapse="|"))) %>%
  separate_rows(name, sep = ";")
all_potential_matches$name <- trimws(all_potential_matches$name, which = c("both"))

# Check this output. Check how many FALSEs there are
standards$Compound.Name %in% all_potential_matches$name

# Everything in the "test" value is a standard and can be given the gold.
test <- all_potential_matches %>%
  filter(name %in% standards$Compound.Name)

missing_values <- anti_join(standards, test) %>%
  filter(Compound.Type != "Internal Standard")

## Match only to first kegg ID, which semi-works but misses compounds and makes some strange matches.
first_kegg_ID <- all_kegg_IDs %>%
  mutate(name = gsub("\\;.*", "", name))

first_kegg_match <- first_kegg_ID %>%
  filter(str_detect(first_kegg_ID$name, str_c(standards$Compound.Name, collapse="|")))


standards4join <- standards %>%
  rename(name = Compound.Name) %>%
  
  
test <- first_kegg_match %>%
  left_join(standards4join)

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
