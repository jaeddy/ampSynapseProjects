#!/bin/sh

# assign inputs
GWAS_DATA="$1"
CHR="$2"
CHUNK_START=`printf "%.0f" $3`
CHUNK_END=`printf "%.0f" $4`

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.b37/
GENMAP_DIR=${DATA_DIR}haplotypes/
# GWAS_HAPS_DIR=${GENMAP_DIR}${GWAS_DATA}.phased/
GWAS_HAPS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.phased/

# prefixes and files
HAP_PREFIX=".integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nosing."

# create new directory to store results
RESULTS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.imputed/

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# executable
IMPUTE_EXEC=${ROOT_DIR}resources/impute2/impute2

# specify data files
GWAS_HAPS_FILE=${GWAS_HAPS_DIR}${GWAS_DATA}.chr${CHR}.phased.haps
HAPS_FILE=${GENMAP_DIR}ALL.chr${CHR}${HAP_PREFIX}haplotypes.gz
LEGEND_FILE=${GENMAP_DIR}ALL.chr${CHR}${HAP_PREFIX}legend.gz
GENMAP_FILE=${GENMAP_DIR}genetic_map_chr${CHR}_combined_b37.txt

RESULT_FILE="${GWAS_DATA}.chr${CHR}.pos${CHUNK_START}-${CHUNK_END}.imputed"

# impute estimated haplotype files with impute2 and save to results directory        
$IMPUTE_EXEC \
    -use_prephased_g \
    -m $GENMAP_FILE \
    -h $HAPS_FILE \
    -l $LEGEND_FILE \
    -known_haps_g $GWAS_HAPS_FILE \
    -iter 30 \
    -burnin 10 \
    -k 80 \
    -k_hap 500 \
    -Ne 20000 \
    -int $CHUNK_START $CHUNK_END \
    -allow_large_regions \
    -o ./resources/impute2/Example/example.chr22.one.phased.impute2

# mv *.chr${CHR}.*.imputed* "$RESULTS_DIR"
