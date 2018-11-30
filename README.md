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
* Plasmids database
* Plasmids markers database 
* Chromosomes database 
* rRNA database 
* Phylogenetic markers database 

## 2. Launch workflow 

You starts with a plasmidome assembly obtained from cleaned reads. Let's imagine this assembly is called myAssembly.fasta and your are localised in directory where you clone this repository. 

### 2.1. PlasPredict 
Launch PlasPredict to isolate predicted plasmids from your assembly.  
```bash plasmidome_script/PlasPredict/PlasPredict.sh -a myAssembly.fasta -o resultsPlasPredict``` 
