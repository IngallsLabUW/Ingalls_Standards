## Will's code
#########################################################
library(data.table)
library(httr)
library(tidyverse)

## TODO TALK TO LAURA ABOUT PROPIONYL VS PROPANOYL CO-AS, WHICH ONE IS RIGHT/DO WE NEED TO FIX THAT
## TODO Internal standards don't have C0, this is normal, right?


## Pull down data from KEGG (try not to run too often or it crashes)
# path <- "http://rest.kegg.jp/list/compound"
# raw_content <- GET(url = path) %>%
#   content()
# all_kegg_IDs <- read.csv(text = gsub("\t\n", "", raw_content), sep = "\t", 
#               header = FALSE, col.names = c("cmpd", "name"))

## Load pre-saved KEGG scrape and drop all brackets
all_kegg_IDs <- read.csv("data_extra/Kegg_C0_info.csv") %>%
  rename(C0 = cmpd)
all_kegg_IDs$name <- gsub("\\[|\\]", "", all_kegg_IDs$name)

# Import standards and isolate compound names
standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Name, C0) %>%
  unique() 
standards_names_only <- standards[["Compound.Name"]]


## For individual standards, one at a time
single_compound <- all_kegg_IDs[all_kegg_IDs[["name"]] %like% "Choline", ]

## Attempted loop.
kegg_short <- all_kegg_IDs[1:100, ]
for(i in standards_names_only) {
  print(kegg_short[kegg_short[["name"]] %like% i, ])
}

## Same as above but looped. Seems to missing a lot.
kegg_matches <- do.call(rbind.data.frame, lapply(unique(standards$Compound.Name), function(i) {
  test <- kegg_short[kegg_short[["name"]] %like% i, ]
  return(test)
}))


## Seems like it should be working but has way too many matches.
all_potential_matches <- all_kegg_IDs %>%
  filter(str_detect(all_kegg_IDs$name, str_c(standards$Compound.Name, collapse="|")))

## Match only to first kegg ID, which semi-works but misses compounds and makes some strange matches.
first_kegg_ID <- all_kegg_IDs %>%
  mutate(name = gsub("\\;.*", "", name))

first_kegg_match <- first_kegg_ID %>%
  filter(str_detect(first_kegg_ID$name, str_c(standards$Compound.Name, collapse="|")))




##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))
