### Pre-processing

"Remove SNPs and individuals with poor calling rate":
Use Plink for BED/BIM/FAM format

Plink options:
	--mind .02
	--geno 0.02
	--maf 0.05
	--hwe 0.001

Original Plink options:
	--mind 0.1
	--geno 0.1
	--maf 0.01
	--hwe 0.001
	+ sex check option?
	+ genome option: check for cryptic relatedness to evaluate paired identity by descent in all samples

Split the dataset by chromosome:

for chr in $(seq 1 22); do
     plink --file myGwasData \
           --chr $chr \
           --recode \
           --out myGwasData.chr$chr ;
done

./preprocess.sh ./data/ SYounkin_MayoGWAS_09-05-08

### Pre-Phasing with SHAPEIT

Version v2.r790

* File inputs *
shapeit --input-bed gwas.bed gwas.bim gwas.fam \
        -M genetic_map.txt \
        -O gwas.phased
        
    Map input or no?
		--input-map chr20.gmap.gz
		
* Effective pop size
        --effective-size 11418

* Multi-threading and seeding *
        --thread 4
        
        --seed 123456789
        Note also that you cannot reproduce two multi-threaded runs even if you specify the seed.

./prephase.sh ./data/ SYounkin_MayoGWAS_09-05-08 1 2
./prephase.sh ./data/ SYounkin_MayoGWAS_09-05-08 3 5
./prephase.sh ./data/ SYounkin_MayoGWAS_09-05-08 6 8
./prephase.sh ./data/ SYounkin_MayoGWAS_09-05-08 9 12
./prephase.sh ./data/ SYounkin_MayoGWAS_09-05-08 13 17
./prephase.sh ./data/ SYounkin_MayoGWAS_09-05-08 18 22


### Imputation with IMPUTE2

Version 2.3.1

reference panel : https://mathgen.stats.ox.ac.uk/impute/data_download_1000G_phase1_integrated_SHAPEIT2_9-12-13.html

(ii) ALL.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nosing.tgz - haplotypes with singleton sites removed

Impute options:
		–-known_haps_g
		–-iter 30
		–-burnin 10
		–-k 80
		–-k_hap 500
		–-Ne 20000
		–-seed 367946
		–-allow_large_regions
		–-filt_rules_l 'eur.maf==0'
		
We use the sliding windows approach and make sure that within each 2.5-7MB chucnk we have ~ 200 GWAS Panel SNPs

### Post-Impute QC with qctool

–qctool -g example.bgen -og subsetted.gen -snp-missing-rate 0.05 -maf 0 1 -info 0.4 1 -hwe 20