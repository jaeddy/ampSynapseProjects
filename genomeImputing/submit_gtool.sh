#!/bin/bash

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

qhost | awk 'NR>2 {print $1}' | grep -v global | while read NODE; do

    qsub -V -cwd ./rerun_gtool.sh $GWAS_DATA \
        -j y -l h=${NODE} -M james.a.eddy@gmail.com ;
        
done
