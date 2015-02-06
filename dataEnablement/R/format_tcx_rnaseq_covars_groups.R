
# This script is used to extract clinical variables (and sample groups) from 
# the temporal cortex sample cohort of the U01 Mayo RNAseq study, which 
# includes AD and PSP samples

library(synapseClient)
library(xlsx)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

# Define paths for required Synapse objects
tcx_rnaseq_id <- "syn3157267" # pilot RNAseq covariates Excel file
clinical_folder_id <- "syn2866158" # id of destination folder
parent_folder_id <- "syn3163039" # id of parent folder

# Download files from Synapse
tcx_rnaseq_file <- synGet(tcx_rnaseq_id)
tcx_rnaseq_path <- getFileLocation(tcx_rnaseq_file)

# Define column headers from template
headers <- c("participant_id", "age_at_onset", "age_at_last_assessment", 
             "age_at_death", "post_mortem_interval", "sex", "education",
             "apoe_genotype", "race_ethnicity", "braak_stage", "mmse_at_onset",
             "mmse_at_last_assessment", "cerad")

### AD samples ###
##################

# Read AD info table to data frame
ad_rnaseq_info <- read.xlsx2(pilot_rnaseq_path, sheetIndex = 1,
                             stringsAsFactors = FALSE)

# Get clinical variables
ad_rnaseq_clinical <- ad_rnaseq_info %>%
    # pull out relevant variables from original data frame
    select(participant_id = Path_ID, age_at_diagnosis = Age, 
           sex = Sex) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis),
           sex = ifelse(sex == 0, "M", "F")) %>%
    
    # add empty columns for additional template variables
    mutate(age_at_onset = NA,
           age_at_death = NA,
           post_mortem_interval = NA,
           education = NA,
           apoe_genotype = NA,
           race_ethnicity = NA,
           braak_stage = NA,
           mmse_at_onset = NA,
           mmse_at_last_assessment = NA,
           cerad = NA) %>%
    
    # reorder variables to match template column order
    select(one_of(headers))

# Save to file
out_path <- file.path(tempdir(), "ad_pilot_rnaseq_clinical_vars.txt")
write.table(ad_rnaseq_clinical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
ad_rnaseq_clinical_object <- File(path = out_path, 
                                  parentId = clinical_folder_id)
ad_rnaseq_clinical_object <- synStore(ad_rnaseq_clinical_object)

# Get technical variables
ad_rnaseq_technical <- ad_rnaseq_info %>%
    # pull out relevant variables from original data frame
    select(Path_ID, IlluminaSampleID, Sequence.ID, RIN, RINsqAdj, 
           Library.Batch, FCC1MR9ACXX, FCD1K78ACXX, FCD1LTPACXX, FCD1LUUACXX,
           Flowcell)

# Save to file
out_path <- file.path(tempdir(), "ad_pilot_rnaseq_tech_vars.txt")
write.table(ad_rnaseq_technical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
ad_rnaseq_technical_object <- File(path = out_path, 
                                   parentId = technical_folder_id)
ad_rnaseq_technical_object <- synStore(ad_rnaseq_technical_object)


### PSP samples ###
###################

# Read PSP info table to data frame
psp_rnaseq_info <- read.xlsx2(pilot_rnaseq_path, sheetIndex = 2,
                              stringsAsFactors = FALSE)

# Get clinical variables
psp_rnaseq_clinical <- psp_rnaseq_info %>%
    # pull out relevant variables from original data frame
    select(participant_id = Path_ID, age_at_diagnosis = Age, 
           sex = Sex) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis),
           sex = ifelse(sex == 0, "M", "F")) %>%
    
    # add empty columns for additional template variables
    mutate(age_at_onset = NA,
           age_at_death = NA,
           post_mortem_interval = NA,
           education = NA,
           apoe_genotype = NA,
           race_ethnicity = NA,
           braak_stage = NA,
           mmse_at_onset = NA,
           mmse_at_last_assessment = NA,
           cerad = NA) %>%
    
    # reorder variables to match template column order
    select(one_of(headers))

# Save to file
out_path <- file.path(tempdir(), "psp_pilot_rnaseq_clinical_vars.txt")
write.table(psp_rnaseq_clinical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
psp_rnaseq_clinical_object <- File(path = out_path, 
                                   parentId = clinical_folder_id)
psp_rnaseq_clinical_object <- synStore(psp_rnaseq_clinical_object)


# Get technical variables
psp_rnaseq_technical <- psp_rnaseq_info %>%
    # pull out relevant variables from original data frame
    select(Path_ID, IlluminaSampleID, Sequence.ID, RIN, RINsqAdj, 
           Library.Batch, FCD1GH3ACXX, FCD1KHGACXX, FCC1CDJACXX, Flowcell)

# Save to file
out_path <- file.path(tempdir(), "psp_pilot_rnaseq_tech_vars.txt")
write.table(psp_rnaseq_technical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
psp_rnaseq_technical_object <- File(path = out_path, 
                                    parentId = technical_folder_id)
psp_rnaseq_technical_object <- synStore(psp_rnaseq_technical_object)

