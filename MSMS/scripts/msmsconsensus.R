
library(tidyverse)
init_dat <- read_csv(r"(MSMS\data_processed\Ingalls_Lab_Standards_MSMS.csv)")

mz_group <- function(mz_vals, ppm){
  group_vec <- numeric(length(mz_vals))
  group_num <- 1L
  init_vec <- mz_vals
  names(init_vec) <- seq_along(init_vec)
  while(length(init_vec)>0){
    mz_i <- init_vec[1]
    err <- mz_i*ppm/1000000
    mz_idxs <- init_vec>mz_i-err & init_vec<mz_i+err
    group_vec[as.numeric(names(mz_idxs)[mz_idxs])] <- group_num
    init_vec <- init_vec[!mz_idxs]
    group_num <- group_num+1L
  }
  group_vec
}

# dat %>%
#   filter(compound_name=="L-Alanine") %>% 
#   separate_rows(MS2, sep = "; ") %>%
#   separate(MS2, into = c("mz", "int"), sep = ", ") %>%
#   mutate(mz=as.numeric(mz)) %>%
#   mutate(int=as.numeric(int)) %>%
#   group_by(filename, voltage) %>%
#   mutate(int=int/max(int)*100) %>%
#   ungroup() %>%
#   arrange(desc(int)) %>%
#   mutate(mz_group=mz_group(mz, ppm = 10)) %>%
#   filter(mz_group%in%sort(unique(mz_group))[1:20]) %>%
#   ggplot() +
#   geom_point(aes(x=mz, y=int, color=factor(mz_group), group=filename)) +
#   facet_wrap(~voltage, ncol=1)
# plotly::ggplotly()


#' General plan:
#' 1. Find and parse fragments for a given compound
#' 2. Group those fragments into clusters (currently done via custom mz_group)
#' 3. Identify "good" fragments - those that are robust across multiple files
#'   - Done by hierarchical clustering (hclust)
#'   - Cluster fragments in m/z space 
#'     - Could be intensity too but not currently implemented
#'   - Cut the tree into clusters based on a cut height that produces the most
#'     groups with 5 +/- 1 fragment
#'  4. Calculate mean m/z and intensity for each cluster of "good" fragments
#'  5. Repeat for each voltage separately
#'  6. Repeat for each compound separately
# Takes about a minute to run
conMS2_dat <- init_dat %>%
  mutate(polarity=str_extract(filename, "pos|neg")) %>% 
  distinct(compound_name, polarity) %>%
  # Loop over each compound separately, expect a single character vector back
  mutate(consensus_MS2=map_chr(compound_name, function(cmpd_name){
    print(cmpd_name)
    # Grab the fragments associated with a given file
    # Parse into tidy format (cols for name, mz, int)
    # Normalize to % of largest fragment in a given file/voltage
    # Group in m/z space
    # Remove fragments less than 1% the intensity of the largest one
    meth_frags <- init_dat %>%
      filter(compound_name==cmpd_name) %>% 
      separate_rows(MS2, sep = "; ") %>%
      separate(MS2, into = c("mz", "int"), sep = ", ") %>%
      mutate(mz=as.numeric(mz)) %>%
      mutate(int=as.numeric(int)) %>%
      group_by(filename, voltage) %>%
      mutate(int=int/max(int)*100) %>%
      ungroup() %>%
      arrange(desc(int)) %>%
      mutate(mz_group=mz_group(mz, ppm = 10)) %>%
      filter(int>1)
    # Loop over each voltage separately, expect single character vector back
    all_volts <- sort(unique(meth_frags$voltage))
    map_chr(all_volts, function(volts_i){
      good_frags <- meth_frags %>%
        filter(voltage==volts_i)
      
      # Create hierarchical clustering tree
      # Using Euclidean distance in m/z space
      hc <- good_frags %>%
        select(mz) %>%
        dist() %>%
        hclust()
      
      # Test multiple possible cut heights
      # Typically around 0.01 seems to work well but does vary (why?)
      cutree_output <- cutree(hc, h = 10^c(-5:5)) %>%
        as.data.frame() %>%
        cbind(good_frags, .) %>%
        pivot_longer(cols = -everything(names(good_frags)), names_to = "cut_height", 
                     values_to = "cluster") %>%
        mutate(cut_height=as.numeric(cut_height))
      # Choose the best possible cut height based on the one that produces the most
      # fragment clusters of 5 (because there's 5 files and we want "good" 
      # fragments to show up in all 5 files)
      best_cut_height <- cutree_output %>%
        group_by(cut_height, cluster) %>%
        count() %>%
        group_by(cut_height) %>%
        filter(n%in%c(4:6)) %>%
        count() %>%
        ungroup() %>%
        arrange(desc(n)) %>%
        filter(n==n[1]) %>%
        summarize(cut_height=10^floor(mean(log10(cut_height)))) %>%
        pull(cut_height)
      # Use ideal cut height to separate tree
      # Only keep clusters that are in 5 +/- 1 file (one dups/missing ok)
      consistent_frags <- cutree_output %>%
        filter(cut_height==best_cut_height) %>%
        group_by(mz_group) %>%
        filter(n()%in%c(4:6))
      if(nrow(consistent_frags)==0){
        return("") # Sometimes you get zero frags that are "good", oh well
      }
      
      # Calculate average statistics for each fragment
      # Mean for m/z because it feels right?
      # Median for intensity because we want to avoid skew due to outliers
      # Paste into consistent format string ("mz1, int1; mz2, int2; " etc.)
      consistent_frags %>%
        summarise(mz=round(mean(mz), 5), 
                  int=round(median(int), 1), 
                  voltage=unique(voltage)) %>%
        group_by(voltage) %>%
        summarise(MS2=paste(mz, int, sep = ", ", collapse = "; ")) %>%
        pull(MS2)
    }) %>% 
      # Paste into consistent format string 
      # "voltage_1 MS2s_from_voltage_1: voltage_2 MS2s_from_voltage_2: " etc.)
      paste(all_volts, ., sep="V ", collapse = ": ")
  }))

# Unit test check that output can be parsed
# First separate voltages into different rows, then parse into separate columns
# Next separate mz/int pairs into different rows, then parse into columns
conMS2_dat %>%
  separate_rows(consensus_MS2, sep = ": ") %>%
  separate(consensus_MS2, into = c("voltage", "MS2"), sep = "V ") %>%
  separate_rows(MS2, sep = "; ") %>%
  separate(MS2, into = c("mz", "int"), sep = ", ") %>%
  mutate(mz=as.numeric(mz), int=as.numeric(int))

out_file_name <- "MSMS/data_processed/Ingalls_Lab_Standards_MSMS_consensed.csv"
write.csv(conMS2_dat, out_file_name, row.names = FALSE)
