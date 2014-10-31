
# load the synapseClient package
require(synapseClient)

# login with Synapse credentials (saved in ~./synapseConfig)
synapseLogin()

# download an example MAF file to examine file structure
gbmMAF <- synGet('syn2363592')

# read the first few lines of the file to see where data starts
con <- file(gbmMAF@filePath)
filePrev <- readLines(con, 10)
close(con)
filePrev

# read file to data frame object, skipping the first 4 rows of metadata
gbmMAFdat <- read.delim(gbmMAF@filePath, header = T, skip = 4)
str(gbmMAFdat)

# Looking at the specification for MAF files at https://wiki.nci.nih.gov/...
# display/TCGA/Mutation+Annotation+Format+(MAF)+Specification, the following
# rules should apparently be satisfied for designating a somatic MAF:

#  SOMATIC = A AND (B OR C OR D)
# A: Mutation_Status == "Somatic"
# B: Validation_Status == "Valid"
# C. Verification_Status == "Verified"
# D. Variant_Classification is not {Intron, 5'UTR, 3'UTR, 5'Flank, 
# 3'Flank, IGR}, which implies that Variant_Classification can only be 
# \{Frame_Shift_Del, Frame_Shift_Ins, In_Frame_Del, In_Frame_Ins, 
# Missense_Mutation, Nonsense_Mutation, Silent, Splice_Site, 
# Translation_Start_Site, Nonstop_Mutation, RNA, Targeted_Region}.

# A quick check shows that...
# ...all Mutation_Status == "Somatic"
sum(gbmMAFdat$Mutation_Status != "Somatic") # returns 0

# ...all Validation_Status == "Untested"
levels(gbmMAFdat$Validation_Status) 

# ...all Verification_Status == NA
sum(!is.na(gbmMAFdat$Verification_Status)) # returns 0

# ...all Variant_Classification are in the allowed set
levels(gbmMAFdat$Variant_Classification)

# Thus, A AND D hold. I'll work under the assumption that all rows in the file
# represent a unique somatic mutation.


# calculate the 5 most mutated genes
geneDat <- split(gbmMAFdat$Tumor_Sample_Barcode, gbmMAFdat$Hugo_Symbol)

geneNames <- levels(gbmMAFdat$Hugo_Symbol)
mutCounts <- unlist(lapply(geneDat, length))
nSamples <- length(levels(gbmMAFdat$Tumor_Sample_Barcode))
mutRates <- mutCounts/nSamples
mutGenes <- data.frame(mutRates[order(mutRates, decreasing = TRUE)])

colnames(mutGenes) <- c("Percent.Samples.Gene.Mutated")

topMutGenes <- head(mutGenes, 5)
