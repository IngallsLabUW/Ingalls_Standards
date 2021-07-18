# Script for updating ChEBI and PubChem columns.

grabChEBI <- function(compound_id) {
  # Accepts a KEGG ID (format cpd:C[number]) and returns
  # the ChEBI id found on the KEGG webpage. If there are multiple, return the
  # first one. If not found, return NA.
  if(is.na(compound_id)) {
    return(NA)
  }
  ChEBI <- compound_id %>%
    paste0("http://rest.kegg.jp/get/", .) %>%
    GET() %>%
    content() %>%
    as.character() %>%
    strsplit(., "\\n") %>%
    unlist() %>%
    grep(pattern = "ChEBI", value = TRUE) %>%
    gsub(pattern = " *ChEBI: ", replacement = "") %>%
    gsub(pattern = " .*", replacement = "")
  if(length(ChEBI) == 0) {
    return(NA)
  }
  return(ChEBI)
}

grabPubChem <- function(compound_id) {
  if(is.na(compound_id)) {
    return(NA)
  }
  PubChem <- compound_id %>%
    paste0("http://rest.kegg.jp/get/", .) %>%
    GET() %>%
    content() %>%
    as.character() %>%
    strsplit(., "\\n") %>%
    unlist() %>%
    grep(pattern = "PubChem", value = TRUE) %>%
    gsub(pattern = " *PubChem: ", replacement = "") %>%
    gsub(pattern = " .*", replacement = "")
  if(length(PubChem) == 0){
    return(NA)
  }
  return(PubChem)
}

# Reassign the FigNames standards from the Figure_Names.R script
All_Standards <- Ingalls_Lab_Standards_FigNames

#####################
## TESTRUN for fine-tuning functions
TestRun <- Ingalls_Lab_Standards_NEW
#####################

# Apply the ChEBI and PubChem retrieval functions to the standards list
Latest.ChEBI <- sapply(unique(TestRun$C0), grabChEBI)
Latest.PubChem <- sapply(unique(TestRun$C0), grabPubChem)

# Replace NAs with character values
names(Latest.ChEBI)[which(is.na(names(Latest.ChEBI)))] <- "NA"
names(Latest.PubChem)[which(is.na(names(Latest.PubChem)))] <- "NA"

# Compare old and new ChEBI and PubChem vaues
New_Columns <- data.frame(Latest.ChEBI) %>%
  data.frame(Latest.PubChem) %>%
  rownames_to_column(var = "C0") %>%
  left_join(All_Standards, by = "C0") %>%
  mutate_all(~gsub("CHEBI:", "", .)) %>%
  select(C0, Compound.Name, Latest.ChEBI, Latest.PubChem, CHEBI) %>%
  unique()

if (New_Columns$Latest.ChEBI == New_Columns$CHEBI) {
  print("Old ChEBI is equal to new ChEBI, no changes since last update.")
} else {
  print(paste("Changes have been made! Compound:", New_Columns$Compound.Name,
              ", Old ChEBI:", New_Columns$CHEBI,
              ", New ChEBI:", New_Columns$Latest.ChEBI))
  stop()
}


# Add to full standards
Ingalls_Lab_Standards_ChEBI <- New_Columns %>%
  full_join(Ingalls_Lab_Standards_FigNames) %>%
  unique() %>%
  rename(ChEBI = Latest.ChEBI) %>% 
  select(Compound.Type, Column, Compound.Name, Compound.Name_old, Compound.Name_figure,
         QE.LinRange:z, C0, ChEBI, Fraction1:KEGGNAME, everything())
