#!/bin/bash

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
S3_BUCKET=s3://mayo-gwas-impute/
GWAS_DIR=gwas_results/
RESULTS_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

function get_chr {
    while read FILE; do
        CHR=${FILE##*chr}
        CHR=${CHR%%.*}
        echo $CHR
    done < $1
}

get_chr <(aws s3 ls ${S3_BUCKET}${RESULTS_DIR} | awk '$3==0 {print $4}') \
    | uniq | while read CHR; do

        qsub -S /bin/bash -V -cwd -M james.a.eddy@gmail.com -m abe -j y \
            -N re_merge_qc_chr${CHR} \
            shell/merge_qc.sh $GWAS_DATA $CHR ;

done
