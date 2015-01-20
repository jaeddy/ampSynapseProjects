
# This script uses the merging function saved in merge_file_counts.R to combine
# SNAPR count files for reprocessed pilot AD and PSP RNAseq data from Mayo

library(synapseClient)
library(tools)
source("dataEnablement/R/merge_count_files.R")

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

# Define paths for required Synapse objects
ad_rnaseq_counts <- "syn2875349" # all count files in a zipped directory

# Download files from Synapse
ad_count_files <- synGet(ad_rnaseq_counts)
ad_files_path <- getFileLocation(ad_count_files)

# Get name of temporary directory to store unzipped files (same as name of
# original compressed directory)
fileDir <- file_path_sans_ext(basename(ad_files_path))
tmpDir <- tempdir()
unzip(ad_files_path, exdir = tmpDir)

inputDir <- file.path(tmpDir, fileDir)
prefix <- "ad_pilot_rnaseq"

# I've included a separate call for each count type, just to make things easier
# to follow (but this could be done using a loop)

activity <- createEntity(Activity(name = "clinical data formatting",
                                  used = list(list(name = "format_gwas_covars.R",
                                                   url = code_address, wasExecuted = T),
                                              list(entity = input_file, wasExecuted = F)),
                                  name = "Reformatting of clinical data",
                                  description = 
                                      "To execute run: Rscript format_gwas_covars.R"))

countType <- "gene_name"
merged_file <- create_merged_file(inputDir, countType, prefix)

merged_file_object <- File(path = merged_file, 
                              parentId = covars_file$properties$parentId)
merged_file_object <- synStore(merged_file_object)


countType <- "gene_id"
create_merged_file(dir, countType, prefix)

countType <- "junction_name"
create_merged_file(dir, countType, prefix)

countType <- "junction_id"
create_merged_file(dir, countType, prefix)

countType <- "transcript_name"
create_merged_file(dir, countType, prefix)

countType <- "transcript_id"
create_merged_file(dir, countType, prefix)
