!#/bin/bash

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
BIM_FILE=${GWAS_DIR}${GWAS_DATA}.chr${CHR}.b37.bim

# create new directory to store results
RESULTS_DIR=${GWAS_DIR}impute_intervals/

if [ ! -e "${DATA_DIR}${RESULTS_DIR}" ]; then
    mkdir "${DATA_DIR}${RESULTS_DIR}"
fi

# copy data from S3 bucket
echo "Downloading data from S3..."
aws s3 cp \
    ${S3_BUCKET}${BIM_FILE} \
    ${DATA_DIR}${BIM_FILE}

# run R script to get impute intervals (chunks)
Rscript R/impute_ranges.R $BIM_FILE $CHR $INT_FILE

# copy chr-specific files to S3
echo "Uploading results to S3..."
echo
aws s3 cp \
    ${DATA_DIR}${RESULTS_DIR} \
    ${S3_BUCKET}${RESULTS_DIR} \
    --recursive --exclude "*" --include "*chr${CHR}.*"
