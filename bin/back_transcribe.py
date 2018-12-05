from Bio import SeqIO 
import sys 

def usage(): 
	print("usage : python3 back_transcribe.py <input fasta file> <output fasta file>") 
	print("---")
	print("Back transcribe input fasta (Change U to T) and write new file in output fasta file")
	
if len(sys.argv)!=3: 
	usage()
	exit() 

out=open(sys.argv[2],"w") 	
for record in SeqIO.parse(sys.argv[1],"fasta"):
	record.seq=record.seq.back_transcribe() 
	SeqIO.write(record,out,"fasta") 
		
out.close() 
