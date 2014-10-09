library(dplyr)

rootDir <- "./"
dataDir <- paste0(rootDir, "data/")

gwasData <- "SYounkin_MayoGWAS_09-05-08"
gwasDir <- paste0(dataDir, "gwas_results/", gwasData, ".b37/")

resultsDir <- paste0(gwasDir, "impute_intervals/")

impute_logs <- read.table("impute_logs.txt", stringsAsFactors = FALSE)
impute_files <- read.table("impute_files.txt", stringsAsFactors = FALSE)

strip_logname <- function(x) {
    x <- gsub("int+[[:digit:]]*", "", x)
    x <- gsub(".[o|e]+[[:digit:]]*", "", x)
    unique(x)
}

strip_filename <- function(x) {
    x <- gsub("SYounkin_MayoGWAS_09-05-08.", "", x)
    x <- gsub(".pos", "_", x)
    x <- gsub(".imputed+[_*[[:alnum:]]*]*", "", x)
    unique(x)
}


impute_logs <- impute_logs %>%
    filter(grepl("^chr", V1))
int_logs <- strip_logname(impute_logs$V1)

int_files <- as.data.frame(strip_filename(impute_files$V1))

write.table(int_files, paste0(resultsDir, "already_run.txt"))
