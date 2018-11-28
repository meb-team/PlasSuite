import sys 

def usage(): 
	print("usage: python3 extract_id_prokaryotes.py <INPUT> <OUTPUT>")
	print("Extract chromosomes ID from taxonomy prokaryotes file")
	print("INPUT : Any .tsv file with sequences refs in first column") 
	print("OUTPUT : fasta file with only seq to keep")  
	
if (len(sys.argv)!=3): 
	usage()
	exit() 	 
	
f=open(sys.argv[1],"r") 
out=open(sys.argv[2],"w") 

for l in f : 
	l_split=l.rstrip().split("\t")
	id=l_split[0].split(";") 
	for i in id : 
		if i.split(":")[0].startswith("chromosome"): 
			if "/" in i.split(":")[1]: 
				chrm=i.split(":")[1].split("/")[1]
				out.write(chrm+"\n") 
			else: 
				chrm=i.split(":")[1]
				out.write(chrm+"\n") 	   
f.close() 
out.close() 
