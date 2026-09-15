MSMS data for Ingalls Lab Standards
================

This folder handles MSMS information for the Ingalls Lab Standards.

## Structure:
### data_raw 
*(This folder is NOT completely synced with GitHub due to size, instead find the required data on [our shared Google Drive)](https://drive.google.com/drive/folders/1k32PVbBVRGE7lMWOGLqORcbBhhbyhZ_a)*

 - .mzML files: Open-source versions of the QExactive HF data acquired when
running our standard mixes in DDA mode. 
 - .csv file: A Skyline output file containing manually corrected retention times for
each compound. 

For questions on acquisition and manual retention times, contact Laura T. Carlson (truxal@uw.edu).

### scripts

 - `extract_DDA.R`: An R script that uses the `RaMS` library to open the .mzML files, 
extract the MS2 information for each compound, and create a 
simple output .csv file containing compound name, fragmentation energy, and fragment data.
 - `msmsconsensus.R`: An R script that takes the `extract_DDA.R` output and creates
 a single "consensus" MSMS spectrum instead of having a separate spectrum for each
 replicate injection (pos1, pos2, pos3, pos4, pos5, etc.) and collapses the multiple
 voltages into a single string.

### data_processed

 - Ingalls_Lab_Standards_MSMS.csv: The file produced by `extract_DDA.R`, containing 
compound name, fragmentation energy (aka voltage), and the actual fragments observed.
The fragment data is encoded as a single string per compound and voltage as `fragment 
mass, intensity;`. Charge (z) is included as a a distinguishing column between
fragments from positive and negative mode.

| voltage|MS2                                                                                                                                                                                                                                                                                                     |compound_name                      |filename                              |
|-------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------|:-------------------------------------|
|      20|52.4572, 242112; 60.08158, 17899636; 61.34214, 270615; 68.56908, 237145; 68.57156, 238094; 87.04469, 33288588; 119.27773, 252823; 130.94186, 227040; 137.05507, 267310; 146.11768, 70184896                                                                                                             |(3-Carboxypropyl)trimethylammonium |210420_Std_4uMStdsMix1InH2O_pos1.mzML |
|      35|57.81886, 266419; 58.12984, 262331; 59.60612, 242913; 60.08158, 21468594; 76.95262, 252565; 80.1388, 272781; 87.0447, 38475960; 90.42149, 299105; 95.55755, 225376; 98.8059, 251414; 100.20339, 281069; 101.04132, 273768; 116.98755, 236412; 140.35153, 227516; 146.11771, 78073048                    |(3-Carboxypropyl)trimethylammonium |210420_Std_4uMStdsMix1InH2O_pos1.mzML |
|      50|59.47475, 247352; 60.08158, 24446386; 63.29225, 263250; 71.00157, 261762; 87.04468, 60725936; 146.11771, 24082852; 156.17685, 233650                                                                                                                                                                    |(3-Carboxypropyl)trimethylammonium |210420_Std_4uMStdsMix1InH2O_pos1.mzML |
|     100|50.14535, 253841; 51.04193, 210975; 58.06596, 2827728; 59.07373, 637747; 60.08159, 6656330; 66.0391, 216584; 87.04172, 528734; 87.04469, 8171526; 87.04769, 442505; 94.40489, 227656; 104.44958, 258730; 132.04352, 221628; 139.43246, 224224; 147.67267, 262983                                        |(3-Carboxypropyl)trimethylammonium |210420_Std_4uMStdsMix1InH2O_pos1.mzML |
|      20|51.65563, 241585; 60.08156, 20915792; 62.47221, 233602; 63.23011, 274622; 71.7324, 268294; 87.04466, 35828132; 90.96731, 262637; 93.12482, 252549; 100.05029, 259807; 102.47884, 247098; 127.40302, 257141; 146.11763, 75864408                                                                         |(3-Carboxypropyl)trimethylammonium |210420_Std_4uMStdsMix1InH2O_pos2.mzML |
|      35|51.05899, 249696; 51.33501, 263859; 53.27106, 255025; 53.89771, 239715; 55.55375, 264999; 57.64857, 262411; 60.08157, 22786554; 65.53525, 262263; 68.14494, 238992; 71.06126, 255835; 86.30653, 236989; 87.04466, 42413388; 107.16145, 280212; 123.99916, 299694; 146.11765, 83088840; 153.6828, 305777 |(3-Carboxypropyl)trimethylammonium |210420_Std_4uMStdsMix1InH2O_pos2.mzML |

 - Ingalls_Lab_Standards_MSMS_Consensed.csv: The file produced by `msmsconsensus.R`,
 a flat CSV containing one column for compound name, one for the polarity
 and another for the consensus MSMS spectrum with multiple voltages.
 
 |compound_name                      |polarity |consensus_MS2                                                                                                                                                                                                                    |
|:----------------------------------|:--------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|(3-Carboxypropyl)trimethylammonium |pos      |20V 146.11767, 100; 87.04469, 47.4; 60.08157, 26.5: 35V 146.1177, 100; 87.0447, 51.2; 60.08158, 27.5: 50V 146.11769, 37.8; 87.04468, 100; 60.08158, 41.6: 100V 87.04469, 100; 60.08158, 90.2; 58.06595, 35.2; 59.07376, 7.8      |
|2,3-Pyridinedicarboxylic acid      |pos      |20V 168.06919, 1.6: 35V 112.03975, 1.3; 168.06932, 1.7: 50V 108.99589, 1.9; 86.07191, 1.8; 119.06927, 1.4: 100V 126.0223, 6.1; 87.0797, 3.3; 108.99583, 3.1; 86.07195, 2.6; 58.0659, 1.8; 50.01591, 1.9                          |
|2-Heptyl-3-hydroxy-quinolone       |pos      |20V : 35V : 50V 188.07073, 1.7: 100V 119.07335, 2.7; 174.05532, 2.5; 91.05474, 2.1; 115.05459, 2.2; 129.05762, 1.7; 92.06256, 1.5; 105.03388, 1.7; 78.04701, 1.6; 132.08101, 1.7; 117.05759, 1.4; 103.05462, 1.5; 128.04973, 1.5 |
|4-Aminobutyric acid                |pos      |20V 87.04468, 100; 69.03423, 18.3; 68.05023, 1.9: 35V 87.04468, 100; 69.03424, 18.6; 57.03434, 19; 68.05025, 1.8: 50V 68.05026, 2: 100V 87.0446, 11.3; 69.03418, 25.3                                                            |
|5-Hydroxyectoine                   |pos      |20V 83.06105, 1.4; 117.06631, 1.9; 159.12113, 2.5: 35V 159.12116, 2.8; 99.05591, 1.1: 50V 58.066, 2.4; 59.06928, 1.3; 159.12115, 1.6; 82.02942, 1.2; 96.05305, 1.1: 100V 59.06931, 2.2; 72.04297, 1.9; 71.06116, 1.1             |
|5-Methylcytosine                   |pos      |20V : 35V : 50V : 100V 66.0347, 1.5; 67.04248, 1.5; 69.00917, 1.5 

#### Data format for MS2 strings
We ended up needing a format slightly more compact than every m/z-int pair on its own row because our CSV files got large and unwieldy when we did that. Instead, we decided to create mz/int pairs in string format and separated m/z and int with a comma, then used semicolons to separate the additional pairs from other fragments ("mz, int; mz, int;"). To compress multiple voltages onto the same line as well we used colons, with a "V " to denote the numerical voltage collision energy ("20V <MS2string from above>: 35V <MS2string from above>"). m/z values have been rounded to the fifth decimal place; intensity values have been rounded to the integer or first decimal.

Example of the MS2 string for TMAB: "20V 146.11767, 100; 87.04469, 47.4; 60.08157, 26.5: 35V 146.1177, 100; 87.0447, 51.2; 60.08158, 27.5: 50V 146.11769, 37.8; 87.04468, 100; 60.08158, 41.6: 100V 87.04469, 100; 60.08158, 90.2; 58.06595, 35.2; 59.07376, 7.8"

In table format: 

|compound_name                      |polarity |voltage |        mz|   int|
|:----------------------------------|:--------|:-------|---------:|-----:|
|(3-Carboxypropyl)trimethylammonium |pos      |20      | 146.11767| 100.0|
|(3-Carboxypropyl)trimethylammonium |pos      |20      |  87.04469|  47.4|
|(3-Carboxypropyl)trimethylammonium |pos      |20      |  60.08157|  26.5|
|(3-Carboxypropyl)trimethylammonium |pos      |35      | 146.11770| 100.0|
|(3-Carboxypropyl)trimethylammonium |pos      |35      |  87.04470|  51.2|
|(3-Carboxypropyl)trimethylammonium |pos      |35      |  60.08158|  27.5|
|(3-Carboxypropyl)trimethylammonium |pos      |50      | 146.11769|  37.8|
|(3-Carboxypropyl)trimethylammonium |pos      |50      |  87.04468| 100.0|
|(3-Carboxypropyl)trimethylammonium |pos      |50      |  60.08158|  41.6|
|(3-Carboxypropyl)trimethylammonium |pos      |100     |  87.04469| 100.0|
|(3-Carboxypropyl)trimethylammonium |pos      |100     |  60.08158|  90.2|
|(3-Carboxypropyl)trimethylammonium |pos      |100     |  58.06595|  35.2|
|(3-Carboxypropyl)trimethylammonium |pos      |100     |  59.07376|   7.8|

Conversion from table format to MS2string can be done using `paste(mz, int, sep=", ", collapse="; ")` for a single voltage and `paste(voltage, MS2string, sep="V ", collapse = ": ")` for multiple voltages.

Conversion from MS2string to table format can be done concisely using `tidyr` and `dplyr`:

```
dataframe_with_MS2string_in_consensusMS2_column %>%
  separate_rows(consensus_MS2, sep = ": ") %>%
  separate(consensus_MS2, into = c("voltage", "MS2"), sep = "V ") %>%
  separate_rows(MS2, sep = "; ") %>%
  separate(MS2, into = c("mz", "int"), sep = ", ") %>%
  mutate(mz=as.numeric(mz), int=as.numeric(int))
```

## Setup:

In order to access the .mzML files, you will need to set your working directory to access the shared Ingalls Drive. In the `extract_DDA.R` script, please ensure you have local access to the drive and change the setwd() command accordingly or launch the R project in the root directory of this project.
