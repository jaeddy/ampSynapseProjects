library(xlsx)

file <- "~/Dropbox/data/projects/ampSynapseProjects/synapseUploads/TLR4-5_12-05-14_ForUpload.xlsx"
ped <- read.xlsx2(file, sheetIndex = 3, header=FALSE)
write.table(ped, file = "~/Dropbox/data/projects/ampSynapseProjects/synapseUploads/mayo-u01-genotypes/test.ped", quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")
