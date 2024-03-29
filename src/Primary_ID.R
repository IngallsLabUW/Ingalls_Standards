## Script outlining the renaming of the primary ID column (Compound.Name) on the Ingalls Standards sheet.

# Outline specific edits made by Laura
Laura_Edit <- Ingalls_Lab_Standards %>%
  mutate(Compound.Name = recode(Compound.Name,
                                # old = new
                                "DMSP" = "Dimethylsulfoniopropionate",
                                "ADP" = "Adenosine diphosphate",
                                "AMP" = "Adenosine monophosphate",
                                "AMP, 15N5" = "Adenosine monophosphate, 15N5",
                                "ATP" = "Adenosine triphosphate",
                                "FAD" = "Flavin adenine dinucleotide",
                                "GMP" = "Guanosine monophosphate",
                                "GMP, 15N5" = "Guanosine monophosphate, 15N5",
                                "GTP" = "Guanosine triphosphate",
                                "PEP" = "Phosphoenolpyruvic acid",
                                "TMAB" = "(3-Carboxypropyl)trimethylammonium",
                                "cAMP" = "3',5'-Cyclic AMP",
                                "cGMP" = "3',5'-Cyclic GMP",
                                "Cys-Gly" = "L-Cysteinylglycine",
                                "Methyl (indol-3-yl)acetate" = "Methyl indole-3-acetate",
                                "4-Hydroxybenzaldehyde" = "4-hydroxybenzaldehyde",
                                "Vitamin B2, 13C4, 15N2" = "Riboflavin-dioxopyrimidine, 13C4, 15N2",
                                "Vitamin B2" = "Riboflavin",
                                "Vitamin C" = "Ascorbic acid",
                                "Vitamin D2" = "Calciferol",
                                "Vitamin K1" = "Phytonadione",
                                "Vitamin K2" = "Menaquinone",
                                "O-Propanoylcarnitine" = "O-Propionylcarnitine",
                                "O-Acetyl-L-carnitine" = "O-Acetylcarnitine",
                                "Propanoyl-CoA" = "Propionyl-CoA",
                                "beta-Ionine" = "beta-Ionone",
                                "Calciferol" = "Ergocalciferol"))

Laura_Edit$Compound.Name <- Laura_Edit$Compound.Name <- str_replace_all(Laura_Edit$Compound.Name, "Â", "")


Ingalls_Lab_Standards_PrimaryID <- Laura_Edit
