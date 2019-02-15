# Plasmidome analysis (simulation) 

## Material and methods

### Database construction 

To simulate plasmidome sequencing, we need initial sequences, from plasmids and from chromosomes to simulate contamination. 
Accessions of plasmids and contaminants used are in [plasmids_accession.txt](PlasSimul/simulation_ref/plasmids_accession.txt) and [contaminants_accession.txt](PlasSimul/simulation_ref/contaminants_accession.txt). There's 1828 plasmids sequences and 506 chromosomes sequences (more than 500 because we can have more than 1 chromosomes for 1 genome). 
To construct plasmid database, plasmid database from NCBI is used, and 1 sequence per specie is keeped. To construct contaminants databases, prokaryotes chromosomes database from NCBI is used, 1 genome per database is keeped and 500 genomes are randomly selected. 

### Sequencing simulation 

Illumina and PacBio sequencing are simulated with Grinder. For Illumina sequencing, 150 bp paired-end reads with insert size of 350 bp are simuled. For PacBio sequencing, 6000 bp single-end reads are simuled. To simulate contamination, contaminants reads are simuled and added to plasmids reads. For example, for what we call "20% contamination", a contamination reads number of 20% of plasmids reads is added. If there's 100k plasmids reads, 20k contaminants reads will be add to sequencing. 

Several sequencing coverage are simuled : 1X, 2X, 5X, 10X and 20X for Illumina. 0.5X,1X and 5X for PacBio. Several contamination rate are also simuled : 0%, 5%, 10% and 20%. 

### Assembly 

6 tools are tested for assembly. Short-reads only assemblies are tested with Megahit, SPAdes and MetaSPAdes. Hybrid assemblies are tested with HybridSPAdes, Unicycler, and a "super-assembly" of short-reads assemblies and long reads with CAP3.  

List of assemblies done for each tool : 
* Megahit, MetaSPAdes and SPAdes : All Illumina coverage (1X, 2X, 5X, 10X, 20X) for 0% contamination. Illumina coverage of 10X for other contamination rates. 
* HybridSPAdes and Unicycler : Illumina coverage of 10X, all PacBio coverage for 0% contamination. Illumina coverage of 10X and PacBio coverage of 1X for other contamination rates. 
* CAP3 : Used with Megahit, MetaSPAdes and SPAdes short assemblies (10X) and with PacBio long reads for coverage 1X.   

After assembly, only contigs >= 1kb are conserved. 

### Assembly evaluation 

Assembly evaluation is done with MetaQuast and the treatment of its output files. Evaluation parameters are : 
* N50 : N50 is a classical assembly evaluation parameters. It means that 50% of assembly bases are in contigs with N50 length or more. 
* Number of misassembled contigs : misassembled contigs are defined like that by Metaquast, and represents contigs that can be chimeric (different part of contigs maps against different plasmids), inverted (maps in two directions against same plasmid) or relocalised (left and right part of contig maps against same plasmid with gap or overlap > 1 kb) 
* Longest contig : longest contig produces by assembly.
* Reference coverage : reference coverage is the percentage of bases in reference sequences (plasmids used to simulate sequencing) covered by good contigs (correct or ambiguous, misassembled are discarded). 
* Complete plasmids : A plasmid is complete when at least 90% of its length is covered by only one contig. 
* Contaminated contigs : Contaminated contigs are contigs that doesn't map with reference plasmids and maps against reference contaminants. 

### Plasmid prediction 

Plasmid prediction is done for two assemblies : Megahit and MetaSPAdes short-reads assemblies, defined as the best with assembly evaluation. Several methods for separate plasmids contigs and contaminants contigs are tested. Two tools designed for this purpose are first tested : 
* PlasFlow : PlasFlow is a tool that uses learning to create models for plasmid prediction. Each contig will have a probability to be plasmids or chromosomes. Probability threshold can be defined, if a contig have a probability greater than this threshold to be plasmids or chromosomes, it will be assigned to the corresponding category. If not, it will be defined as "unclassified". PlasFlow has been tested with all probability threshold from 10 to 90, with steps of 10. 
* cBar : cBar is another tool that classify contigs as plasmids or chromosomes with learning. There's no adjustable threshold and contigs can just be classify as plasmids or chromosomes, not unclassified. 
* cBar + PlasFlow : cBar and PlasFlow seems to produce relatively complementary results, so a combination of the tools has been tested. 
2 others methods are also tested : 
* Chromosomes alignment : The purpose is to align against known prokaryotic chromosomes to eliminate chromosomes contigs. The database of chromosomes is NCBI prokaryotes chromosomes, the same used for select contaminants genomes in Database construction part. Contaminants genomes are discarded. Contigs are aligned against this new database. Contigs that maps are considered as chromosomes and others as plasmids. Several clustering are then done to estimate if we can decontaminate samples when we have a chromosomes with more distant genome. Clustering is done using contaminants chromosomes as seeds and it deletes chromosomes from database wich are closer than 90, 95, 97 and 99% identity.      
* Plasmids markers searching : The purpose is to search plasmids markers in contigs. When a plasmid marker is found, contig is classified as plasmids. Markers used are markers from mob_suite tool. It contains replicase dna, oriT dna, mobilization proteins and mate-pair formation proteins. For proteins, search is done with blastp against contigs predicted genes translate to proteins. For DNA, search is done with blastn against contigs. Same treatment parameters as mob_suite are applied. If markers maps with contigs or predicted genes at 80% identity and on 80% of its length (90 and 90% for oriT dna), it's considered as found. 

### Plasmid prediction evaluation

To evaluate plasmid prediction, we compare real affectation (if a contig represents plasmid or chromosome, determined by alignment against reference done for assembly evaluation) and predicted affectation (contigs classified as plasmids or chromosomes by plasmid prediction methods). 
Based on this comparison, we can define true positives, true negatives, false positives and false negatives contigs. 
* True positives (TP) : contigs classified as plasmids and really represents plasmids 
* True negatives (TN) : contigs classified as chromosomes and really represents chromosomes
* False positives (FP) : contigs classified as plasmids but really represents chromosomes
* False negatives (FN) : contigs classified as chromosomes but really represents plasmids. 
With this parameters, we can compute metrics : 
* Recall : TP / (TP + FP). Number of correctly predicted plasmids among all plasmids. Reflects how much real plasmids are correctly predicted. 
* Precision : TP / (TP + TN). Number of correctly predicted plasmids among all contigs predicted as plasmids. Reflects how much predicted plasmids are real plasmids. 
* Accuracy : (TP+TN) / (TP+TN+FN+FP). Number of correctly predicted contigs, plasmids or chromosomes among all contigs. Reflects how much sequences are correctly predicted. 
* [F1-Score](https://en.wikipedia.org/wiki/F1_score) and F0.5-Score : Summarize recall and precision (harmonic average of recall and precision for F1-Score).

# Plasmidome analysis (real sequencing) 

## Material and methods 

### Data 

Data are Illumina sequencing from several environment : Pavin lake, hospital biofilm, human feces and wastewater treatment plant. 

### Pre-treatment 

Reads are cleaned with Trimmomatic. 
NonPareil is used to estimate rarefaction curve. 

### Assembly 

Assemblies are done with Megahit. 

### Plasmids prediction 



### Plasmids annotation 

### Plasmids taxonomy 

### Genes abundance 



   




