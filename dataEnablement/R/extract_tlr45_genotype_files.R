library(xlsx)

# This script is used to exctract individual sheets from an Excel workbook and
# save each as a separate tab-delimited text file (with appropriate extensions
# for PLINK genotype files).

dataDirectory <- "~/Dropbox/data/projects/ampSynapseProjects"
excelFile <- file.path(dataDirectory, "TLR4-5_12-05-14_ForUpload.xlsx")

outDirectory <- paste0(dataDirectory, "/mayo-u01-genotypes")

# Note: the 2nd sheet of the Excel file contains a ReadMe, which can be saved
# manually as a text file via Excel (read.xlsx2 does not work in this case)

# Extract data for .ped file, saved in the 3rd sheet
ped <- read.xlsx2(excelFile, sheetIndex = 3, header = FALSE)
fileName <- "TLR4-5_12-05-14.ped"

write.table(ped, file = file.path(outDirectory, fileName), 
            quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")

# Extract data for .map file, saved in the 4th sheet
map <- read.xlsx2(excelFile, sheetIndex = 4, header = FALSE)
fileName <- "TLR4-5_12-05-14.map"

write.table(map, file = file.path(outDirectory, fileName), 
            quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")

# Extract data for .cov file, saved in the 5th sheet; note we want to keep the
# headers this time
cov <- read.xlsx2(excelFile, sheetIndex = 5, header = TRUE)
fileName <- "TLR4-5_12-05-14.cov"

write.table(cov, file = file.path(outDirectory, fileName), 
            quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")
