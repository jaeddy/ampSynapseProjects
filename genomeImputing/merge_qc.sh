#!/bin/sh

# assign inputs
# GWAS_DATA="$1"
# CHR="$2"
GWAS_DATA=SYounkin_MayoGWAS_09-05-08
CHR=22

# directories
ROOT_DIR=./
DATA_DIR=${ROOT_DIR}data/
GWAS_DIR=${DATA_DIR}gwas_results/
GENMAP_DIR=${DATA_DIR}haplotypes/
GWAS_HAP_DIR=${GENMAP_DIR}${GWAS_DATA}.phased/
GWAS_IMP_DIR=${GWAS_DIR}${GWAS_DATA}.imputed/

# executables
GTOOL_EXEC=${ROOT_DIR}resources/gtool/gtool
QCTOOL_EXEC=${ROOT_DIR}resources/qctool/qctool

# specify additional data files
# SAMPLE_FILE=${GWAS_HAP_DIR}${GWAS_DATA}.chr${CHR}.phased.sample
# echo $SAMPLE_FILE

# get list of imputed genotype files for chromosome
CHUNK_LIST=$(ls -d -1 ${GWAS_IMP_DIR}*.* | grep "chr${CHR}.*.imputed$")
# echo $CHUNK_LIST

# merge all imputed genotype files for chromosome
GEN_FILE="${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.gen"
# echo $GEN_FILE

# cat $CHUNK_LIST > $GEN_FILE
head $GEN_FILE | cut -d " " -f 1-20

# create new directory to store results
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

if [ ! -e "$RESULTS_DIR" ]; then
	mkdir "$RESULTS_DIR"
fi

# perform QC with qctool
QC_FILE=${RESULTS_DIR}${GWAS_DIR}.chr${CHR}.imputed.qc.gen

time $QCTOOL_EXEC -g $GEN_FILE -og $QC_FILE \
	-snp-missing-rate 0.05 -maf 0 1 -info 0.4 1 -hwe 20



# PED_FILE="${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.ped"
# MAP_FILE="${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.map"


# convert to ped/map with gtool
# time $GTOOL_EXEC -G --g $GEN_FILE --s $SAMPLE_FILE \
# 	--ped $PED_FILE --map $MAP_FILE \
# 	--phenotype plink_pheno
