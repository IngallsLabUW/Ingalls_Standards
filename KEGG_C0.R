## Will's code
#########################################################
library(tidyverse)
library(data.table)
library(httr)
library(xml2)
library(sjmisc)

## TODO TALK TO LAURA ABOUT PROPIONYL VS PROPANOYL CO-AS, WHICH ONE IS RIGHT/DO WE NEED TO FIX THAT


## Pull down data from KEGG (try not to run too often or it crashes)
# path <- "http://rest.kegg.jp/list/compound"
# raw_content <- GET(url = path) %>%
#   content()
# kegg_content <- read.csv(text = gsub("\t\n", "", raw_content), sep = "\t", 
#               header = FALSE, col.names = c("cmpd", "name"))

kegg_content <- read.csv("data_extra/Kegg_C0_info.csv")

# Import standards and isolate compound names
standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Name, C0) %>%
  unique() 
standards.names <- standards[["Compound.Name"]]


## For individual standards, one at a time
single_compound <- kegg_content[kegg_content[["name"]] %like% "Choline", ]

## Attempt to loop. Sort of works for full list but takes a while
## Can't get it into data frame format
kegg_short <- kegg_content[1:100, ]
for(i in standards.names) {
  print(kegg_short[kegg_short[["name"]] %like% i, ])
}


## This is kind of working but seems to not be catching all of the compounds.
kegg_matches <- do.call(rbind.data.frame,
                        lapply(unique(standards$Compound.Name),
                               function(i) {
                                 test <- kegg_short[kegg_short[["name"]] %like% i, ]
                                 return(test)}))

## Seems like it should be working but has way too many matches.
all_potential_matches <- kegg_content %>%
  filter(str_detect(kegg_content$name, str_c(standards$Compound.Name, collapse="|")))

## Works well, seems to only be missing a few
test_kegg_content <- kegg_content %>%
  mutate(name = gsub("\\;.*", "", name))

test_matches <- test_kegg_content %>%
  filter(str_detect(test_kegg_content$name, str_c(standards$Compound.Name, collapse="|"))) %>%
  rename(C0 = cmpd) 

test_matches$name <- gsub("\\[|\\]", "", test_matches$name)


test_has_match <- semi_join(standards, test_matches, by="C0")
test_no_match <- anti_join(standards, test_matches, by="C0")



##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))
