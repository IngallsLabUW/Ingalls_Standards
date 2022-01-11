library(tidyverse)

## Will's code: Small edits made by Regina

# RML function for scaling raw MS2 data
ScaleMS2 <- function(scan) {
  scantable <- read.table(text = as.character(scan),
                          col.names = c("mz", "intensity"), fill = TRUE) %>%
    mutate(mz = as.numeric(mz %>% str_replace(",", "")),
           intensity = as.numeric(intensity %>% str_replace(";", "")),
           intensity = round(intensity / max(intensity) * 100, digits = 1)) %>%
    filter(intensity > 0.5) %>%
    arrange(desc(intensity)) %>%
    unite("MS2", mz:intensity, sep = ", ") %>%
    mutate(MS2 = paste(MS2, collapse = "; ")) %>% # This is adding the ".MS2 addition on the 
    unique()
  
  return(scantable)
}

# Import complete five-run MSMS data
Ingalls_Lab_Standards_MSMS <- read.csv("MSMS/data_processed/Ingalls_Lab_Standards_MSMS.csv")

# Rep
ScaledforMS2 <- Ingalls_Lab_Standards_MSMS %>%
  drop_na() %>%
  rowwise() %>%
  mutate(ScaleMS2(MS2))

## Will's grouping function
## IS THIS BASED ON M/Z AND INTENSITY? Ie what about thymidine voltage 35 group 1?
## Are you assigning group 1 based on size and intensity?
mz_group <- function(mz_vals, ppm) {
  group_vec <- numeric(length(mz_vals))
  group_num <- 1L
  init_vec <- mz_vals
  names(init_vec) <- seq_along(init_vec)
  while(length(init_vec)>0){
    mz_i <- init_vec[1]
    err <- mz_i*ppm/1000000
    mz_idxs <- init_vec>mz_i-err & init_vec<mz_i+err # What does the idxs stand for?
    group_vec[as.numeric(names(mz_idxs)[mz_idxs])] <- group_num
    init_vec <- init_vec[!mz_idxs]
    group_num <- group_num+1L
  }
  group_vec
}

assign_subgroup <- function(mzs, ints, filenames){
  data_mat <- cbind(mzs, ints)
  n_centers <- ceiling(nrow(data_mat)/length(unique(filenames)))
  if(n_centers==nrow(data_mat)){
    seq_len(n_centers)
  } else {
    kmeans(data_mat, centers = n_centers)$cluster
  }
}

#msdata <- read.csv("https://raw.githubusercontent.com/IngallsLabUW/Ingalls_Standards/dbbee62372e93ff9f5992ce083f0509465f94308/MSMS/data_processed/Ingalls_Lab_Standards_MSMS.csv") %>%
msdata_pre <- ScaledforMS2 %>%
  separate_rows(MS2, sep = "; ") %>%
  separate(MS2, sep = ", ", into = c("mz", "int")) %>%
  mutate(int=as.numeric(int)) %>%
  mutate(mz=as.numeric(mz)) %>%
  arrange(desc(int)) %>%
  group_by(compound_name, voltage) %>%
  # Create the groups within compound_name and voltage
  mutate(frag_group = mz_group(mz, ppm = 5)) 

v <- msdata_pre %>%
  filter(str_detect(filename, "Mix1")) %>%
  filter(compound_name=="Glycine betaine") %>%
  group_by(voltage, frag_group) %>%
  # filter(voltage==20, frag_group==1) %>%
  mutate(sub_group=assign_subgroup(mz, int, filename))

msdata_final <- msdata_pre %>%
  group_by(frag_group, .add = TRUE) %>%
  # Do any filtering you want here
  # E.g. choose only the largest fragment from each fragment group per file
  group_by(filename, .add = TRUE) %>%
  slice(1) %>%
  ungroup(filename) %>%
  # E.g. only include fragments that appear in more than one file
  # Could be increased with more files!
  mutate(n=n()) %>%
  filter(n>=2) %>%
  # Take the median of the mz and intensity
  summarise(mz=median(mz), int=median(int)) %>% # originally mean
  summarise(MS2=paste(mz, int, sep = ", ", collapse = "; "))

variance_test <- msdata_pre %>%
  ungroup() %>% 
  group_by(voltage, compound_name, filename) %>%
  mutate(variance_mz = var(mz)) %>%
  mutate(variance_int = var(int)) %>%
  select(voltage, compound_name, filename, variance_mz, variance_int) %>%
  unique()

