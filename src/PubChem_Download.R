Standards_Names <- Ingalls_Lab_Standards_ChEBI %>%
  select(Compound.Name) %>%
  unique()
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

All_PubChem_Data = bind_rows(Looped_Names) %>%
  rename(Compound.Name = Title,
         InChI_Key_Code = InChIKey,
         Canon_SMILES_Code = CanonicalSMILES,
         IUPAC_Code = IUPACName,
         PubChem_Code = CID,
         PubChem_Formula = MolecularFormula) %>%
  filter(Compound.Name %in% Ingalls_Lab_Standards_ChEBI$Compound.Name) %>%
  select(PubChem_Code:IUPAC_Code) 
All_PubChem_Data[All_PubChem_Data == ""] <- NA


