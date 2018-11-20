import sys 
from Bio import SeqIO 

def usage():  
	print("usage: python3 delete_seq_from_file.py <input fasta file> <file with seq to delete(txt)> <output fasta file> <type id>")
	
def search_normal(list_del,out):
	out=open(out,"w") 	
	for record in SeqIO.parse(sys.argv[1],"fasta"): 
		if record.id not in list_del : 
			SeqIO.write(record,out,"fasta") 
	out.close() 		


def search_simple(list_del,out):  	
	out=open(out,"w") 	
	for record in SeqIO.parse(sys.argv[1],"fasta"): 
		rec=record.id.split(".")[0]
		if rec not in list_del : 
			SeqIO.write(record,out,"fasta") 
	out.close() 	

if len(sys.argv) != 5: 
	usage()
	exit()

f=open(sys.argv[2],"r") 
		
dic={}
list2=[]
list_del=set() 
count=0
for l in f:  
	list_del.add(l.rstrip()) 
f.close() 	

if sys.argv[4]=="normal": 
	search_normal(list_del,sys.argv[3]) 
	
elif sys.argv[4]=="simple": 
	search_simple(list_del,sys.argv[3]) 
	
else : 
	print("<type id> is not valid (normal or simple)")  		


	
