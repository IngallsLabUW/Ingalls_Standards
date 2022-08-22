library(lsa)
library(tidyverse)

# WKumler function to assign intensity subgroups within fragment groups
assign_subgroup <- function(mzs, ints, filenames){
  data_mat <- cbind(mzs, ints)
  n_centers <- ceiling(nrow(data_mat)/length(unique(filenames)))
  if(n_centers==nrow(data_mat)){
    seq_len(n_centers)
  } else {
    kmeans(data_mat, centers = n_centers)$cluster
  }
}

# WKumler function to assign fragment group based on m/z
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

# RML function for scaling raw MS2 intensity data
ScaleMS2Intensity <- function(scan) {
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

# RML/KRH function for finding cosine similarity
MS2CosineSimilarity <- function(scan1, scan2) {
  
  weight1 <- (scan1[, 1] ^ 2) * sqrt(scan1[, 2])
  weight2 <- (scan2[, 1] ^ 2) * sqrt(scan2[, 2])
  
  diff.matrix <- sapply(scan1[, 1], function(x) scan2[,1] - x)
  
  same.index <- which(abs(diff.matrix[[1]]) < 0.02, arr.ind = TRUE)
  cosine.similarity <- sum(weight1[same.index[, 2]] * weight2[same.index[, 1]]) /
    (sqrt(sum(weight2 ^ 2)) * sqrt(sum(weight1 ^ 2)))
  
  return(cosine.similarity)
}


# Import complete five-run MSMS data and original standards list
# Scale intensity to 100 and filter out intensities < 0.5
Ingalls_Lab_Standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(compound_name = Compound_Name, HILIC_Mix) %>%
  drop_na() %>%
  unique()
Ingalls_Lab_Standards_MSMS <- read.csv("MSMS/data_processed/Ingalls_Lab_Standards_MSMS.csv") %>%
  left_join(Ingalls_Lab_Standards, by = "compound_name") %>%
  filter(str_detect(filename, HILIC_Mix)) %>%
  select(-HILIC_Mix) %>%
  drop_na() %>%
  rowwise() %>%
  mutate(ScaleMS2Intensity(MS2))

# Separate MS2 data from concatenated format, assign fragment group
msdata_frags <- Ingalls_Lab_Standards_MSMS %>%
  separate_rows(MS2, sep = "; ") %>%
  separate(MS2, sep = ", ", into = c("mz", "int")) %>%
  mutate(int=as.numeric(int)) %>%
  mutate(mz=as.numeric(mz)) %>%
  arrange(desc(int)) %>%
  group_by(compound_name, voltage) %>%
  # Create the groups within compound_name and voltage
  mutate(frag_group = mz_group(mz, ppm = 5)) 

# Create intensity subgroups
intensity_subgroups <- msdata_frags %>%
  #filter(voltage==20) %>% # and compound name for specific visualizations
  group_by(frag_group, compound_name, voltage) %>% 
  mutate(sub_group=assign_subgroup(mz, int, filename))

## Option 2 test run
option2 <- intensity_subgroups %>%
  group_by(compound_name, voltage, frag_group, filename) %>%
  top_n(1, int) %>%
  slice_sample() %>%
  filter(compound_name == "Gonyol" & voltage == 20)

scan1 <- option2 %>%
  filter(!str_detect(filename, "pos5")) %>%
  group_by(frag_group) %>%
  mutate(mz = median(mz)) %>%
  mutate(int = median(int)) %>%
  ungroup() %>%
  select(mz, int) %>%
  unique()

scan2 <- option2 %>%
  filter(str_detect(filename, "pos5")) %>%
  ungroup() %>%
  select(mz, int)

## Find the cosine similarity of the other files to file 5


# ------------------------
# "Finalize" with filtering
msdata_final <- msdata_frags %>%
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
  summarise(mz=median(mz), int=median(int)) %>%
  summarise(MS2=paste(mz, int, sep = ", ", collapse = "; "))
