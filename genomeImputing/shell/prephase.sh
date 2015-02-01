#!/bin/bash

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.b37/
GENMAP_DIR=${DATA_DIR}haplotypes/
REFHAPS_DIR=${GENMAP_DIR}1000genomes/

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
# GWAS_DIR=gwas_results/${GWAS_DATA}.b37/
# HAPS_DIR=haplotypes/
# REFHAPS_DIR=${HAPS_DIR}1000genomes/
#
# # executables
# SHAPEIT_EXEC=${ROOT_DIR}resources/shapeit/shapeit
#
# # create new directory to store results
# RESULTS_DIR=${HAPS_DIR}${GWAS_DATA}.phased/
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
#     ${S3_BUCKET}${REFHAPS_DIR} \
#     ${DATA_DIR}${REFHAPS_DIR} \
#     --recursive --exclude "*" --include "chr${CHR}.*"
#
# # specify data files
# GWAS_FILE=${DATA_DIR}${GWAS_DIR}${GWAS_DATA}.chr${CHR}.b37
# MAP_FILE=${DATA_DIR}${REFHAPS_DIR}genetic_map_chr${CHR}_combined_b37.txt
# RESULT_FILE=${DATA_DIR}${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.phased
#
# # prephase preprocessed binary genotype files with shapeit, with specified
# # reference map & store in results directory
# echo "Reprocessing genotype data for chromosome ${CHR}..."
# echo
# $SHAPEIT_EXEC \
#     --input-ped $GWAS_FILE \
#     --input-map $MAP_FILE \
#     --effective-size 11418 \
#     --seed 367946 \
#     --output-log ${RESULT_FILE}.log \
#     --output-max ${RESULT_FILE}.haps ${RESULT_FILE}.sample ;
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
RESULTS_DIR=${GENMAP_DIR}${GWAS_DATA}.phased/

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# executable
SHAPEIT_EXEC=${ROOT_DIR}resources/shapeit/shapeit

# specify data files
GWAS_FILE=${GWAS_DIR}${GWAS_DATA}.chr${CHR}.b37
MAP_FILE=${REFHAPS_DIR}genetic_map_chr${CHR}_combined_b37.txt
RESULT_FILE=${GWAS_DATA}.chr${CHR}.phased

# prephase preprocessed binary genotype files with shapeit, with specified
# reference map & store in results directory
$SHAPEIT_EXEC \
	--input-ped $GWAS_FILE \
	--input-map $MAP_FILE \
	--effective-size 11418 \
	--seed 367946 \
	--output-log ${RESULT_FILE}.log \
	--output-max ${RESULT_FILE}.haps ${RESULT_FILE}.sample ;

mv *.chr${CHR}.phased* "$RESULTS_DIR"
