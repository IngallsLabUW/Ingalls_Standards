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
                                    "Cys-Gly" = "L-Cysteinylglycine")) 

# Fix some small mistakes
Laura_Edit[Laura_Edit == "O-Propanoylcarnitine"] <- "O-Propionylcarnitine"
Laura_Edit[Laura_Edit == "O-Acetyl-L-carnitine"] <- "O-Acetylcarnitine"
Laura_Edit[Laura_Edit == "Propanoyl-CoA"] <- "Propionyl-CoA"

# Add Laura's edits
Standards_LauraEdit <- Ingalls_Lab_Standards %>%
  left_join(Laura_Edit %>% rename(Compound.Name = Compound.Name_old)) %>%
  rename(Compound.Name_old = Compound.Name,
         Compound.Name = Compound.Name_Laura) %>%
  select(Compound.Type, Column, Compound.Name, Compound.Name_old, everything()) %>%
  unique()

# Remove abbreviations for primary_ID column.
# Abbreviations <- Laura_Edit %>%
#   #select(Compound.Name_new, Compound.Name_old, Compound.Type) %>% 
#   # mutate(Compound.Name_new = recode(Compound.Name_new,
#   #                                   "DMSP" = "Dimethylsulfoniopropionate",
#   #                                   "ADP" = "Adenosine diphosphate",
#   #                                   "AMP" = "Adenosine monophosphate",
#   #                                   "ATP" = "Adenosine triphosphate",
#   #                                   "FAD" = "Flavin adenine dinucleotide",
#   #                                   "GMP" = "Guanosine monophosphate",
#   #                                   "GMP, 15N5" = "Guanosine monophosphate, 15N5",
#   #                                   "GTP" = "Guanosine triphosphate",
#   #                                   "PEP" = "Phosphoenolpyruvic acid",
#   #                                   "TMAB" = "(3-Carboxypropyl)trimethylammonium",
#   #                                   "cAMP" = "3',5'-Cyclic AMP",
#   #                                   "cGMP" = "3',5'-Cyclic GMP",
#   #                                   "Cys-Gly" = "L-Cysteinylglycine")) %>%
#   filter(#Compound.Type != "Internal Standard",
#          Compound.Name_Laura != Compound.Name_old) %>% 
#   mutate(letter.count = nchar(Compound.Name_Laura)) %>%
#   arrange(letter.count) %>%
#   filter(nchar(Compound.Name_old) < 10 | Compound.Name_old == "(3-Carboxypropyl)trimethylammonium (TMAB)",
#          nchar(Compound.Name_old) < 7 | str_detect(Compound.Name_old, "-"))

# Finalize changes of abbreviated compounds
# Abbreviations_final <- Standards_LauraEdit %>%
#   left_join(Abbreviations %>% select(Compound.Name_new, Compound.Name_old) %>% unique()) %>%
#   select(Compound.Name, Compound.Name_new, Compound.Name_old, Compound.Type, everything()) %>%
#   mutate(Compound.Name = ifelse(is.na(Compound.Name), Compound.Name_new, Compound.Name)) %>%
#   select(Compound.Type, Column, everything(), -Compound.Name_new) 

# Isolate different capitalizations of compounds
Capitalizations <- Laura_Edit %>%
  select(Compound.Name_Laura, Compound.Name_old) # %>%
  # filter(!Compound.Name_new %in% Abbreviations_final$Compound.Name, 
  #        Compound.Name_new != Compound.Name_old) # drop commpounds already reassigned or matching originals

# View different capitalization sections.
# Acid.Capitals <- Capitalizations %>%
#   filter(str_detect(Compound.Name_Laura, regex("acid", ignore_case = TRUE))) %>%
#   select(Compound.Name_Laura, Compound.Name_old)
# Beta.Capitals <- Capitalizations %>%
#   filter(str_detect(Compound.Name_Laura, regex("beta-", ignore_case = TRUE))) %>%
#   select(Compound.Name_Laura, Compound.Name_old)
# Just.Capitals <- Capitalizations %>%
#   select(Compound.Name_Laura, Compound.Name_old) %>%
#   filter(!Compound.Name_Laura %in% c(Acid.Capitals$Compound.Name_Laura, Beta.Capitals$Compound.Name_Laura),
#          tolower(Compound.Name_Laura) == tolower(Compound.Name_old),
#          Compound.Name_Laura != Compound.Name_old) %>%
#   unique()

# Complete.Caps <- Acid.Capitals %>%
#   rbind(Beta.Capitals) %>%
#   rbind(Just.Capitals)

# Finalize changes of capitalized compounds
# Capitalizations_final <- Abbreviations_final %>%
#   left_join(Complete.Caps) %>%
#   select(Compound.Name, Compound.Name_new, Compound.Name_old, Compound.Type, everything()) %>%
#   mutate(Compound.Name = ifelse(is.na(Compound.Name), Compound.Name_new, Compound.Name)) %>%
#   select(Compound.Type, Column, everything(), -Compound.Name_new) %>%
#   unique()

# Isolate Symbols  
# Symbols <- Laura_Edit %>%
#   filter(Compound.Name_Laura != Compound.Name_old) %>%
#   filter_all(any_vars(str_detect(., "[^[:alnum:] ]"))) %>%
#   unique()
# 
# # Finalize changes of compounds with symbols
# Symbols_final <- Capitalizations_final %>%
#   left_join(Symbols) %>%
#   select(Compound.Name, Compound.Name_new, Compound.Name_old, Compound.Type, everything()) %>%
#   mutate(Compound.Name = ifelse(is.na(Compound.Name), Compound.Name_new, Compound.Name)) %>%
#   select(Compound.Type, Column, everything(), -Compound.Name_new) %>%
#   unique()

# Adjust Vitamins to descriptive names
Vitamins <- Symbols_final %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Methyl indole 3 carboxylate", "Methyl indole-3-carboxylate", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin B1", "Thiamine", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin B2, 13C4, 15N2", "Riboflavin-dioxopyrimidine, 13C4, 15N2", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin B2", "Riboflavin", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin B6", "Pyridoxine", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin B7", "Biotin", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin C", "Ascorbic acid", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin D2", "Calciferol", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin K1", "Phytonadione", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Vitamin K2", "Menaquinone", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "AMP, 15N5", "Adenosine monophosphate, 15N5", Compound.Name)) %>%
  mutate(Compound.Name = ifelse(Compound.Name_old == "Indole 3 methyl acetate", "Indole-3-methyl acetate", Compound.Name))

Ingalls_Lab_Standards_PrimaryID <- Vitamins

