
egwas_dir <- "~/data/projects/ampSynapseProjects/mayo-egwas-dasl/"
system(paste("ls", egwas_dir))

cer_dasl_path <- file.path(egwas_dir, "CER-All-343_2014-10-08.txt")
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

names(cer_covars)

cer_clinical <- cer_covars %>%
    # pull out relevant variables from original data frame
    select(participant_id = IID.of.CER_ALL, age_at_diagnosis = Age, 
           sex = Sex, E4dose) %>%
    
    # rename and modify variables to match template
    mutate(age_at_last_assessment = as.numeric(age_at_diagnosis),
           sex = ifelse(sex == 1, "M", "F"),
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

cer_technical <- cer_covars %>%
    # pull out relevant variables from original data frame
    select(IID = IID.of.CER_ALL, plate0, plate1, plate2, plate3, plate4,
           RIN, RINsqAdj)

# Move these steps to a shell script

# tmp <- tempfile()
# system(sprintf("paste <(cut -f 1 %s) <(cut -f 14- %s) > %s", 
#                cer_dasl_path, cer_dasl_path, tmp))
# cer_covars <- read.table(tmp, sep = "\t", header = TRUE)
# unlink(tmp)
