
library(xlsx)
library(dplyr)

data_dir <- "~/Dropbox/data/projects/ampSynapseProjects/ufl-il10-nanostring"
nano_file_path <- file.path(data_dir, "Nano_data.xlsx")

nano_sample_groups <- read.xlsx2(nano_file_path, sheetIndex = 3, 
                                 header = FALSE, startRow = 2, endRow = 7)

nano_sample_groups <- as.data.frame(t(nano_sample_groups))

nano_sample_groups <- nano_sample_groups %>%
    
    select(sample_id = V6,
           sex = V2,
           age = V3,
           group = V5) %>%
    
    mutate(is_TG = ifelse(group %in% c("Tg IL10", "Tg control", "CRND8"), 1, 0),
           is_treated = ifelse(group %in% c("Tg IL10", "WT IL10"), 1, 0),
           is_old = ifelse(group %in% c("CRND8", "nTg control"), 1, 0))

nano_sample_groups$age[nano_sample_groups$age == "6month"] <- "6mo"

out_path <- file.path(data_dir, "mouse_il10_nanostring_sample_groups.txt")
write.table(nano_sample_groups, out_path, quote = FALSE, row.names = FALSE)


