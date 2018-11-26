import sys 
from ete3 import NCBITaxa

class Taxo:
	def __init__(self,kingdom,phylum,classe,order,family,genus,species): 
		self.kingdom=kingdom 
		self.phylum=phylum
		self.classe=classe
		self.order=order
		self.family=family 
		self.genus=genus
		self.species=species

def usage(): 
	print("usage : python3 treat_taxo.py <.paf alignment chrm file> <chrm taxonomy.tsv> <plasflow_taxonomy.tsv> <rna_alignment.tsv> <rna_taxonomy.tsv> <.paf plasmids alignment> <plasmids_taxonomy.tsv>")  

def set_dic_chrm(f_align,dic):
	f=open(f_align,"r") 
	for l in f: 
		l_split=l.rstrip().split("\t") 
		contig=l_split[0]
		chrm=l_split[5]
		dic[contig]["chrm"].append(dic_chrm[chrm]) 
	f.close() 
	return dic 	
	
def set_dic_plasmids(f_align,dic):
	f=open(f_align,"r") 
	for l in f: 
		l_split=l.rstrip().split("\t") 
		contig=l_split[0]
		plasmid=l_split[5]
		dic[contig]["plasmid"].append(dic_plasmids[plasmid]) 
	f.close() 
	return dic 		
	
def set_dic_rna(align_rna,dic): 
	f=open(align_rna,"r") 
	for l in f : 
		l_split=l.rstrip().split("\t") 
		contig=l_split[1]
		rna=l_split[0]
		dic[contig]["rna"].append(dic_rna[rna])
	f.close() 
	return dic 	
	
def initialize_dic(f_plasflow,ncbi): 
	dic={}
	f=open(f_plasflow,"r") 
	for l in f: 
		l_split=l.rstrip().split("\t") 
		contig=l_split[0]
		taxo=l_split[1]
		if taxo=="unclassified" or taxo=="other": 
			dic[contig]={"plasflow":"unclassified","chrm":[],"rna":[],"plasflowPhylum":"unclassified","plasmid":[]}
		else : 	
			try : 
				taxid=ncbi.get_name_translator([taxo])[taxo][0] 
				rank=ncbi.get_rank([taxid])
				if rank[taxid] == "phylum" : 
					dic[contig]={"plasflow":taxo,"chrm":[],"rna":[],"plasflowPhylum":taxo,"plasmid":[]}
				else:
					dic[contig]={"plasflow":taxo,"chrm":[],"rna":[],"plasflowPhylum":"to_search","plasmid":[]}
			except : 
				if taxo=="DeinococcusThermus": 
					dic[contig]={"plasflow":taxo,"plasflowPhylum":"DeinococcusThermus","chrm":[],"rna":[],"plasmid":[]}
				else: 			
					dic[contig]={"plasflow":taxo,"plasflowPhylum":"to_search","chrm":[],"rna":[],"plasmid":[]}		
	f.close() 	
	return dic 	
	
def set_taxo(f_taxo): 
	f=open(f_taxo,"r") 
	dic={}
	f.readline()
	for l in f: 
		l_split=l.rstrip().split("\t") 
		dic[l_split[0]]=Taxo(l_split[2],l_split[3],l_split[4],l_split[5],l_split[6],l_split[7],l_split[8]) 
	f.close() 	
	return dic 
	
def set_rna_taxo(f_rna): 
	f=open(f_rna,"r") 
	dic={}
	f.readline() 
	for l in f : 
		l_split=l.rstrip().split("\t") 
		dic[l_split[0]]=Taxo(l_split[1],l_split[2],l_split[3],l_split[4],l_split[5],l_split[6],l_split[7]) 
	f.close() 	
	return dic 	
	
def set_plasmids_taxo(f_taxo): 
	f=open(f_taxo,"r") 
	dic={}
	f.readline()
	for l in f: 
		l_split=l.rstrip().split("\t") 
		dic[l_split[0]]=Taxo(l_split[1],l_split[2],l_split[3],l_split[4],l_split[5],l_split[6],l_split[7]) 
	f.close() 	
	return dic 		
	
def min_tax_level(taxo_list): 
	species=set([tax.species for tax in taxo_list])	 
	length=len(species) 
	species=species.pop() 
	if length==1 and species!="-": 
		return species 
	genus=set([tax.genus for tax in taxo_list])	 
	length=len(genus) 
	genus=genus.pop() 
	if length==1 and genus!="-": 
		return(genus) 	
	family=set([tax.family for tax in taxo_list])	 
	length=len(family) 
	family=family.pop() 
	if length==1 and family!="-": 
		return(family) 		
	order=set([tax.order for tax in taxo_list])	 
	length=len(order) 
	order=order.pop() 
	if length==1 and order!="-": 
		return(order) 		
	classe=set([tax.classe for tax in taxo_list])	 
	length=len(classe) 
	classe=classe.pop() 
	if length==1 and classe!="-": 
		return(classe) 	
	phylum=set([tax.phylum for tax in taxo_list])	 
	length=len(phylum) 
	phylum=phylum.pop() 
	if length==1 and phylum!="-": 
		return(phylum) 	
	kingdom=set([tax.kingdom for tax in taxo_list])	 
	length=len(kingdom) 
	kingdom=kingdom.pop() 
	if length==1 and kingdom!="-": 
		return(kingdom) 							
	return("Undefined") 
	
def get_phylum(taxo_list): 
	phylum=set([tax.phylum for tax in taxo_list])	 
	length=len(phylum) 
	phylum=phylum.pop() 
	if length==1 and phylum!="-": 
		return(phylum)	
	kingdom=set([tax.kingdom for tax in taxo_list])	 
	length=len(kingdom) 
	kingdom=kingdom.pop() 
	if length==1 and kingdom!="-": 
		return(kingdom) 							
	return("Undefined") 		

if len(sys.argv) != 8: 
	usage() 
	exit() 	
	
ncbi=NCBITaxa()	
dic_chrm=set_taxo(sys.argv[2])
dic_rna=set_rna_taxo(sys.argv[5])
dic_plasmids=set_plasmids_taxo(sys.argv[7]) 	
dic_taxo=initialize_dic(sys.argv[3],ncbi)
dic_taxo=set_dic_chrm(sys.argv[1],dic_taxo) 
dic_taxo=set_dic_rna(sys.argv[4],dic_taxo) 
dic_taxo=set_dic_plasmids(sys.argv[6],dic_taxo) 


print("#Contig_id\tPlasflow_taxo\tChrm_taxo\tRNA_taxo\tPlasmid_taxo\tChrm_phylum\tRNA_phylum\tPlasmid_phylum")
for contig in dic_taxo: 
	to_print=contig+"\t"+dic_taxo[contig]["plasflow"]+"\t" 
	if len(dic_taxo[contig]["chrm"])==0:
		to_print+="-\t" 
		chrm_phylum="-"
	else:
		tax_level=min_tax_level(dic_taxo[contig]["chrm"])
		chrm_phylum=get_phylum(dic_taxo[contig]["chrm"]) 
		to_print+=tax_level+"\t"  	
	if len(dic_taxo[contig]["rna"])==0:	
		to_print+="-\t"
		rna_phylum="-"
	else:
		tax_level=min_tax_level(dic_taxo[contig]["rna"])
		rna_phylum=get_phylum(dic_taxo[contig]["rna"])
		to_print+=tax_level+"\t"
	if len(dic_taxo[contig]["plasmid"])==0: 
		to_print+="-\t"
		plasmid_phylum="-"
	else: 
		tax_level=min_tax_level(dic_taxo[contig]["plasmid"]) 
		plasmid_phylum=get_phylum(dic_taxo[contig]["plasmid"])
		to_print+=tax_level+"\t"
	to_print+=chrm_phylum+"\t"+rna_phylum+"\t"+plasmid_phylum	
	print(to_print) 
 
	
 

