ScaleMS2 <- function(concatenated.scan) {
  scantable <- read.table(text = as.character(concatenated.scan),
                          col.names = c("mz", "intensity"), fill = TRUE) %>%
    mutate(mz = as.numeric(mz %>% str_replace(",", "")),
           intensity = as.numeric(intensity %>% str_replace(";", "")),
           intensity = round(intensity / max(intensity) * 100, digits = 1)) %>%
    filter(intensity > 0.5) %>%
    arrange(desc(intensity)) %>%
    unite("MS2", mz:intensity, sep = ", ") %>%
    mutate(MS2 = paste(MS2, collapse = "; ")) %>%
    unique()
  
  return(scantable)
}