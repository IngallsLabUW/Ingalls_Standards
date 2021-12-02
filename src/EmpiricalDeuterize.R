library(tidyverse)

## Load latest standard version
Ingalls_Lab_Standards <- read.csv("Ingalls_Lab_Standards.csv")

NonDeuterized <- Ingalls_Lab_Standards %>%
  mutate(Empirical_Formula = ifelse(Compound_Type == "Internal Standard", 
                                    gsub("D", "H(2)", Empirical_Formula),
                                    Empirical_Formula))







