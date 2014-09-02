#!/bin/sh

# ./test.sh ./data/ SYounkin_MayoGWAS_09-05-08

# specify directories
DATA_DIR="$1"
GWAS_DATA="$2"

cd "$DATA_DIR"

# reference data files
GWAS_DIR="gwas_results/${GWAS_DATA}.by_chr/"

# impute estimated haplotype files with impute2 and save to results directory
for CHR in $(seq 1 22); do
	
	NUM_FILE="${GWAS_DIR}impute_intervals/num_ints.txt"
	NUM_INTS=$(awk -v chr=$CHR '$2==chr {print $3}' $NUM_FILE)
	
	INTS_FILE="${GWAS_DIR}impute_intervals/chr${CHR}.ints"
	for INT in $(seq 1 $NUM_INTS); do
	
	    START=$(awk -v i=$INT '$3==i {print $5}' $INTS_FILE)
	    END=$(awk -v i=$INT '$3==i {print $6}' $INTS_FILE)
		
		echo "$CHR"
		echo "$INT"
		echo "$START"
		echo "$END"
		
	done
done
	