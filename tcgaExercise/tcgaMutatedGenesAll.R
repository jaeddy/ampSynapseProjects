
# This function gets all MAF files from the specified source and returns a
# data frame with the top 'n' mutated genes (and the corresponding percentage
# of samples in which they were mutated) across all cancers corresponding to
# all MAF files

# Note: the function assumes that the synapseClient package has been loaded and
# the user has logged in

tcgaMutatedGenesAll <- function(benefactorId = "syn1446577", n = 5){
  
  # set up the query to Synapse
  queryStr <- paste('SELECT name FROM file WHERE benefactorId=="',
                    benefactorId, '" AND fileType=="maf"', sep = '')
  synapseFiles <- synapseQuery(queryStr)

  # intialize a data frame to track mutation rates across all cancers
  mutAllCancers <- data.frame(matrix(nrow = 0, ncol = 4))
  colnames(mutAllCancers) <- c("Gene.Names",
                               "Total.Gene.Mutations",
                               "Num.Samples.Gene.Mutated",
                               "Num.Samples.Total")
  
  for(file in synapseFiles$file.id){
    fileName <- synapseFiles[synapseFiles$file.id == file, 1]
    print(fileName)
    
    # download current file
    mafFile <- synGet(file)
    
    # preview the first few lines to determine where to start reading
    con <- file(mafFile@filePath)
    filePrev <- readLines(con, 10)
    close(con)
    dataStart <- grep("Hugo_Symbol*", filePrev)
    
    # read file to data frame
    mafDat <- read.delim(mafFile@filePath, header = T, skip = dataStart-1)
    
    # remove genes with unknown names
    mafDat <- mafDat[!mafDat$Hugo_Symbol == "Unknown", ]
    
    # split the data by gene name
    geneDat <- split(mafDat$Tumor_Sample_Barcode, mafDat$Hugo_Symbol)
    geneNames <- levels(mafDat$Hugo_Symbol)
    
    # simply count the lengths of each list element to determine the number of
    # tumor samples in which each gene was mutated
    mutCounts <- unlist(lapply(geneDat, length))
    
    # divide counts by total number of samples to calculate mutation rates
    mutSamples <- unlist(lapply(geneDat, function(x) length(unique(x))))
    nSamples <- length(levels(mafDat$Tumor_Sample_Barcode))
    
    # create a data frame with genes ordered by mutation number
    mutGenes <- data.frame(geneNames, mutCounts, mutSamples, 
                           rep(nSamples,length(geneNames)))
    colnames(mutGenes) <- c("Gene.Names", 
                            "Total.Gene.Mutations", 
                            "Num.Samples.Gene.Mutated",
                            "Num.Samples.Total")
    mutAllCancers <- rbind(mutAllCancers, mutGenes)
  }
  
  # process aggregated mutation counts and frequencies across all cancers
  geneDatAll <- split(mutAllCancers, mutAllCancers$Gene.Names)
  geneTotals <- lapply(geneDatAll, function(x) colSums(x[, 2:4]))
  mutCountsAll <- unlist(lapply(geneTotals, function(x) x[1]))
  mutRatesAll <- unlist(lapply(geneTotals, function(x) x[2]/x[3]))
  
  # create data frame with genes ordered by overall mutation number
  mutGenesAll <- data.frame(mutCountsAll, mutRatesAll)
  row.names(mutGenesAll) <- names(geneDatAll)
  mutGenesAll <- mutGenesAll[order(mutCountsAll, decreasing = TRUE), ]
  colnames(mutGenesAll) <- c("Total.Gene.Mutations", 
                             "Percent.Samples.Gene.Mutated")
  
  # return the data frame with top n mutated genes
  topMutGenesAllCancers <- head(mutGenesAll, n)
  topMutGenesAllCancers
}    


