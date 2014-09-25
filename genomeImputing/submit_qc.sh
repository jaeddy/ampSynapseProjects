#!/bin/sh

echo ""

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.b37/

for CHR in $(seq 1 22); do

    NUM_FILE="${GWAS_DIR}impute_intervals/num_ints.txt"
    NUM_INTS=$(awk -v chr=$CHR '$2==chr {print $3}' $NUM_FILE)
    INTS_FILE="${GWAS_DIR}impute_intervals/chr${CHR}.ints"

    for INT in 1; do

        CHUNK_START=$(awk -v i=$INT '$3==i {print $5}' $INTS_FILE)
        CHUNK_END=$(awk -v i=$INT '$3==i {print $6}' $INTS_FILE)
                
        qsub -V -cwd ./postqc.sh $GWAS_DATA $CHR $CHUNK_START $CHUNK_END
    
    done

done
    