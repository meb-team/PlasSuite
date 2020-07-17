# PlasSuite
Scripts for plasmidome analysis 

## [PlasSimul](PlasSimul) 
Scripts for plasmidome sequencing simulation and analysis  

## [PlasPreAssembl](PlasPreAssembl) 
Treat and clean raw reads before assembly

## [PlasPredict](PlasPredict) 
Predict plasmids contigs from assembly 

## [PlasAnnot](PlasAnnot)
Annotate plasmids contigs from assembly (preferentially with only predicted plasmids) 

## [PlasTaxo](PlasTaxo) 
Retrieve and compare taxonomy from assembly using PlasFlow taxonomy and plasmids alignment 

## [PlasAbund](PlasAbund) 
Produce abundance matrix of predicted genes clusters, and resistances genes abundance matrix. 

# Example of workflow 

## 1. Prepare or download your databases

To be found by default, databases must be stored in `$HOME/plasmidome_databases` so create this directory.  

These files can be downloaded with the following command:
```
wget https://s3.mesocentre.uca.fr/swift/v1/AUTH_f70cfb776e144d419461999459de06fb/PlasSuite/plasmidome_databases.tar.gz
```


## 2. Launch workflow 

You starts with a plasmidome assembly obtained from cleaned reads. Let's imagine this assembly is called myAssembly.fasta and your are localised in directory where you clone this repository. 

Cleaned reads can be obtained with [PlasPreAssembl](PlasPreAssembl). In this work, assemblies are done with default Megahit but you can use any assembly as long as it produces fasta file. Example for running Megahit : 
```
megahit -1 <R1_cleaned_reads.fastq> -2 <R2_cleaned_reads.fastq> -r <single_end_reads.fastq> -t 6
```

### 2.1. PlasPredict 
Launch PlasPredict to isolate predicted plasmids from your assembly. 
 
```
bash PlasSuite/PlasPredict/PlasPredict.sh -a myAssembly.fasta -o resultsPlasPredict 
```

### 2.2. PlasAnnot 
Launch PlasAnnot to annotate predicted plasmids 

```
bash PlasSuite/PlasAnnot/PlasAnnot.sh -f resultsPlasPredict/myAssembly.predicted_plasmids.fasta -o resultsPlasAnnot
```

### 2.3. PlasTaxo 
Launch PlasTaxo to obtain taxonomy
```
bash PlasSuite/PlasTaxo/PlasTaxo.sh --predicted_plasmids_dir resultsPlasPredict --predicted_plasmids_prefix myAssembly -o resultsPlasTaxo --prefix myAssembly
```

This first 3 steps has to be launch for all your assemblies. Then you can launch resistances genes treatment. To do that, you must create an input file with all your assemblies prefix. For example, the file `prefix.txt` which contains 3 lines for 3 assemblies :  
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

### 2.4. PlasAbund 
Launch PlasAbund to have abundance matrix. 

```
bash PlasSuite/PlasAbund/PlasAbund.sh -i prefix.txt -o resultsPlasAbund --reads_dir cleaned_reads
```

### Authors 
* Cécile Hilpert - [cecilpert](https://github.com/cecilpert)
* Didier Debroas
