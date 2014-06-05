
# This function gets all MAF files from the specified source and returns a
# data frame with the top 'n' mutated genes (and the corresponding percentage
# of samples in which they were mutated) for each cancer corresponding to a
# single MAF file

# Note: the function assumes that the synapseClient package has been loaded and
# the user has logged in

tcgaMutatedGenes <- function(benefactorId = "syn1446577", n = 5){
  
  # set up the query to Synapse
  queryStr <- paste('SELECT name FROM file WHERE benefactorId=="',
                    benefactorId, '" AND fileType=="maf"', sep = '')
  synapseFiles <- synapseQuery(queryStr)
  
  # initialize the data frame to list top mutated genes for all cancers
  topMutGenesByCancer <- data.frame(matrix(nrow = 0,
                                           ncol = 3))
  colnames(topMutGenesByCancer) <- c("Total.Gene.Mutations", 
                             "Percent.Samples.Gene.Mutated",
                             "Tumor.Source")
  
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
    mutRates <- mutSamples/nSamples
    
    # create a data frame with genes ordered by mutation rate
    mutGenes <- data.frame(mutCounts, mutRates)
    mutGenes <- mutGenes[order(mutCounts, decreasing = TRUE), ]
    
    # collect top n mutated genes and add to full list
    topMutGenes <- head(mutGenes, n)
    topMutGenes <- cbind(topMutGenes, rep(fileName, n))
    colnames(topMutGenes) <- c("Total.Gene.Mutations", 
                            "Percent.Samples.Gene.Mutated",
                            "Tumor.Source")
    topMutGenesByCancer <- rbind(topMutGenesByCancer, topMutGenes)
  }
  
  # return the data frame with top n mutated genes for each cancer
  topMutGenesByCancer
}    

    
