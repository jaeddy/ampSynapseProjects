#!/bin/sh

echo ""

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

for CHR in $(seq 1 22); do

    qsub -V -cwd -M james.a.eddy@gmail.com \
        -N chr${CHR}_merge_qc -j y \
        ./merge_qc.sh $GWAS_DATA $CHR ;

done
