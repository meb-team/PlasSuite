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

### Assembly evaluation 

Assembly evaluation is done with MetaQuast and the treatment of its output files. Evaluation parameters are : 
* N50 
* Number of misassembled contigs : misassembled contigs are defined like that by Metaquast, and represents contigs that can be chimeric (different part of contigs maps against different plasmids), inverted (maps in two directions against same plasmid) or relocalised (left and right part of contig maps against same plasmid with gap or overlap > 1 kb) 
* Longest contig : longest contig produces by assembly 
* Reference coverage : 
* Complete plasmids : 

### Plasmid prediction 

### Plasmid prediction evaluation

## Results 

### Short reads assemblies (no contamination)  

### Hybrid assemblies 

#### Variation of long reads coverage 

### 



# Plasmidome analysis (real sequencing) 

### Data 



   




