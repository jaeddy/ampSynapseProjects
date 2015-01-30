#!/bin/bash

# assign inputs
GWAS_DATA="$1"

# directories
S3_BUCKET=s3://mayo-gwas-impute/
ROOT_DIR=./
DATA_DIR=/mnt/data/

GWAS_DIR=gwas_results/
GENMAP_DIR=haplotypes/
GWAS_HAP_DIR=${GENMAP_DIR}${GWAS_DATA}.phased/
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

# executables
GTOOL_EXEC=${ROOT_DIR}resources/gtool

FILE_LIST=`mktemp qcfiles.XXX`
ls -lah ${DATA_DIR}${RESULTS_DIR} | awk '$5==0 {print $9}' > $FILE_LIST

cat $FILE_LIST | while read FILE; do
    CHR=${FILE##*chr}
    CHR=${CHR%%.*}
    echo "Rerunning gtool for chromosome $CHR ped/map conversion..."
    echo

    # specify additional data files
    SAMPLE_FILE=${GWAS_HAP_DIR}${GWAS_DATA}.chr${CHR}.phased.sample

    # perform QC with qctool
    QC_FILE=${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.imputed.qc.gen

    # convert to ped/map with gtool
    PED_FILE="${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.imputed.ped"
    MAP_FILE="${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.imputed.map"

    echo "$GTOOL_EXEC -G --g ${DATA_DIR}${QC_FILE} --s ${DATA_DIR}${SAMPLE_FILE} --ped ${DATA_DIR}${PED_FILE} --map ${DATA_DIR}${MAP_FILE} --phenotype plink_pheno"
    echo

    echo "Converting gen/sample format to ped/map..."
    echo
    time $GTOOL_EXEC -G \
       --g ${DATA_DIR}${QC_FILE} --s ${DATA_DIR}${SAMPLE_FILE} \
       --ped ${DATA_DIR}${PED_FILE} --map ${DATA_DIR}${MAP_FILE} \
       --phenotype plink_pheno --chr ${CHR}

    #gtool swaps the first 2 columns of the ped file; switch back
    TMP_FILE=`mktemp ped.XXX`

    echo "Swapping first two columns of gtool generated ped file..."
    echo
    paste <(cut -f 1-2 ${DATA_DIR}${PED_FILE} \
        | awk '{OFS = "\t"; t = $1; $1 = $2; $2 = t; print}') \
        <(cut -f 3- ${DATA_DIR}${PED_FILE}) > $TMP_FILE
    mv $TMP_FILE ${DATA_DIR}${PED_FILE}

    # copy qc'd files to S3

    echo "Uploading results to S3..."
    echo
    aws s3 cp --dryrun \
        ${DATA_DIR}${RESULTS_DIR} \
        ${S3_BUCKET}${RESULTS_DIR} \
        --recursive --exclude "*" --include "*chr${CHR}.*"
    echo
done

rm $FILE_LIST
