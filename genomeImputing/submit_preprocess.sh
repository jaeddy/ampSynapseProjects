#!/bin/sh

echo ""

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

for CHR in $(seq 1 22); do
                
    qsub -V -cwd ./preprocess.sh $GWAS_DATA $CHR
        
done
