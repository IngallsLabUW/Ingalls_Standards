## Script to rename primary ID column (Compound.Name) on the Ingalls Standards sheet.

# Import original standards sheet
Ingalls_Lab_Standards <- read.csv("data_old/Ingalls_Lab_Standards_old.csv") %>%
  mutate(m.z = as.numeric(m.z))

# Import specific edits made by Laura
Laura_Edit <- read.csv("data_old/Ingalls_Lab_Standards_LauraEdit.csv", 
                                            header = TRUE, stringsAsFactors = FALSE, fileEncoding = "latin1") %>%
  mutate(m.z = as.numeric(m.z)) %>%
  rename(Compound.Name_Laura = Compound.Name_new) %>%
  select(Compound.Name_Laura, Compound.Name_old) %>%
  mutate(Compound.Name_Laura = recode(Compound.Name_Laura,
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
                                    "4-Hydroxybenzaldehyde" = "4-hydroxybenzaldehyde"))

# Fix some small mistakes
Laura_Edit[Laura_Edit == "O-Propanoylcarnitine"] <- "O-Propionylcarnitine"
Laura_Edit[Laura_Edit == "O-Acetyl-L-carnitine"] <- "O-Acetylcarnitine"
Laura_Edit[Laura_Edit == "Propanoyl-CoA"] <- "Propionyl-CoA"
Laura_Edit[87, 1] <- "Methyl indole-3-carboxylate"

# Add Laura's edits
Standards_LauraEdit <- Ingalls_Lab_Standards %>%
  left_join(Laura_Edit %>% rename(Compound.Name = Compound.Name_old), by = "Compound.Name") %>%
  rename(Compound.Name_old = Compound.Name,
         Compound.Name = Compound.Name_Laura) %>%
  select(Compound.Type, Column, Compound.Name, Compound.Name_old, everything()) %>%
  unique()

# Adjust Vitamins to descriptive names
Vitamins <- Standards_LauraEdit %>%
  mutate(Compound.Name = recode(Compound.Name, # old = new
                                "Vitamin B2, 13C4, 15N2" = "Riboflavin-dioxopyrimidine, 13C4, 15N2",
                                "Vitamin B2" = "Riboflavin",
                                "Vitamin C" = "Ascorbic acid",
                                "Vitamin D2" = "Calciferol",
                                "Vitamin K1" = "Phytonadione",
                                "Vitamin K2" = "Menaquinone")) 

Ingalls_Lab_Standards_PrimaryID <- Vitamins



