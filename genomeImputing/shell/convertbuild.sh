#!/bin/bash

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.by_chr/

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
# GWAS_DIR=gwas_results/${GWAS_DATA}.by_chr/
#
# # executables
# LIFTOVER_EXEC=python ${ROOT_DIR}python/LiftMap.py
#
# # create new directory to store results
# RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.b37/
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
#     --recursive --exclude "*" --include "chr${CHR}.*"
#
# aws s3 cp \
#     ${S3_BUCKET}/hg18ToHg19.over.chain.gz \
#     ${DATA_DIR}
#
# # specify data files
# MAP_FILE=${DATA_DIR}${GWAS_DIR}${GWAS_DATA}.chr${CHR}.map
# PED_FILE=${DATA_DIR}${GWAS_DIR}${GWAS_DATA}.chr${CHR}.ped
# RESULT_FILE=${DATA_DIR}${GWAS_DATA}.chr${CHR}.b37
#
# # reprocess binary files with plink & store in results directory
# echo "Reprocessing genotype data for chromosome ${CHR}..."
# echo
# $LIFTOVER_EXEC \
#     -m $MAP_FILE \
#     -p $PED_FILE \
#     -o $RESULT_FILE ;
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
RESULTS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.b37/

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# reference data files
MAP_FILE=${GWAS_DIR}${GWAS_DATA}.chr${CHR}.map
PED_FILE=${GWAS_DIR}${GWAS_DATA}.chr${CHR}.ped
RESULT_FILE=${GWAS_DATA}.chr${CHR}.b37

# http://genome.sph.umich.edu/wiki/LiftOver#Resources

python \
    ./python/LiftMap.py \
    -m $MAP_FILE \
    -p $PED_FILE \
    -o $RESULT_FILE ;

mv *.chr${CHR}.b37* "$RESULTS_DIR"
