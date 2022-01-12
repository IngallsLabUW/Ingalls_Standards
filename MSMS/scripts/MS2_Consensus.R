library(tidyverse)

## Will's code: Edits made by Regina

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


# Import complete five-run MSMS data and original standards list
Ingalls_Lab_Standards <- read.csv("Ingalls_Lab_Standards.csv") %>%
  select(compound_name = Compound_Name, HILIC_Mix) %>%
  unique()
Ingalls_Lab_Standards_MSMS <- read.csv("MSMS/data_processed/Ingalls_Lab_Standards_MSMS.csv") %>%
  left_join(Ingalls_Lab_Standards, by = "compound_name") %>%
  filter(str_detect(filename, HILIC_Mix)) %>%
  select(-HILIC_Mix)

# Scale the intensity to 100 and filter out intensities < 0.5
ScaledforMS2 <- Ingalls_Lab_Standards_MSMS %>%
  drop_na() %>%
  rowwise() %>%
  mutate(ScaleMS2Intensity(MS2))

# Separate, arrange MS2 data, assign fragment group
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

subgroup_test <- msdata_pre %>%
  filter(voltage==20 & compound_name=="Trehalose") %>%
  group_by(voltage, frag_group) %>% 
  mutate(sub_group=assign_subgroup(mz, int, filename))

full_subgroup_test <- msdata_pre %>%
  filter(voltage==20) %>%
  group_by(frag_group, compound_name) %>% 
  mutate(sub_group=assign_subgroup(mz, int, filename))

# Visualize
subgroup_test %>% filter(voltage==20) %>% ggplot() + 
  geom_point(aes(x=mz, y=int, color=filename)) + facet_wrap(~frag_group, scales = "free")
subgroup_test %>% filter(voltage==20) %>% ggplot() + 
  geom_point(aes(x=mz, y=int, color=factor(sub_group))) + facet_wrap(~frag_group, scales = "free")


# "Finalize" with filtering
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
  summarise(mz=median(mz), int=median(int)) %>%
  summarise(MS2=paste(mz, int, sep = ", ", collapse = "; "))
