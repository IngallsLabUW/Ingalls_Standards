
## Save pre-facelift standards to an "archive data" sheet. This includes the 
## columns that have been dropped 
Auxilary_Columns <- Ingalls_Lab_Standards_Classyfire %>%
  select(Compound.Name, Column, z, QE.LinRange, QE.RF.ratio, QE.RSD, 
         TQS.LinRange, TQS.RF.ratio, TQS.RSD, everything())
write.csv(Auxilary_Columns, 
          "data_old/Ingalls_Lab_Standards_AuxColumns.csv", row.names = FALSE)

## New column order 
# Dropped all "QE" and "TQS" columns like RSD, LinRange, Ratio.
Ingalls_Lab_Standards_ColumnSelection <- Ingalls_Lab_Standards_Classyfire %>%
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
 
        
  