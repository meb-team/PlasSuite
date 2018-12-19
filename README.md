# plasmidome_scripts
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

## 1. Prepare your databases 

To be found by defaults, databases must be stored in `$HOME/plasmidome_databases` so create this directory.  

### 1.1. Plasmids database  
* **Sequences**   
	`$HOME/plasmidome_databases/all_plasmids.fasta` is default name.  
	Plasmids sequences must be a fasta file contained complete plasmids.    
	You can obtained last version of NCBI plasmids database with  
	```plasmidome_scripts/bin/update_plasmids_database.sh -o $HOME/plasmidome_databases/all_plasmids.fasta --info $HOME/plasmidome_databases/all_plasmids.ncbi.info```  
	If you already have plasmids fasta file and you just want to add new sequences, use `--db <your_file>` option. If you want to clean deprecated sequences (present in your file but not in ncbi database) use `--clean` option.      
* **Taxonomy**   
Taxonomy plasmids file must be a tsv file, `$HOME/plasmidome_databases/all_plasmids.taxo.tsv` is default location.  
If you used `update_plasmids_database.sh`, you can use `taxo_plasmids.py` to obtain this file. 
```
python3 plasmidome_scripts/bin/taxo_plasmids.py $HOME/plasmidome_databases/all_plasmids.fasta $HOME/plasmidome_databases/all_plasmids.ncbi.info $HOME/plasmidome_databases all_plasmids.taxo
```
Example of *all_plasmids.fasta* file 
```
>NZ_CP011122.1 Acetobacter sp. SLV-7 plasmid unnamed2, complete sequence
TTCGGTTTTTCGTCGGTAATGCCAGACGCACGCGGGATGGCTTTATGGCCACGCAAGCTC
...
>NZ_CP017473.1 Enterobacter cloacae strain M12X01451 plasmid pM12X01451, complete sequence
ATGAGGCATACTATGAAAAGTATTAATATCAACGAGTTTAATGCAAATGATTTTTCTGTT
...
```
Example of *all_plasmids.ncbi.info* file 
```
#Organism/Name	Kingdom	Group	SubGroup	Plasmid Name	RefSeq	INSDC	Size (Kb)	GC%	Protein	rRNA	tRNA	Other RNA	Gene	Pseudogene
Acetobacter oryzifermentans	Bacteria	Proteobacteria	Alphaproteobacteria	unnamed2	NZ_CP011122.1	CP011122	116.245	51.5308	99	-	-	-	123	24
Enterobacter cloacae	Bacteria	Proteobacteria	Gammaproteobacteria	pM12X01451	NZ_CP017473.1	CP017473	169.226	49.8481	133	-	-	-	185	52
```
Organism/Name and RefSeq columns are used for taxonomy construction, so you can provide any file with organism name in 1st column and sequence id in 6th column. 

Example of *all_plasmids.taxo.tsv* file 
```
#reference	Kingdom	Phylum	Class	Order	Family	Genus	Species
NZ_CP011122.1	Bacteria	Proteobacteria	Alphaproteobacteria	Rhodospirillales	Acetobacteraceae	Acetobacter	Acetobacter oryzifermentans
NZ_CP017473.1	Bacteria	Proteobacteria	Gammaproteobacteria	Enterobacterales	Enterobacteriaceae	Enterobacter	Enterobacter cloacae
```


### 1.2. Chromosomes database 
* **Sequences**  
`$HOME/plasmidome_databases/all_plasmids.fasta` is default name.  
Chromosomes sequences must be a fasta file contained complete chromosomes.    
You can obtained last version of NCBI prokaryotes database with  
```
bash plasmidome_scripts/bin/update_prokaryotes_database.sh -o $HOME/plasmidome_databases/all_prokaryotes.fasta --info $HOME/plasmidome_databases/all_prokaryotes.ncbi.info
```  
If you already have prokaryotes fasta file and you just want to add new sequences, use `--db <your_file>` option. If you want to clean deprecated sequences (present in your file but not in ncbi database) use `--clean` option.  
    
* **Taxonomy**  
Taxonomy chromosomes file must be a tsv file, `$HOME/plasmidome_databases/all_prokaryotes.taxo.tsv` is default location.  
If you used `update_prokaryotes_database.sh`, you can use `taxo_prokaryotes.py` to obtain this file. 
```
python3 plasmidome_scripts/bin/taxo_prokaryotes.py $HOME/plasmidome_databases/all_prokaryotes.fasta $HOME/plasmidome_databases/all_prokaryotes.ncbi.info $HOME/plasmidome_databases all_prokaryotes.taxo
```
Example of *all_prokaryotes.fasta* file 
```
>CP024307.1 Sinorhizobium fredii strain NXT3 chromosome, complete genome
CAGCCAGACGGGCGGAGGCGTAAGGCATTTCCCGTTCAACACCTCAAGAACTTTGCGACG
...
>CP025055.1 Pseudomonas aeruginosa strain PB350 chromosome, complete genome
TTTAAAGAGACCGGCGATTCTAGTGAAATCGAACGGGCAGGTCAATTTCCAACCAGCGAT
...
```
Example of *all_prokaryotes.ncbi.info* file 
```
#Organism/Name	TaxID	BioProject Accession	BioProject ID	Group	SubGroup	Size (Mb)	GC%	Replicons	WGS	Scaffolds	Genes	Proteins	Release Date	Modify Date	Status	Center	BioSample Accession	Assembly Accession	Reference	FTP Path	Pubmed ID	Strain
Sinorhizobium fredii	380	PRJNA415486	415486	Proteobacteria	Alphaproteobacteria	6.5577	62.3103	chromosome:NZ_CP024307.1/CP024307.1; plasmid pSfreNXT3a:NZ_CP024308.1/CP024308.1; plasmid pSfreNXT3b:NZ_CP024309.1/CP024309.1; plasmid pSfreNXT3c:NZ_CP024310.1/CP024310.1	-	4	6310	5866	2018/02/02	2018/03/02	Complete Genome	Centro de Ciencias Genomicas UNAM	SAMN07824032GCA_002944405.1	-	ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/944/405/GCA_002944405.1_ASM294440v1	-	NXT3
Pseudomonas aeruginosa	287	PRJNA419916	419916	Proteobacteria	Gammaproteobacteria	6.75287	66.2	chromosome:NZ_CP025055.1/CP025055.1	-	1	6419	6238	2017/12/06	2017/12/08	Complete Genome	New York Medical College	SAMN08101543	GCA_002812905.1	-	ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/812/905/GCA_002812905.1_ASM281290v1	-	PB350
```
TaxID and Replicons columns are used for taxonomy construction, so you can provide any file with TaxID in 2nd column and chromosome id like `chromosome:id` in 9th column. 

Example of *all_prokaryotes.taxo.tsv* file 
```
#reference	description	Kingdom	Phylum	Class	Order	Family	Genus	Species
CP024307.1	Sinorhizobium fredii strain NXT3 chromosome	Bacteria	Proteobacteria	Alphaproteobacteria	Rhizobiales	Rhizobiaceae	Sinorhizobium	Sinorhizobium fredii
CP025055.1	Pseudomonas aeruginosa strain PB350 chromosome	Bacteria	Proteobacteria	Gammaproteobacteria	Pseudomonadales	Pseudomonadaceae	Pseudomonas	Pseudomonas aeruginosa
```
	
### 1.3. Plasmids markers database   
Plasmids markers database must be stored in `$HOME/plasmidome_databases/plasmids_markers` directory. 4 files must be in this directory :
* `mob.proteins.faa` : fasta file with mob proteins in amino acids.  
* `mpf.proteins.faa` : fasta file with mpf proteins in amino acids.  
* `rep.dna.fas` : fasta file with rep DNA in nucleotides.  
* `orit.fas` : fasta file with orit DNA in nucleotides.   
This files has been download from [mob_suite](https://github.com/phac-nml/mob-suite) tool, via figshare link : [https://ndownloader.figshare.com/articles/5841882?private_link=a4c92dd84f17b2cefea6](https://ndownloader.figshare.com/articles/5841882?private_link=a4c92dd84f17b2cefea6) 		
		
### 1.4. rRNA database
* **Sequences**  
rRNA sequences must be a fasta file contained rRNA, and stored in `$HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta` to be found by default. 
You can use [SILVA](https://www.arb-silva.de) database. 
Sequences must be back transcribed (U -> T). You can use `bash plasmidome_scripts/bin/back_transcribe.py <input fasta> <output fasta>` to do that. 

* **Taxonomy**  
Taxonomy rRNA file must be a tsv file, `$HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.taxo.tsv` is default location.  
If you have tax_fila file from SILVA for your rRNA database, you can use `taxo_silva.py` to construct taxonomy file.  
```
python3 plasmidome_scripts/bin/taxo_silva.py $HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta $HOME/plasmidome_databases SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.taxo
```
Example of *SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta*   
```
>GY193009.2153721.2155249 Bacteria;Firmicutes;Bacilli;Lactobacillales;Streptococcaceae;Streptococcus;unidentified
AGAGTTTGATCCTGGCTCAGGACGAACGCTGGCGGCGTGCCTAATACATGCAAGTAGAAC
....
>AM182288.1.505 Bacteria;Proteobacteria;Alphaproteobacteria;Rhodobacterales;Rhodobacteraceae;Loktanella;uncultured alpha proteobacterium
GCCTGATCTAGCCATGCCGCGTGAGTGACGAAGGCCTTAGGGTCGTAAAGCTCTTTCGCC
...
```
Example of *SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.taxo.tsv* 
```
#reference	description	Kingdom	Phylum	Class	Order	Family	Genus	Species
GY193009.2153721.2155249	Bacteria	Firmicutes	Bacilli	Lactobacillales	Streptococcaceae	Streptococcus	-
AM182288.1.505	Bacteria	Proteobacteria	Alphaproteobacteria	Rhodobacterales	Rhodobacteraceae	Loktanella	-
```

### 1.5. Phylogenetic markers database

Phylogenetic markers must be stored in `$HOME/plasmidome_databases/phylogenetic_markers/wu2013/bacteria_and_archaea_dir/BA.hmm`
Phylogenetic markers can be download from [Wu 2013](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3798382/) publication, in figshare associated : https://figshare.com/articles/Systematically_identify_phylogenetic_markers_at_different_taxonomic_levels_for_bacteria_and_archaea/722713  
`BA.hmm` is the concatenation of all `BA*.hmm` files in `bacteria_and_archaea_dir.tar.gz`. 
If you want to use other database, it must be hmm profiles. 

## 2. Launch workflow 

You starts with a plasmidome assembly obtained from cleaned reads. Let's imagine this assembly is called myAssembly.fasta and your are localised in directory where you clone this repository. 

Cleaned reads can be obtained with [PlasPreAssembl](PlasPreAssembl). In this work, assemblies are done with default Megahit but you can use any assembly as long as it produces fasta file. Example for running Megahit : 
```
megahit -1 <R1_cleaned_reads.fastq> -2 <R2_cleaned_reads.fastq> -r <single_end_reads.fastq> -t 6
```

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
bash plasmidome_scripts/PlasAbund/PlasAbund.sh -i prefix.txt -o resultsPlasAbund --reads_dir cleaned_reads
```

### Authors 
* Cécile Hilpert - [cecilpert](https://github.com/cecilpert)
