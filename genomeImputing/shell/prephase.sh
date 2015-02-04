#!/bin/bash

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
S3_BUCKET=s3://mayo-gwas-impute/
ROOT_DIR=./
DATA_DIR=/mnt/data/

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

GWAS_DIR=gwas_results/${GWAS_DATA}.b37/
HAPS_DIR=haplotypes/
REFHAPS_DIR=${HAPS_DIR}1000genomes/

# executables
SHAPEIT_EXEC=${ROOT_DIR}resources/shapeit/shapeit
PLINK_EXEC=${ROOT_DIR}resources/plink/plink

# specify data files
GWAS_HANDLE=${GWAS_DIR}${GWAS_DATA}.chr${CHR}.b37
MAP_FILE=${REFHAPS_DIR}genetic_map_chr${CHR}_combined_b37.txt

# copy data from S3 bucket
echo "Downloading data from S3..."
aws s3 cp \
    ${S3_BUCKET}${GWAS_DIR} \
    ${DATA_DIR}${GWAS_DIR} \
    --recursive --exclude "*" --include "*chr${CHR}.*"

aws s3 cp \
    ${S3_BUCKET}${MAP_FILE} \
    ${DATA_DIR}${MAP_FILE}

# create new directory to store results
RESULTS_DIR=${HAPS_DIR}${GWAS_DATA}.phased/

if [ ! -e "${DATA_DIR}${RESULTS_DIR}" ]; then
    mkdir "${DATA_DIR}${RESULTS_DIR}"
fi

RESULT_FILE=${DATA_DIR}${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.phased

# need to make sure that SNP data is ordered by position; use PLINK for this
echo "Reordering genotype data for chromosome ${CHR}..."
echo
GWAS_HANDLE_ORDERED=${GWAS_HANDLE}.ordered
time $PLINK_EXEC \
    --file ${DATA_DIR}${GWAS_HANDLE} \
    --recode \
    --out ${DATA_DIR}${GWAS_HANDLE_ORDERED}


# prephase preprocessed binary genotype files with shapeit, with specified
# reference map & store in results directory
echo "Pre-phasing data for chromosome ${CHR}..."
echo
time $SHAPEIT_EXEC \
    --input-ped ${DATA_DIR}${GWAS_HANDLE_ORDERED} \
    --input-map ${DATA_DIR}${MAP_FILE} \
    --effective-size 11418 \
    --seed 367946 \
    --output-log ${RESULT_FILE}.log \
    --output-max ${RESULT_FILE}.haps ${RESULT_FILE}.sample ;

# copy chr-specific files to S3
echo "Uploading results to S3..."
echo
aws s3 cp \
    ${DATA_DIR}${RESULTS_DIR} \
    ${S3_BUCKET}${RESULTS_DIR} \
    --recursive --exclude "*" --include "*chr${CHR}.*"
