# Script for SQL-Safe, CMAP-Friendly compound names

replace_special_characters <- function(x) (gsub("[^[:alnum:] ]", " ", x))
replace_double_spaces <- function(x) (gsub("  ", " ", x))

All_Standards <- Ingalls_Lab_Standards_ChEBI

Special.Names <- Ingalls_Lab_Standards_ChEBI %>%
  select(Compound.Name, Compound.Name_figure) %>%
  filter_all(any_vars(str_detect(., "[^[:alnum:] ]"))) %>%
  unique() %>%
  mutate(Long.SpecialCharacter = ifelse(str_detect(Compound.Name, "[^[:alnum:] ]"), TRUE, FALSE)) %>%
  mutate(Compound.Name_SQL = ifelse(Long.SpecialCharacter == FALSE, Compound.Name, Compound.Name_figure)) %>%
  mutate_at(c("Compound.Name_SQL"), replace_special_characters) %>%
  mutate_at(c("Compound.Name_SQL"), replace_double_spaces) %>%
  select(Compound.Name, Compound.Name_SQL) %>%
  drop_na() 

All.Characters.Replaced <- All_Standards %>%
  left_join(Special.Names, by = "Compound.Name") %>%
  mutate(Compound.Name_SQL = ifelse(is.na(Compound.Name_SQL), Compound.Name, Compound.Name_SQL)) %>%
  select(Compound.Type:Compound.Name_figure, Compound.Name_SQL, everything())


# Handle leading numbers
LauraEditsSQL <- read.csv("data_extra/Standards_LeadingNumbers_LTC.csv") %>%
  select(Compound.Name_SQL, Compound.Name_SQL_LTC)

Leading.Numbers <- All.Characters.Replaced %>%
  select(Compound.Name, Compound.Name_SQL) %>%
  drop_na() %>%
  mutate(SQL = recode(Compound.Name_SQL,
                                    "2iP" = "Dimethylallyladenine",
                                    "1 2 3 phosphocholine" = "POPC",
                                    "1 2 3 phosphoethanolamine" = "SOPE",
                                    "3O12 HSL" = "Oxododecanoyl homoserine lactone",
                                    "3OC10 HSL" = "Oxodecanoyl homoserine lactone",
                                    "3OC8 HSL" = "Oxooctanoyl homoserine lactone",
                                    "3OC6 HSL" = "Oxohexanoyl homoserine lactone"
                                    )) %>%
  filter(str_detect(SQL, "^[0-9]")) %>%
  mutate(SQL = gsub("[[:digit:]]+", "", SQL)) 
Leading.Numbers$SQL <- trimws(Leading.Numbers$SQL, which = c("left"))


Final.SQL <- All.Characters.Replaced %>%
  left_join(Leading.Numbers %>% select(Compound.Name, SQL)) %>%
  mutate(Compound.Name_SQL = ifelse(!is.na(SQL), SQL, Compound.Name_SQL)) %>%
  select(-SQL)

