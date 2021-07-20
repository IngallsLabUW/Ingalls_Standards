library(data.table)
library(httr)
library(tidyverse)

## Pull down data from KEGG (try not to run too often or it crashes)
# path <- "http://rest.kegg.jp/list/compound"
# raw_content <- GET(url = path) %>%
#   content()
# all_kegg_IDs <- read.csv(text = gsub("\t\n", "", raw_content), sep = "\t", 
#               header = FALSE, col.names = c("cmpd", "name"))

## Load pre-saved KEGG scrape and drop all brackets
all_kegg_IDs <- read.csv("data_extra/Kegg_C0_info.csv") %>%
  rename(C0 = cmpd)

# Import standards and isolate compound names, drop internal standards that have no KEGG ID.
Full_Standards <-read.csv("Ingalls_Lab_Standards.csv")

standards <- Full_Standards %>%
  select(Compound.Type, Compound.Name, C0) %>%
  unique() %>%
  filter(!str_detect(Compound.Type, "Internal"))

# Checks and matches most of the standards
all_potential_matches <- all_kegg_IDs %>%
  separate_rows(name, sep = ";")
all_potential_matches$name <- trimws(all_potential_matches$name, which = c("both"))
all_potential_matches <- all_potential_matches %>%
  filter(str_detect(all_potential_matches$name, str_c(standards$Compound.Name, collapse="|"))) 

# Identify which standards have been matched with a KEGG compound
Match_Check <- do.call(rbind.data.frame,
             lapply(unique(standards$Compound.Name),
                    function(i){
                      output <- print(i %in% all_potential_matches$name)
                      return(output)})) %>%
  rename(Has_KEGG_Match = 1)

# Add names to the matches
Name_Check <- do.call(rbind.data.frame,
             lapply(unique(standards$Compound.Name),
                    function(i){
                      name <- print(i)
                      return(name)})) %>%
  rename(Compound.Name = 1)

# Combine matches with old and new names/IDs
Mid_Check <- Match_Check %>% 
  cbind(Name_Check) %>%
  left_join(standards %>% select(Compound.Name, C0)) %>%
  rename(Standards_C0 = C0)

# Compare any upated C0s from latest kegg download
Full_Check <- Mid_Check %>%
  left_join(all_potential_matches %>% rename(Compound.Name = name)) %>%
  mutate(Same_C0 = ifelse(Standards_C0 != C0, FALSE, TRUE)) %>%
  filter(is.na(Same_C0) | Same_C0 == FALSE)

Final_KEGG_Standards <- Full_Standards %>%
  select(Compound.Name, C0) %>%
  mutate(C0 = replace(C0, Compound.Name == "Cys-Gly, oxidized", "cpd:C01419"),
              replace(C0, Compound.Name == "2-keto-4-methylthiobutyric acid", "cpd:C01180"),
              replace(C0, Compound.Name == "Ophthalmic acid", "cpd:C21016"), #Opthalmate check
              replace(C0, Compound.Name == "Malic acid", "cpd:C00149"), # Check for malate and correct form
              replace(C0, Compound.Name == "Methylphosphonic acid", "cpd:C20396"),
              replace(C0, Compound.Name == "3-Phosphoglycerate", "cpd:C00597"),
              replace(C0, Compound.Name == "(R)-2,3-Dihydroxypropane-1-sulfonate", "cpd:C19675"),
              replace(C0, Compound.Name == "Caffeic acid", "cpd:C01197"),
              replace(C0, Compound.Name == "beta-Cyclocitral", "cpd:C20425"),
              replace(C0, Compound.Name == "Camalexin", "cpd:C21721"),
              replace(C0, Compound.Name == "N-(4-Coumaroyl)-L-homoserine lactone", "cpd:C20677"),
              replace(C0, Compound.Name == "N-(3-Oxohexanoyl)homoserine lactone", "cpd:C11839"),
              replace(C0, Compound.Name == "N-(3-Oxooctanoyl)homoserine lactone", "cpd:C11841"),
              replace(C0, Compound.Name == "2-(3,5-Dichlorophenylcarbamoyl)-1,2-dimethylcyclopropane-1-carboxylic acid", "cpd:C15249"),
              replace(C0, Compound.Name == "5-(2-Hydroxyethyl)-4-methylthiazole", "cpd:C04294")) 

# Ethyl dihydroxybenzoate
# 2-Hydroxy-4-(methylthio)butyric acid, maybe cpd:C01180
# Homocysteine thiolactone
# Butyrylcarnitine
# Glucosamine, maybe cpd:C00329
# S-Farnesyl-L-cysteine methyl ester
# Gonyol
# O-Methylmalonyl-L-carnitine
# Allopurinol
# beta-glutamic acid. L/d glutamic acid? 
# Threonic acid
# Propionylglycine
# Succinylglycine
# Acetylglycine
# Butyrylglycine
# Glutamylphenylalanine
# Homarine
# Indole-3-carbinol
# Sulfolactic acid, maybe cpd:C16069
# Amino Propanesulfonic Acid, maybe cpd:C03349
# Dimethylsulfoniopropionate, maybe cpd:C03392
# Ethanesulfonic acid
# Sodium 2-mercaptoethanesulfonate, maybe cpd:C03576
# N-Acetyltaurine
# N-Methyltaurine
# 1-Propanesulfonate
# Monesin
# Trolox
# Syringaldehyde
# beta-Apo-8'-carotenal, maybe cpd:C06733
# beta-Ionine
# beta-Ionylidene acetaldehyde
# Decarboxylated S-Adenosylmethionine
# Indoleacrylic acid, maybe cpd:C21283
# Isobutyryl-carnitine
# 1-Palmitoyl-2-oleoyl-sn-glycero-3-phosphocholine
# 1-Stearoyl-2-oleoyl-sn-glycero-3-phosphoethanolamine
# Indole-3-methyl acetate
# 3-Indolepropionic acid
# Methyl indole-3-carboxylate
# 2,4-Decadienal
# 2,4-Octadienal
# Coenzyme Q1
# 2-Heptyl-4(1H)-quinolone
# N-(3-Oxodecanoyl)homoserine lactone
# N-(3-Oxododecanoyl)homoserine lactone, maybe cpd:C11840
# 3OHC12-HSL
# N-Decanoyl-L-homoserine lactone, maybe cpd:C21201
# N-Tetradecanoyl-DL-homoserine lactone
# Calciferol, maybe incorrectly matched? Currently cpd:C05441
# Sulfolactic acid currently cpd:C11537, is that correct?
# Is Palmitoyl-L-carnitine the same as cpd:C02990 L-Palmitoylcarnitine

## Lipids
# Triacylglycerol 12:0-12:0-12:0 and Triacylglycerol 14:0-14:0-14:0, do either match to cpd:C00422?
# Diacylglycerol 18:1-18:1, could it match to cpd:C00165?
# MonoacylglycerolÂ 18:1, could it match to cpd:C01885? ALSO REMOVE FUNKY CHARACTER
# Phosphatidylcholine diacylglycerol 16:0-18:2
# Phosphatidylserine diacylglycerol 18:0-18:1
# Lysophosphatidylcholine monoacylglycerol 18:1 is matched with cpd:C03916, 1-Oleoylglycerophosphocholine; 1-Oleoyl-sn-glycero-3-phosphocholine
# Monogalactosyldiacylglycerol 16:3-18:3
# Digalactosyldiacylglycerol 18:3-18:3
# Sulfoquinovosyldiacylglycerol 16:0-18:3 may match to cpd:C13508
# 1,2-Diacylglyceryl-3-O-4'-(N,N,N-trimethyl)-homoserineÂ 16:0-16:0
# Diacylglycerophosphoglycerol 16:0-18:2
# Diether phosphatidylcholine diacylglycerol 16:0-16:0
# Ceramide d18:1-24:0, is the d intentional?









  



##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))
