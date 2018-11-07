# plasmidome_scripts
Scripts for plasmidome analysis 

## Useful_scripts 
This directory contains several small scripts that can be use independantly

* seq_from_list.py 
Only keep sequences given by user, with option to search in SILVA database 
```usage: seq_from_list.py [-h] [--input_fasta INPUT_FASTA] [--keep KEEP]
                        [--output_fasta OUTPUT_FASTA] [--silva SILVA]

optional arguments:
  -h, --help            show this help message and exit
  --input_fasta INPUT_FASTA
                        Input fasta file where seq to keep are present
  --keep KEEP           File with only id of seq to keep
  --output_fasta OUTPUT_FASTA
                        Output fasta file with seq to keep
  --silva SILVA         search in silva fasta database (True or False, default
                        : false)```
                        
