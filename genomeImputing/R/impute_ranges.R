library(dplyr)

rootDir <- getwd()
setwd(paste0("genomeImputing/data/gwas_results/",
             "SYounkin_MayoGWAS_09-05-08.by_chr/"))

if (!file.exists("impute_intervals")) {
    dir.create("impute_intervals")
}

chrInts <- data.frame()
for (chr in 1:22) {
    chrBim <- read.table(paste0("SYounkin_MayoGWAS_09-05-08.chr", chr, ".bim"))
                         
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
    
    write.table(chrBim, paste0("impute_intervals/chr", chr, ".ints"), )
    
    numInts <- nrow(chrBim)
    chrInts <- rbind(chrInts, data.frame(chr = chr, numInts = numInts))
}
write.table(chrInts, "impute_intervals/num_ints.txt")

setwd(rootDir)
