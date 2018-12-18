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

CAP3 takes short-read assembly and long reads for hybrid assembly. 

* Hybrid assembly from Megahit assembly and long reads 
```
bash run_cap3.sh assembly/megahit/final.contigs.fa --l_fq simulated_reads/grinder-pacbio-1X-am0.1-with-cont0.2-reads.fastq -o assembly/megahitCap3
```
You can change overlap thresholds with `--ov_length` and `--ov_percent`

## 4. Assembly treatment 

* Prerequisites 
 * Single fasta databases   
You will need one directory per database (1 for plasmids and 1 for contaminants) with single fasta of each sequences. 
You can generate this directories from multi fasta with 
```
python3 plasmidome_scripts/bin/write_separate_fasta.py simulation_database/plasmids.selectall.fasta simulation_database/plasmids_sequences 
python3 plasmidome_scripts/bin/write_separate_fasta.py simulation_database/contaminants.select500.fasta simulation_database/contaminants_sequences
```
 * Plasmids length file   
You will need a tsv file with plasmids reference in first column and plasmids length in second column. You can generate it with 
```
python3 plasmidome_scripts/bin/sequences_length.py simulation_database/plasmids.selectall.fasta simulation_database/plasmids.selectall.length 
```

* Run assembly treatment for short-reads contaminated assemblies 
```
bash run_assembly_treatment.sh megahit,metaspades,spades assembly/megahit/final.contigs.fa assembly/metaspades/scaffolds.fasta assembly/spades/scaffolds.fasta -o assembly_evaluation --suffix short_reads_assembly --metaquast --metaquast_treatment --metaquast_cont --sr_cov 10X --cont 20% --plasmid_db simulation_database/plasmids_sequences --cont_db simulation_database/contaminants_sequences --plasmids_length simulation_database/plasmids.selectall.fasta --plasmids_ab plasmids_abundance.txt
```

* Run assembly treatment for hybrid contaminated assemblies
```
bash run_assembly_treatment.sh hybridspades,unicycler,megahitCap3 assembly/hybridspades/scaffolds.fasta assembly/unicycler/assembly.fasta assembly/megahitCap3/xxxx -o assembly_evaluation --suffix hybrid_assembly --metaquast --metaquast_treatment --metaquast_cont --sr_cov 10X --lr_cov 1X --cont 20% --plasmid_db simulation_database/plasmids_sequences --cont_db simulation_database/contaminants_sequences --plasmids_length simulation_database/plasmids.selectall.fasta --plasmids_ab plasmids_abundance.txt
```

If you don't use contamination, delete `--metaquast_cont` option. 

* Main output files 
Output files are in `<outdir>/metaquast_treatment_<suffix>/`  

| File | Description | 
|---------|------------|
|assemblies_stats.tsv|Main result file with all assembly statistics| 
|plasmids_stats.tsv|Assembly statistic of each plasmid in each assembly| 
|contigs_stats.tsv|Statistics for each type of contigs in each assembly| 
|plasmids_contigs.*.id|List of plasmids contigs, one file per assembly|
|chromosomes_contigs.*.id|List of contaminated contigs, one file per assembly| 

## 5. Decontamination 

Decontamination can be done with several tools. cBar and PlasFlow use learning to classify sequences in plasmids or chromosomes (or unclassified for PlasFlow). 

* cBar/PlasFlow 

You can launch PlasFlow with several detection threshold, cBar, or a combination of cBar and PlasFlow. 

	* PlasFlow with 70 (default) and 80% threshold for Megahit assembly 
```
bash run_learning_decontamination.sh -f assembly/megahit/final.contigs.fa -o decontamination --plasflow 70,80 --real_plasmids assembly_evaluation/metaquast_treatment_short_reads_assembly/plasmids_contigs.megahit.id --real_chrm assembly_evaluation/metaquast_treatment_short_reads_assembly/chromosomes_contigs.megahit.id --prefix megahit10X
```
	* cBar for Megahit assembly  
```
bash run_learning_decontamination.sh -f assembly/megahit/final.contigs.fa -o decontamination --cbar --real_plasmids assembly_evaluation/metaquast_treatment_short_reads_assembly/plasmids_contigs.megahit.id --real_chrm assembly_evaluation/metaquast_treatment_short_reads_assembly/chromosomes_contigs.megahit.id --prefix megahit10X
```

	* Combination of cBar and PlasFlow at threshold 70% for Megahit assembly 
```
bash run_learning_decontamination.sh -f assembly/megahit/final.contigs.fa -o decontamination --cbar_plasflow 70 --real_plasmids assembly_evaluation/metaquast_treatment_short_reads_assembly/plasmids_contigs.megahit.id --real_chrm assembly_evaluation/metaquast_treatment_short_reads_assembly/chromosomes_contigs.megahit.id --prefix megahit10X
```

You can combine `--plasflow`, `--cbar` and `--cbar_plasflow` options to have directly each decontamination with only one command.  

* Main output files 

You have one subdirectory by method : `plasflow`, `cbar`, `cbar_plasflow`. 
In each directory these files are present :  

| File extension | Description | 
|---------|------------|
|.chrm.id or .chromosomes.id|List of contigs identified as chromosomes| 
|.plasmids.id|List of contigs identified as plasmids| 
|.unclassified.id (only for PlasFlow)|List of unidentified contigs| 
|.stats|Comparison stats with "real" plasmids and contaminants identified by previous assembly treatment step. Stats like False positives, True positives, False negative and False positives are displayed.| 


## 5. Treatment 


