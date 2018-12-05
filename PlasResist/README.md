# PlasResist

PlasResist creates abundance matrix for resistances in several samples 

### How to launch ?

```
bash PlasResist.sh  bash PlasTaxo.sh -i <input file> -o <output directory> --reads_dir <reads directory> --annot_dir <annotation directory>"  
```

* *Mandatory arguments*  
* *input file* : input file is .txt file with list of your assemblies prefix. Example :  
```
NG-14342_NG-17411_BIOFILM.megahit
NG-14342_NG-17411_WWTP2.megahit
```
* *reads directory* : reads directory is directory where your cleaned reads are stored. In this directory, you must have one directory per sample, with paired end R1 and R2 fastq and single end fastq. R1 fastq name must contain "R1", R2 fastq name must contains "R2" and single end fastq name must contains "se". Fastq files are zipped (.fastq.gz). Example :  
```
|-- reads directory 
	|-- NG-14342_NG-17411_BIOFILM
		|-- NG-14342_NG-17411_BIOFILM_R1_trimmed_pe.fastq.gz
		|-- NG-14342_NG-17411_BIOFILM_R2_trimmed_pe.fastq.gz
		|-- NG-14342_NG-17411_BIOFILM_trimmed_se.fastq.gz
	|-- NG-14342_NG-17411_BIOFILM
		|-- NG-14342_NG-17411_WWTP2_R1_trimmed_pe.fastq.gz
		|-- NG-14342_NG-17411_WWTP2_R2_trimmed_pe.fastq.gz
		|-- NG-14342_NG-17411_WWTP2_trimmed_se.fastq.gz
```
* *annotation directory * : directory where annotation product by PlasAnnot is stored. Directory must at least contains .ffn and .resistances file for each assembly. See PlasAnnot readme for description of this file (in outputs category). Files must have same prefix than prefix provided in input file. Example :  
```
|-- annotation directory 
	|-- NG-14342_NG-17411_BIOFILM.megahit.predicted_plasmids.ffn 
	|-- NG-14342_NG-17411_BIOFILM.megahit.predicted_plasmids.resistances 
	|-- NG-14342_NG-17411_WWTP2.megahit.predicted_plasmids.ffn 
	|-- NG-14342_NG-17411_WWTP2.megahit.predicted_plasmids.resistances 
```  
* *output directory* : Name of output directory. Will be created if not exists. 

### Outputs 

* Output directory root 

| File | Description | 
|---------|------------|
|all_predicted_resistances.ffn|All resistances genes in all assemblies| 
|all_predicted_resistances.clust.ffn|Resistances genes after clustering|
|all_predicted_resistances.tsv|All resistances genes description| 

* `abundance_matrix` subdirectory 

3 types of abundance matrix are provided :  
* raw matrix : raw counts of reads mapped to resistances genes for each assembly. 
* "relative" matrix (*relative* in files names) : 1st type of matrix normalization. Reads counts are rapported to total reads count mapped with resistances genes. Useful to compare assemblies in terms of resistances genes proportion. 
* "normalized" matrix (*normalized* in files names) : 2nd type of matrix normalization to overcome library size. Reads counts are rapported to library size (+ multiplied by a factor for clearer outputs). It conserves the information of quantity provided in raw matrix but take into account library size. 

| Suffix | Description | 
|---------|------------|
|.matrix|Raw matrix with only predicted resistances id| 
|.matrix.detailed|Same as .matrix with supplementary colums to describe each gene|
|.matrix.sum.catAb|Matrix with counts group by "Antibiotics category" defined by Resfams|
|.matrix.sum.drugClass|Matrix with counts group by "Drug Class" defined by CARDS with ARO of each gene| 
|.matrix.sum.ResfamsProfile|Matrix with counts group by Resfams profiles| 
|.format|Same matrixes in another format more convenient to create graphical representations| 

### Required tools/libraries/languages
Version indicated are tested versions. It can be work (or not) with others.  
It has been tested with Ubuntu 16.04.03 distribution. 
* [cd-hit](http://weizhongli-lab.org/cd-hit/) v4.6
* MAPMe 
* MAMa 
* [Python](https://www.python.org/download/releases/3.0/) v3.5.5



