
input_address <- "syn3025476"
input_file <- synGet(input_address, downloadFile = F)

output_address <- "syn3026423"
output_file <- synGet(output_address, downloadFile = F)

# Specify provenance for an activity
code_address <- paste0("https://github.com/jaeddy/ampSynapseProjects/",
"raw/master/synapseUploads/R/format_gwas_covars.R")

activity <- createEntity(Activity(name = "clinical data formatting",
                used = list(list(name = "format_gwas_covars.R",
                                 url = code_address, wasExecuted = T),
                            list(entity = input_file, wasExecuted = F)),
                name = "Reformatting of clinical data",
                description = 
                    "To execute run: Rscript format_gwas_covars.R"))

output_file <- synStore(output_file, activity)

