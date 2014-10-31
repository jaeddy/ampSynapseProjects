#!/bin/sh

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/

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
$PLINK_EXEC \
	--bfile $GWAS_FILE \
	--chr $CHR \
	--recode \
	--maf 0.05 \
	--geno 0.02 \
	--hwe 0.001 \
	--mind 0.02 \
	--out $RESULT_FILE ;
	
mv *.chr${CHR}* "$RESULTS_DIR"      

