#!/bin/bash

# directories
ROOT_DIR=./

# create new directory to store data
DATA_DIR=${ROOT_DIR}data/

if [ ! -e "$DATA_DIR" ]; then
    mkdir "$DATA_DIR"
fi

# copy data from S3 bucket
aws s3 cp s3://mayo-gwas-impute $DATA_DIR --recursive
