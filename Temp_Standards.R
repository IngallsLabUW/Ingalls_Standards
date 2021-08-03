
## Save pre-facelift standards to an "archive data" sheet. This includes the 
## columns that have been dropped 
Ingalls_Lab_Standards_August2021 <- Ingalls_Lab_Standards_Classyfire %>%
  select(Compound.Name, Column, z, QE.LinRange, QE.RF.ratio, QE.RSD, 
         TQS.LinRange, TQS.RF.ratio, TQS.RSD, everything())
write.csv(Ingalls_Lab_Standards_August2021, 
          "data_old/Ingalls_Lab_Standards_August2021.csv", row.names = FALSE)

Liquid_Fractions <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(Compound.Name, Liquid.Fraction, Priority)

## New column order 
# Dropped all "QE" and "TQS" columns like RSD, LinRange, Ratio.
Ingalls_Lab_Standards_ColumnSelection <- Ingalls_Lab_Standards_Classyfire %>%
  left_join(Liquid_Fractions) %>%
  select(Compound.Name, m.z, RT..min., z, Column, HILICMix,
         Conc..uM, ionization_form, Liquid.Fraction, 
         Compound.Type, Emperical.Formula, 
         C0, KEGGNAME, ChEBI_Names, CID,
         IUPACName, InChIKey, CanonicalSMILES, Classyfire,
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
         Compound_Type = Compound.Type,
         Empirical_Formula = Emperical.Formula,
         Liquid_Fraction = Liquid.Fraction,
         KEGG_Code = C0,
         KEGG_Name = KEGGNAME,
         IUPAC_Code = IUPACName,
         InCHI_Key_Code = InChIKey,
         Canon_SMILES_Code = CanonicalSMILES,
         Compound_Name_Original = Compound.Name_old,
         Compound_Name_Figure = Compound.Name_figure,
         Compound_Name_SQL = Compound.Name_SQL,
         Date_Added = Date.added)
