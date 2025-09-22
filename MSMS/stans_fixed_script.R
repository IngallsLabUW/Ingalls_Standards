
library(tidyverse)
library(DBI)
options(pillar.sigfig=7)

stans <- read_csv("Ingalls_Lab_Standards.csv") %>%
  filter(Column=="HILIC") %>%
  select(compound_name=Compound_Name, formula=Empirical_Formula, compound_type=Compound_Type, mz) %>%
  distinct()
# write_csv(stans, "MSMS/stans_original.csv")
atom_masses <- tribble(
  ~element, ~mass,
  "C", 12,
  "H", 1.007825,
  "N", 14.003074,
  "O", 15.994915,
  "P", 30.973763,
  "S", 31.972072,
  "As", 74.921596,
  "H(2)", 2.014102,
  "C(13)", 13.003355,
  "N(15)", 15.000109,
  "+", -0.00054858,
  "-", 0.00054858
)

stan_masses <- read_csv("MSMS/stans_fixed.csv") %>%
  # filter(compound_name=="Adenosine monophosphate, 15N5") %>%
  separate_rows(formula, sep = "(?=[[:upper:]]|\\+|\\-)") %>%
  filter(formula!="") %>%
  mutate(count=as.numeric(str_extract(formula, "\\d+$"))) %>%
  mutate(count=ifelse(is.na(count), 1, count)) %>%
  mutate(element=str_remove(formula, "\\d+$")) %>%
  left_join(atom_masses) %>%
  summarise(mono_mass=sum(mass*count), .by = c(compound_name, polarity, best_adduct, rtmin, rtmax)) %>%
  mutate(mz=case_when(
    best_adduct=="[M+H]+"~mono_mass+1.007276,
    best_adduct=="[M-H]-"~mono_mass-1.007276,
    best_adduct=="[M]+"~mono_mass,
    best_adduct=="[M]-"~mono_mass,
    TRUE~mono_mass
  ))

stan_mixes <- read_csv("HILIC_Stds_SeparateMixes.csv") %>% 
  rename(compound_name=Compound) %>%
  mutate(compound_name=str_replace(compound_name, "Sulfolactic acid", "3-Sulfolactate")) %>%
  mutate(compound_name=str_replace(compound_name, "Sodium 2-mercaptoethanesulfonate", "2-mercaptoethanesulfonic acid")) %>%
  mutate(compound_name=str_replace(compound_name, "Sodium taurocholate", "Taurocholic acid"))
stan_df <- stan_masses %>%
  left_join(stan_mixes) %>%
  filter(!is.na(Mix) | str_detect(compound_name, ", "))

con <- dbConnect(duckdb::duckdb(), r"(Z:\1_QEdata\2025\250911_HILIC_StandardMixes_Separate\msdata_combined.duckdb)")
stan_df %>%
  filter(compound_name=="Adenosine monophosphate, 15N5") %>%
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
dbDisconnect(con)


# Get EIC data
con <- dbConnect(duckdb::duckdb(), r"(Z:\1_QEdata\2025\250911_HILIC_StandardMixes_Separate\msdata_combined.duckdb)")
dbExecute(con, "PRAGMA disable_progress_bar;")
all_eics <- stan_df %>%
  # slice(1) -> row_data
  pmap(function(...){
    row_data <- data.frame(...)
    row_data %>%
      mutate(lower_bound=mz*(1-5/1e6), upper_bound=mz*(1+5/1e6)) %>%
      mutate(polarity=ifelse(str_detect(best_adduct, "\\+$"), "pos", "neg")) %>%
      mutate(query=paste("SELECT * FROM MS1 WHERE mz BETWEEN", lower_bound, "AND", upper_bound, "AND polarity =", paste0("'", polarity, "'"))) %>%
      pull(query) %>%
      dbGetQuery(conn=con) %>%
      slice_max(int, by=c(filename, rt, polarity)) %>%
      mutate(file_type=str_extract(filename, "Blk|Mix\\d|IS")) %>%
      mutate(compound_name=row_data$compound_name)
  }, .progress = TRUE) %>%
  bind_rows()
dbDisconnect(con)


# Extract peak RTs
write_csv(data.frame(compound_name=character(), rtmin=numeric(), rtmax=numeric()), "stan_df.csv")
walk(stan_df$compound_name, function(name_i){
  print(name_i)
  mix_i <- stan_df$Mix[stan_df$compound_name==name_i]
  gp <- all_eics %>%
    filter(compound_name==name_i) %>%
    ggplot() +
    geom_line(aes(x=rt, y=int, group=filename, color=file_type)) +
    scale_x_continuous(breaks = 0:25) +
    theme_bw() +
    theme(plot.title = element_text(color=scales::hue_pal()(8)[mix_i+2][1])) +
    ggtitle(name_i)
  x11(width = 16, height = 6)
  print(gp)
  rt_vals <- ggmap::gglocator(n = 2, mercator = FALSE)$rt
  dev.off()
  write_csv(data.frame(compound_name=name_i, rtmin=rt_vals[1], rtmax=rt_vals[2]), "stan_df.csv", append = TRUE)
})


# Render peaks for confirmation
pdf("stan_obs.pdf", width = 8, height=4)
walk(stan_df$compound_name, function(name_i){
  mix_i <- stan_df$Mix[stan_df$compound_name==name_i]
  gp <- all_eics %>%
    filter(compound_name==name_i) %>%
    ggplot() +
    geom_line(aes(x=rt, y=int, group=filename, color=file_type)) +
    geom_vline(xintercept = stan_df$rtmin[stan_df$compound_name==name_i], color="green") +
    geom_vline(xintercept = stan_df$rtmax[stan_df$compound_name==name_i], color="red") +
    scale_x_continuous(breaks = 0:25) +
    theme_bw() +
    theme(plot.title = element_text(color=scales::hue_pal()(8)[mix_i+2][1])) +
    ggtitle(name_i)
  print(gp)
}, .progress=TRUE)
dev.off()

# Recalculate masses
obs_mzs <- stan_df %>%
  mutate(file_type=ifelse(is.na(Mix), "IS", paste0("Mix", Mix))) %>%
  mutate(polarity=ifelse(str_detect(best_adduct, "\\+$"), "pos", "neg")) %>%
  pmap(function(...){
    row_data <- data.frame(...)
    eic_i <- all_eics %>%
      filter(compound_name==row_data$compound_name) %>%
      filter(rt>row_data$rtmin) %>% 
      filter(rt<row_data$rtmax) %>%
      filter(file_type==row_data$file_type) %>%
      filter(str_detect(polarity, row_data$polarity))
    eic_i %>%
      summarise(obs_mz=weighted.mean(mz, int), 
                obs_rt=weighted.mean(rt, int),
                .by = filename) %>%
      summarise(obs_mz=mean(obs_mz), obs_rt=mean(obs_rt)) %>%
      mutate(compound_name=row_data$compound_name) %>%
      left_join(row_data, by = join_by(compound_name))
}, .progress=TRUE) %>%
  bind_rows()

obs_mzs %>%
  select(compound_name, best_adduct, polarity, rtmin, rtmax, mono_mass, mz, obs_mz, file_type) %>%
  write_csv("MSMS/MSMS_stan_data.csv")
