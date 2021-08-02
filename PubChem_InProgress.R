# grabPubChem <- function(compound_id) {
#   if(is.na(compound_id)) {
#     return(NA)
#   }
#   PubChem <- compound_id %>%
#     paste0("http://rest.kegg.jp/get/", .) %>%
#     GET() %>%
#     content() %>%
#     as.character() %>%
#     strsplit(., "\\n") %>%
#     unlist() %>%
#     grep(pattern = "PubChem:", value = TRUE) %>%
#     gsub(pattern = " *PubChem: ", replacement = "")# %>%
#     #gsub(pattern = " .*", replacement = "")
#   if(length(PubChem) == 0){
#     return(NA)
#   }
#   return(PubChem)
# }
#Latest.PubChem <- sapply(unique(TestRun$C0), grabPubChem)
#names(Latest.PubChem)[which(is.na(names(Latest.PubChem)))] <- "NA"
#New_Columns <- data.frame(Latest.ChEBI) %>%
  #data.frame(Latest.PubChem) %>%