#!/bin/bash

echo ""

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
S3_BUCKET=s3://mayo-gwas-impute/
# DATA_DIR=/mnt/data/
DATA_DIR="data/"

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

GWAS_DIR=gwas_results/${GWAS_DATA}.b37/
INTS_DIR=${GWAS_DIR}impute_intervals/

for CHR in $(seq 1 22); do

    INTS_FILE="${INTS_DIR}chr${CHR}.ints"

    # get impute interval ranges from S3
    aws s3 cp \
        ${S3_BUCKET}${INTS_FILE} \
        ${DATA_DIR}${INTS_FILE}

    NUM_INTS=$(expr $(wc -l ${DATA_DIR}${INTS_FILE} | awk '{print $1}') - 1)

    for INT in $(seq 1 $NUM_INTS); do

        CHUNK_START=$(awk -v i=$INT '$3==i {print $5}' $INTS_FILE)
        CHUNK_END=$(awk -v i=$INT '$3==i {print $6}' $INTS_FILE)

        qsub -S /bin/bash -V -cwd -M james.a.eddy@gmail.com -m abe -j y \
            -N impute_chr${CHR}_int${INT}${CHUNK_START}-${CHUNK_END} \
            shell/impute.sh $GWAS_DATA $CHR $CHUNK_START $CHUNK_END ;

    done

done
