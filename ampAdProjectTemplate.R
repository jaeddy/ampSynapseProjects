#####
## LOAD NECESSARY PACKAGES (OR INSTALL IF NOT ALREADY INSTALLED)
#####
if(!require(devtools)){
  install.packages("devtools")
  require(devtools)
}
if(!require(synapseClient)){
  source("http://depot.sagebase.org/CRAN.R")
  pkgInstall("synapseClient")
  require(synapseClient)
}

## LOG INTO SYNAPSE - AUTOMATICALLY IF .synapseConfig FILE SET UP - OTHERWISE INTERACTIVELY
synapseLogin()

#####
## INPUT THE ID OF YOUR NEWLY CREATED AMP-AD SYNAPSE PROJECT
#####
projId <- "syn2397885"

## THE ID OF THE TEMPLATE PROJECT IN SYNAPSE
templateId <- "syn2395418"

## SOURCE IN GIST WITH copyWikis FUNCTION
source_gist("10067278")

#####
## COPY THE WIKIS FROM THE TEMPLATE TO THE NEW PROJECT
#####
copyWikis(oldOwnerId=templateId, newOwnerId=projId)
onWeb(projId)
