
library(tidyverse)

stans_fixed <- read_csv("MSMS/stans_fixed.csv") %>%
  mutate(polarity=list(ifelse(polarity=="both", list(c("pos", "neg")), list(polarity))), .by=compound_name) %>%
  unnest(polarity) %>%
  unnest(polarity)
best_frags <- read_csv("MSMS/best_frags.csv")

stans_fixed %>%
  filter(compound_name=="Guanine") %>%
  left_join(best_frags) %>%
  head()

stans_fixed %>%
  left_join(best_frags) %>%
  arrange(compound_name, polarity, first_scan, fragmz) %>%
  mutate(scan_id = paste0(compound_name, "_", polarity),
         .by = c(compound_name, polarity)) %>%
  reframe(text = c("BEGIN IONS",
                   paste0("TITLE=", unique(scan_id)),
                   paste0("PEPMASS=", unique(mz)),
                   paste0(fragmz, " ", int),
                   "END IONS"),
          .by = c(compound_name, polarity)) %>%
  pull(text) %>%
  writeLines("MSMS/ingalls_library_70ce.mgf")
