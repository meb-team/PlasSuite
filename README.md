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
bash plasmidome_scripts/PlasAnnot/PlasAnnot.sh -f resultsPlasPredict/myAssembly.predicted_plasmids.fasta -o resultsPlasAnnot```

### 2.3. PlasTaxo 
Launch PlasTaxo to obtain taxonomy
```
bash plasmidome_scripts/PlasTaxo/PlasTaxo.sh --predicted_plasmids_dir resultsPlasPredict --predicted_plasmids_prefix myAssembly -o resultsPlasTaxo --prefix myAssembly
```

### 2.4. PlasResist 
Launch PlasResist to treat resistances genes 

