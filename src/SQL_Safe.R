## Script for SQL-Safe, CMAP-Friendly compound names

replace_special_characters <- function(x) (gsub("[^[:alnum:] ]", " ", x))
replace_double_spaces <- function(x) (gsub("  ", " ", x))

## Replace special characters
Special_Names <- Ingalls_Lab_Standards_FigNames %>%
  select(Compound.Name, Compound.Name_figure) %>%
  filter_all(any_vars(str_detect(., "[^[:alnum:] ]"))) %>%
  unique() %>%
  mutate(Long.SpecialCharacter = ifelse(str_detect(Compound.Name, "[^[:alnum:] ]"), TRUE, FALSE)) %>%
  mutate(Compound.Name_SQL = ifelse(Long.SpecialCharacter == FALSE, Compound.Name, Compound.Name_figure)) %>%
  mutate_at(c("Compound.Name_SQL"), replace_special_characters) %>%
  mutate_at(c("Compound.Name_SQL"), replace_double_spaces) %>%
  select(Compound.Name, Compound.Name_SQL) %>%
  drop_na() 

All_Characters_Replaced <- Ingalls_Lab_Standards_FigNames %>%
  left_join(Special_Names, by = c("Compound.Name", "Compound.Name_SQL")) %>%
  mutate(Compound.Name_SQL = ifelse(is.na(Compound.Name_SQL), Compound.Name, Compound.Name_SQL)) %>%
  mutate(Compound.Name_SQL = recode(Compound.Name_SQL,
                      "2iP" = "Dimethylallyladenine",
                      "1 2 3 phosphocholine" = "POPC",
                      "1 2 3 phosphoethanolamine" = "SOPE",
                      "3O12 HSL" = "Oxododecanoyl homoserine lactone",
                      "3OC10 HSL" = "Oxodecanoyl homoserine lactone",
                      "3OC8 HSL" = "Oxooctanoyl homoserine lactone",
                      "3OC6 HSL" = "Oxohexanoyl homoserine lactone")) %>%
  select(Compound.Type:Compound.Name_figure, Compound.Name_SQL, everything())

Ingalls_Lab_Standards_SQL <- All_Characters_Replaced
