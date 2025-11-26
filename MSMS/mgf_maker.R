
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
                   paste0("TITLE=", unique(compound_name)),
                   paste0("NAME=",  unique(compound_name)),
                   paste0("RTINSECONDS=",unique((rtmin+rtmax)/2*60)),
                   paste0("PEPMASS=", unique(mz)),
                   paste0("CHARGE=", case_when(
                     polarity[1] == "pos" ~ "1+",
                     polarity[1] == "neg" ~ "1-"
                   )),
                   paste0(fragmz, " ", int),
                   "END IONS"),
          .by = c(compound_name, polarity)) %>%
  # print(n=40)
  pull(text) %>%
  writeLines("MSMS/ingalls_library_70ce.mgf")



stans_fixed %>%
  left_join(best_frags) %>%
  arrange(compound_name, polarity, first_scan, fragmz) %>%
  reframe(text = c("BEGIN IONS",
                   paste0("TITLE=", unique(compound_name)),
                   paste0("NAME=",  unique(compound_name)),
                   paste0("RTINSECONDS=",unique((rtmin+rtmax)/2*60)),
                   paste0("PEPMASS=", unique(mz)),
                   paste0("CHARGE=", case_when(
                     polarity[1] == "pos" ~ "1+",
                     polarity[1] == "neg" ~ "1-"
                   )),
                   paste0(fragmz, " ", int),
                   "END IONS"),
          .by = c(compound_name, polarity)) %>%
  # print(n=40)
  pull(text) %>%
  writeLines("MSMS/ingalls_library_70ce.mgf")



stans_fixed %>%
  left_join(best_frags) %>%
  arrange(compound_name, polarity, first_scan, fragmz) %>%
  reframe(text = c(
    paste0("Name: ", unique(compound_name)),
    paste0("Precursor_type: ", case_when(
      polarity[1] == "pos" ~ "[M+H]+",
      polarity[1] == "neg" ~ "[M-H]-"
    )),
    paste0("Ion_mode: ", case_when(
      polarity[1] == "pos" ~ "P",
      polarity[1] == "neg" ~ "N"
    )),
    paste0("PrecursorMZ: ", unique(mz)),
    paste0("Retention_time: ", unique((rtmin+rtmax)/2*60)),
    paste0("Num Peaks: ", length(fragmz)),
    paste(fragmz, int)
  ),
  .by = c(compound_name, polarity)) %>%
  # print(n=40)
  pull(text) %>%
  writeLines("MSMS/ingalls_library_70ce.msp")
