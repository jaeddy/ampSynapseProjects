#!/bin/bash

# assign inputs
GWAS_DATA="$1"
CHR="$2"

# directories
S3_BUCKET=s3://mayo-gwas-impute/
ROOT_DIR=./
DATA_DIR=/mnt/data/

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

GWAS_DIR=gwas_results/
GENMAP_DIR=haplotypes/
GWAS_IMP_DIR=${GWAS_DIR}${GWAS_DATA}.imputed/
GWAS_HAP_DIR=${GENMAP_DIR}${GWAS_DATA}.phased/

# executables
GTOOL_EXEC=${ROOT_DIR}resources/gtool
QCTOOL_EXEC=${ROOT_DIR}resources/qctool/qctool

# specify additional data files
SAMPLE_FILE=${GWAS_HAP_DIR}${GWAS_DATA}.chr${CHR}.phased.sample

# copy data from S3 bucket
echo "Downloading data from S3..."

aws s3 cp \
   ${S3_BUCKET}${SAMPLE_FILE} \
   ${DATA_DIR}${SAMPLE_FILE}

aws s3 cp \
   ${S3_BUCKET}${GWAS_IMP_DIR} \
   ${DATA_DIR}${GWAS_IMP_DIR} \
   --recursive --exclude "*" --include "*chr${CHR}.*.imputed"

# get list of imputed genotype files for chromosome
CHUNK_LIST=$(find ${DATA_DIR}${GWAS_IMP_DIR} \
   | grep "chr${CHR}\..*imputed$")

# merge all imputed genotype files for chromosome
GEN_FILE="${DATA_DIR}${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.gen"

echo "Merging all chunk files for chromsome ${CHR}..."
echo
cat $CHUNK_LIST > $GEN_FILE

# create new directory to store results
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

if [ ! -e "${DATA_DIR}${RESULTS_DIR}" ]; then
    mkdir "${DATA_DIR}${RESULTS_DIR}"
fi

# perform QC with qctool
QC_FILE=${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.imputed.qc.gen

echo "Performing QC on merged file ${GEN_FILE}..."
echo
time $QCTOOL_EXEC -g $GEN_FILE -og ${DATA_DIR}${QC_FILE} \
   -snp-missing-rate 0.05 -maf 0 1 -info 0.4 1 -hwe 20

# qctool adds an extra columns of NA for some reason; need to remove
TMP_FILE=`mktemp qcgen.XXX`

echo "Removing extraneous first coumn from QC output ${QC_FILE}..."
echo
cut -d " " -f 2- ${DATA_DIR}${QC_FILE} > $TMP_FILE
mv $TMP_FILE ${DATA_DIR}${QC_FILE}

# convert to ped/map with gtool
PED_FILE="${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.imputed.ped"
MAP_FILE="${RESULTS_DIR}${GWAS_DATA}.chr${CHR}.imputed.map"

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
aws s3 cp \
    ${DATA_DIR}${RESULTS_DIR} \
    ${S3_BUCKET}${RESULTS_DIR} \
    --recursive --exclude "*" --include "*chr${CHR}.*"
