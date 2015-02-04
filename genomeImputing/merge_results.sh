#!/bin/bash

# assign inputs
GWAS_DATA=SYounkin_MayoGWAS_09-05-08

# directories
S3_BUCKET=s3://mayo-gwas-impute/
DATA_DIR=/mnt/data/

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

GWAS_DIR=gwas_results/
QC_DIR=${GWAS_DIR}${GWAS_DATA}.imputed.qc/

# executables
PLINK_EXEC=${ROOT_DIR}resources/plink/plink

# get ped/map files for each chromosome from S3
aws s3 cp --dryrun \
    ${S3_BUCKET}${QC_DIR} \
    ${DATA_DIR}${QC_DIR} \
    --recursive --exclude "*" --include "*chr1.*" --exclude "*.qc.gen"

# get list of files for all chromosomes
FILE_LIST=`mktemp file-list.XXX`
find ${DATA_DIR}${QC_DIR} -mindepth 1 | grep -v ".qc.gen" > $FILE_LIST

# conversion from impute2 format to ped/map creates ambiguous SNP IDs in map file; recode these SNPs before merging with plink
grep ".map" $FILE_LIST | while read file; do
    chr=$(head -n 1 $file | awk '{print $1}')
    echo "Recoding SNP IDs in .map file for chromosome ${chr}..."
    TMP_FILE=`mktemp ${chr}-new.XXX`
    awk '{ORS = ""
        print $1"\t"
        if ($2 == ".") print "chr"$1"."$4"\t"
        else print $2"\t"
        print $3"\t"
        print $4"\n"
        }' $file > $TMP_FILE
    mv $TMP_FILE $file
done

# function to list files side-by-side in .ped, .map order for each chr
function get_chr_files {
    for CHR in $(seq 1 22); do
        chr_files=$(grep "chr$CHR\." $1 | sort -r)
        if [ ! "$chr_files" == "" ]; then
            echo $chr_files
        fi
    done
}

# format files to create merge list for plink
MERGE_LIST=`mktemp merge-list.XXX`
get_chr_files $FILE_LIST > $MERGE_LIST

# pull out first file and remove extension to use as plink --file arg
MERGE_START=$(awk 'NR==1 {gsub(".ped", ""); print $1}' $MERGE_LIST)

# remove the first line from merge list
TMP_FILE=`mktemp`
awk 'NR>1 {print $0}' $MERGE_LIST > $TMP_FILE
mv $TMP_FILE $MERGE_LIST

# merge all chromosome files with plink
echo "Merging chromosomes into single file with plink..."
time $PLINK_EXEC \
    --noweb \
    --file $MERGE_START \
    --merge-list $MERGE_LIST \
    --make-bed \
    --out ${DATA_DIR}${GWAS_DIR}${GWAS_DATA}.imputed

rm $FILE_LIST
rm $MERGE_LIST
