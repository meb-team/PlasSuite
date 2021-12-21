### 1. Plasmids database  
* **Sequences**   
	`$HOME/plasmidome_databases/all_plasmids.fasta` is default name.  
	Plasmids sequences must be a fasta file contained complete plasmids.    
	You can obtained last version of NCBI plasmids database (sequences and taxonomies) with  the following command:
	```
	plasmidome_scripts/bin/update_plasmids_database.sh -o $HOME/plasmidome_databases/all_plasmids.fasta --info $HOME/plasmidome_databases/all_plasmids.ncbi.info
	```  
	If you already have plasmids fasta file and you just want to add new sequences, use `--db <your_file>` option. If you want to clean deprecated sequences (present in your file but not in ncbi database) use `--clean` option.      
* **Taxonomy**   
Taxonomy plasmids file must be a tsv file, `<path to plasmidome database>/all_plasmids.taxo.tsv` is default location.  

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


### 2. Chromosomes database 
* **Sequences**  
`$HOME/plasmidome_databases/all_prokaryotes.fasta` is default name.  
Chromosomes sequences must be a fasta file contained complete chromosomes.    
You can obtained last version of NCBI prokaryotes database (sequences and taxonomies) with  the following command: 
```
bash plasmidome_scripts/bin/update_prokaryotes_database.sh -o $HOME/plasmidome_databases/all_prokaryotes.fasta --info $HOME/plasmidome_databases/all_prokaryotes.ncbi.info
```  
If you already have prokaryotes fasta file and you just want to add new sequences, use `--db <your_file>` option. If you want to clean deprecated sequences (present in your file but not in ncbi database) use `--clean` option.  
 * **Taxonomy**   
Taxonomy plasmids file must be a tsv file, `<path to plasmidome database>/all_prokaryotes.taxo.tsv` is default location.    

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
	
### 3. Plasmids markers database   
Plasmids markers database must be stored in `$HOME/plasmidome_databases/plasmids_markers` directory. 4 files must be in this directory :
* `mob.proteins.faa` : fasta file with mob proteins in amino acids.  
* `mpf.proteins.faa` : fasta file with mpf proteins in amino acids.  
* `rep.dna.fas` : fasta file with rep DNA in nucleotides.  
* `orit.fas` : fasta file with orit DNA in nucleotides.   
This files has been download from [mob_suite](https://github.com/phac-nml/mob-suite) tool, via figshare link : [https://ndownloader.figshare.com/articles/5841882?private_link=a4c92dd84f17b2cefea6](https://ndownloader.figshare.com/articles/5841882?private_link=a4c92dd84f17b2cefea6) 		
		
### 4. rRNA database
* **Sequences**  
rRNA sequences must be a fasta file contained rRNA, and stored in `$HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta` to be found by default. 
You can use [SILVA](https://www.arb-silva.de) database. 
Sequences must be back transcribed (U -> T). You can use `bash plasmidome_scripts/bin/back_transcribe.py <input fasta> <output fasta>` to do that. 
