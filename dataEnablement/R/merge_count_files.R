
# This is a reusable function to merge output count files from SNAPR into a
# single data matrix file, given an input directory name, count type, and
# output file prefix

# Example usage:
# 
# source("merge_count_files.R")
#
# dir <- "~/Dropbox/data/projects/ampSynapseProjects/mayo-prelim-rnaseq"
# countType <- "gene_name"
# prefix <- "ad_psp_pilot_rnaseq"
# 
# create_merged_file(dir, countType, prefix)

countTypes <- c("gene_name", "gene_id",
                "junction_name", "junction_id",
                "transcript_name", "transcript_id")

create_merged_file <- function(dir = "", countType = countTypes, prefix = "") {
    
    fileList <- list.files(dir, pattern = countType, recursive = TRUE)

    message("Merging input files...")
    sample <- character(length(fileList))
    for (i in 1:length(fileList)) {
        filePath <- file.path(dir, fileList[i])
        
        # Pull out sample name
        sample[i] <- sub("(^[^.]+)(.+$)", "\\1", basename(filePath))
        
        if (i == 1) {
            tmpDat <- read.table(filePath, row.names = 1)
            countDat <- data.frame(matrix(nrow = nrow(tmpDat), 
                                          ncol = length(fileList)),
                                   row.names = row.names(tmpDat))
            countDat[, 1] <- tmpDat
        } else {
            countDat[, i] <- read.table(filePath, row.names = 1)
        }   
    }
    colnames(countDat) <- sample
    countDat <- as.data.frame(t(countDat))
    
    message("Writing file...")
    fileName <- paste(prefix, countType, "counts.txt", sep = "_")
    
    write.table(countDat, file.path(dir, fileName), quote = FALSE)
    system(paste("gzip", file.path(dir, fileName), sep = " "))
    
    message(paste0("Output file: ", fileName))
    message(paste0("Number of variables: ", ncol(countDat)))
    message(paste0("Number of observations: ", nrow(countDat)))
}



