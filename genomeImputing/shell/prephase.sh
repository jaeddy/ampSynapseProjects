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

echo "$GWAS_FILE"

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
