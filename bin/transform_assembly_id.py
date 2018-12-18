import sys  
from Bio import SeqIO 

def usage(): 
	print("usage : python3 transform_megahit_id.py <input fasta> <output fasta>")
	
if len(sys.argv)!=3: 
	usage() 
	exit() 	  

out=open(sys.argv[2],"w") 	
for rec in SeqIO.parse(sys.argv[1],"fasta"): 
	rec.description=rec.id
	SeqIO.write(rec,out,"fasta")  
	
out.close() 
