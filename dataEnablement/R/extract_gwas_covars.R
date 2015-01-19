library(xlsx)

setwd("synapseUploads/")
dataDir <- "~/Dropbox/data/projects/ampSynapseProjects/synapseUploads"

mayo_covars_path <- file.path(dataDir, "TLR5+GWAScov_10-28-14_0912_CM+SGY.xlsx")
mayo_covars <- read.xlsx2("data/TLR5+GWAScov_10-28-14_0912_CM+SGY.xlsx", 1,
                          stringsAsFactors = FALSE, na.strings = "NA")

gwas_fam_path <- file.path(dataDir, "SYounkin_MayoGWAS_09-05-08.fam")
load_gwas_fam <- read.table(gwas_fam_path)
names(load_gwas_fam) <- c("family_id", "sample_id", "paternal_id",
                          "maternal_id", "sex", "phenotype")

names(mayo_covars)
extract_cols <- names(mayo_covars)[c(1, 4:13)]

no_id <- mayo_covars$IlluminaIID...IID %in% "NA"
gwas_covars <- mayo_covars[!no_id, extract_cols]

load_gwas_covars <- merge(x = load_gwas_fam, y = gwas_covars,
                          by.x = "sample_id", by.y = "IlluminaIID...IID",
                          all = TRUE)

output_path <- file.path(dataDir, "LOAD_GWAS_covars.xlsx")
write.xlsx(load_gwas_covars, output_path)
