current_sheet <- read.csv("Ingalls_Lab_Standards.csv")

columns_to_split <- c("KEGG_Names", "ChEBI_Code", "IUPAC_Code", 
                      "InChI_Key_Code", "Canon_SMILES_Code", "Classyfire", 
                      "Compound_Name_SQL")

supplement_sheet <- current_sheet[,c("Compound_Name", columns_to_split)]
supplement_sheet <- supplement_sheet[!duplicated(supplement_sheet),]
new_sheet <- current_sheet[,!names(current_sheet)%in%columns_to_split]

write.csv(new_sheet, "Ingalls_Lab_Standards.csv", row.names = FALSE)
write.csv(supplement_sheet, "data_extra/Ingalls_Lab_Standards_Supplement.csv")