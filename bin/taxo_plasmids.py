import sys 
from ete3 import NCBITaxa 

def usage(): 
	print("usage : python3 taxo_plasmids.py <plasmids.fasta> <NCBI plasmids summary file> <outdir> <out prefix>")
	
def set_dic_summary(summary):
	f=open(summary,"r") 
	f.readline() 
	dic={}
	for l in f : 
		l_split=l.rstrip().split("\t") 
		organism=l_split[0]
		ref=l_split[5]
		if ref != "-" : 
			dic[ref]=organism 
	f.close() 				
	return dic 				
	
def treat_sequences(ids,out): 
	f=open(ids,"r") 
	o1=open(out+".notfound.id","w") 
	o2=open(out+".tsv","w") 
	o2.write("#reference\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\Species\n") 
	for l in f : 
		if l.startswith(">"): 
			ref=l.split(" ")[0].lstrip(">") 
			if ref in dic_summary : 
				taxo=retrieve_lineage_from_name(dic_summary[ref]) 
				if taxo=="": 
					o1.write(l) 
				else:	
					o2.write(ref+"\t"+taxo+"\n") 
			else :
				o1.write(l) 
	o1.close() 		
	o2.close() 	 	
	f.close() 	 		
	
def retrieve_lineage(ref): 
	taxid=dic_summary[ref] 
	lineage=ncbi.get_lineage(taxid)  	
	ranks=ncbi.get_rank(lineage) 
	taxo=treat_ranks(ranks) 
	return taxo 

def retrieve_lineage_from_name(name): 
	try : 
		taxid=ncbi.get_name_translator([name])[name][0]
		lineage=ncbi.get_lineage(taxid)  	
		ranks=ncbi.get_rank(lineage) 
		taxo=treat_ranks(ranks)
	except : 
		taxo=""
	
	return taxo 
	
def treat_ranks(ranks): 
	kingdom="-"
	phylum="-"
	species="-" 
	classe="-"
	order="-"
	family="-"
	genus="-"
	for r in ranks : 
		if ranks[r]=="superkingdom": 
			kingdom=ncbi.get_taxid_translator([r])[r] 
		elif ranks[r]=="phylum": 
			phylum=ncbi.get_taxid_translator([r])[r]	
		elif ranks[r]=="species": 
			species=ncbi.get_taxid_translator([r])[r]	
			species=species.replace("'","").replace("#","") 
		elif ranks[r]=="class": 
			classe=ncbi.get_taxid_translator([r])[r]
		elif ranks[r]=="order": 
			order=ncbi.get_taxid_translator([r])[r]
		elif ranks[r]=="family": 
			family=ncbi.get_taxid_translator([r])[r]
		elif ranks[r]=="genus":
			genus=ncbi.get_taxid_translator([r])[r]	
	taxo=kingdom+"\t"+phylum+"\t"+classe+"\t"+order+"\t"+family+"\t"+genus+"\t"+species		
	return taxo		
	
if len(sys.argv) != 5: 
	usage() 
	exit() 
	

out=sys.argv[3]+"/"+sys.argv[4] 	
dic_summary=set_dic_summary(sys.argv[2]) 
ncbi = NCBITaxa()
treat_sequences(sys.argv[1],out) 	
		 
