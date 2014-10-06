library(dplyr)

rootDir <- "./"
dataDir <- paste0(rootDir, "data/")

gwasData <- "SYounkin_MayoGWAS_09-05-08"
gwasDir <- paste0(dataDir, "gwas_results/", gwasData, ".b37/")

resultsDir <- paste0(gwasDir, "impute_intervals/")
if (!file.exists(resultsDir)) {
    dir.create(resultsDir)
}

chrInts <- data.frame()
for (chr in 1:22) {
    chrBim <- read.table(paste0(gwasDir, gwasData, ".chr", chr, ".b37.map"))
                         
    nSNPs <- nrow(chrBim)
    nInts <- ceiling(nSNPs / 200)
    intLength <- nSNPs / nInts
    
    ints <- findInterval(1:nSNPs, seq(1, nSNPs, intLength))

    chrBim <- chrBim %>%
        mutate(chr = V1,
               interval = factor(ints)) %>%
        group_by(chr, interval) %>%
        summarise(numSNPs = length(V1),
                  start = min(V4),
                  end = max(V4)) %>%
        mutate(interval = as.numeric(interval))
    
    write.table(chrBim, paste0(gwasDir, "impute_intervals/chr", chr, ".ints"))
    
    numInts <- nrow(chrBim)
    chrInts <- rbind(chrInts, data.frame(chr = chr, numInts = numInts))
}
write.table(chrInts, paste0(gwasDir, "impute_intervals/num_ints.txt"))
