import sys 
from ete3 import NCBITaxa

def usage():
	print("usage : python3 comp_taxo.py <taxo file>") 
	
def compare_two_taxo(taxo1,taxo2,ncbi): 
	if taxo1=="DeinococcusThermus":
		taxo1="Deinococcus-Thermus" 
	if taxo2=="DeinococcusThermus": 
		taxo2="Deinococcus-Thermus" 
	if taxo1=="unclassified" or taxo1=="Undefined" or "uncultured bacterium" in taxo1: 
		return True
	elif taxo2=="unclassified" or taxo2=="Undefined" or "uncultured bacterium" in taxo2: 
		return True 
	else: 
		taxid1=ncbi.get_name_translator([taxo1])[taxo1][0]
		taxid2=ncbi.get_name_translator([taxo2])[taxo2][0]
		rank1=ncbi.get_rank([taxid1])[taxid1]
		rank2=ncbi.get_rank([taxid2])[taxid2]	
		lineage1=ncbi.get_lineage(taxid1) 
		lineage2=ncbi.get_lineage(taxid2) 
		ranks1=ncbi.get_rank(lineage1)
		ranks2=ncbi.get_rank(lineage2)
		highest_common_rank=get_highest_common_ranks(ranks1,ranks2,0) 
		if highest_common_rank: 
			taxid1=[taxid for taxid in ranks1 if ranks1[taxid]==highest_common_rank] 
			taxid2=[taxid for taxid in ranks2 if ranks2[taxid]==highest_common_rank]
			taxo1=ncbi.get_taxid_translator(taxid1)[taxid1[0]]  
			taxo2=ncbi.get_taxid_translator(taxid2)[taxid2[0]]  
			while taxo1!=taxo2: 
				numb_rank=dic_taxo[highest_common_rank]
				if numb_rank==7:
					return False
				numb_rank+=1 
				highest_common_rank=get_highest_common_ranks(ranks1,ranks2,numb_rank-1)  
				if highest_common_rank: 
					taxid1=[taxid for taxid in ranks1 if ranks1[taxid]==highest_common_rank] 
					taxid2=[taxid for taxid in ranks2 if ranks2[taxid]==highest_common_rank]
					taxo1=ncbi.get_taxid_translator(taxid1)[taxid1[0]] 
					taxo2=ncbi.get_taxid_translator(taxid2)[taxid2[0]]	
				else: 
					return True	
			return True 	
		else : 
			return False 	
			
def get_highest_common_ranks(ranks1,ranks2,begin_rank):
	ranks1=list(ranks1.values()) 
	ranks2=list(ranks2.values())
	taxo_ranks=["species","genus","family","order","class","phylum","superkingdom"]
	taxo_treat=taxo_ranks[begin_rank:] 
	for t in taxo_treat: 
		if t in ranks1 and t in ranks2 : 
			return t 
	return False 			
	 	
def is_same_taxo(list_same): 
	same=True	
	for s in list_same: 			
		if not s : 
			same=False 
	return same 
	
if len(sys.argv)!=2: 
	usage() 
	exit()
	
f=open(sys.argv[1],"r") 
o1=open(sys.argv[1]+".sameTaxo","w") 
o2=open(sys.argv[1]+".differentTaxo","w") 
#o3=open(sys.argv[1]+".differentChrmRNA","w") 
dic_taxo={"superkingdom":7,"phylum":6,"class":5,"order":4,"family":3,"genus":2,"species":1}
dic_taxo_inv={7:"superkingdom",6:"phylum",5:"class",4:"order",3:"family",2:"genus",1:"species"}
ncbi=NCBITaxa() 
f.readline() 
for l in f:
	same_taxo=True 
	l_split=l.rstrip().split("\t") 
	contig=l_split[0]
	plasflow=l_split[1]
	chrm=l_split[2]
	rna=l_split[3]
	plasmid=l_split[4]	
	
	list_same=[]
	
	if chrm != "-" or rna != "-" or plasmid != "-": 
		if chrm != "-" : 
			same_plasflow_chrm=compare_two_taxo(plasflow,chrm,ncbi)
			list_same.append(same_plasflow_chrm) 
			if rna != "-" : 
				same_chrm_rna=compare_two_taxo(chrm,rna,ncbi)
				list_same.append(same_chrm_rna) 
				if plasmid != "-" : 
					same_rna_plasmid=compare_two_taxo(rna,plasmid,ncbi) 
					list_same.append(same_rna_plasmid) 
			if plasmid!="-":
				same_chrm_plasmid=compare_two_taxo(chrm,plasmid,ncbi) 
				list_same.append(same_chrm_plasmid) 
		if rna != "-" : 
			same_plasflow_rna=compare_two_taxo(plasflow,rna,ncbi) 
			list_same.append(same_plasflow_rna) 
			if plasmid != "-" : 
				same_rna_plasmid=compare_two_taxo(rna,plasmid,ncbi) 
				list_same.append(same_rna_plasmid)
		if plasmid != "-" : 
			same_plasflow_plasmid=compare_two_taxo(plasflow,plasmid,ncbi) 
			list_same.append(same_plasflow_plasmid)
		if is_same_taxo(list_same): 
			o1.write(l)
		else :
			o2.write(l) 			
				
	
f.close() 		
o1.close() 	
o2.close() 
	
		
