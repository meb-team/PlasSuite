# Useful scripts 

* **seq_from_list.py** 

Only keep sequences given by user, with option to search in SILVA database 
```
usage: python3 seq_from_list.py`
Options : 
-h, --help  show this help message and exit
--input_fasta <input.fasta> Input fasta file where seq to keep are present
--keep <id file> File with only id of seq to keep
--output_fasta <output.fasta> Output fasta file with seq to keep
--silva <True/False> search in silva fasta database (True or False, default: false)
```
                        
* **write_separate_fasta.py**

Write each sequence from input fasta separately in output directoy 
```
usage : python3 write_separate_fasta.py <input fasta> <output directory>
```
                        
