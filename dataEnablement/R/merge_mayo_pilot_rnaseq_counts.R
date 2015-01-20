
# This script uses the merging function saved in merge_file_counts.R to combine
# SNAPR count files for reprocessed pilot AD and PSP RNAseq data from Mayo

source("dataEnablement/R/merge_count_files.R")

dir <- "~/Dropbox/data/projects/ampSynapseProjects/mayo-prelim-rnaseq"
prefix <- "ad_psp_pilot_rnaseq"

# I've included a separate call for each count type, just to make things easier
# to follow (but this could be done using a loop)

countType <- "gene_name"
create_merged_file(dir, countType, prefix)

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
