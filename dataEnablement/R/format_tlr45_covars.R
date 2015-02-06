
# This script is used to reformat clinical variables from the Mayo TLR4/TLR5
# genotyping study to match the AMP template.

library(synapseClient)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

# Define paths for required Synapse objects
tlr45_covars_id <- "syn3136057" # .cov plink file
tlr45_ped_id <- "syn3136063" # .ped plink file
folder_id <- "syn3162963" # id of destination folder

# Download files from Synapse
tlr45_covars_file <- synGet(tlr45_covars_id)
tlr45_covars_path <- getFileLocation(tlr45_covars_file)

tlr45_ped_file <- synGet(tlr45_ped_id)
tlr45_ped_path <- getFileLocation(tlr45_ped_file)

# Load the files into R
unformatted_tlr45_covars <- read.table(tlr45_covars_path, header = TRUE,
                                      stringsAsFactors = FALSE)
tlr45_ped <- read.table(tlr45_ped_path, stringsAsFactors = FALSE)

# Simple function to recode APOE genotype value
recode_apoe_status <- Vectorize(function(apoe4_status, apoe2_status) {
    if (sum(apoe4_status, apoe2_status) > 0) {
        apoe_genotype <- paste0(rep("E4", apoe4_status), collapse = "")
        apoe_genotype <- paste0(apoe_genotype, 
                                rep("E2", apoe2_status), collapse = "")
    } else {
        apoe_genotype <- "none"
    }
})

# Define column headers from template
headers <- c("participant_id", "age_at_onset", "age_at_last_assessment", 
             "age_at_death", "post_mortem_interval", "sex", "education",
             "apoe_genotype", "race_ethnicity", "braak_stage", "mmse_at_onset",
             "mmse_at_last_assessment", "cerad")

tlr45_covars <- unformatted_tlr45_covars %>% 
    # pull out relevant variables from original data frame
    select(participant_id = IID, age_at_diagnosis = DxAge, 
           sex = SEXcov, APOE4, APOE2) %>%
    
    # keep only sample IDs in .ped file
    filter(participant_id %in% tlr45_ped$V2) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis),
           sex = ifelse(sex == 1, "M", "F"),
           apoe_genotype = recode_apoe_status(APOE4, APOE2)) %>%
    
    # add empty columns for additional template variables
    mutate(age_at_onset = NA,
           age_at_death = NA,
           post_mortem_interval = NA,
           education = NA,
           race_ethnicity = NA,
           braak_stage = NA,
           mmse_at_onset = NA,
           mmse_at_last_assessment = NA,
           cerad = NA) %>%
    
    # reorder variables to match template column order
    select(one_of(headers))

# Save to file
out_path <- file.path(tempdir(), "mayo_tlr4-5_clinical_vars.txt")
write.table(tlr45_covars, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
tlr45_covars_object <- File(path = out_path, 
                            parentId = folder_id)
tlr45_covars_object <- synStore(tlr45_covars_object)
