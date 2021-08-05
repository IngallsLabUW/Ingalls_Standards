# Script for updating ChEBI column.

## Combine with the full standards frame
Complete_ChEBI <- Ingalls_Lab_Standards_KEGG %>%
  left_join(Full_ChEBI) %>%
  select(Compound.Type:KEGG_Code, ChEBI, ChEBI_Code, everything())

## Quick check to see any differences between latest download and standards sheet.
ChEBI_Match_Check <- Complete_ChEBI %>% 
  mutate(ChEBI_Code = ifelse(is.na(ChEBI_Code)==TRUE & is.na(ChEBI)==FALSE, ChEBI,
                             ifelse(is.na(ChEBI_Code)==FALSE & is.na(ChEBI)==TRUE, ChEBI_Code,
                                    ifelse(ChEBI == ChEBI_Code, ChEBI_Code, ChEBI_Code))))
  
# Add to full standards
Ingalls_Lab_Standards_ChEBI <- ChEBI_Match_Check %>%
  select(-ChEBI)