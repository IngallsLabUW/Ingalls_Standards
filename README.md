Ingalls Standards Repository
================
RLionheart
08/23/2022

<!--This document was created by knitting the README.Rmd file. Please edit that instead.-->

### The Ingalls Lab Standards Repository

**The Ingalls_Lab_Standards.csv** is the latest version of the list.
Please download that version for all analysis needs.

This repository contains the most recent standards list, all previous
versions, and all relational information for the standards.

#### Sections of the repository

**Add_New_Standard.Rmd**: A markdown script for creating all required
columns for entering a new standard.

**data_extra**: This folder contains supplemental information (columns
that are not part of the main standards csv but are relevant to various
processes). External downloads and all alternate compound names (ChEBI,
IUPAC, InCHL, SMILES, and Classyfire) can be found here. **If you need
to upload to CMAP or need SQL-safe names, those columns will be located
here.**

**data_old**: This folder contains information that is no longer current
for the standards, such a summarized history of the 2020 standards
overhaul, previous versions of the standards list (including all old
columns that have been archived) and original external database
downloads.

**MSMS**: Merged from a separate branch, this is a folder of mostly
*experimental* information for incorporating MSMS data into the
standards list in the future.

**src**: Mostly for archived debugging, this folder contains all of the
code for editing the standards list from older versions.

------------------------------------------------------------------------

### Naming Conventions for Compounds

*Capitalization*

-   All “Acid”s changed to “acid”, in accordance with KEGG conventions
    -   Example: 3-Sulfopyruvic Acid –\> 3-Sulfopyruvic acid
-   First appearance of compound in complete name capitalized
    -   Example: 7-dehydrocholesterol –\> 7-Dehydrocholesterol
    -   Example: thiamine pyrophosphate –\> Thiamine pyrophosphate
-   “B-compoundName” changed to beta-CompoundName
    -   Example: B-ionine –\> beta-Ionine
-   Second part of compound name lowercase
    -   Example: Glutathione Disulfide –\> Glutathione disulfide

*Abbreviations*

For shorter compound names, the column Compound_Name_Figure provides an
abbreviated version of the compound name whenever possible.

-   When possible, change compound names to acronyms
    -   Example: S-Adenosylhomocysteine –\> SAH
-   Drop prefixes for compounds.
    -   Example: L-Cystathionine –\> Cystathionine
-   Drop unnecessary commas and apostrophes.
    -   Example: Guanosine monophosphate, 15N5 –\> GMP 15N5

*Internal Standards*

-   Keep internal standard names consistent with their unlabeled
    counterparts.
    -   Example: 3-Sulfolactate, 13C3 should correspond to Sulfolactate,
        rather than Sulfolactic acid.

*Other conventions*

-   Use complete descriptive names for compounds.
    -   Example: All B12s –\> Methylcobalamin, Hydroxocobalamin, etc.
    -   All Vitamins should be listed as their descriptive name:
        Vitamine B1 –\> Thiamine, Vitamin B2 –\> Riboflavin, etc.

------------------------------------------------------------------------

### History and Previous Versions

In June of 2020 and August of 2021, significant changes were made to the
original Ingalls Standards sheet. Summarized changes are listed in the
data_old folder, and specific changes can be viewed on the git log of
this project, available at
<https://github.com/IngallsLabUW/Ingalls_Standards/commits/master>.

This includes all previous versions of the the “original” standards
list:

-   Pre June 2020 (found at
    “data_old/Ingalls_Lab_Standards_pre2020.csv”)

-   Pre August 2021 (found at
    “data_old/Ingalls_Lab_Standards_August2021.csv”)

-   Standards with all auxilary columns that have since been dropped
    (found at “data_old/Ingalls_Lab_Standards_AuxColumns.csv”)
