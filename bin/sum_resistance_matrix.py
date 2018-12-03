import sys 

def usage(): 
	print("usage : python3 sum_resistance_matrix.py <resistance matrix> <new matrix prefix>")
	
def complete_dic(sample,abundance,res,dic): 
	if res in dic[sample]: 
		dic[sample][res]+=abundance
	else:
		dic[sample][res]=abundance	
		
def initialize(matrix): 
	dic_samples_index={}
	dic_desc_index={}
	f=open(matrix,"r")
	first_line=f.readline() 
	samples=first_line.split("\t")[2:-12]
	desc=first_line.rstrip().split("\t")[-12:] 
	index=2
	for s in samples: 
		dic_samples_index[s]=index
		index+=1 
	index=2+len(samples) 
	for d in desc : 
		dic_desc_index[d]=index 
		index+=1
		
	f.close()   		
	return dic_samples_index,dic_desc_index 
	
		
def create_dic(matrix,cat_name): 
	f=open(matrix,"r")
	f.readline()  
	dic={}
	list_cat=set()
	for s in dic_samples_index: 
		dic[s]={}
	for l in f: 
		l_split=l.rstrip().split("\t")
		cat=l_split[dic_desc_index[cat_name]] 
		list_cat.add(cat) 
		for s in dic_samples_index:
			index=dic_samples_index[s]
			complete_dic(s,float(l_split[index]),cat,dic) 
	f.close() 	
	return dic,list_cat
	
def write_new_matrix(matrix,dic,l,cat): 
	o=open(matrix,"w") 
	o.write(cat+"\t"+"\t".join(list(dic_samples_index.keys()))+"\n")
	for i in l: 
		to_print=i+"\t"
		for s in dic_samples_index: 
			to_print+=str(dic[s][i])+"\t" 
		to_print=to_print.rstrip("\t")+"\n" 
		o.write(to_print) 	 
	o.close() 	
		
		
def write_R_formatted(out,dic): 
	o=open(out,"w") 
	o.write("Profile\tSample\tCount\n")
	for s in dic : 
		for c in dic[s] : 
			o.write(c+"\t"+s+"\t"+str(dic[s][c])+"\n") 
	o.close() 		
	
def most_present(dic,out): 
	out=open(out,"w") 
	out.write("Profile\tSample\tCount\n") 
	common_top5=set()
	for s in dic : 
		sorted_dic=sorted(dic[s].items(),key=lambda x: x[1],reverse=True) 
		top_five=sorted_dic[:5] 
		others=sorted_dic[5:]
		for top in top_five : 
			common_top5.add(top[0]) 	
	for s in dic : 
		sum_others=0
		for rf in dic[s] : 
			if rf in common_top5: 
				out.write(rf+"\t"+s+"\t"+str(dic[s][rf])+"\n")
			else:
				sum_others+=dic[s][rf] 
		out.write("Others\t"+s+"\t"+str(sum_others)+"\n") 			  
	out.close() 		  	  
			
		
if len(sys.argv)!=3: 
	usage()
	exit() 
	
dic_samples_index,dic_desc_index=initialize(sys.argv[1]) 
dic_cat_ab,list_cat_ab=create_dic(sys.argv[1],"Resfams_Ab_classif") 
dic_drug_class,list_drug_class=create_dic(sys.argv[1],"Drug Class")  
dic_rf,list_rf=create_dic(sys.argv[1],"Resfams_profile") 

matrix_cat_ab=sys.argv[2]+".catAb" 
write_new_matrix(matrix_cat_ab,dic_cat_ab,list_cat_ab,"Resfams_Ab_classif")  	
write_R_formatted(sys.argv[2]+".catAb.format",dic_cat_ab) 
matrix_drug_class=sys.argv[2]+".drugClass" 
write_new_matrix(matrix_drug_class,dic_drug_class,list_drug_class,"Drug Class") 
write_R_formatted(sys.argv[2]+".drugClass.format",dic_drug_class)
matrix_rf=sys.argv[2]+".ResfamsProfile" 	
write_new_matrix(matrix_rf,dic_rf,list_rf,"Resfams_profile") 			     	 		
write_R_formatted(sys.argv[2]+".ResfamsProfile.format",dic_rf)
most_present(dic_rf,sys.argv[2]+".ResfamsProfile.morePresent") 
