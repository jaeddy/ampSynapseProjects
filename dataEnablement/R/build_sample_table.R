
file_1 <- "~/data/projects/ampSynapseProjects/mayo-load-gwas-covariates/mayo_gwas_clinical_vars.txt"
file_2 <- "~/data/projects/ampSynapseProjects/mayo-egwas-tech-covariates/mayo_egwas_cer_tech_vars.txt"

file_list <- c(file_2, file_1)

master_list <- data.frame(id = "")
num <- 0
for (file in file_list) {
    num <- num + 1
    table <- read.table(file, header = TRUE)
    list <- table %>%
        select(1) %>%
        mutate(src = file)
    names(list) <- c("id", paste0("src_", num))
    
    master_list <- left_join(list, master_list)
}

list_full <- master_list %>%
    filter(!is.na(src_1))
