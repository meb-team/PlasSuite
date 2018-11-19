# PlasPredict 

PlasPredict takes an input assembly and predict plasmids in this assembly. 

*pipeline figure soon...*

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

### Outputs 

The script will generate several output files. 

#### Final outputs

| Suffix | Description | 
|---------|------------|
|.predicted_plasmids.fasta|All predicted plasmids in fasta format| 
|.resume.tsv|Give informations for each step of pipeline, with number of concerned contigs and cumulated length of concerned contigs| 

#### Intermediate subdirectory
Pipeline will create several subdirectories for each step in your output directory  

| Directory | Description | 
|---------|------------|
|chrm_search|Contains **.id** and **.paf** files. **.paf** is results of treated minimap2 alignment between all contigs and chromosomes database. **.id** lists contigs id with chromosomes alignment| 
|plasmids_search|Contains **.id** and **.paf** files. **.paf** is results of treated minimap2 alignment between all contigs and plasmids database. **.id** lists contigs id with plasmids alignment|
|circular|Contains **.fasta** and **.id** files. **.fasta** is fasta file with circular contigs, **.id** lists circular contigs id|  
|learning|Contains **.fasta**, **.id** and **.taxo** files. **.chromosomes.fasta**, **.plasmids.fasta**,**.unclassified.fasta** are respectively fasta files with PlasFlow predicted plasmids, predicted chromosomes and unclassified contigs. **.id** lists each fasta id. **.taxo** is a tsv file with contigs id in first column and PlasFlow predicted taxonomy in 2nd column.|
|phylogenetic_markers|*.tsv* file is raw hmm results for alignment between predicted proteins and phylogenetic markers. *.contigs.id* lists contigs id with phylogenetic markers alignments. *.proteins_family.id* lists HMM profiles with alignments. *.predicted_proteins.id* lists predicted proteins ids with alignment| 
|plasmids_markers|**.conserve.blast.tsv** is treated blast alignment between markers and predicted proteins. **.conserve.searched.id** lists plasmids markers id found. **.conserve.contigs.id** lists contigs id with plasmids markers alignment. Mobilization proteins, replication sequences, oriT sequences and mate-pair formation proteins are respectively indicated by **mob**, **rep**,**orit** and **mpf**. **.all_markers.contigs.id** lists contigs ids with alignement with any plasmids markers.| 
|proteins_prediction|**.faa** file with predicted proteins in amino-acids (fasta format)| 
|rna_search|**.tsv** is treated blast results between contigs and RNA. **.id** lists contigs id with RNA alignment|    


### Required tools 
Version indicated are tested versions. It can be work (or not) with others. 
* [Prodigal](https://github.com/hyattpd/Prodigal) V2.6.3 
* [HHMER](http://hmmer.org/) V3.1b2
* [Minimap2](https://github.com/lh3/minimap2) V2.12-r827
* [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) v2.2.31+
* [PlasFlow](https://github.com/smaegol/PlasFlow) V1.1





