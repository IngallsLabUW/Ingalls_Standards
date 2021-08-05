## Script for downloading the latest ChEBI codes.

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

## Apply the ChEBI retrieval function to the standards list
ChEBI_Code <- sapply(unique(Ingalls_Lab_Standards_KEGG$KEGG_Code), grabChEBI)
names(ChEBI_Code)[which(is.na(names(ChEBI_Code)))] <- "NA"

## Make dataframe of the latest ChEBI download
Latest_ChEBI_Download <- data.frame(ChEBI_Code) %>%
  drop_na() %>%
  rownames_to_column(var = "KEGG_Code") %>%
  left_join(Ingalls_Lab_Standards_KEGG %>% select(Compound.Name, KEGG_Code)) %>%
  unique()
