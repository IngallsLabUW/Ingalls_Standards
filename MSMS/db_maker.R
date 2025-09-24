
library(tidyverse)
library(DBI)

stans_fixed <- read_csv("MSMS/stans_fixed.csv")
best_frags <- read_csv("MSMS/best_frags.csv")

# Need to build 4 tables corresponding to dbListTables(dbcon)
# CompoundTable contains info about the individual compounds
# SpectrumTable contains a combined spectrum for each compound, linked by CompoundId
# MaintenanceTable is empty??
# HeaderTable records version and afaics is always the same
buildCompoundTable <- function(stans){
  data.frame(CompoundId=stans$CompoundId,
             Formula=stans$formula,
             Name=stans$compound_name,
             Synonyms="", Tag="", Sequence="", CASId="", ChemSpiderId="", HMDBId="", KEGGId="", PubChemId="", 
             Structure="", mzCloudId=NA_integer_, CompoundClass="", SmilesDescription="", InChiKey="",
             check.names = FALSE)
}

# stans_fixed %>%
#   separate_rows(formula, sep = "(?=[[:upper:]]|\\+|\\-)") %>%
#   filter(formula!="") %>%
#   mutate(count=as.numeric(str_extract(formula, "\\d+$"))) %>%
#   mutate(count=ifelse(is.na(count), 1, count)) %>%
#   mutate(element=str_remove(formula, "\\d+$")) %>%
#   mutate(count=case_when(
#     best_adduct=="[M+H]+" & element=="H"~element+1,
#     best_adduct=="[M-H]-" & element=="H"~element-1,
#     best_adduct=="[M]-" & element=="-"~element+1,
#     best_adduct=="[M]+" & element=="+"~element+1,
#   )) %>%
#   summarise(formula=paste0(element, count, collapse = ""),
#             .by=c(compound_name, polarity))
outCompoundTable <- stans_fixed %>%
  mutate(formula=ifelse(str_detect(formula, "\\+$"), paste0("[", str_remove(formula, "\\+$"), "]+"), formula)) %>%
  mutate(formula=ifelse(str_detect(formula, "\\-$"), paste0("[", str_remove(formula, "\\-$"), "]-"), formula)) %>%
  mutate(formula=str_replace(formula, "N\\(15\\)", "\\[15\\]N")) %>%
  mutate(formula=str_replace(formula, "C\\(13\\)", "\\[13\\]C")) %>%
  mutate(formula=str_replace(formula, "H\\(2\\)", "\\[2\\]H")) %>%
  mutate(CompoundId=row_number()) %>%
  buildCompoundTable()

mzVaultEncode <- function(num_vec){
  blob::blob(writeBin(num_vec, raw(), size = 8, endian = "little"))
}
buildSpectrumTable <- function(scan_stuff){
  scan_stuff %>%
    summarise(RetentionTime=mean(rt), ScanNumber=min(first_scan), PrecursorMass=mean(med_premz), 
              blobMass=mzVaultEncode(med_fragmz), blobIntensity=mzVaultEncode(med_int), 
              .by = c(compound_name, Polarity, CompoundId)) %>%
    mutate(SpectrumId=row_number(), mzCloudURL="", ScanFilter="", NeutralMass=0,
           CollisionEnergy="70.00", FragmentationMode="HCD", IonizationMode="ESI",
           MassAnalyzer="", InstrumentName="Orbitrap Astral OA10249", InstrumentOperator="Ingalls Lab",
           RawFileURL="C:\\Users\\Ingalls Lab\\Desktop\\MATBD_comp_CD\\250625_Std_4uMStdsMix2InH2O_pos1.raw",
           blobAccuracy="", blobResolution="", blobNoises="", blobFlags="", blobTopPeaks="",
           Version=5L, CreationDate=format(Sys.time(), "%m/%d/%Y %H:%M:%S"), Curator="", CurationType="Averaged",
           PrecursorIonType="", Accession="") %>%
    # Reorder in the correct order in case that matters
    select("SpectrumId", "CompoundId", "mzCloudURL", "ScanFilter", "RetentionTime", 
           "ScanNumber", "PrecursorMass", "NeutralMass", "CollisionEnergy", 
           "Polarity", "FragmentationMode", "IonizationMode", "MassAnalyzer", 
           "InstrumentName", "InstrumentOperator", "RawFileURL", "blobMass", 
           "blobIntensity", "blobAccuracy", "blobResolution", "blobNoises", 
           "blobFlags", "blobTopPeaks", "Version", "CreationDate", "Curator", 
           "CurationType", "PrecursorIonType", "Accession")
}
outSpectrumTable <- best_frags %>%
  mutate(Polarity=ifelse(polarity=="pos", "+", "-")) %>%
  mutate(rt=(rtmin+rtmax)/2) %>%
  select(compound_name, Polarity, rt, first_scan, med_premz=mz, med_fragmz=fragmz, med_int=int) %>%
  left_join(outCompoundTable %>% distinct(compound_name=Name, CompoundId)) %>%
  buildSpectrumTable()

outMaintenanceTable <- data.frame(
  CreationDate=character(0), NoofCompoundsModified=numeric(0), Description=character(0)
)
outHeaderTable <- data.frame(
  version=5L, CreationDate=NA_character_, LastModifiedDate=NA_character_, Description=NA_character_, 
  Company=NA_character_, ReadOnly=NA_real_, UserAccess=NA_character_, PartialEdits=NA_real_
)

# Write out to new database
# Schema have been stolen from a random existing database
out_db_name <- "MSMS/ingalls_mzvault_70CE.db"
if(file.exists(out_db_name)){
  unlink(out_db_name)
}

writecon <- dbConnect(RSQLite::SQLite(), out_db_name)

create_cmpd <- "CREATE TABLE CompoundTable (CompoundId INTEGER PRIMARY KEY, Formula TEXT, Name TEXT, Synonyms BLOB_TEXT, Tag TEXT, Sequence TEXT, CASId TEXT, ChemSpiderId TEXT, HMDBId TEXT, KEGGId TEXT, PubChemId TEXT, Structure BLOB_TEXT, mzCloudId INTEGER, CompoundClass TEXT, SmilesDescription TEXT, InChiKey TEXT )"
dbExecute(writecon, create_cmpd)
dbAppendTable(writecon, "CompoundTable", outCompoundTable)

create_head <- "CREATE TABLE HeaderTable (version INTEGER, CreationDate TEXT, LastModifiedDate TEXT, Description TEXT, Company TEXT, ReadOnly BOOL, UserAccess TEXT, PartialEdits BOOL)"
dbExecute(writecon, create_head)
dbAppendTable(writecon, "HeaderTable", outHeaderTable)

create_maint <- "CREATE TABLE MaintenanceTable (CreationDate TEXT, NoofCompoundsModified INTEGER, Description TEXT)"
dbExecute(writecon, create_maint)
dbAppendTable(writecon, "MaintenanceTable", outMaintenanceTable)

create_maint <- "CREATE TABLE SpectrumTable (SpectrumId INTEGER PRIMARY KEY, CompoundId INTEGER, mzCloudURL TEXT, ScanFilter TEXT, RetentionTime DOUBLE, ScanNumber INTEGER, PrecursorMass DOUBLE, NeutralMass DOUBLE, CollisionEnergy TEXT, Polarity TEXT, FragmentationMode TEXT, IonizationMode TEXT, MassAnalyzer TEXT, InstrumentName TEXT, InstrumentOperator TEXT, RawFileURL TEXT, blobMass BLOB, blobIntensity BLOB, blobAccuracy BLOB, blobResolution BLOB, blobNoises BLOB, blobFlags BLOB, blobTopPeaks BLOB, Version INTEGER, CreationDate TEXT, Curator TEXT, CurationType , PrecursorIonType TEXT, Accession TEXT)"
dbExecute(writecon, create_maint)
dbAppendTable(writecon, "SpectrumTable", outSpectrumTable)

dbDisconnect(writecon)
