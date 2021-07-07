## Incorporate IUPAC, InChl, and SMILES keys into Ingalls Standards csv.
library(httr)
library(tidyverse)
# could modify the path with a loop using the chemical formulas


standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Name) %>%
  unique %>%
  slice(1:3)
standards <- standards[["Compound.Name"]]

for (i in standards) {
  path <- paste("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", i, "/property/Title,MolecularFormula,inchikey,CanonicalSMILES,IUPACName/CSV", sep = "")
  print(path)
  
  r <- GET(url = path) 
  status_code(r)
  content(r)
  mydata <- read.csv(text = gsub("\t\n", "", r), sep = ",",
                     header = TRUE)
}

httr::set_config(httr::config(http_version = 0))
datalist = list()

for (i in standards) {
  path <- paste("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", i, "/property/Title,MolecularFormula,inchikey,CanonicalSMILES,IUPACName/CSV", sep = "")
  print(path)
  
  r <- GET(url = path) 
  status_code(r)
  content(r)
  dat <- read.csv(text = gsub("\t\n", "", r), sep = ",",
                     header = TRUE)
  datalist[[i]] <- dat # add it to your list
}

big_data = do.call(rbind, datalist)

compound.name <- "L-Methionine"

path <- paste("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", compound.name, "/property/Title,MolecularFormula,inchikey,CanonicalSMILES,IUPACName/CSV", sep = "")

r <- GET(url = path) 
status_code(r)
content(r)
mydata <- read.csv(text = gsub("\t\n", "", r), sep = ",",
              header = TRUE)




All_Standards <- Ingalls_Lab_Standards_ChEBI

IUPAC.InChl.SMILES <- read.csv("data_extra/Ingalls_Lab_Standards_Alt_Names.csv") %>%
  select(Column, Compound.Name, IUPAC.Name, InChI.Key.Name, Canon.SMILES.Name) %>%
  mutate_if(is.character, list(~na_if(., ""))) %>%
  #group_by(Column, Compound.Name) %>%
  left_join(All_Standards, by = c("Compound.Name", "Column")) %>%
  unique()


Ingalls_Lab_Standards_IUPAC.InCHI.SMILES <- IUPAC.InChl.SMILES