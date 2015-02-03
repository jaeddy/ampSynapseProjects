#!/bin/bash

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/

######## FOR SWITCH TO S3 ##########
# # directories
# S3_BUCKET=s3://mayo-gwas-impute/
# ROOT_DIR=./
# DATA_DIR=/mnt/data/
#
# if [ ! -e "$DATA_DIR" ]; then
#     mkdir "$DATA_DIR"
# fi
#
# GWAS_DIR=gwas_results/
#
# # executables
# PLINK_EXEC=${ROOT_DIR}resources/plink/plink
#
# # create new directory to store results
# RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.by_chr/
#
# if [ ! -e "${DATA_DIR}${RESULTS_DIR}" ]; then
#     mkdir "${DATA_DIR}${RESULTS_DIR}"
# fi
#
# # copy data from S3 bucket
# echo "Downloading data from S3..."
# aws s3 cp \
#     ${S3_BUCKET}${GWAS_DIR} \
#     ${DATA_DIR}${GWAS_DIR} \
#     --recursive --exclude "*" --include "${GWAS_DATA}.*"
#
# # specify data files
# GWAS_FILE=${DATA_DIR}${GWAS_DIR}${GWAS_DATA}
# RESULT_FILE=${DATA_DIR}${RESULTS_DIR}${GWAS_DATA}.chr${CHR}
#
# # reprocess binary files with plink & store in results directory
# echo "Reprocessing genotype data for chromosome ${CHR}..."
# echo
# $PLINK_EXEC \
#     --bfile $GWAS_FILE \
#     --chr $CHR \
#     --recode \
#     --maf 0.05 \
#     --geno 0.02 \
#     --hwe 0.001 \
#     --mind 0.02 \
#     --out $RESULT_FILE ;
#
# # copy chr-specific files to S3
# echo "Uploading results to S3..."
# echo
# aws s3 cp \
#     ${DATA_DIR}${RESULTS_DIR} \
#     ${S3_BUCKET}${RESULTS_DIR} \
#     --recursive --exclude "*" --include "*chr${CHR}.*"

####################################

# create new directory to store results
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.by_chr/

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# executable
PLINK_EXEC=${ROOT_DIR}resources/plink/plink

# specify data files
GWAS_FILE=${GWAS_DIR}${GWAS_DATA}
RESULT_FILE=${GWAS_DATA}.chr${CHR}

# reprocess binary files with plink & store in results directory
time $PLINK_EXEC \
	--bfile $GWAS_FILE \
	--chr $CHR \
	--recode \
	--maf 0.05 \
	--geno 0.02 \
	--hwe 0.001 \
	--mind 0.02 \
	--out $RESULT_FILE ;

mv *.chr${CHR}* "$RESULTS_DIR"
