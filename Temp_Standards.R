## Temp script for producing a test Ingalls_Standards_Sheet.csv
library(tidyverse)

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

# Import standards
Ingalls_Lab_Standards_NEW <- read.csv("Ingalls_Lab_Standards.csv") 

## Slice to 10 rows for mini example.
Ingalls_Lab_Standards_NEW <- Ingalls_Lab_Standards_NEW %>%
  slice(1:10)

## New column names and order!
# Check new order. Does it make sense?
# Dropped all "QE" and "TQS" columns like RSD, LinRange, Ratio.
Ingalls_Lab_Standards_NEW <- Ingalls_Lab_Standards_NEW %>%
  select(Compound.Name, m.z, RT..min., z, Column, HILICMix,
         Conc..uM, ionization_form, Liquid.Fraction, 
         Compound.Type, Emperical.Formula, 
         C0, KEGGNAME, #ChEBI, 
         IUPAC.Name, InChI.Key.Name, Canon.SMILES.Name, Classyfire,
         Compound.Name_old, Compound.Name_figure, Compound.Name_SQL,
         Date.added, Priority)

## Rename columns! 
# Note the renamed "old" to "original".
Ingalls_Lab_Standards_NEW <- Ingalls_Lab_Standards_NEW %>%
  rename(Compound_Name = Compound.Name,
         mz = m.z,
         RT_minute = RT..min.,
         HILIC_Mix = HILICMix,
         Concentration_uM = Conc..uM,
         Ionization_Form = ionization_form,
         Compound_Type = Compound.Type,
         Empirical_Formula = Emperical.Formula,
         Liquid_Fraction = Liquid.Fraction,
         Emperical_Formula = Emperical.Formula,
         KEGG_ID = C0,
         KEGG_Name = KEGGNAME,
         #ChEBI_ID = ChEBI,
         IUPAC_Name = IUPAC.Name,
         InCHI_Key_Name = InChI.Key.Name,
         Canon_SMILES_Name = Canon.SMILES.Name,
         Compound_Name_Original = Compound.Name_old,
         Compound_Name_Figure = Compound.Name_figure,
         Compound_Name_SQL = Compound.Name_SQL,
         Date_Added = Date.added)

## Small changes
# Drop the "CHEBI:" prefix in the chebi column, and the "cpd:" in the KEGG_ID column
#Ingalls_Lab_Standards_NEW$ChEBI_ID <- gsub("CHEBI:", "", Ingalls_Lab_Standards_NEW$ChEBI_ID) 
Ingalls_Lab_Standards_NEW$KEGG_ID <- gsub("cpd:", "", Ingalls_Lab_Standards_NEW$KEGG_ID)

# Apply the ChEBI and PubChem retrieval functions to the standards list
ChEBI_ID <- sapply(unique(Ingalls_Lab_Standards_NEW$KEGG_ID), grabChEBI)
PubChem_ID <- sapply(unique(Ingalls_Lab_Standards_NEW$KEGG_ID), grabPubChem)

# Replace NAs with character values
names(ChEBI_ID)[which(is.na(names(ChEBI_ID)))] <- "NA"
names(PubChem_ID)[which(is.na(names(PubChem_ID)))] <- "NA"

# Compare old and new ChEBI and PubChem vaues
New_Columns <- data.frame(ChEBI_ID) %>%
  data.frame(PubChem_ID) %>%
  rownames_to_column(var = "KEGG_ID") %>%
  left_join(Ingalls_Lab_Standards_NEW, by = "KEGG_ID") %>%
  select(Compound_Name:Emperical_Formula, KEGG_ID, KEGG_Name, ChEBI_ID, PubChem_ID, everything()) %>%
  unique()
