# Script for Figure Names

#All_Standards <- Ingalls_Lab_Standards_PrimaryID

#Complete_Standards <- All_Standards %>%
Name_Columns <- Ingalls_Lab_Standards_PrimaryID %>%
  mutate(Compound.Name_figure = Compound.Name_old) %>%
  select(Compound.Type, Compound.Name, Compound.Name_old, Compound.Name_figure) %>%
  mutate(old.letter.count = nchar(Compound.Name_old)) %>%
  arrange(old.letter.count) 

Figure_Names <- Name_Columns %>%
  mutate(Compound.Name_figure = ifelse(old.letter.count <= 14, Compound.Name, Compound.Name_figure)) %>%
  mutate(Compound.Name_figure = ifelse(old.letter.count <= 7, Compound.Name_old, Compound.Name_figure)) %>%
  mutate(Compound.Name_figure = recode(Compound.Name_figure,
                                       # Small fixes
                                       "B-ionine" = "b-Ionine",
                                       "beta-Alanine" = "b-Alanine",
                                       "Betaine" = "Glycine betaine",
                                       "N-Acetylserine" = "N-acetylserine",
                                       "RP B12" = "Cyano B12",
                                       ###### Abbreviations ######
                                       "(3-Carboxypropyl)trimethylammonium (TMAB)" = "TMAB",
                                       "3 Indolebutyric acid" = "Indolebutyric acid",
                                       "5-(2-Hydroxyethyl)-4-methylthiazole" = "Sulfurol",
                                       "6-Methyladenine" = "N6-Methyladenine",
                                       "7-dehydrocholesterol" = "7-DHC",
                                       "Adenosyl Methionine" = "SAM",
                                       "Adenosyl Homocysteine" = "SAH",
                                       "Aminobenzoic acid" = "PABA",
                                       "Aminobutyric acid" = "GABA",
                                       "Amino Propanesulfonic acid" = "APA",
                                       "Arachidonic acid" = "ARA",
                                       "Argininosuccinic acid" = "Argininosuccinate",
                                       "B-ionylidene-acetaldehyde" = "b-Ionylidene acetaldehyde",
                                       "beta-Glutamic acid" = "b-Glutamic acid",
                                       "Cysteinesulfinic acid" = "CSA",
                                       "Dimethyl-benzimidazole" = "DMB",
                                       "Dimethyl Glycine" = "DMG",
                                       "Dimethyl glycine" = "DMG",
                                       "Dimethylsulfonioacetate (DMS-Ac)" = "DMS-Ac",
                                       "Ethyl 3 aminobenzoate" = "Ethyl aminobenzoate",
                                       "Glutathione Disulfide" = "GSSG",
                                       "Glutamylphenylalanine" = "GMPA",
                                       "Glycerophosphocholine" = "GPP",
                                       "Homocysteine Thiolactone" = "Homocysteine thiolactone",
                                       "Homoserine lactone" = "AHL", 
                                       "Indoleacrylic acid" = "IAA",
                                       "Isobutyryl-carnitine" = "IBC",
                                       "Riboflavin Monophosphate" = "RMP",
                                       "Ribose 5 phosphate" = "R5P",
                                       "MESNA (Sodium 2-mercaptoethanesulfonate)" = "MESNA",
                                       "Methionine Sulfoxide" = "Methionine sulfoxide",
                                       "Methylmalonyl carnitine" = "MMC",
                                       "Methylphosphonic acid" = "MPA",
                                       "Methylthioadenosine" = "MTA",
                                       "N-Acetyl-Serine" = "N-Acetylserine",
                                       "Propionyl-L-carnitine" = "O-Propionylcarnitine",
                                       "Pyridoxal Phosphate" = "PLP",
                                       "Succinic semialdehyde" = "SSA",
                                       "Thiamine monophosphate" = "TMP",
                                       "thiamine pyrophosphate" = "TPP",
                                       "Thiamine pyrophosphate" = "TPP",
                                       "trans cinnamic acid" = "trans-Cinnamic acid",
                                       "trans Hydroxyl proline" = "THP",
                                       "Trimethylamine N-oxide" = "TMAO",
                                       "Trimethylammonium Propionate (TMAP)" = "TMAP",
                                       "Tropodithietic acid" = "Thiotropocin",
                                       ###### Shorten ######
                                       "1-stearoyl-2-oleoyl-sn-glycero-3-phosphoethanolamine" = "1,2,3-phosphoethanolamine",
                                       "1-palmitoyl-2-oleoyl-sn-glycero-3-phosphocholine" = "1,2,3-phosphocholine",
                                       "2-(3,5-Dichlorophenylcarbamoyl)-1,2-dimethylcyclopropane-1-carboxylic acid" = "cinnamoyl-HSL",
                                       "3',5'-Cyclic diGMP" = "Cyclic diGMP",
                                       "5-Hydroxyectoine" = "Hydroxyectoine",
                                       "Adenosylcobalamin" = "Adenosyl B12",
                                       "alpha-Tocotrienol" = "a-Tocotrienol",
                                       "beta-Carotene" = "b-Carotene",
                                       "beta-Cyclocitral" = "b-Cyclocitral",
                                       "beta-Ionine" = "b-Ionine",
                                       "cis-Aconitic acid" = "Aconitic acid",
                                       "Decarboxylated S-Adenosylmethionine" = "D-SAM",
                                       "Ethyl Dihydroxybenzoate" = "EDHB",
                                       "Fructose 6 phosphate" = "F6-phosphate",
                                       "glycerol 3 phosphate" = "G3-phosphate",
                                       "Hydroxocobalamin" = "Hydroxo B12",
                                       "Indole 3 carbinol" = "Indole-3-carbinol",
                                       "Indole 3 carboxylic acid" = "Indole-3-carboxylic acid",
                                       "Indole 3 Lactic acid" = "Indoleactate",
                                       "Indole 3 methyl acetate" = "Indole-3-methyl acetate",
                                       "Indole 3 Pyruvic acid" = "I3P acid",
                                       "Isobutyryl-carnitine" = "Isobutyryl-carnitine",
                                       "Keto-?-(methylthio)butyric Acid" = "Methylthiobutyric acid",
                                       "Methylcobalamin" = "Methyl B12",
                                       "Methyl indole 3 carboxylate" = "Methyl indole-3-carboxylate",
                                       "Methyl Malonyl CoA" = "Methylmalonyl CoA",
                                       "N-(3-Oxodecanoyl)homoserine lactone" = "3OC10-HSL",
                                       "N-(3-Oxododecanoyl)homoserine lactone" = "3O12-HSL",
                                       "N-(3-Oxohexanoyl)homoserine lactone" = "3OC6-HSL",
                                       "N-(3-Oxooctanoyl)homoserine lactone" = "3OC8-HSL",
                                       "N-Acetylmuramic acid" = "MurNAc",
                                       "Phosphoglyceric acid" = "3-Phosphoglycerate",
                                       "Stachydrine hydrochloride" = "Proline betaine",
                                       "Tocopherol (Vit E)" = "Vit E",
                                       ###### Different name ######
                                       "B-apo-8'-carotenal" = "Apocarotenal",
                                       "Ethanesulfonic acid" = "Esylic acid", 
                                       "Imidazoleacrylic acid" = "Urocanate",
                                       "Ophthalmic acid" = "Ophthalmate",
                                       "L-Pyroglutamic acid" = "Pidolic acid",
                                       "S-Farnesyl-L-cysteine Methyl Ester" = "S-Fcme",
                                       ###### Vitamins ######
                                       "Ascorbic acid" = "Vit C",
                                       "Biotin" = "Vit B7",
                                       "Calciferol" = "Vit D2",
                                       "Folic acid" = "Vit B9",
                                       "Menaquinone" = "Vit K2",
                                       "Riboflavin" = "Vit B2",
                                       "Nicotinic acid" = "Vit B3",
                                       "Pantothenic acid" = "Vit B5",
                                       "Phytonadione" = "Vit K1",
                                       "Pyridoxine" = "Vit B6",
                                       "Thiamine" = "Vit B1")) %>%
  unique() 

Figure_Names$Compound.Name_figure <- gsub(".*DL-|.*L-" ,"", Figure_Names$Compound.Name_figure)

Ingalls_Lab_Standards_FigNames <- Ingalls_Lab_Standards_PrimaryID %>%
  left_join(Figure_Names, c("Compound.Type", "Compound.Name", "Compound.Name_old", "Compound.Name_figure")) %>%
  select(Compound.Type, Column, Compound.Name, Compound.Name_old, Compound.Name_figure, everything()) %>%
  select(-old.letter.count) 

