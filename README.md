Ingalls Standards Repository
================
RLionheart
6/3/2020

<!--This document was created by knitting the README.Rmd file. Please edit that instead.-->

### Overview

In June of 2020 and August of 2021, significant changes were made to the
original Ingalls Standards sheet. Summarized changes are listed below,
and specific changes can be viewed on the git log of this project,
available at
<https://github.com/IngallsLabUW/Ingalls_Standards/commits/master>.

### This Repository

This repository contains all the relevant information for the Ingalls
Lab Standards. This includes all previous versions of the the “original”
standards list:

-   Pre June 2020 (found at
    “data_old/Ingalls_Lab_Standards_pre2020.csv”)
-   Pre August 2021 (found at
    “data_old/Ingalls_Lab_Standards_August2021.csv”)
-   Standards with all auxilary columns that have since been dropped
    (found at “data_old/Ingalls_Lab_Standards_AuxColumns.csv”)

If you are looking to simply use the new Ingalls Standards list,
download Ingalls_Lab_Standards.csv and use accordingly. If you would
like to view a previous version of the standards, or see how changes
were made, the **Structural_Changes.Rmd** markdown file outlines the
history of changes to the original csv.

### Summarized Change Log

4/8/20: Internal standards updated to reflect consistent naming
scheme.  
4/20/20: Abbreviated compounds switched to full-length KEGG names.  
4/20/20: Adjusted compounds with incorrect capitalization.  
4/22/20: Added or removed symbols as required by KEGG names.  
4/23/20: Update last compounds not falling into the above groups.
4/23/20: Complete renaming of compounds, including those that didn’t
change from the original names. 4/28/20: Adjust vitamins to descriptive
names. 4/29/20: Adjust abbreviations for consistency. 5/8/20: FINAL
NAMES DECIDED FOR PRIMARY ID. 5/28/20: Bug fixes in final names.
5/28/20: First suggestions for Figure Name column. 6/3/20: Final Figure
Names decided. 7/30/20: ChEBI names scraped from website and added in
new column. 8/3/20: IUPAC, InCHI, and SMILES columns added to standards.
8/10/20: Classyfire classifications added for those compounds that have
them. 10/14/20: First version of SQL-safe names introduced. 10/22/20:
Remove all trailing numbers from SQL-safe names. This is the column to
be used for CMAP. 08/01/21: Columns renamed, reordered, and unnecessary
columns trimmed. 02/11/22: Supplemental columns have been moved to
data_extra/Ingalls_Lab_Standards_Supplement.csv

------------------------------------------------------------------------

#### Conventions made in Summer 2020 Revamp

*Capitalization*  
\* All “Acid”s changed to “acid”, as per KEGG conventions. Example:
3-Sulfopyruvic Acid –> 3-Sulfopyruvic acid  
\* First appearance of compound in complete name capitalized. Example:
7-dehydrocholesterol –> 7-Dehydrocholesterol, thiamine pyrophosphate –>
Thiamine pyrophosphate  
\* “B-compoundName” changed to beta-CompoundName. Example: B-ionine –>
beta_Ionine  
\* Second part of compound name lowercase. Example: Glutathione
Disulfide –> Glutathione disulfide

*Abbreviations*  
For compound names in figures, the column Compound_Name.figure provides
an abbreviated verison of the compound name whenever possible. \* When
possible, change compound names to acronyms. Example:
S-Adenosylhomocysteine –> SAH \* Drop prefixes for compounds. Example:
L-Cystathionine –> Cystathionine \* Drop unnecessary commas and
apostrophes. Example: Guanosine monophosphate, 15N5 –> GMP 15N5

*Symbols, Database Ingestions*  
To facilitate compatibility with ingestion into other databases, SQL
parsing, etc, the column Compound_Name.SQL removes any non-ASCII
characters from the Compound_Name column. This column also incorporates
the Compound_Name.figure shortened name, as those names often have
already dropped special characters. \* Example: Diacylglycerol 18:1-18:1
–> DAG 18s1_18s1

*Other specific changes*  
\* All B12s –> Methylcobalamin, Hydroxocobalamin, etc.  
\* All Vitamins changed to their descriptive name: Vitamine B1 –>
Thiamine, Vitamin B2 –> Riboflavin, etc.  
\* Remove Fraction1 and Fraction2 columns. Fix NADH and
Riboflavin-5-phosphate ionization forms and z charges (SHA 51d3d3c).

*External database ingestion* \* ChEBI names added \* IUPAC, InCHL,
SMILES names added \* Known Classyfire compound designation added
