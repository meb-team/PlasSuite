from Bio import SeqIO 
import sys 

def usage(): 
	print("usage: python3 sequences_length.py <input fasta file> <output tsv file>")
	print("Write tsv file with length of each sequence in fasta file") 
	
if len(sys.argv)!=3: 
	usage() 
	exit()
	
out=open(sys.argv[2],"w") 	
out.write("id\tlength\tlength_cat\n") 	
for record in SeqIO.parse(sys.argv[1],"fasta"): 
	length=len(record.seq) 
	if length<10000:
		length_cat="<10kb" 
	elif length<=50000:
		length_cat="10-50kb" 
	elif length<=100000: 
		length_cat="50-100kb"
	elif length<=500000: 
		length_cat="100-500kb" 	
	elif length <= 1000000 : 
		length_cat="500kb-1Mb"			 
	else: 
		length_cat=">1Mb"	
	
	out.write(record.id+"\t"+str(length)+"\t"+length_cat+"\n")		
