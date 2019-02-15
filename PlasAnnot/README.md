# PlasAnnot 

PlasAnnot takes an input assembly and annotate this assembly.   
To annotate, prokka is used, with Resfams profile in priority to identify resistances.   
Pipeline also draw circular contigs and linear contigs >= 10kb.    

*figure...* 

### How to launch 

```bash PlasAnnot.sh -f <assembly.fasta> -o <outdir>```

**Options**
* --prefix <prefix> : prefix for output files (default : assembly.fasta name) 
* --force : overwrite results 

**Databases options**    
If not specified, databases are searched in `hilpert/databis/plasmidome_databases`
* --resfams <hmm> : Resfams hmm profile 
* --markers_db <dir> : dir where plasmids markers databases are stored

### Outputs 

| Suffix | Description | 
|---------|------------|
|.faa|Predicted proteins in amino acids (fasta)| 
|.ffn|Predicted proteins in nucleotides (fasta)|
|.gff|Gff file for annotation, completed by Resfams and plasmids markers info. .gff.circular contains only circular contigs and .gff.linear contains only linear contig.| 
|.pdf|`.linear.10kb.pdf` is graphic representation of linear contigs >= 10kb and `.circular.pdf` is graphical representation of circular contigs. It's representation of gff annotation. For long contigs, annotation can be difficult to see graphically, you can search your contig of interest with `grep` in gff file to have details.|   
|.resistances|Tsv file with resistances genes and descriptions| 

### Required tools/libraries/languages
Version indicated are tested versions. It can be work (or not) with others.  
It has been tested with Ubuntu 16.04.03 distribution.  
* [Python](https://www.python.org/download/releases/3.0/) v3.5.5
* [Prokka](https://github.com/tseemann/prokka) v1.13.3
* [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) v2.7.1+
* [genoPlotR](http://genoplotr.r-forge.r-project.org/) v0.8.7
* [circlize](https://github.com/jokergoo/circlize) v0.4.4

