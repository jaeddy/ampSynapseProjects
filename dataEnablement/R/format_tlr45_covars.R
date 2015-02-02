library(dplyr)

covars_file_path <- "~/data/projects/ampSynapseProjects/mayo-tlr4-5-genotypes/TLR4-5_12-05-14.cov"

# Load the files into R
unformatted_gwas_covars <- read.table(covars_file_path, header = TRUE,
                                      stringsAsFactors = FALSE)

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

tlr45_covars <- unformatted_gwas_covars %>% 
  # pull out relevant variables from original data frame
  select(participant_id = IID, age_at_diagnosis = DxAge, 
         sex = SEXcov, APOE4, APOE2) %>%
  
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
