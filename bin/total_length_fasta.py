import sys 
from Bio import SeqIO 	

def usage(): 
	print('usage : python3 total_length_fasta.py <fasta file>')
	print("Give cumulated sequences length") 
	

def generate_total_length(fasta):
	length=0
	for record in SeqIO.parse(fasta,"fasta"):  
		length+=len(record.seq) 
	return length		
				
if len(sys.argv) != 2: 
	usage() 
	exit() 	
			
print(generate_total_length(sys.argv[1]))	
