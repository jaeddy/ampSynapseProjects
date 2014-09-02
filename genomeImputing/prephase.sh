#!/bin/sh

# specify directories
DATA_DIR="$1"
GWAS_DATA="$2"
START_CHR="$3"
END_CHR="$4"

cd "$DATA_DIR"

# reference data files
GWAS_DIR="gwas_results/${GWAS_DATA}.by_chr/"
GENMAP_DIR="haplotypes/"

# create new directory to store results
RESULTS_DIR="gwas_results/${GWAS_DATA}.phased/"

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# prephase preprocessed binary genotype files with shapeit, with specified 
# reference map & store in results directory
for CHR in $(seq $START_CHR $END_CHR); do
	GWAS_FILE="${GWAS_DIR}${GWAS_DATA}.chr${CHR}"
	MAP_FILE="${GENMAP_DIR}genetic_map_chr${CHR}_combined_b37.txt"
	RESULT_FILE="${GWAS_DATA}.chr${CHR}.phased"
	
	echo "$RESULT_FILE"
		
	shapeit --input-bed $GWAS_FILE \
    	--input-map $MAP_FILE \
        --effective-size 11418 \
		--seed 367946 \
        --output-log ${RESULT_FILE}.log \
        --output-max ${RESULT_FILE}.haps ${RESULT_FILE}.sample ;
        
    mv *.chr${CHR}.phased* "$RESULTS_DIR"
done

http://hgdownload.cse.ucsc.edu/admin/exe/macOSX.i386/
sudo ln -s /Users/jeddy/Google\ Drive/MyCode/Resources/liftOver liftOver