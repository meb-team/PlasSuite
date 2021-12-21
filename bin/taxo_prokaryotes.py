import sys 
from ete3 import NCBITaxa 

def usage(): 
	print("usage : python3 taxo_prokaryotes.py <path to plasmid database> ")
	# ~ print("INPUT : tsv file with sequence ref in first column and sequence name in 2nd column")   
	
def set_dic_summary(summary):
	f=open(summary,"r") 
	dic={}
	for l in f : 
		l_split=l.rstrip().split("\t") 
		taxid=l_split[1]
		ref=l_split[8]
		if ref != "-": 
			ref=[r.split(":")[-1] for r in ref.split(";")]  
			for r in ref : 
				if "/" in r :
					r=r.split("/") 
					for r2 in r : 
						dic[r2]=taxid 
				else: 
					dic[r]=taxid
	f.close() 				
	return dic 				
	
def treat_sequences(ids,out): 
	f=open(ids,"r") 
	o1=open(out+".notfound.id.desc","w") 
	o2=open(out+".tsv","w") 
	o2.write("#reference\tdescription\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\Species\n") 
	for l in f : 
		if l.startswith(">"): 
			l_split=l.rstrip().split(" ") 
			all_name=l_split[1].split(",")[0]
			ref=l_split[0].lstrip(">") 
			if ref in dic_summary : 
				taxo=retrieve_lineage(ref) 
				o2.write(ref+"\t"+all_name+"\t"+taxo+"\n") 
			else :
				name=" ".join(all_name.split(" ")[:2])
				taxo=retrieve_lineage_from_name(name)  
				if taxo=="": 
					o1.write(l) 
				else: 
					o2.write(ref+"\t"+all_name+"\t"+taxo+"\n") 	
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
	
if len(sys.argv) != 2: 
	usage() 
	exit() 
	

out=sys.argv[1]+"/all_prokaryotes.taxo" 	
dic_summary=set_dic_summary(sys.argv[1]+"/all_prokaryotes.ncbi.info") 
ncbi = NCBITaxa()
ncbi.update_taxonomy_database()
treat_sequences(sys.argv[1]+"/all_prokaryotes.fasta",out) 	
