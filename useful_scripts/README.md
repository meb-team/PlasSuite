# Useful scripts 

* **seq_from_list.py** 

Only keep sequences given by user, with option to search in SILVA database 
```usage: python3 seq_from_list.py [-h] [--input_fasta INPUT_FASTA] [--keep KEEP] [--output_fasta OUTPUT_FASTA] [--silva SILVA]

optional arguments:
  -h, --help            show this help message and exit
  --input_fasta INPUT_FASTA
                        Input fasta file where seq to keep are present
  --keep KEEP           File with only id of seq to keep
  --output_fasta OUTPUT_FASTA
                        Output fasta file with seq to keep
  --silva SILVA         search in silva fasta database (True or False, default
                        : false)```
                        
* **write_separate_fasta.py**
Write each sequence from input fasta separately in output directoy 
```usage : python3 write_separate_fasta.py <input fasta> <output directory>```
                        
