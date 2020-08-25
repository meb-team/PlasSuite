# PlasAbund

PlasResist creates abundance matrix for predicted genes clusters, and abundance matrix for resistances genes. 

### How to launch ?

```
bash PlasAbund.sh -i <input file> -o <output directory> --reads_dir <reads directory> --annot_dir <annotation directory>"  
```

**Mandatory arguments** 
* *input file* : input file is .txt file with list of your assemblies prefix. Example :  
```
Plasmidome1
Plasmidome2
```
* *reads directory* : reads directory is directory where your cleaned reads are stored. In this directory, you must have one directory per sample, with paired end R1 and R2 fastq and single end fastq. R1 fastq name must contain "R1", R2 fastq name must contains "R2" and single end fastq name must contains "se". Fastq files are zipped (.fastq.gz). Example :  
```
|-- reads directory 
	|-- Plasmidome1
		|-- Plasmidome1_R1_trimmed_pe.fastq.gz
		|-- Plasmidome1_R2_trimmed_pe.fastq.gz
		|-- Plasmidome1_trimmed_se.fastq.gz
	|-- Plasmidome2
		|-- Plasmidome2_R1_trimmed_pe.fastq.gz
		|-- Plasmidome2_R2_trimmed_pe.fastq.gz
		|-- Plasmidome2_trimmed_se.fastq.gz
```
All the reads included in this directory will be mapped against the genes. Check before launching the data integrity: the reads directory must correspond to the plasmidomes described in the  input file.

* *annotation directory* : directory where annotation product by PlasAnnot is stored. Directory must at least contains .ffn and .resistances file for each assembly. See PlasAnnot readme for description of this file (in outputs category). Files must have same prefix than prefix provided in input file. Example :  
```
|-- annotation directory 
	|-- Plasmidome1.predicted_plasmids.ffn 
	|-- Plasmidome1.predicted_plasmids.resistances 
	|-- Plasmidome2.predicted_plasmids.ffn 
	|-- Plasmidome2.predicted_plasmids.resistances 
```  
* *output directory* : Name of output directory. Will be created if not exists. 

### Outputs 

* Output directory root 

| File | Description | 
|---------|------------|
|all_prot.ffn|All predicted genes in all assemblies| 
|all_prot.95.ffn|Predicted genes after 95% clustering|
|all_resistances.tsv|All resistances genes description| 

* `abundance_matrix` subdirectory 

* **Full abundance matrix**  
* raw matrix : `abundance.matrix` raw counts of reads mapped to resistances genes for each assembly. 
* "relative" matrix (*relative* in files names) : `abundance.relative.matrix` 1st type of matrix normalization. Reads counts are rapported to total reads count mapped with resistances genes. Useful to compare assemblies in terms of resistances genes proportion. 
* "normalized" matrix (*normalized* in files names) : `abundance.normalized.matrix` 2nd type of matrix normalization to overcome library size. Reads counts are rapported to library size (+ multiplied by a factor for clearer outputs). It conserves the information of quantity provided in raw matrix but take into account library size. 

* **Resistances matrix** 

| File | Description | 
|---------|------------|
|resistances_abundance.matrix|Raw matrix with only predicted resistances id| 
|resistances_abundance.matrix.detailed|Same as .matrix with supplementary colums to describe each gene|
|resistances_abundance.matrix.sum.catAb|Matrix with counts group by "Antibiotics category" defined by Resfams|
|resistances_abundance.matrix.sum.drugClass|Matrix with counts group by "Drug Class" defined by CARDS with ARO of each gene| 
|resistances_abundance.matrix.sum.ResfamsProfile|Matrix with counts group by Resfams profiles| 
|resistances_abundance.matrix.sum.ResfamsProfile.morePresent|Matrix with counts for 5 most present Resfams profile in each assembly. Other profiles are classified in Others.|
|Files with .format suffix|Same matrixes in another format more convenient to create graphical representations| 

### Required tools/libraries/languages
Version indicated are tested versions. It can be work (or not) with others.  
It has been tested with Ubuntu 16.04.03 distribution. 
* [cd-hit](http://weizhongli-lab.org/cd-hit/) v4.6
* MAPMe, provided in bin/, written by [Corentin Hochart](https://github.com/chochart)
* [BAM-Tk](https://github.com/meb-team/BAM-Tk.git)(formerly MAMa) v0.1.1 
* [Python](https://www.python.org/download/releases/3.0/) v3.5.5



