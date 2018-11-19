# PlasPredict 

### How to launch 

` bash PlasPredict.sh -a <assembly.fasta> -o <outdir>`

Output options : 
* --prefix <prefix> : prefix for output files (default : assembly.fasta name) 

Databases options : 

If not specified, databases are searched in `hilpert/databis/plasmidome_databases`
* --chrm_db <fasta> : fasta file with bacterial chromosomes sequences you want to use 
* --rna_db <fasta> : fasta file with rRNA sequences (must be back transcribed) you want to use
* --phylo_db <hmm> : hmm profile(s) with phylogenetic markers
* --markers_db <dir> : dir where plasmids markers databases are stored
* --plasmids_db <fasta> : fasta file with complete plasmids sequences you want to use

### Required tools 
Version indicated are tested versions. It can be work (or not) with others. 
* [Prodigal](https://github.com/hyattpd/Prodigal) V2.6.3 
* [HHMER](http://hmmer.org/) V3.1b2
* [Minimap2](https://github.com/lh3/minimap2) V2.12-r827
* [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) v2.2.31+
* [PlasFlow](https://github.com/smaegol/PlasFlow) V1.1



