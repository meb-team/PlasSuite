# PlasTaxo 
 
PlasTaxo uses PlasPredict outputs to determine assembly taxonomy.  

### How to launch ? 

```bash PlasTaxo.sh  bash PlasTaxo.sh --predicted_plasmids_dir <input directory> --predicted_plasmids_prefix <input prefix> -o <output directory> --prefix <output prefix>```

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
See [general readme](https://github.com/meb-team/plasmidome_scripts/)(1.Prepare your databases section) to create this files. 	

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

### Outputs 

| Suffix | Description | 
|---------|------------|
|.taxo|All taxonomies assigned to all contigs| 
|.taxo.predicted_plasmids|All taxonomies assigned to predicted plasmids|
|.taxo.differentTaxo|Contigs with non consistent taxonomy between PlasFlow and others| 
|.taxo.differentTaxo.count|Count PlasFlow phylum of contigs with non consistent taxonomy between PlasFlow and others| 
|.sameTaxo|Contigs with consistent taxonomy between PlasFlow and others| 
|.sameTaxo.count|Count PlasFlow phylum of contigs with consistent taxonomy between PlasFlow and others|
|.taxo.plasflowPrediction.stats|Statistics about PlasFlow taxonomy prediction| 

### Required tools/libraries/languages
Version indicated are tested versions. It can be work (or not) with others.  
It has been tested with Ubuntu 16.04.03 distribution.  
* [Python](https://www.python.org/download/releases/3.0/) v3.5.5
* [ete3](http://etetoolkit.org/) v3.0.0b35


 		
		
		


