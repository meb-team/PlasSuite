import sys 

def usage(): 
	print("usage : python3 add_markers_to_prokka_results.py <blast_results.tsv> <prokka gff> <prokka gff out> <marker type>") 
	print("/!\ bitscore must be in 12th column in <blast_results.tsv>, careful if you changed --outfmt 6 when launch blast")
	 
if len(sys.argv)!=5: 
	usage() 
	exit() 
	
inp=open(sys.argv[1],"r") 
dic_score={}
dic_query={}
for l in inp: 
	l_split=l.rstrip().split("\t") 
	query=l_split[0]
	db=l_split[1]
	score=l_split[11]
	if query not in dic_score:
		dic_score[query]=[score] 
		dic_query[query]={}
		if score not in dic_query[query]:
			dic_query[query][score]=[db] 
		else:
			dic_query[query][score].append(db) 	
	else:
		dic_score[query].append(score) 
		if score not in dic_query[query]:
			dic_query[query][score]=[db] 
		else:
			dic_query[query][score].append(db) 
	
inp.close() 		

dic_final={} 

for query in dic_score: 
	max_score=max(dic_score[query])
	ref=dic_query[query][max_score][0]
	dic_final[query]=ref 

gff=open(sys.argv[2],"r")
out=open(sys.argv[3],"w") 
marker_type=sys.argv[4]
for l in gff : 
	l_split=l.rstrip().split("\t")
	if len(l_split)==9:
		prot_id=[a for a in l_split[8].split(";") if a.startswith("ID")] 
		if len(prot_id)==1: 
			prot_id=prot_id[0].lstrip("ID=") 
			if prot_id in dic_query: 
				new_desc="" 
				for desc in l_split[8].split(";"):
					if desc.startswith("inference"):
						desc=desc+",similar to sequence:mob_suite:"+marker_type+":"+dic_final[prot_id]    
					new_desc+=desc+";"
				new_desc=new_desc.rstrip(";") 	  				
				out.write("\t".join(l_split[:8])+"\t"+new_desc+"\n") 
			else:
				out.write(l) 	
		else: 
			out.write(l)  		
	else:
		out.write(l) 			 

gff.close()
out.close()  		
	


	
	
	
	
