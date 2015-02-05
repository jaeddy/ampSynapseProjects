
# This script contains a record of all commands used to build provenance
# relationships for Synapse objects in the project. Commands should be
# commented out after use to avoid duplicating activities.

### Run these commands first

library(synapseClient)
source("synapseHelpers/R/set_provenance.R")

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

### Reformatting Mayo LOAD GWAS clinical variables

activity_name <- "clinical data formatting"
input_files <- c("syn3025476")

code_address <- paste0("https://github.com/jaeddy/ampSynapseProjects/",
                       "blob/master/dataEnablement/R/",
                       "format_load_gwas_covars.R")
code_files <- list(list(name = "format_load_gwas_covars.R",
                        url = code_address))
output_files <- c("syn3026423")
description <- paste("Ran in Rstudio using:", 
                     "source('format_load_gwas_covars.R')")

build_relationship(activity_name, input_files, code_files, 
                   output_files, description)


### Creating merged data matrices for AD pilot RNAseq SNAPR read counts

activity_name <- "RNAseq count file merging"
input_files <- c("syn2875349")

code_addresses <- c(paste0("https://github.com/jaeddy/ampSynapseProjects/",
                           "blob/master/dataEnablement/R/",
                           "merge_ad_pilot_rnaseq_counts.R"),
                    paste0("https://github.com/jaeddy/ampSynapseProjects/",
                           "blob/master/dataEnablement/R/",
                           "merge_count_files.R"))
code_files <- list(list(name = "merge_ad_pilot_rnaseq_counts.R",
                        url = code_addresses[1]),
                   list(name = "merge_count_files.R",
                        url = code_addresses[2]))
output_files <- c("syn3160433", "syn3160436", "syn3160437")
description <- paste("Ran in Rstudio using:", 
                     "source('merge_mayo_pilot_rnaseq_counts.R')")

build_relationship(activity_name, input_files, code_files, 
                   output_files, description)

### Creating merged data matrices for AD pilot RNAseq SNAPR read counts

activity_name <- "RNAseq count file merging"
input_files <- c("syn2875350")

code_addresses <- c(paste0("https://github.com/jaeddy/ampSynapseProjects/",
                           "blob/master/dataEnablement/R/",
                           "merge_psp_pilot_rnaseq_counts.R"),
                    paste0("https://github.com/jaeddy/ampSynapseProjects/",
                           "blob/master/dataEnablement/R/",
                           "merge_count_files.R"))
code_files <- list(list(name = "merge_psp_pilot_rnaseq_counts.R",
                        url = code_addresses[1]),
                   list(name = "merge_count_files.R",
                        url = code_addresses[2]))
output_files <- c("syn3160442", "syn3160443", "syn3160444")
description <- paste("Ran in Rstudio using:", 
                     "source('merge_psp_pilot_rnaseq_counts.R')")

build_relationship(activity_name, input_files, code_files, 
                   output_files, description)
