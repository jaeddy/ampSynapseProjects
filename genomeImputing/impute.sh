#!/bin/sh

# specify directories
DATA_DIR="$1"
GWAS_DATA="$2"

cd "$DATA_DIR"

# reference data files
GWAS_DIR="gwas_results/${GWAS_DATA}.by_chr/"
PREPHASED_DIR="gwas_results/${GWAS_DATA}.phased/"
GENMAP_DIR="haplotypes/"

HAP_PREFIX=".integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nosing."
NUM_FILE="${GWAS_DIR}impute_intervals/num_ints.txt"


# create new directory to store results
RESULTS_DIR="gwas_results/${GWAS_DATA}.imputed/"

if [ ! -e "$RESULTS_DIR" ]; then
    mkdir "$RESULTS_DIR"
fi

# impute estimated haplotype files with impute2 and save to results directory
for CHR in 22; do
	
	ESTHAP_FILE="${PREPHASED_DIR}${GWAS_DATA}.chr${CHR}.phased.haps"
	
	REFHAP_FILE="${GENMAP_DIR}ALL.chr${CHR}${HAP_PREFIX}haplotypes.gz"
	LEGEND_FILE="${GENMAP_DIR}ALL.chr${CHR}${HAP_PREFIX}legend.gz"
	MAP_FILE="${GENMAP_DIR}genetic_map_chr${CHR}_combined_b37.txt"
	
	RESULT_FILE="${GWAS_DATA}.chr${CHR}"
	
	NUM_INTS=$(awk -v chr=$CHR '$2==chr {print $3}' $NUM_FILE)
	INTS_FILE="${GWAS_DIR}impute_intervals/chr${CHR}.ints"
	for INT in 1; do
		
		CHUNK_START=$(awk -v i=$INT '$3==i {print $5}' $INTS_FILE)
	    CHUNK_END=$(awk -v i=$INT '$3==i {print $6}' $INTS_FILE)
    
        RESULT_INT="${RESULT_FILE}.pos${CHUNK_START}-${CHUNK_END}.imputed"
        
        echo "$REFHAP_FILE"
        echo "$LEGEND_FILE"
            
        impute2 -use_prephased_g \
            –known_haps_g $ESTHAP_FILE \
            -h $REFHAP_FILE \
            -l $LEGEND_FILE \
            –iter 30 \
            –burnin 10 \
            –k 80 \
            –k_hap 500 \
            –Ne 20000 \
            -int $CHUNK_START $CHUNK_END \
            –seed 367946 \
            –allow_large_regions \
            –filt_rules_l 'eur.maf==0' \
            -o $RESULT_INT ;
	
	done
	
	mv *.chr${CHR}.*.imputed* "$RESULTS_DIR"
done

    