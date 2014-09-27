#!/bin/sh

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.by_chr/

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
