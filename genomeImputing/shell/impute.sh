#!/bin/bash

# assign inputs
GWAS_DATA="$1"
CHR="$2"
CHUNK_START=`printf "%.0f" $3`
CHUNK_END=`printf "%.0f" $4`

# directories
S3_BUCKET=s3://mayo-gwas-impute/
ROOT_DIR=./
DATA_DIR=/mnt/data/

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

GWAS_DIR=gwas_results/

if [ ! -e "$DATA_DIR$GWAS_DIR" ]; then
    mkdir "$DATA_DIR$GWAS_DIR"
fi

HAPS_DIR=haplotypes/
REFHAPS_DIR=${HAPS_DIR}1000genomes/
GWAS_HAPS_DIR=${HAPS_DIR}${GWAS_DATA}.phased/

# reference prefix
HAP_PREFIX=".integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nosing."

# executables
IMPUTE_EXEC=${ROOT_DIR}resources/impute2/impute2

# specify data files
GWAS_HAPS_FILE=${GWAS_HAPS_DIR}${GWAS_DATA}.chr${CHR}.phased.haps
HAPS_FILE=${REFHAPS_DIR}ALL.chr${CHR}${HAP_PREFIX}haplotypes.gz
LEGEND_FILE=${REFHAPS_DIR}ALL.chr${CHR}${HAP_PREFIX}legend.gz
MAP_FILE=${REFHAPS_DIR}genetic_map_chr${CHR}_combined_b37.txt

# copy data from S3 bucket
echo "Downloading data from S3..."
# get pre-phased data
aws s3 cp \
    ${S3_BUCKET}${GWAS_HAPS_FILE} \
    ${DATA_DIR}${GWAS_HAPS_DIR}

# get reference data
aws s3 cp \
    ${S3_BUCKET}${HAPS_FILE} \
    ${DATA_DIR}${REFHAPS_DIR}

aws s3 cp \
    ${S3_BUCKET}${LEGEND_FILE} \
    ${DATA_DIR}${REFHAPS_DIR}

aws s3 cp \
    ${S3_BUCKET}${MAP_FILE} \
    ${DATA_DIR}${REFHAPS_DIR}

# create new directory to store results
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.imputed/

if [ ! -e "${DATA_DIR}${RESULTS_DIR}" ]; then
    mkdir "${DATA_DIR}${RESULTS_DIR}"
fi

RESULT_FILE="${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.pos${CHUNK_START}-${CHUNK_END}.imputed"
echo $RESULT_FILE

# impute estimated haplotype files with impute2 and save to results directory
echo "Reprocessing genotype data for chromosome ${CHR}..."
echo
time $IMPUTE_EXEC \
    -use_prephased_g \
    -m ${DATA_DIR}${MAP_FILE} \
    -h ${DATA_DIR}${HAPS_FILE} \
    -l ${DATA_DIR}${LEGEND_FILE} \
    -known_haps_g ${DATA_DIR}${GWAS_HAPS_FILE} \
    -iter 30 \
    -burnin 10 \
    -k 80 \
    -k_hap 500 \
    -Ne 20000 \
    -int $CHUNK_START $CHUNK_END \
    -allow_large_regions \
    -filt_rules_l 'eur.maf==0' \
    -o ${DATA_DIR}${RESULT_FILE} ;

# copy chr-specific files to S3
echo "Uploading results to S3..."
echo
aws s3 cp \
    ${DATA_DIR}${RESULTS_DIR} \
    ${S3_BUCKET}${RESULTS_DIR} \
    --recursive --exclude "*" --include "*chr${CHR}.*"
