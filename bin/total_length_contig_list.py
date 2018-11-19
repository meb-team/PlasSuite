import sys 
from Bio import SeqIO 
from common_functions import give_list_id	

def usage(): 
	print('usage : python3 total_length_fasta.py <fasta file> <list of seq to count>')
	print("Give cumulated sequences length") 
	

def generate_total_length(fasta,list_id):
	length=0
	for record in SeqIO.parse(fasta,"fasta"):  
		if record.id in list_id:
			length+=len(record.seq) 
	return length		
				
if len(sys.argv) != 3: 
	usage() 
	exit() 	
	
list_id=give_list_id(sys.argv[2])		
print(generate_total_length(sys.argv[1],list_id))	
	
