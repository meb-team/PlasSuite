from Bio import Entrez 
from Bio import SeqIO
import sys 

def usage(): 
	print("usage: python3 download_plasmids.py <RefSeq ID file> <output fasta file>")
	print("INPUT : file with id of seq to download") 
	print("OUTPUT : fasta file") 
	
if len(sys.argv)!=3: 
	usage() 
	exit()
	
f=open(sys.argv[1],"r") 

list_records=[]
Entrez.email="cecile.hilpert@gmail.com" 
out=open(sys.argv[2],"w") 
count=0 
for l in f : 
	count+=1 
	if count%50==0: 
		print(str(count)+" sequences processed...")
	accession=l.rstrip() 
	try : 
		handle_search=Entrez.esearch(db="nucleotide",term=accession)	
		record_search=Entrez.read(handle_search)
		records_fasta=[Entrez.efetch(id=i,db="nucleotide",rettype="fasta",retmode="text") for i in record_search["IdList"]]	
		records_seqio=[SeqIO.read(record,"fasta") for record in records_fasta] 
	except: 
		continue 	
	for rec in records_seqio : 
		if accession in rec.id : 
			SeqIO.write(rec,out,"fasta")
out.close()  	
	
