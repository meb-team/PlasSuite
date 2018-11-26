import sys 
from Bio import SeqIO 

def usage(): 
	print("usage : python3 circular_headers.py <input fasta> <output fasta>")
	
if len(sys.argv) != 3 : 
	usage() 
	exit() 	

o=open(sys.argv[2],"w") 
for record in SeqIO.parse(sys.argv[1],"fasta"): 
	record.id=record.id+"_circ" 
	SeqIO.write(record,o,"fasta") 
o.close() 
