#!/bin/sh

echo ""

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

for CHR in $(seq 1 22); do
                
    qsub -V -cwd ./prephase.sh $GWAS_DATA $CHR -m ea -M james.a.eddy@gmail.com ;
        
done
