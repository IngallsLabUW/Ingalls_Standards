
library(tidyverse)
library(DBI)
options(pillar.sigfig=7)

stan_bounds <- read_csv("MSMS/MSMS_stan_bounds.csv")

stan_data <- stan_bounds %>%
  select(-mz, -obs_mz) %>%
  mutate(best_adduct=ifelse(polarity=="both", list(c("[M+H]+", "[M-H]-")), best_adduct)) %>%
  mutate(polarity=ifelse(polarity=="both", list(c("pos", "neg")), polarity)) %>%
  unnest(c(polarity, best_adduct)) %>%
  mutate(mz=case_when(
    best_adduct=="[M+H]+"~mono_mass+1.007276,
    best_adduct=="[M-H]-"~mono_mass-1.007276,
    TRUE~mono_mass
  ))

con <- dbConnect(duckdb::duckdb(), r"(Z:\1_QEdata\2025\250911_HILIC_StandardMixes_Separate\msdata_combined.duckdb)")
dbExecute(con, "PRAGMA disable_progress_bar;")
stan_data %>%
  filter(compound_name=="Uracil") %>%
  slice(1) %>%
  print() %>%
  mutate(lower_bound=mz*(1-5/1e6), upper_bound=mz*(1+5/1e6)) %>%
  mutate(polarity=ifelse(str_detect(best_adduct, "\\+$"), "pos", "neg")) %>%
  mutate(query=paste("SELECT * FROM MS1 WHERE mz BETWEEN", lower_bound, "AND", upper_bound, "AND polarity =", paste0("'", polarity, "'"))) %>%
  pull(query) %>%
  print() %>%
  dbGetQuery(conn=con) %>%
  slice_max(int, by=c(filename, rt, polarity)) %>%
  mutate(file_type=str_extract(filename, "Blk|Mix\\d|IS")) %>%
  ggplot() +
  geom_line(aes(x=rt, y=int, group=filename, color=file_type)) +
  scale_x_continuous(breaks = 0:25) +
  theme_bw()

stan_ms2s <- stan_data %>%
  pmap(function(...){
    row_data <- data.frame(...)
    row_data %>%
      mutate(lower_bound=mz*(1-5/1e6), upper_bound=mz*(1+5/1e6)) %>%
      mutate(polarity=ifelse(str_detect(best_adduct, "\\+$"), "pos", "neg")) %>%
      mutate(query=paste("SELECT * FROM MS2 WHERE premz BETWEEN", lower_bound, "AND", upper_bound, 
                         "AND polarity =", paste0("'", polarity, "'"), 
                         "AND rt BETWEEN", rtmin, "AND", rtmax, 
                         "AND filename LIKE", paste0("'%", file_type, "%'"))) %>%
      pull(query) %>%
      dbGetQuery(conn=con) %>%
      mutate(compound_name=row_data$compound_name) %>%
      left_join(row_data, by = join_by(polarity, compound_name))
  }, .progress = TRUE) %>%
  bind_rows()
dbDisconnect(con)


stan_ms2s %>%
  group_by(compound_name, polarity) %>%
  arrange(desc(int)) %>%
  mutate(mz_group=RaMS::mz_group(fragmz, 10, max_groups = 20, min_group_size = 15)) %>%
  filter(!is.na(mz_group)) %>%
  ungroup() %>%
  summarise(mz_group=round(mean(fragmz), 5), .by = c(compound_name, polarity, mz_group)) %>%
  mutate(compound_name=factor(compound_name, levels = unique(stan_ms2s$compound_name))) %>%
  arrange(compound_name, desc(polarity)) %>%
  write_csv("MSMS/frag_quality_init.csv")

pdf("MSMS/ms2_chroms.pdf", width = 8, height=5)
stan_ms2s %>%
  distinct(compound_name, polarity, mz) %>%
  # slice(1:20) %>%
  # slice(33) -> row_data
  pwalk(function(...){
    row_data <- data.frame(...)
    ms2_frags <- row_data %>%
      left_join(stan_ms2s, by = join_by(polarity, compound_name)) %>%
      arrange(desc(int)) %>%
      mutate(mz_group=RaMS::mz_group(fragmz, 10, max_groups = 20, min_group_size = 15)) %>%
      filter(!is.na(mz_group)) %>%
      mutate(mz_group=fct_inorder(as.character(round(mean(fragmz), 5))), .by = mz_group)
    if(nrow(ms2_frags)==0){
      gp <- ggplot() + geom_blank() +
        ggtitle(paste0(row_data$compound_name, " (", row_data$polarity, ") ", row_data$mz))
    } else {
      gp <- ms2_frags %>%
        ggplot() +
        geom_line(aes(x=rt, y=int, group=filename)) +
        facet_wrap(~mz_group, scales="free_y") +
        ggtitle(paste0(row_data$compound_name, " (", row_data$polarity, ") ", row_data$mz))
    }
    print(gp)
  }, .progress = TRUE)
dev.off()



best_frags <- read_csv("MSMS/frag_quality.csv") %>%
  filter(!is.na(quality)) %>%
  select(compound_name, polarity, mz_group, quality) %>%
  mutate(mzmin=mz_group*(1-10/1e6), mzmax=mz_group*(1+10/1e6)) %>%
  left_join(stan_ms2s, by = join_by(polarity, compound_name, between(y$fragmz, x$mzmin, x$mzmax))) %>%
  group_by(compound_name, polarity, mz, rtmin, rtmax, mz_group, quality, filename) %>%
  summarise(fragmz=weighted.mean(fragmz, int), first_scan=min(scan_idx), int=mean(int), .groups = "drop_last") %>%
  summarise(fragmz=mean(fragmz), int=mean(int), first_scan=min(first_scan), .groups = "drop") %>%
  select(-mz_group) %>%
  arrange(mz)

# best_frags %>%
#   mutate(mz_group=RaMS::mz_group(fragmz, 10)) %>%
#   filter(!is.na(mz_group)) %>%
#   mutate(mz_group=fct_inorder(as.character(round(mean(fragmz), 5))), .by = mz_group) %>%
#   count(mz_group, polarity) %>%
#   arrange(desc(n)) %>%
#   print(n=20)
# best_frags %>%
#   mutate(neutral_loss=mz-fragmz) %>%
#   filter(neutral_loss>1) %>%
#   mutate(mz_group=RaMS::mz_group(neutral_loss, 10)) %>%
#   filter(!is.na(mz_group)) %>%
#   mutate(mz_group=fct_inorder(as.character(round(mean(neutral_loss), 5))), .by = mz_group) %>%
#   count(mz_group, polarity) %>%
#   arrange(desc(n)) %>%
#   print(n=20)

best_frags %>%
  mutate(neutral_loss=mz-fragmz) %>%
  arrange(neutral_loss) %>%
  filter(neutral_loss< -2)

write_csv(best_frags, "MSMS/best_frags.csv")
