#!/bin/bash

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
S3_BUCKET=s3://mayo-gwas-impute/
HAPS_DIR=haplotypes/
GWAS_HAPS_DIR=${HAPS_DIR}${GWAS_DATA}.phased/

function get_chr {
    while read FILE; do
        CHR=${FILE##*chr}
        CHR=${CHR%%.*}
        echo $CHR
    done < $1
}
get_chr <(aws s3 ls ${S3_BUCKET}${GWAS_HAPS_DIR} \
    | grep ".haps" \
    | awk '$3==0 {print $4}') \
    | while read CHR; do

        echo $CHR
        qsub -S /bin/bash -V -cwd -M james.a.eddy@gmail.com -m abe -j y \
            -N re_prephase_chr${CHR} \
            shell/prephase.sh $GWAS_DATA $CHR ;

done

# rm $S3_INTS_LIST
