import sys 

def usage(): 
	print("usage : count_taxo.py <count_taxo_same.tsv> <count_taxo_different.tsv> <outfile>") 
	
if len(sys.argv)!=4: 
	usage()
	exit() 
	
def set_dic_count(f,list_taxo):
	f=open(f,"r") 
	dic={}
	f.readline()
	for l in f : 
		l_split=l.rstrip().split("\t") 
		dic[l_split[0]]=int(l_split[1]) 
		list_taxo.add(l_split[0]) 
	f.close()  	
	return dic 
	
list_taxo=set() 	
same=set_dic_count(sys.argv[1],list_taxo) 	
different=set_dic_count(sys.argv[2],list_taxo) 

o=open(sys.argv[3],"w") 
o.write("Taxon\tSame\tDifferent\t%correctly predicted\n") 
all_same=0
all_different=0
for taxon in list_taxo:  
	if taxon != "unclassified" : 
		try:
			number_same=same[taxon]
			all_same+=number_same
		except KeyError:
			number_same=0
		try: 
			number_different=different[taxon]
			all_different+=number_different
		except KeyError:
			number_different=0
		percent=number_same/(number_same+number_different)*100
		o.write(taxon+"\t"+str(number_same)+"\t"+str(number_different)+"\t"+str(percent)+"\n")		
all_percent=all_same/(all_same+all_different)*100
o.write("All\t"+str(all_same)+"\t"+str(all_different)+"\t"+str(all_percent)+"\n")	 	
o.close()
