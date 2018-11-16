# Useful scripts 

* **common_functions.sh** 

Contains bash functions used in several scripts. Use `source common_functions.sh` in bash script to use functions. 
Contains : 
	- verif_file <file_path> <message to display if not found> <message to display if found> : Check existence of file. If exists, display message and continue. If not, display message and exit script. 
	- verif_dir <directory_path> <message to display if not found> <message to display if found> : Same as verif_file but for directories. 
	- verif_blast_db <db_path> <type_db> <message to display if not found> <message to display if found> : Check existence of blast database for fasta file. If not exists, create it. <type_db> if "nucl" or "prot" 
	- verif_result <file> : Check if a result exists and return $file_exist variable, =1 if exists, 0 if not. Take into account $FORCE variable. If $FORCE==1, 0 is always returned  
	
	 

* **seq_from_list.py** 

Only keep sequences given by user, with option to search in SILVA database 
```
usage: python3 seq_from_list.py
Options : 
-h, --help  show this help message and exit
--input_fasta <input.fasta> Input fasta file where seq to keep are present
--keep <id file> File with only id of seq to keep
--output_fasta <output.fasta> Output fasta file with seq to keep
--silva <True/False> search in silva fasta database (True or False, default: false)
```

* **sequences_length.py** 

Take fasta as input and generate a tsv summary file about sequences with their length and length category
*INPUT* : fasta file 
*OUTPUT* : tsv file with column `sequences_id	length(pb)	length_category`

```
usage : python3 sequences_length.py <input.fasta> <output.tsv>
```	
                        
* **write_separate_fasta.py**

Write each sequence from input fasta separately in output directoy 
```
usage : python3 write_separate_fasta.py <input fasta> <output directory>
```
                        
