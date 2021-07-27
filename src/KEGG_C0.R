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
              replace(C0, Compound.Name == "Ophthalmic acid", "cpd:C21016"), # Opthalmate check
              replace(C0, Compound.Name == "Malic acid", "cpd:C00149"), # Check for malate and correct form
              replace(C0, Compound.Name == "Threonic acid", "cpd:C01620"), # There's also L- and D- threonate
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
              replace(C0, Compound.Name == "5-(2-Hydroxyethyl)-4-methylthiazole", "cpd:C04294"),
              replace(C0, Compound.Name == "Monesin", "cpd:C06693"),
              replace(C0, Compound.Name == "2-Heptyl-4(1H)-quinolone", "cpd:C20643")) 


## After a secondary internet search
# Homocysteine thiolactone
  # Suggests on ebi.uk that L-Homocysteine is a KEGG match, cpd:C00155
# Butyrylcarnitine
  # Suggests on kegg that O-Butanoylcarnitine is a match, cpd:C02862
# S-Farnesyl-L-cysteine methyl ester
  # Kegg suggestion is Protein C-terminal S-farnesyl-L-cysteine methyl ester, cpd:C04748
# beta-Ionine
  # Closest is beta-Ionone, not sure if that's the same thing. cpd:C12287
# Decarboxylated S-Adenosylmethionine
  # KEGG does have S-Adenosylmethionine, but not decarboxylated.cpd:C00019
# 1-Stearoyl-2-oleoyl-sn-glycero-3-phosphoethanolamine
  # Closest match is cpd:C01233, sn-Glycero-3-phosphoethanolamine
# Indole-3-methyl acetate
  # Closest match is Methyl (indol-3-yl)acetate, cpd: C20635. This was a previous match for KEGG in the OG standards.
# Methyl indole-3-carboxylate
  # Closest KEGG match is Indole-3-carboxylate, cpd: C19837
# Coenzyme Q1
  # Closest is Coenzyme Q, cpd:C00399
# N-(3-Oxodecanoyl)homoserine lactone
  # Comes close with N-3-Oxo-dodecanoyl-L-homoserine lactone, cpd:C21201, but probably not the same thing
# 2-Hydroxy-4-(methylthio)butyric acid
  # maybe cpd:C01180
# Glucosamine
  # maybe cpd:C00329
# Sulfolactic acid
  # maybe cpd:C16069
# Amino Propanesulfonic Acid
  # maybe cpd:C03349
# Dimethylsulfoniopropionate
  # maybe cpd:C03392
# Sodium 2-mercaptoethanesulfonate
  # maybe cpd:C03576
# beta-Apo-8'-carotenal
  # maybe cpd:C06733
# Indoleacrylic acid
  # maybe cpd:C21283
# N-(3-Oxododecanoyl)homoserine lactone
  # maybe cpd:C11840
# N-Decanoyl-L-homoserine lactone
  # maybe cpd:C21201
# Calciferol
  # maybe incorrectly matched? Currently cpd:C05441
# Sulfolactic acid
  # currently cpd:C11537, is that correct?
# Palmitoyl-L-carnitine
  # the same as cpd:C02990 L-Palmitoylcarnitine"
# beta-glutamic acid
  # L/d glutamic acid? 
# Allopurinol
  # Listed as part of the drug database, D00224


## Currently unable to find any potential matches
# Gonyol
  # Has some long synonyms on chemspider
# O-Methylmalonyl-L-carnitine
# Propionylglycine
# Succinylglycine
  # Potentialy N-Succinylglycine, but still no kegg matches
# Ethyl dihydroxybenzoate
# Acetylglycine
# Butyrylglycine
# Glutamylphenylalanine
# Homarine
# Indole-3-carbinol
# Ethanesulfonic acid
# N-Acetyltaurine
# N-Methyltaurine
# 1-Propanesulfonate
# Trolox
# Syringaldehyde
# beta-Ionylidene acetaldehyde
# Isobutyryl-carnitine
# 1-Palmitoyl-2-oleoyl-sn-glycero-3-phosphocholine
# 3-Indolepropionic acid
# 2,4-Decadienal
# 2,4-Octadienal
# 3OHC12-HSL
# N-Tetradecanoyl-DL-homoserine lactone



## Lipids, potential matches
# Triacylglycerol 12:0-12:0-12:0 and Triacylglycerol 14:0-14:0-14:0, do either match to cpd:C00422?
# Diacylglycerol 18:1-18:1, could it match to cpd:C00165?
# MonoacylglycerolÂ 18:1, could it match to cpd:C01885? ALSO REMOVE FUNKY CHARACTER
# Lysophosphatidylcholine monoacylglycerol 18:1 is matched with cpd:C03916, 1-Oleoylglycerophosphocholine; 1-Oleoyl-sn-glycero-3-phosphocholine
# Sulfoquinovosyldiacylglycerol 16:0-18:3 may match to cpd:C13508
# Ceramide d18:1-24:0, is the d intentional?

## Lipids, missing/can't find
# Phosphatidylcholine diacylglycerol 16:0-18:2
# Phosphatidylserine diacylglycerol 18:0-18:1
# Monogalactosyldiacylglycerol 16:3-18:3
# Digalactosyldiacylglycerol 18:3-18:3
# 1,2-Diacylglyceryl-3-O-4'-(N,N,N-trimethyl)-homoserineÂ 16:0-16:0 REMOVE FUNKY CHARACTER
# Diacylglycerophosphoglycerol 16:0-18:2
# Diether phosphatidylcholine diacylglycerol 16:0-16:0









  



##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))
