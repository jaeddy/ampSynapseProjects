#!/bin/bash

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
S3_BUCKET=s3://mayo-gwas-impute/
GWAS_DIR=gwas_results/
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

FILE_LIST="s3_files"

function get_chr {
    while read FILE; do
        CHR=${FILE##*chr}
        CHR=${CHR%%.*}
        echo $CHR
    done < $1
}


get_chr <(aws s3 ls ${S3_BUCKET}${RESULTS_DIR} | awk '$3==0 {print $4}') \
    | uniq | while read CHR; do

    # qsub -V -cwd -M james.a.eddy@gmail.com \
    #     -N chr${CHR}_merge_qc -j y \
    #     ./merge_qc.sh $GWAS_DATA $CHR ;

done
