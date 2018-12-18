import sys 

class Plasmid: 	
	def __init__(self,name,length,length_cat): 
		self.name=name
		self.length=length 
		self.length_cat=length_cat 
		self.bases_aligned=set() 
		self.contigs=set() 		
		self.complete=False 
		self.coverage=0

def usage(): 
	print('usage : python3 treat_metaquast.py <metaquast treatment dir> <plasmids length.tsv> <names of assemblies> <SR coverage> <LR coverage> <contamination> ')
	
def initialize_plasmids(f): 
	f=open(f,"r") 
	dic_p={}
	total_length=0
	f.readline() 
	for l in f:  
		l_split=l.rstrip().split("\t") 
		id_p=l_split[0]
		p=Plasmid(id_p,int(l_split[1]),l_split[2])  	
		total_length+=int(l_split[1]) 		
		dic_p[id_p]=p
	f.close() 
	return dic_p, total_length  
	
def give_list_good_contigs(directory,a): 
	f=open(directory+"/good_contigs."+a+".tsv","r") 
	dic={}
	for l in f : 
		name=l.split("\t")[1]
		length=l.split("\t")[2] 
		dic[name]=int(length)
	return dic
		
	
def treat_plasmids(directory,a,dic_p,list_good_contigs): 
	f=open(directory+"/all_alignments_"+a+".rev.tsv","r") 	
	for l in f : 
		if not l.startswith("CONTIG"): 
			l_split=l.split("\t")
			if len(l_split)==9: 
				plasmid="_".join(l_split[4].split("_")[:2])
				contig=l_split[5]
				if contig in list_good_contigs: 
					dic_p[plasmid].contigs.add(contig)
					start_p=int(l_split[0]) 
					end_p=int(l_split[1]) 		
					current_base_aligned_p=give_list_base_aligned(start_p,end_p) 
					dic_p[plasmid].bases_aligned.update(current_base_aligned_p) 
					
def is_plasmids_complete(dic_p,dic_c): 
	complete_length=0
	number_complete=0
	for p in dic_p : 
		pobj=dic_p[p]
		pobj.coverage=len(pobj.bases_aligned)/pobj.length 
		if(pobj.coverage)>=0.9 : 
			for c in pobj.contigs: 
				if(dic_c[c]/pobj.length)>0.9: 
					complete_length+=pobj.length
					number_complete+=1
					pobj.complete=True 
					continue 
	return number_complete,complete_length			
		
def give_list_base_aligned(start,end):
	if start < end : 
		list_base_aligned=set(range(start,end+1)) 
	else : 
		list_base_aligned=set(range(end,start+1))	
	
	return list_base_aligned
	
def write_plasmid_file(dic_p,a,out,SR,LR,cont): 
	for p in dic_p : 
		pobj=dic_p[p]
		if pobj.complete:
			status="complete"
		else:
			status="not.complete"	
		out.write("%s\t%s\t%s\t%s\t%s\t%d\t%d\t%s\t%d\t%s\n"%(a,SR,LR,cont,pobj.name,pobj.length,len(pobj.bases_aligned),pobj.length_cat,len(pobj.contigs),status))
								
if len(sys.argv)!= 7 : 
	usage()
	exit() 
	

assemblies=sys.argv[3].split(",") 
out=open(sys.argv[1]+"/plasmids_stats.tsv","w") 
out2=open(sys.argv[1]+"/summary_plasmids_stats.tsv","w") 
out.write("Assembly\tIllumina coverage\tPacBio coverage\tContamination\tPlasmid\tLength\tAligned_length\tLength category\tNumber contigs\tStatus\n") 
out2.write("Assembly\tNumber complete plasmids\tComplete length\t%Complete plasmids (length)\n") 

for a in assemblies : 
	print(a) 
	dic_p,total_length=initialize_plasmids(sys.argv[2])
	list_good_contigs=give_list_good_contigs(sys.argv[1],a)
	treat_plasmids(sys.argv[1],a,dic_p,list_good_contigs)
	number_complete,complete_length=is_plasmids_complete(dic_p,list_good_contigs)
	write_plasmid_file(dic_p,a,out,sys.argv[4],sys.argv[5],sys.argv[6]) 
	out2.write(a+"\t"+str(number_complete)+"\t"+str(complete_length)+"\t"+str((complete_length/total_length)*100)+"\n")

out2.close() 
out.close()		
