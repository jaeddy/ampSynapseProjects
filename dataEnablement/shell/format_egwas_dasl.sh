#!/bin/bash

#synapse login
#synapse get syn3131609

DATA_DIR="/Users/jaeddy/data/projects/ampSynapseProjects/"
DASL_DIR="${DATA_DIR}mayo-egwas-dasl/"
CER_DASL_FILE="${DASL_DIR}CER-All-343_2014-10-08.txt"

TECH_COVAR_DIR="${DATA_DIR}mayo-egwas-tech-covariates/"

if [ ! -e  "$TECH_COVAR_DIR" ]; then
    mkdir "$TECH_COVAR_DIR"
fi

# Pull out technical covariates
TECH_COVAR_FILE="${TECH_COVAR_DIR}mayo_egwas_cer_tech_vars.txt"

paste <(cut -f 2 $CER_DASL_FILE | awk '{gsub("IID+.*", "IID")}1') \
    <(cut -f 7-13 $CER_DASL_FILE) \
    > $TECH_COVAR_FILE

# Pull out expression values
EXPRS_FILE="${DASL_DIR}mayo_egwas_cer_expression.txt"

paste <(cut -f 2 $CER_DASL_FILE | awk '{gsub("IID+.*", "IID")}1') \
    <(cut -f 14- $CER_DASL_FILE) \
    > $EXPRS_FILE
