library(synapseClient)
library(xlsx)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

# Define paths for required Synapse objects
unformatted_gwas_covars_address <- "syn3025476" # covariates Excel file

# Download files from Synapse
covars_file <- synGet(unformatted_gwas_covars_address)
covars_file_path <- getFileLocation(covars_file)

# Load the files into R
unformatted_gwas_covars <- read.xlsx2(covars_file_path, 2, 
                                      stringsAsFactors = FALSE)

# Simple function to recode APOE genotype value
recode_apoe_status <- Vectorize(function(apoe_status) {
    if (apoe_status == 1) {
        "E4"
    } else if (apoe_status == 0) {
        "none"
    } else {
        NA
    }
})

# Define column headers from template
headers <- c("participant_id", "age_at_onset", "age_at_last_assessment", 
             "age_at_death", "post_mortem_interval", "sex", "education",
             "apoe_genotype", "race_ethnicity", "braak_stage", "mmse_at_onset",
             "mmse_at_last_assessment", "cerad")

gwas_covars <- unformatted_gwas_covars %>% 
    # pull out relevant variables from original data frame
    select(participant_id = IID, age_at_diagnosis = AgeOver60, 
           sex = Sex, apoe_genotype = APOE4_Dose) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis) + 60,
           sex = ifelse(sex == 1, "M", "F"),
           apoe_genotype = recode_apoe_status(apoe_genotype)) %>%
    
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

# Write new data frame to text file
file_path <- file.path(tempdir(), "mayo_gwas_clinical_vars.txt")
write.table(gwas_covars, file_path)

formatted_covars_file <- File(path = file_path, 
                              parentId = covars_file$properties$parentId)
formatted_covars_file <- synStore(formatted_covars_file)