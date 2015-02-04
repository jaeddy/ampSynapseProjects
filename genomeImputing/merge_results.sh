#!/bin/bash

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
S3_BUCKET=s3://mayo-gwas-impute/
DATA_DIR=/mnt/data/

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

GWAS_DIR=gwas_results/
QC_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

# executables
PLINK_EXEC=${ROOT_DIR}resources/plink/plink

# get ped/map files for each chromosome from S3
aws s3 cp --dryrun \
    ${S3_BUCKET}${QC_DIR} \
    ${DATA_DIR}${QC_DIR} \
    --recursive --exclude ".qc.gen"

FILE_LIST=`mktemp file-list.XXX`
find ${DATA_DIR}${QC_DIR} -mindepth 1 > $MERGE_FILE

function get_chr_files {
    for CHR in $(seq 1 22); do
        chr_files=$(grep $CHR $1)
        echo $chr_files
    done
}

MERGE_LIST=`mktemp merge-list.XXX`
cat > $MERGE_LIST <(get_chr_files $FILE_LIST)

time $PLINK_EXEC \
    --noweb \
    --file ${DATA_DIR}${QC_DIR}${GWAS_DATA}.chr1.imputed \
    --merge-list $MERGE_LIST \
    --make-bed \
    --out ${DATA_DIR}${GWAS_DIR}${GWAS_DATA}.imputed
