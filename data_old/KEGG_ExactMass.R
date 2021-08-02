##############################################################
masspath <- "http://rest.kegg.jp/find/compound/exact_mass"	
emass <- GET(url = masspath) %>%
  content()
tmass <- read.csv(text = gsub("\t\n", "", emass), sep = "\t", header = FALSE, col.names = c("cmpd", "exact_mass"))