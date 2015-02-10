## GWAS Genotype Imputation

*Note: this README is old and needs to be updated.*

### Directory structure

The following analysis is designed to be self-contained within the `genomeImputing` directory, assuming the following file structure:

```
./
|-install.sh
|-get_data.sh
|-preprocess.sh
|-convertbuild.sh
|-prephase.sh
|-impute.sh
|-postqc.sh
|-submit_preprocess.sh
|-submit_convert.sh
|-submit_prephase.sh
|-submit_impute.sh
|-submit_qc.sh
|-data/
    |-gwas_results/
    |-haplotypes/
        |-1000genomes/
    |-hg18ToHg19.over.chain.gz
|-resources/
    |-impute2/
        |-impute2
    |-liftOver
    |-plink/
        |-plink
    |-qctool/
        |-qctool
    |-shapeit/
        |-shapeit
|-R/
    |-impute_ranges.R
|-python/
    |-LiftMap.py
```

Under the `resources` directory, `impute2`, `plink`, `qctool`, and `shapeit` are all command line genomics tools.

Under the `data` directory, `gwas_results` should include PLINK binary-formatted GWAS files (.bed/.bim/.fam). The `haplotypes/1000genomes/` directory should include all relevant 1000 Genomes Project files obtained from [this site](https://mathgen.stats.ox.ac.uk/impute/data_download_1000G_phase1_integrated_SHAPEIT2_9-12-13.html) (see option **ii** - haplotypes with singleton sites removed).


### Getting started

The analysis pipeline can be run on any Sun Grid Engine (SGE) environment (e.g., a new or existing AWS AMI) with the following installed:  

+ Python (2.7)
+ R (3.0.2 or higher), including the `dplyr` package
+ AWS Command Line Interface (CLI)

Before starting the analysis, the following commands should be run to download all code, download/install binary genomics tools under `resources` and to load the appropriate files under `data`. 

```
$ git clone https://github.com/jaeddy/ampSynapseProjects
$ cd genotypeImputing
$ ./install.sh
$ ./get_data.sh
```

All subsequent commands should be executed from within the `genotypeImputing` directory.


### Pre-processing with PLINK

The following command is used to submit a job with `preprocess.sh` for each chromosome: 
 
```$ ./submit_preprocess.sh```

`preprocess.sh` is a script wrapped around the `PLINK` tool, which is used to split genotype data into individual chromosomes, filter calls using more stringent options, and output results in non-binary file formats (i.e., PED/MAP).

Original PLINK options:

```
--mind 0.1
--geno 0.1
--maf 0.01
--hwe 0.001
```

Updated PLINK options:  

```
--mind 0.02
--geno 0.02
--maf 0.05
--hwe 0.001
```


### Converting genome build with liftOver

The following command is used to submit a job with `convertbuild.sh` for each chromosome:

```$ ./submit_convert.sh```

`convertbuild.sh` is a script wrapped around the `LiftMap.py` Python script<sup>1</sup>. `LiftMap.py`, which calls the `liftOver` tool to convert genotype positions between genome builds. In this case, `LiftMap.py` references the chain file `hg18ToHg19.over.chain.gz` in the `data` directory to convert GWAS call positions from build 36 to build 37 of the human genome.

<sup>1</sup>This script was obtained from the Abecasis Group Wiki (@University of Michigan) page for [LiftOver](http://genome.sph.umich.edu/wiki/LiftOver#Resources).


### Pre-phasing with SHAPEIT

The following command is used to submit a job with `prephase.sh` for each chromosome:

```$ ./submit_prephase.sh```

`prephase.sh` is a script wrapped around the `SHAPEIT` tool, which is used to phase GWAS calls into estimated haplotypes prior to imputation with `IMPUTE2`. In this case, a reference map is provided from the 1000 Genomes Project in the form `genetic_map_chr#_combined_b37.txt`. 

`SHAPEIT` is called with the following options:

```
--effective-size 11418
--seed 367946
```

**Note:** you cannot reproduce two multi-threaded runs with `SHAPEIT`, even if you specify the seed, so the `--thread` option is not used.


### Imputing with IMPUTE2

Prior to imputation with `IMPUTE2`, the R script `impute_ranges.R` is used to define interval ranges for each chromsome, with all intervals containing ~200 SNPs. The following command produces a text file for each chromosome with all intervals as well as a single text file listing the number of intervals for each chromosome:

```$ Rscript ./R/impute_ranges.R```

The following command is then used to submit a job with `impute.sh` for each chromosome and for each individual interval:

```$ ./submit_impute.sh```

`impute.sh` is a script wrapped around the `IMPUTE2` too, which is used to impute estimated study haplotypes to reference haplotypes (in this case, from the 1000 Genomes Project). 

`IMPUTE2` is called with the following options:

```
-use_prephased_g
-iter 30
-burnin 10
-k 80
-k_hap 500
-Ne 20000
-allow_large_regions
-filt_rules_l 'eur.maf==0'
```


### Post-impute QC with qctol