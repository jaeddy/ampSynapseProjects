
# This script is used to convert Excel spreadsheets containing probe and 
# sample group info for the Mayo eGWAS DASL data

library(synapseClient)
library(xlsx)
library(dplyr)

# Login to Synapse using credentials saved in .synapseConfig file
synapseLogin()

### Probe info reformatting ###
###############################

# Define paths for required Synapse objects
probe_info_id <- "syn3131610" # probe info in Excel spreadsheet
folder_id <- "syn2786319"

# Download files from Synapse
probe_info_file <- synGet(probe_info_id)
probe_info_path <- getFileLocation(probe_info_file)

# Read probe info table to data frame
probe_info <- read.xlsx2(probe_info_path, sheetIndex = 1)

# Switch first two columns
probe_info[, 1:2] <- probe_info[, c(2, 1)]
pnames <- names(probe_info)
pnames[1:2] <- pnames[c(2, 1)]
names(probe_info) <- pnames

# Save to file
out_path <- file.path(tempdir(), "mayo_egwas_probe_info.txt")
write.table(probe_info, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
probe_info_object <- File(path = out_path, 
                          parentId = folder_id)
probe_info_object <- synStore(probe_info_object)

### Sample gropus reformatting ###
##################################

# Define paths for required Synapse objects
sample_groups_id <- "syn3131611" # sample groups in Excel spreadsheet
folder_id <- "syn2786319"

# Download files from Synapse
sample_groups_file <- synGet(sample_groups_id)
sample_groups_path <- getFileLocation(sample_groups_file)

# Read cerebellum sample groups table to data frame
sample_groups <- read.xlsx2(sample_groups_path, sheetIndex = 1)

# Switch first two columns
sample_groups[, 1:2] <- sample_groups[, c(2, 1)]
sgnames <- names(sample_groups)
sgnames[1:2] <- sgnames[c(2, 1)]
names(sample_groups) <- sgnames

# Save to file
out_path <- file.path(tempdir(), "mayo_egwas_cer_sample_groups.txt")
write.table(sample_groups, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
sample_groups_object <- File(path = out_path, 
                          parentId = folder_id)
sample_groups_object <- synStore(sample_groups_object)


# Read cerebellum sample groups table to data frame
sample_groups <- read.xlsx2(sample_groups_path, sheetIndex = 2)

# Switch first two columns
sample_groups[, 1:2] <- sample_groups[, c(2, 1)]
sgnames <- names(sample_groups)
sgnames[1:2] <- sgnames[c(2, 1)]
names(sample_groups) <- sgnames

# Save to file
out_path <- file.path(tempdir(), "mayo_egwas_tcx_sample_groups.txt")
write.table(sample_groups, out_path, quote = FALSE, row.names = FALSE)

# Create a Synapse object for the output file and upload
sample_groups_object <- File(path = out_path, 
                             parentId = folder_id)
sample_groups_object <- synStore(sample_groups_object)
