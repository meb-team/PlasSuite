# plasmidome_scripts
Scripts for plasmidome analysis 

## [PlasPredict](PlasPredict) 
Predict plasmids contigs from assembly 

## [PlasAnnot](PlasAnnot)
Annotate plasmids contigs from assembly (preferentially with only predicted plasmids) 

## [PlasTaxo](PlasTaxo) 
Retrieve and compare taxonomy from assembly using PlasFlow taxonomy and plasmids alignment 

## [PlasResist](PlasResist) 
Analyze Resfams resistance from assembly annotation. Produce abundance matrix.  

# Example of workflow 

## 1. Prepare your databases 

To be found by defaults, databases must be stored in `$HOME/plasmidome_databases` so create this directory.  

### 1.1. Plasmids database  
* **Sequences**   
	`$HOME/plasmidome_databases/all_plasmids.fasta` is default name.  
	Plasmids sequences must be a fasta file contained complete plasmids.    
	You can obtained last version of NCBI plasmids databases with  
	```plasmidome_scripts/bin/update_plasmids_database.sh -o $HOME/plasmidome_databases/all_plasmids.fasta```  
	If you already have plasmids fasta file and you just want to add new sequences, use `--db <your_file>` option. If you want to clean deprecated sequences (present in your file but not in ncbi database) use `--clean` option.      
* **Taxonomy**   
	
### 1.2. Chromosomes database 
* **Sequences**  
* **Taxonomy**  
	
### 1.3. Plasmids markers database   
Plasmids markers database must be stored in `$HOME/plasmidome_databases/plasmids_markers` directory. 4 files must be in this directory :
* `mob.proteins.faa` : fasta file with mob proteins in amino acids.  
* `mpf.proteins.faa` : fasta file with mpf proteins in amino acids.  
* `rep.dna.fas` : fasta file with rep DNA in nucleotides.  
* `orit.fas` : fasta file with orit DNA in nucleotides.   
This files has been download from [mob_suite](https://github.com/phac-nml/mob-suite) tool, via figshare link : [https://ndownloader.figshare.com/articles/5841882?private_link=a4c92dd84f17b2cefea6](https://ndownloader.figshare.com/articles/5841882?private_link=a4c92dd84f17b2cefea6) 		
		
### 1.4. rRNA database
* **Sequences** 
* **Taxonomy** 
	
### 1.5. Phylogenetic markers database

## 2. Launch workflow 

You starts with a plasmidome assembly obtained from cleaned reads. Let's imagine this assembly is called myAssembly.fasta and your are localised in directory where you clone this repository. 

### 2.1. PlasPredict 
Launch PlasPredict to isolate predicted plasmids from your assembly. 
 
```
bash plasmidome_scripts/PlasPredict/PlasPredict.sh -a myAssembly.fasta -o resultsPlasPredict
```

### 2.2. PlasAnnot 
Launch PlasAnnot to annotate predicted plasmids 

```
bash plasmidome_scripts/PlasAnnot/PlasAnnot.sh -f resultsPlasPredict/myAssembly.predicted_plasmids.fasta -o resultsPlasAnnot
```

### 2.3. PlasTaxo 
Launch PlasTaxo to obtain taxonomy
```
bash plasmidome_scripts/PlasTaxo/PlasTaxo.sh --predicted_plasmids_dir resultsPlasPredict --predicted_plasmids_prefix myAssembly -o resultsPlasTaxo --prefix myAssembly
```

This first 3 steps are done with all your assemblies. Then you can launch resistances genes treatment. To do that, you must create an input file with all your assemblies prefix. For example, the file `prefix.txt` which contains 3 lines for 3 assemblies :  
```
myAssembly
myAssembly2
myAssembly3
```
You also need a directory with cleaned reads use for assembly. This directory, for example `cleaned_reads` must be organized with one directory per sample. Reads must be zipped and R1 reads must have "R1" in their name, R2 reads "R2" and single-ends reads "se". 
```
|-- cleaned_reads 
	|-- myAssembly 
		|-- myAssembly_R1_trimmed_pe.fastq.gz
		|-- myAssembly_R2_trimmed_pe.fastq.gz 
		|-- myAssembly_trimmed_se.fastq.gz  
	|-- myAssembly2 
		|-- myAssembly2_R1_trimmed_pe.fastq.gz
		|-- myAssembly2_R2_trimmed_pe.fastq.gz 
		|-- myAssembly2_trimmed_se.fastq.gz 
	|-- myAssembly3 
		|-- myAssembly3_R1_trimmed_pe.fastq.gz
		|-- myAssembly3_R2_trimmed_pe.fastq.gz 
		|-- myAssembly3_trimmed_se.fastq.gz 			
```

### 2.4. PlasResist 
Launch PlasResist to treat resistances genes 

```
bash plasmidome_scripts/PlasResist/PlasResist.sh -i prefix.txt -o resultsPlasResist --reads_dir cleaned_reads
```
