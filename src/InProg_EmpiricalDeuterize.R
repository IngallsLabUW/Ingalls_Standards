
## Save original empirical formula columns to the "archive data" sheet. 
Auxilary_Columns <- read.csv("data_old/Ingalls_Lab_Standards_AuxColumns.csv") 



## New column order 
# Dropped all "QE" and "TQS" columns like RSD, LinRange, Ratio.
Ingalls_Lab_Standards_ColumnSelection <- Ingalls_Lab_Standards_DropRows %>%
  select(Compound.Name, m.z, RT..min., z, Column, HILICMix,
         Conc..uM, ionization_form, Liquid.Fraction, 
         Compound.Type, Emperical.Formula, PubChem_Formula, 
         PubChem_Code, KEGG_Code, KEGG_Names, ChEBI_Code,
         IUPAC_Code, InChI_Key_Code, Canon_SMILES_Code, Classyfire,
         Compound.Name_old, Compound.Name_figure, Compound.Name_SQL,
         Date.added, Priority)

## Rename columns! 
# Note the renamed "old" to "original".
Ingalls_Lab_Standards_RenamedColumns <- Ingalls_Lab_Standards_ColumnSelection %>%
  rename(Compound_Name = Compound.Name,
         mz = m.z,
         RT_minute = RT..min.,
         HILIC_Mix = HILICMix,
         Concentration_uM = Conc..uM,
         Ionization_Form = ionization_form,
         Liquid_Fraction = Liquid.Fraction,
         Compound_Type = Compound.Type,
         Empirical_Formula = Emperical.Formula,
         Compound_Name_Original = Compound.Name_old,
         Compound_Name_Figure = Compound.Name_figure,
         Compound_Name_SQL = Compound.Name_SQL,
         Date_Added = Date.added)


