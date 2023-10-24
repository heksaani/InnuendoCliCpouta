 ## Main changes made to Patho_typing schema

 Availability of new target genes as well as new variants of existing targets for in silico pathogenic typing  requires updating patho_tyiping tool schema. [Read more about the path_typing tool](https://github.com/B-UMMI/patho_typing)

 ### Updated typing rules:
- **STEC, tEPEC and aEPEC**: No update on patho_typing rules was done.
- **ETEC**: There are about 60 new target genes have been identified for ETEC patho_typing. Updated rule for patho_typing rule: "at least one ETEC target and no stx" 
- **EAEC**: New marker gene aggR is added and removed aaiC, aap, aat from old list. New EAEC patho_typing rule: "aggR only, NO stx, NO eae"
- **EIEC**: Removed icsA. Added ipaH7.8, ipaH9.8 and ipaD. ETEC patho_typing is based on the presence of at least one from the following  list:ipaH, ipaH7.8, ipaH9.8, ipaD.
- **Shigella ST1**: Removed icsA. Added ipaH7.8 and ipaH9.8. Patho_typing is based on the presence of at least one of ipaH, ipaH7.8, ipaH9.8 and presence of stx1
- **STEC-ETEC**: New rule for hybrid patho_typing of STEC-ETEC: At least one stx type with/without eae AND at least one ETEC marker gene
- **STEC-EAEC**: New rule for hybrid patho_typing of STEC-EAEC: At least one stx type with/without eae AND aggR

Updated typing rules are reflected in the file ""**typing_rules.tab**".

### Managing large number of variants in genes

Various combinations of 60+ ETEC genes posed some challenge in designing the schema needed for defining ETC pathogenic typing. To minimise the number of combinations of all ETEC genes in matrix,  the genes were clustered based on their similarity of raw read sequence. A representative variant (preferably, longer one) was selected from each of the five clusters to define pathogeneic typing of ETEC.  For the patho_typing of EIEC, if there are more variants, only a variant with large sequence is used.

### Updated config and fasta files of Patho_typing tool
Config settings (file name: typiing.config) in Patho_typing tool was updated as below :
- minimum_gene_coverage: 70 (previous value 60)
- minimum_gene_identity: 60 (previous value: 70). Gene_identi value was changed based on the minimum similarity value in the clusters.
  
Fasta file (file name: **typing.fasta**) was modified to reflect the updated rules in typing.

### Updated singularity image

New definition file for singularity image was made ( file name: patho_typing.def) and image was built accordingly. 

**PS**: If gene name contains ".", the tool parses it as "_" in the fasta files. Thus gene names in schema file are also named accordingly(e.g., ipaH7.8 -> ipaH7_8) to avoid errors in the analysis.  
