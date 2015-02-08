
# This script is used to extract clinical variables (and sample groups) from 
# the temporal cortex sample cohort of the U01 Mayo RNAseq study, which 
# includes AD and PSP samples

library(synapseClient)
library(xlsx)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

# Define paths for required Synapse objects
tcx_rnaseq_id <- "syn3163262" # pilot RNAseq covariates Excel file
clinical_folder_id <- "syn2866158" # id of clinical covars folder
technical_folder_id <- "syn3163735" # id of technical covars folder
rnaseq_folder_id <- "syn3163039" # id of RNAseq folder

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
tcx_rnaseq_info <- read.xlsx2(tcx_rnaseq_path, sheetIndex = 1,
                             stringsAsFactors = FALSE)

# Get clinical variables
tcx_rnaseq_clinical <- tcx_rnaseq_info %>%
    
    # select only Mayo samples
    filter(Source != "RUSH-BROAD") %>%
    
    # pull out relevant variables from original data frame
    select(participant_id = RNASubjectId, age_at_diagnosis = Age, 
           sex = Sex, braak_stage = Braak) %>%
    
    # rename and modify variables to match template
    mutate(age = as.numeric(age_at_diagnosis),
           age_at_last_assessment = ifelse(age > 90, "censored", age)) %>%
    
    # add empty columns for additional template variables
    mutate(age_at_onset = NA,
           age_at_death = NA,
           post_mortem_interval = NA,
           education = NA,
           apoe_genotype = NA,
           race_ethnicity = NA,
           mmse_at_onset = NA,
           mmse_at_last_assessment = NA,
           cerad = NA) %>%
    
    # reorder variables to match template column order
    select(one_of(headers))

# Save to file
out_path <- file.path(tempdir(), "mayo_tcx_rnaseq_clinical_vars.txt")
write.table(tcx_rnaseq_clinical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
tcx_rnaseq_clinical_object <- File(path = out_path, 
                                  parentId = clinical_folder_id)
tcx_rnaseq_clinical_object <- synStore(tcx_rnaseq_clinical_object)


# Get technical variables
tcx_rnaseq_technical <- tcx_rnaseq_info %>%
    
    # select only Mayo samples
    filter(Source != "RUSH-BROAD") %>%
    
    # pull out relevant variables from original data frame
    select(RNASubjectId, RNAId, Source, Tissue, RIN)

# Save to file
out_path <- file.path(tempdir(), "mayo_tcx_rnaseq_tech_vars.txt")
write.table(tcx_rnaseq_technical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
tcx_rnaseq_technical_object <- File(path = out_path, 
                                   parentId = technical_folder_id)
tcx_rnaseq_technical_object <- synStore(tcx_rnaseq_technical_object)


# Format sample groups
tcx_rnaseq_sample_groups <- tcx_rnaseq_info %>%
    
    # select only Mayo samples
    filter(Source != "RUSH-BROAD") %>%
    
    # pull out sample IDs and diagnosis
    select(RNAId, FinalDx) %>%
    
    # reformat diagnoses
    mutate(is_AD = ifelse(FinalDx == "AD", 1, 0),
           is_PSP = ifelse(FinalDx == "PSP", 1, 0),
           is_PathAging = ifelse(FinalDx == "Pathological Aging", 1, 0),
           is_Control = ifelse(FinalDx == "Control", 1, 0))

# Save to file
out_path <- file.path(tempdir(), "mayo_tcx_rnaseq_sample_groups.txt")
write.table(tcx_rnaseq_sample_groups, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
tcx_rnaseq_sample_groups_object <- File(path = out_path, 
                                    parentId = rnaseq_folder_id)
tcx_rnaseq_sample_groups_object <- synStore(tcx_rnaseq_sample_groups_object)
