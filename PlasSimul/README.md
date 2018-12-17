# PlasSimul 

This part is for simulation and treatment of plasmidome sequencing. 

## 1. Starting data 

You start with 2 databases : plasmids and contaminants. References used are in [plasmids.txt](simulation_ref/plasmids.txt) and [contaminants.txt](simulation_ref/contaminants.txt). 

The idea is to have one plasmids per specie. You can construct database from all plasmids and contaminants database with 
```
bash construct_simulation_databases.sh --plasmids_db all_plasmids.fasta --chrm_db all_prokaryotes.fasta --plasmids_taxo all_plasmids.taxo.tsv --chrm_taxo all_prokaryotes.taxo.tsv -o simulation_database
``` 
See general readme for construct complete databases and taxonomy files. 
You will obtain simulation database with one plasmid per specie, and 500 random chromosomes (one per specie) with RNA data available for further clustering. You can modify the number of sequences you want with `--n_plasmids` and `--n_chrm` options. 

## 2. Sequencing simulation 

For simulation sequencing, you must have an abundance file for your plasmids and contaminants. It's a .tsv file with sequences reference in first column and abundance in 2nd column. The sum of all abundance must be equal to 100. Abundance files for [used plasmids](simulation_ref/plasmids_abundance.txt) and [used contaminants](simulation_ref/contaminants_abundance.txt) are given in [simulation_ref](simulation_ref) (generate by Grinder with powerlaw 0.1)    
* for Illumina 10X sequencing simulation
```
bash parallelize_simulation.sh simulation_database/plasmids.selectall.fasta --illumina 10 --ab_file plasmids_abundance.txt -o simulated_reads
```
Modify `--illumina` for other coverage. 
* for PacBio 1X sequencing simulation 
```
bash parallelize_simulation.sh simulation_database/plasmids.selectall.fasta --pacbio 1 --ab_file plasmids_abundance.txt -o simulated_reads
```
Modify `--pacbio` for other coverage. 
* for Illumina 10X sequencing with 20% contamination
```
bash parallelize_simulation.sh simulation_database/plasmids.selectall.fasta --illumina 10 --ab_file plasmids_abundance.txt --contamination 0.2 --contamination_f simulation_database/prokaryotes.select500.fasta --ab_file_cont contaminants_abundance.txt -o simulated_reads
```
`--contamination 0.2` is for 20% contamination. It means the number of contaminants reads added is 20% of plasmids reads. 
* for PacBio 1X sequencing with 20% contamination
```
bash parallelize_simulation.sh simulation_database/plasmids.selectall.fasta --pacbio 1 --ab_file plasmids_abundance.txt --contamination 0.2 --contamination_f simulation_database/prokaryotes.select500.fasta --ab_file_cont contaminants_abundance.txt -o simulated_reads
```
* for PacBio 1X and Illumina 10X sequencing with contamination
```
bash parallelize_simulation.sh simulation_database/plasmids.selectall.fasta --pacbio 1 --illumina 10 --ab_file plasmids_abundance.txt --contamination 0.2 --contamination_f simulation_database/prokaryotes.select500.fasta --ab_file_cont contaminants_abundance.txt -o simulated_reads
```

## 3. Assembly 

For assembly steps, you can assemble using several tools in one step. Available tools are Megahit, SPAdes, MetaSPAdes, hybridSPAdes and Unicycler. For Unicycler and HybridSPAdes, you have to provide PacBio and Illumina simulated sequencing. 

Example for assembly with all available tools, for Illumina 10X and PacBio 1X sequencing with 20% contamination : 
```
bash run_assembly.sh -i simulated_reads/grinder-illumina-10X-am0.1-with-cont0.2-reads.fastq -l simulated_reads/grinder-pacbio-1X-am0.1-with-cont0.2-reads.fastq --megahit --metaspades --spades --unicycler --hybridspades -o assembly
```

* CAP3 assembly 

CAP3 hybrid assembly can be launch separately with 
```
bash run_cap3.sh simulated_reads/grinder-illumina-10X-am0.1-with-cont0.2-reads.fastq --l_fq simulated_reads/grinder-pacbio-1X-am0.1-with-cont0.2-reads.fastq -o assembly
```
You can change overlap thresholds with `--ov_length` and `--ov_percent`

## 4. Decontamination 

## 5. Treatment 


