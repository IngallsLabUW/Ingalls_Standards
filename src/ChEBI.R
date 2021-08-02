# Script for updating ChEBI column.

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
    trimws(which = "both")
  ChEBI <- sub("^(\\S*\\s+\\S+).*", "\\1", ChEBI)
  ChEBI <- gsub( " ", "", ChEBI) 
  if(length(ChEBI) == 0) {
    return(NA)
  }
  return(ChEBI)
}

# Load the latest ChEBI scrape if you don't want to run the whole function.
# Latest_ChEBI <- read.csv("data_extra/ChEBI_Download_28-Jul-2021.csv")

# Reassign the FigNames standards from the Figure_Names.R script
All_Standards <- Ingalls_Lab_Standards_KEGG
All_Standards$CHEBI <- gsub("CHEBI", "ChEBI", All_Standards$CHEBI)

# Apply the ChEBI retrieval function to the standards list
ChEBI_Names <- sapply(unique(All_Standards$C0), grabChEBI)
names(ChEBI_Names)[which(is.na(names(ChEBI_Names)))] <- "NA"

# Compare old and new ChEBI values
Latest_ChEBI <- data.frame(ChEBI_Names) %>%
  drop_na() %>%
  rownames_to_column(var = "C0")

Full_ChEBI <- All_Standards %>%
  left_join(Latest_ChEBI) 

# Write the latest download here if you want to save it.
# Last_ChEBI_Download <- data.frame(New_Columns)
# write.csv(Last_ChEBI_Download, paste0("data_extra/ChEBI_Download_",
#                                       format(Sys.time(), "%d-%b-%Y"), ".csv"),
#           row.names = FALSE)


if (identical(Full_ChEBI[["ChEBI"]], Full_ChEBI[["ChEBI_Names"]]) == TRUE) {
  print("Old ChEBI is equal to new ChEBI, no changes since last update.")
} else {
  print(which(Full_ChEBI$CHEBI != Full_ChEBI$ChEBI_Names))
  message("There are updated ChEBI IDs! Check the printed row numbers above.")
}

# Add to full standards
Ingalls_Lab_Standards_ChEBI <- Full_ChEBI %>%
  unique() %>%
  rename(ChEBI = ChEBI_Names) %>% 
  select(Compound.Type, Column, Compound.Name, Compound.Name_old, Compound.Name_figure,
         QE.LinRange:z, C0, ChEBI, Fraction1:KEGGNAME, everything())
