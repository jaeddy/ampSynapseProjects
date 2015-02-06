
# This script is used to extract clinical variables from the Mayo eGWAS DASL
# dataset and format to match the AMP consortium template.

library(synapseClient)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

### Cerebellum data ###
#######################

# Define paths for required Synapse objects
cer_dasl_id <- "syn3131609" # cerebellar DASL data
folder_id <- "syn2866150" # id of destination folder

# Download files from Synapse
cer_dasl_file <- synGet(cer_dasl_id)
cer_dasl_path <- getFileLocation(cer_dasl_file)

tmp <- tempfile()
system(sprintf("cut -f 1-13 %s > %s", cer_dasl_path, tmp))
cer_covars <- read.table(tmp, sep = "\t", header = TRUE)
unlink(tmp)

# Simple function to recode APOE genotype value
recode_apoe_status <- Vectorize(function(apoe4_status, apoe2_status) {
    if (apoe4_status > 0) {
        apoe_genotype <- paste0(rep("E4", apoe4_status), collapse = "")
    } else {
        apoe_genotype <- "none"
    }
})

# Define column headers from template
headers <- c("participant_id", "age_at_onset", "age_at_last_assessment", 
             "age_at_death", "post_mortem_interval", "sex", "education",
             "apoe_genotype", "race_ethnicity", "braak_stage", "mmse_at_onset",
             "mmse_at_last_assessment", "cerad")

cer_clinical <- cer_covars %>%
    # pull out relevant variables from original data frame
    select(participant_id = IID.of.CER_ALL, age_at_diagnosis = Age, 
           sex = Sex, E4dose) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis),
           sex = ifelse(sex == 0, "M", "F"),
           apoe_genotype = recode_apoe_status(E4dose)) %>%
    
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
out_path <- file.path(tempdir(), "mayo_egwas_cer_clinical_vars.txt")
write.table(cer_clinical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
cer_clinical_object <- File(path = out_path, 
                             parentId = folder_id)
cer_clinical_object <- synStore(cer_clinical_object)

### Temporal cortex data ###
############################

# Define paths for required Synapse objects
tcx_dasl_id <- "syn3131612" # cerebellar DASL data
folder_id <- "syn2866150" # id of destination folder

# Download files from Synapse
tcx_dasl_file <- synGet(tcx_dasl_id)
tcx_dasl_path <- getFileLocation(tcx_dasl_file)

tmp <- tempfile()
system(sprintf("cut -f 1-13 %s > %s", tcx_dasl_path, tmp))
tcx_covars <- read.table(tmp, sep = "\t", header = TRUE)
unlink(tmp)

tcx_clinical <- tcx_covars %>%
    # pull out relevant variables from original data frame
    select(participant_id = IID, age_at_diagnosis = Age, 
           sex = Sex, E4dose) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis),
           sex = ifelse(sex == 0, "M", "F"),
           apoe_genotype = recode_apoe_status(E4dose)) %>%
    
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
out_path <- file.path(tempdir(), "mayo_egwas_tcx_clinical_vars.txt")
write.table(tcx_clinical, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
tcx_clinical_object <- File(path = out_path, 
                            parentId = folder_id)
tcx_clinical_object <- synStore(tcx_clinical_object)
