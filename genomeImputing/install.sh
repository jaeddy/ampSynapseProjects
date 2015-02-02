#!/bin/bash

# directories
ROOT_DIR=./

# create new directory to store resources
RESOURCES_DIR=${ROOT_DIR}resources/

if [ ! -e "$RESOURCES_DIR" ]; then
    mkdir "$RESOURCES_DIR"
fi

cd $RESOURCES_DIR

# install PLINK
wget http://pngu.mgh.harvard.edu/~purcell/plink/dist/plink-1.07-x86_64.zip
unzip plink-1.07-x86_64.zip
mv plink-1.07-x86_64 plink

# install liftOver
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver
chmod a+x ./liftOver

# install IMPUTE2
wget https://mathgen.stats.ox.ac.uk/impute/impute_v2.3.1_x86_64_static.tgz
tar -zxvf impute_v2.3.1_x86_64_static.tgz
mv impute_v2.3.1_x86_64_static impute2

# install SHAPEIT
mkdir shapeit/
cd shapeit/
wget https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.v2.r790.Ubuntu_12.04.4.static.tar.gz
tar -zxvf shapeit.v2.r790.Ubuntu_12.04.4.static.tar.gz
cd ..

# install GTOOL
wget http://www.well.ox.ac.uk/~cfreeman/software/gwas/gtool_v0.7.5_x86_64.tgz
tar -zxvf gtool_v0.7.5_x86_64.tgz

# install qctool
wget http://www.well.ox.ac.uk/~gav/qctool/resources/qctool_v1.4-linux-x86_64.tgz
tar -zxvf qctool_v1.4-linux-x86_64.tgz
mv qctool_v1.4-linux-x86_64 qctool

cd $ROOT_DIR
