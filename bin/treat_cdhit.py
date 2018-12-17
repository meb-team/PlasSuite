import sys 
from Bio import SeqIO 

def usage(): 
	print("usage : treat_cdhit.py <.clstr file> <.ffn clusters file> <.ffn file all prot> ")
	
def set_dic_prot(prot): 
	prot=open(prot,"r") 
	dic={}	
	for l in prot : 
		if l.startswith(">"): 
			l_split=l.rstrip().split(" ") 
			ref=l_split[0].lstrip(">") 
			desc=" ".join(l_split[1:])
			dic[ref]=desc 
	prot.close() 
	return dic 
	
def correct_names(fasta,dic_consistent_hyp): 
	fasta_out=open(fasta+".correct","w") 
	for record in SeqIO.parse(fasta,"fasta"): 
		if "hypothetical protein" in record.description: 
			if record.id in dic_consistent_hyp:
				record.description=record.id+" "+dic_consistent_hyp[record.id]  
		SeqIO.write(record,fasta_out,"fasta")
		 
if len(sys.argv) != 4 : 
	usage() 
	exit() 

dic_prot=set_dic_prot(sys.argv[3]) 

clstr=open(sys.argv[1],"r") 
dic_clstr={}
for l in clstr: 
	if l.startswith(">"): 
		cluster=l.rstrip().lstrip(">") 
		dic_clstr[cluster]=[] 
	else : 
		prot=l.rstrip().split(",")[1].split("...")[0].lstrip(" >") 
		dic_clstr[cluster].append(prot)  	
clstr.close() 		 

dic_consistent_hyp={}
print("Cluster name\tNumber of proteins\tProteins id\tProteins desc\tCluster status") 
for i in dic_clstr: 
	to_print=i+"\t"+str(len(dic_clstr[i]))+"\t"+";".join(dic_clstr[i])+"\t"+";".join([dic_prot[prot] for prot in dic_clstr[i]])+"\t"
	list_desc=set() 
	for prot in dic_clstr[i]: 
		list_desc.add(dic_prot[prot]) 
	if len(list_desc)> 1 : 
		nb_hypothetical_protein=0 
		for d in list_desc: 
			if d=="hypothetical protein": 
				nb_hypothetical_protein+=1
		if nb_hypothetical_protein==len(list_desc)-1: 
			list_desc.remove('hypothetical protein') 
			for prot_id in dic_clstr[i]: 
				dic_consistent_hyp[prot_id]=tuple(list_desc)[0]
			to_print+="consistent_hyp" 
		else:
			to_print+="divergent" 	
	else: 
		to_print+="consistent" 
	print(to_print) 		

correct_names(sys.argv[2],dic_consistent_hyp)
