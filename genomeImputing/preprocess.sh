#!/bin/sh

# specify directories
DATA_DIR="$1"
GWAS_DATA="$2"

cd "$DATA_DIR"

# reference data files
GWAS_DIR="gwas_results/"

# create new directory to store results
RESULTS_DIR="${GWAS_DIR}${GWAS_DATA}.by_chr"

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# reprocess binary files with plink & store in results directory
for CHR in $(seq 1 22); do
	GWAS_FILE="${GWAS_DIR}${GWAS_DATA}"
		
    plink --bfile $GWAS_FILE \
		--chr $CHR \
        --recode \
        --maf 0.05 \
        --geno 0.02 \
        --hwe 0.001 \
        --mind 0.02 \
        --out ${GWAS_DATA}.chr${CHR} ;
        
    mv *.chr${CHR}* "$RESULTS_DIR"      
done
