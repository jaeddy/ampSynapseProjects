#!/bin/sh

# assign inputs
# GWAS_DATA="$1"
# CHR="$2"

# directories
# ROOT_DIR=./
# DATA_DIR=${ROOT_DIR}data/
# GWAS_DIR=${DATA_DIR}gwas_results/
# GENMAP_DIR=${DATA_DIR}haplotypes/
# GWAS_HAP_DIR=${GENMAP_DIR}${GWAS_DATA}.phased/
# GWAS_IMP_DIR=${GWAS_DIR}${GWAS_DATA}.imputed/

GWAS_DATA=SYounkin_MayoGWAS_09-05-08
CHR=22

GWAS_HAP_DIR=impute_exdata/
GWAS_IMP_DIR=impute_exdata/

# executable
GTOOL_EXEC=gtool  #${ROOT_DIR}resources/impute2/impute2
QCTOOL_EXEC=qctool

CHUNK_LIST=$(ls -d -1 ${GWAS_IMP_DIR}*.* | grep "chr${CHR}.*.imputed$")
echo $CHUNK_LIST

GEN_FILE="${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.gen"
echo $GEN_FILE

# cat $CHUNK_LIST > $GEN_FILE
head $GEN_FILE | cut -d " " -f 1-20

# Perform QC
BGEN_FILE=${GWAS_IMP_DIR}${GWAS_DIR}.chr${CHR}.imputed.qc.bgen
time $QCTOOL_EXEC -g $GEN_FILE -og subsetted.gen \
	-snp-missing-rate 0.05 -maf 0 1 -info 0.4 1 -hwe 20

# specify data files
# SAMPLE_FILE=${GWAS_HAP_DIR}${GWAS_DATA}.chr${CHR}.phased.sample
# echo $SAMPLE_FILE

# PED_FILE="${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.ped"
# MAP_FILE="${GWAS_IMP_DIR}${GWAS_DATA}.chr${CHR}.imputed.map"


# convert to ped/map with gtool
# time $GTOOL_EXEC -G --g $GEN_FILE --s $SAMPLE_FILE \
# 	--ped $PED_FILE --map $MAP_FILE \
# 	--phenotype plink_pheno
