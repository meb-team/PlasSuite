# PlasPreAssembl

PlasPreAssembl launch fastqc on raw reads, cleans it with Trimmomatic and runs NonPareil for coverage estimation. 

### How to launch ? 

```bash PlasPreAssembl.sh -r <reads directory> -o <output directory> -p <output prefix>```

`reads directory` is directory where all raw compressed reads are stored for one sequencing.  
Example :
```
|-- NG-18198_FeGe10
	|-- NG-18198_FeGe10_Ill_lib302876_6227_1_1.fastq.gz
	|-- NG-18198_FeGe10_Ill_lib302876_6227_1_2.fastq.gz
	|-- NG-18198_FeGe10_Ill_lib302876_6231_2_1.fastq.gz
	|-- NG-18198_FeGe10_Ill_lib302876_6231_2_2.fastq.gz
```

### Outputs 
3 directories are created in output directory : `cleaned_reads`, `fastqc` and `nonpareil` 

`cleaned_reads` contains one directory per sequencing, with one file for trimmed R1 paired-end reads, one for trimmed R2 paired-end reads and one for trimmed single end reads.  

`fastqc` contains fastqc report (.html and .zip) for each raw reads file. 

`nonpareil` contains mainly a `.pdf` graph with rarefaction curve. 

**Example of output directory**     
```
|-- output directory 
	|-- cleaned_reads
		|-- NG-18198_FeGe10
			|-- NG-18198_FeGe10_R1_trimmed_pe.fastq.gz
			|-- NG-18198_FeGe10_R2_trimmed_pe.fastq.gz
			|-- NG-18198_FeGe10_trimmed_se.fastq.gz
	|-- fastqc 
		|-- NG-18198_FeGe10_Ill_lib302876_6227_1_1_fastqc.html
		|-- NG-18198_FeGe10_Ill_lib302876_6227_1_1_fastqc.zip
		|-- NG-18198_FeGe10_Ill_lib302876_6227_1_2_fastqc.html
		|-- NG-18198_FeGe10_Ill_lib302876_6227_1_2_fastqc.zip
		|-- NG-18198_FeGe10_Ill_lib302876_6231_2_1.fastqc.html
		|-- NG-18198_FeGe10_Ill_lib302876_6231_2_1.fastqc.zip
		|-- ... 
	|-- nonpareil 	
		|-- NG-18198_FeGe10.nonPareil.pdf
		|-- ... 
```    
