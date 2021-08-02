## Incorporate IUPAC, InChl, and SMILES keys into Ingalls Standards csv.

## Doing this with one specific compound
# compound.name <- "L-Methionine"
# 
# path <- paste("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", compound.name, 
#               "/property/Title,MolecularFormula,inchikey,CanonicalSMILES,IUPACName/CSV", sep = "")
# 
# r <- GET(url = path) 
# status_code(r)
# content(r)
# mydata <- read.csv(text = gsub("\t\n", "", r), sep = ",",
#                    header = TRUE)

## Loop each standard name to match with a scraped pubchem ID.
Standards_Names <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Name) %>%
  unique() %>%
  slice(1:5)
Standards_Names <- Standards_Names[["Compound.Name"]]

httr::set_config(httr::config(http_version = 0))
Looped_Names = list()

for (i in Standards_Names) {
  path <- paste("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", i, 
                "/property/Title,MolecularFormula,inchikey,CanonicalSMILES,IUPACName/CSV", sep = "")
  print(path)
  
  r <- GET(url = path)
  Sys.sleep(1)
  status_code(r)
  content(r)
  names <- read.csv(text = gsub("\t\n", "", r), sep = ",",
                     header = TRUE)
  Looped_Names[[i]] <- names 
}

IUPAC_InCHI_SMILES = do.call(rbind, Looped_Names) %>%
  rownames_to_column(var = "Compound.Name")


All_Standards <- Ingalls_Lab_Standards_ChEBI

Ingalls_Lab_Standards_IUPAC.InCHI.SMILES <- All_Standards %>%
  #select(Column, Compound.Name, IUPAC.Name, InChI.Key.Name, Canon.SMILES.Name) %>%
  #mutate_if(is.character, list(~na_if(., ""))) %>%
  #group_by(Column, Compound.Name) %>%
  left_join(IUPAC_InCHI_SMILES) %>% #, by = c("Compound.Name", "Column")) %>%
  unique()


Ingalls_Lab_Standards_IUPAC.InCHI.SMILES <- IUPAC.InChl.SMILES