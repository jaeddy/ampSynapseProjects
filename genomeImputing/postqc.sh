#!/bin/sh

# assign inputs
GWAS_DATA="$1"
CHR="$2"
CHUNK_START=`printf "%.0f" $3`
CHUNK_END=`printf "%.0f" $4`

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.imputed/

INTERVAL=${CHUNK_START}-${CHUNK_END}
GWAS_HAPS_FILE=${GWAS_DIR}${GWAS_DATA}.chr${CHR}.pos${INTERVAL}.imputed

echo "$GWAS_HAPS_FILE"

# executable
QCTOOL_EXEC=${ROOT_DIR}resources/qctool/qctool

$QCTOOL_EXEC \
    -g $GWAS_HAPS_FILE \
    -filetype impute_haplotypes \
    -og subsetted.gen \
    -snp-missing-rate 0.05 \
    -maf 0 1 \
    -info 0.4 1 \
    -hwe 20 ;
