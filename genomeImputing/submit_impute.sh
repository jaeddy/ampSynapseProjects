#!/bin/sh

echo ""

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/${GWAS_DATA}.b37/

for CHR in $(seq 1 21); do

    NUM_FILE="${GWAS_DIR}impute_intervals/num_ints.txt"
    NUM_INTS=$(awk -v chr=$CHR '$2==chr {print $3}' $NUM_FILE)
    INTS_FILE="${GWAS_DIR}impute_intervals/chr${CHR}.ints"

    for INT in $(seq 1 $NUM_INTS); do

        CHUNK_START=$(awk -v i=$INT '$3==i {print $5}' $INTS_FILE)
        CHUNK_END=$(awk -v i=$INT '$3==i {print $6}' $INTS_FILE)
        
        PREV_INTS_FILE="${GWAS_DIR}impute_intervals/already_run.txt"
        if [ ! -e "$PREV_INTS_FILE" ]; then
            touch "$PREV_INTS_FILE"
        fi
        echo $PREV_INTS_FILE
        
        INT_CHECK=chr${CHR}_${CHUNK_START}-${CHUNK_END}
        echo $INT_CHECK
        if ! grep -q $INT_CHECK $PREV_INTS_FILE; then
            qsub -V -M james.a.eddy@gmail.com -m abe \
            -N chr${CHR}int${INT}_${CHUNK_START}-${CHUNK_END} \
            -cwd ./impute.sh $GWAS_DATA $CHR $CHUNK_START $CHUNK_END ;
        else
            echo "previously run interval $INT_CHECK"
        fi     
    
    done
    
done
