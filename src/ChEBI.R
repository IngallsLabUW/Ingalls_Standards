# Script for updating ChEBI column.


if (identical(Full_ChEBI[["ChEBI"]], Full_ChEBI[["ChEBI_Names"]]) == TRUE) {
  print("Old ChEBI is equal to new ChEBI, no changes since last update.")
} else {
  print(which(Full_ChEBI$CHEBI != Full_ChEBI$ChEBI_Names))
  message("There are updated ChEBI IDs! Check the printed row numbers above.")
}

# Add to full standards
Ingalls_Lab_Standards_ChEBI <- Full_ChEBI %>%
  unique() %>%
  #rename(ChEBI = ChEBI_Names) %>% 
  select(Compound.Type, Column, Compound.Name, Compound.Name_old, Compound.Name_figure,
         QE.LinRange:z, C0, CHEBI, Fraction1:KEGGNAME, everything())
