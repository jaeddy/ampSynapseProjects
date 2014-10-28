import synapseclient
from synapseclient import File, Activity

syn = synapseclient.Synapse()
syn.login()

### Ensembl raw counts
annotDict = dict()
annotDict['fileType'] = 'count'
annotDict['normalized'] = 'no'
annotDict['summaryLevel'] = 'gene'

act = Activity(name='Counting', description='Raw gene counts using HTSeq.')
act.used(['syn2290932', 'syn2215531']) # syn2290932 is BAM, syn2215531 is GTF
act.executed('syn2243147') # syn2243147 is htseq
counts =
File(path='/projects/CommonMind/data/FROM_CORE/Production/readCounts/CMC.'
'DataFreeze.CountMatrix_V7.ensemble.Clean.txt',
name='PFC_CountMatrix_ensembl.txt', description='Gene counts for all BAMs'
'summarized using Ensembl gene models. QC counts (e.g. \"ambiguous\") from HTSeq'
'are not included.', parentId='syn2290933', synapseStore=True)
counts = syn.store(counts, activity=act)
syn.setAnnotations(counts, annotations=annotDict)


# Need to check:
# - annotations: standards?
# - synapseclient: auto-return synapse id on upload
# - syn.store: specify activity independently?
# - Activity.executed: executable file, or just script?

### Plink re-processed genotypes
