# PlasTaxo 
 
PlasTaxo uses PlasPredict outputs to determine assembly taxonomy.  

### How to launch ? 

`bash PlasTaxo.sh  bash PlasTaxo.sh --predicted_plasmids_dir <input directory> --predicted_plasmids_prefix <input prefix> -o <output directory> --prefix <output prefix>`

**Databases** :  
Databases are by default searched in `$HOME/plasmidome_databases`. For PlasTaxo, this directory must contains the 3 databases taxonomy files, 1 for plasmids database, 1 for chromosomes database and 1 for rRNA database. Files has to be stored like :  
```
|-- $HOME/plasmidome_databases
	|-- all_plasmids.taxo.tsv <-
	|-- all_prokaryotes.taxo.tsv <- 
	|-- rRNA
		|-- SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.taxo.tsv <-  
```
You can also directly specified databases files by optionnal arguments `--plasmids_taxo`, `--chrm_taxo` and `--rna_taxo`.   
See [general readme](..) for create this files. 	

**Mandatory arguments** :  
Input directory is output directory from PlasPredict and input prefix is output prefix from PlasPredict. If PlasPredict wasn't used, you must have 4 files in input directory, stored like this :    
```
|-- output_directory  
	|-- chrm_search  
		|-- input_prefix*.0.8.paf <-  
	|-- plasmids_search  
		|-- input_prefix*.0.8.paf <-
	|-- rna_search   
		|-- input_prefix.rna.blast.all.contigs.tsv <- 
	|-- learning  
		|-- input_prefix*.plasflow0.7.taxo <-  
```


 		
		
		


