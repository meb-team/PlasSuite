from Bio import SeqIO 
import sys 
import os 

def usage(): 
	print("python3 write_separate_fasta.py <input fasta> <outdir>") 
	
if len(sys.argv)!=3: 
	usage() 
	exit() 
	
outdir=sys.argv[2]	
os.system("mkdir -p "+outdir) 
for record in SeqIO.parse(sys.argv[1],"fasta"): 
	with open(outdir+"/"+record.id+".fasta","w") as output_handle : 
		SeqIO.write(record,output_handle,"fasta")  	
