library(synapseClient)
library(xlsx)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

# Define paths for required Synapse objects
unformatted_gwas_covars_address <- "syn2866149" # covariates Excel file

tmp <- "~/Dropbox/data/projects/ampSynapseProjects/synapseUploads/mayo-gwas-covariates/MayoGWAScovariates.xlsx"

# Create a temporary directory to store downloaded files
tmpDir <- file.path(getwd(), "tmp/")
if (!file.exists(tmpDir)) {
    dir.create(tmpDir)
}

# Download files from Synapse
covars_file <- synGet(unformatted_gwas_covars_address)
covars_file_path <- getFileLocation(covars_file)

# Load the files into R
unformatted_gwas_covars <- read.xlsx2(covars_file_path, 1, 
                                      stringsAsFactors = FALSE)

# Clean up rows with missing information
gsub("ERROR", "NA", unformatted_gwas_covars[13, 10])
rename_errors <- function(str) {
    gsub("ERROR", "NA", str)
}
unformatted_gwas_covars <- unformatted_gwas_covars %>%
    mutate_each(funs(rename_errors))

# Pull out relevant variables
names(unformatted_gwas_covars)
gwas_covars <- unformatted_gwas_covars %>% 
    select(sample_id, sex, Dx2, DxAge, APOE4, APOE2, AUT)

test <- gwas_covars %>%
    mutate(sex = ifelse(sex == 1, "F", "M"))
