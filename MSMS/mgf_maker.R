
library(tidyverse)

stans_fixed <- read_csv("MSMS/stans_fixed.csv") %>%
  mutate(polarity = map(polarity, function(x) if (x == "both"){c("pos","neg")}else{x}),
         .by = compound_name) %>%
  unnest(polarity)

best_frags <- read_csv("MSMS/best_frags.csv")

stans_fixed %>%
  left_join(best_frags) %>%
  arrange(compound_name, polarity, first_scan, fragmz) %>%
  reframe(text = c("BEGIN IONS",
                   paste0("TITLE=", compound_name),
                   paste0("PEPMASS=", mz),
                   paste0("CHARGE=", case_when(
                     polarity[1] == "pos" ~ "1+",
                     polarity[1] == "neg" ~ "1-"
                   )),
                   paste0(fragmz, " ", int),
                   "END IONS"),
          .by = c(compound_name, polarity)) %>%
  pull(text) %>%
  writeLines("MSMS/ingalls_library_70ce.mgf")
