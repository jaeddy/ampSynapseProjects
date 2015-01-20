
# This script uses a simple function to build a provenance relationship for a
# given set of input files, code files, and output files, allowing for a 
# slightly more intuitive specification of these lists.

# Example usage:
#
# activity_name <- "RNAseq count file merging"
# input_files <- c("syn2875349", "syn2875350")
# code_files <- list(list(name = "merge_mayo_pilot_rnaseq_counts.R",
#                         url = "github.com"),
#                    list(name = "code_file2.R",
#                         url = "github.com"))
# output_files <- c("syn001", "syn002")
# description <- paste("To execute run:", 
#                      "Rscript merge_mayo_pilot_rnaseq_counts.R")
#
# build_relationship(activity_name, input_files, code_files, 
#                    output_files, description)

build_relationship <- function (activity_name, input_files, code_files, 
                                output_files, description) {
    activity_inputs <- list()
    
    # Concatenate input file information
    for (input_file in input_files) {
        input_object <- synGet(input_file, downloadFile = F)
        activity_inputs <- append(activity_inputs,
                                  list(list(entity = input_object,
                                            wasExecuted = F)))
    }
    
    # Add code files to 'used' list
    activity_inputs <- append(activity_inputs, code_files)
    
    # Build Activity object to represent provenance relationship
    activity <- Activity(name = activity_name,
                         used = activity_inputs,
                         description = description)
    activity <- storeEntity(activity)
    
    # Associate output files with activity
    for (output_file in output_files) {
        output_object <- synGet(output_file, downloadFile = F)
        generatedBy(output_object) <- activity
        output_object <- synStore(output_object)
    }
}



