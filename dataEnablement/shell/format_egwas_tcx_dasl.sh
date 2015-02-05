#!/bin/bash

synapse login

# Synapse ID for cerebellum DASL data
SYNAPSE_ID="syn3131612"

# get meta data for object
OBJECT_PROPS=`mktemp syn-props.XXX`
synapse show $SYNAPSE_ID > $OBJECT_PROPS

# download data (this will save in current directory; not sure how to specify
# path or point to synapseCache)
synapse get $SYNAPSE_ID

# Specify path to cerebellum file
TCX_DASL_FILE=$(grep "name=" $OBJECT_PROPS)
TCX_DASL_FILE=${TCX_DASL_FILE##*=}
echo $TCX_DASL_FILE

# Pull out technical covariates
TECH_COVAR_FILE="mayo_egwas_tcx_tech_vars.txt"

paste <(cut -f 2 $TCX_DASL_FILE | awk '{gsub("IID+.*", "IID")}1') \
    <(cut -f 7-13 $TCX_DASL_FILE) \
    > $TECH_COVAR_FILE

# specify target folder for technical covariates
TECH_DIR_ID="syn3161028"

synapse store --parentid $TECH_DIR_ID $TECH_COVAR_FILE

# Pull out expression values
EXPRS_FILE="mayo_egwas_tcx_expression.txt"

paste <(cut -f 2 $TCX_DASL_FILE | awk '{gsub("IID+.*", "IID")}1') \
    <(cut -f 14- $TCX_DASL_FILE) \
    > $EXPRS_FILE

# specify target folder for expression values
EXPRS_DIR_ID="syn2786319"

synapse store --parentid $EXPRS_DIR_ID $EXPRS_FILE

# clean up
rm $OBJECT_PROPS
