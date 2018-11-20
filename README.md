# plasmidome_scripts
Scripts for plasmidome analysis 

## [PlasPredict](PlasPredict) 
Predict plasmids contigs from assembly 

## [PlasAnnot](PlasAnnot)
Annotate plasmids contigs from assembly (preferentially with only predicted plasmids) 

## [PlasTaxo](PlasTaxo) 
Retrieve and compare taxonomy from assembly using PlasFlow taxonomy and plasmids alignment 

## [PlasResist](PlasResist) 
Analyze Resfams resistance from assembly annotation. Produce abundance matrix.  

In order to run properly all pipelines, you must have tools cited in each Required tools/libraries/languages in your $PATH.  
Otherwise, you can create a [conda](https://conda.io/docs/) environment with all tools with 
```
conda create -y -n plasmidome plasflow prokka minimap2
```
And then go in this environment `source activate plasmidome` to run pipelines.    

You still have to install R packages on your own for PlasAnnot : [circlize](https://github.com/jokergoo/circlize) and [genoPlotR](http://genoplotr.r-forge.r-project.org/)

                     
