# Script for updating ChEBI column.
Full_ChEBI$ChEBI <- gsub("CHEBI:NA", NA, Full_ChEBI$ChEBI)
Full_ChEBI$ChEBI <- gsub("CHEBI:", "ChEBI:", Full_ChEBI$ChEBI)

## Quick check to see any differences between latest download and standards sheet.
ChEBI_Match_Check <- Full_ChEBI %>% 
  mutate(ChEBI_Code = ifelse(is.na(ChEBI_Code)==TRUE & is.na(ChEBI)==FALSE, ChEBI,
                             ifelse(is.na(ChEBI_Code)==FALSE & is.na(ChEBI)==TRUE, ChEBI_Code,
                                    ifelse(ChEBI == ChEBI_Code, ChEBI_Code, ChEBI_Code))))
  
# Add to full standards
Ingalls_Lab_Standards_ChEBI <- Full_ChEBI %>%
  select(-ChEBI)