import json 
import argparse
import os 

class ResfamsProfile:
	def __init__(self,ref,name,desc,aro): 
		self.ref=ref
		self.name=name
		self.desc=desc 
		self.aro=aro 
		self.aro_desc={}
		
	def search_aro(self,json,list_class_name):
		for class_name in list_class_name: 
			self.aro_desc[class_name]=set()
		for a in self.aro: 
			aro_category=[card_json[i]["ARO_category"] for i in card_json if not i.startswith("_") if card_json[i]["ARO_accession"]==a]
			if len(aro_category)>0:
				aro_category=aro_category[0]
				for i in aro_category : 
					cat=aro_category[i]
					cat_name=cat["category_aro_class_name"] 
					aro_name=cat["category_aro_name"] 
					self.aro_desc[cat_name].add(aro_name) 
			 
			 	
		


#card="databases/CARD/card.json" 
#card_cat="databases/CARD/aro_categories.csv" 
#card_index="databases/CARD/aro_categories_index.csv" 
#resfams="databases/Resfams/Resfams.summary" 
#no_aro="databases/Resfams/Resfams.noaro" 
#no_aro_found="databases/Resfams/Resfams.noaro.found"
#aro_multipleDrug="databases/Resfams/Resfams.multipleDrug" 
#aro_multipleMech="databases/Resfams/Resfams.multipleMech" 

def treat_args():
	parser = argparse.ArgumentParser()
	parser.add_argument("--card", help="Directory where CARD database is stored",default="/databis/hilpert/plasmidome_databases/CARD")
	parser.add_argument("--resfams", help="Resfams summary file",default="/databis/hilpert/plasmidome_databases/Resfams/Resfams.summary")  
	parser.add_argument("--outdir",help="Output directory for Resfams annotation",default="/databis/hilpert/plasmidome_databases/Resfams") 
	parser.add_argument("--prefix",help="Output prefix",default="Resfams") 
	args = parser.parse_args()
	
	if not os.path.isdir(args.card): 
		print("[resfams_annot] "+args.card+" doesn't found. Use --card to specify it.") 
		exit() 
	else : 
		print("[resfams_annot] "+args.card+" found.")	
		
	if not os.path.exists(args.resfams): 
		print("[resfams_annot] "+args.resfams+" doesn't found. Use --resfams to specify it.") 
		exit()  
	else : 
		print("[resfams_annot] "+args.resfams+" found.")			
	return args 
	
		

def set_dic_cat(f):
	f=open(f,"r") 
	dic={}
	f.readline() 
	for l in f: 
		l_split=l.rstrip().split("\t") 
		aro=l_split[1].split(":")[1]
		dic[aro]=l_split[2]
	f.close() 
	return dic 
	
def set_dic_index(f): 
	f=open(f,"r") 
	dic={}
	for l in f: 
		l_split=l.rstrip().split("\t") 
		name=l_split[2]
		drug=l_split[3]
		mechanism=l_split[4]
		if name in dic : 
			dic[name]["drug"].add(drug) 
			dic[name]["mechanism"].add(mechanism) 
		else : 
			dic[name]={"drug":{drug},"mechanism":{mechanism}}	 		
	f.close() 
	return dic 
	
def treat_multiple(drugs): 
	list_drugs=set() 
	for d in drugs : 
		for d in d.split(";"): 
			list_drugs.add(d) 
	return list_drugs 		 	
	
args=treat_args() 

if not os.path.exists(args.outdir):
    os.makedirs(args.outdir)

card=args.card+"/card.json" 
card_cat=args.card+"/aro_categories.csv" 
card_index=args.card+"/aro_categories_index.csv" 
no_aro=args.outdir+"/"+args.prefix+".noaro" 
no_aro_found=args.outdir+"/"+args.prefix+".noaro.found" 
aro_multipleDrug=args.outdir+"/"+args.prefix+".multipleDrug" 
aro_multipleMech=args.outdir+"/"+args.prefix+".multipleMech"
resfams_annot=args.outdir+"/"+args.prefix+".annot" 

f=open(card,"r") 
card_json=json.loads(f.readline()) 
f.close() 
resfams=open(args.resfams,"r") 
no_aro=open(no_aro,"w") 
no_aro_found=open(no_aro_found,"w") 
aro_multipleDrug=open(aro_multipleDrug,"w") 
aro_multipleMech=open(aro_multipleMech,"w") 
resfams_annot=open(resfams_annot,"w") 

dic_cat=set_dic_cat(card_cat) 
dic_index=set_dic_index(card_index) 

list_class_name=set() 
for entry in card_json : 
	if not entry.startswith("_"): 
		for num in card_json[entry]["ARO_category"]: 
			aro_category=card_json[entry]["ARO_category"][num]
			list_class_name.add(aro_category["category_aro_class_name"]) 

resfams_annot.write("Resfams profile\tName\tDescription\tARO\t"+"\t".join(list(list_class_name))+"\n") 

list_profile=[]
for l in resfams : 
	l_split=l.rstrip().split("\t") 
	ref=l_split[0]
	name=l_split[1]
	desc=l_split[2]
	if "ARO" in desc :
		aro=[aro.rstrip("]").rstrip(";") for aro in desc.split("ARO:")[1:]]
	else:
		aro=[]		
	profile=ResfamsProfile(ref,name,desc,aro) 
	profile.search_aro(card_json,list_class_name)
	list_profile.append(profile) 

for p in list_profile: 
	to_print=p.ref+"\t"+p.name+"\t"+p.desc+"\t"
	if len(p.aro)==0: 
		to_print+="-\t"
	else: 
		to_print+=";".join(p.aro)+"\t"
	for class_name in list_class_name: 
		if len(p.aro_desc[class_name])==0: 
			to_print+="-\t" 
		else : 	
			to_print+=";".join(list(p.aro_desc[class_name]))+"\t"  		
	to_print=to_print.rstrip("\t")+"\n"
	resfams_annot.write(to_print) 
exit()  



for l in resfams : 
	l_split=l.rstrip().split("\t") 
	ref=l_split[0]
	name=l_split[1]
	desc=l_split[2]
	if "ARO" in desc : 
		aro=[aro.rstrip("]").rstrip(";") for aro in desc.split("ARO:")[1:]]
		found=False 
		for a in aro : 
			aro_category=[card_json[i]["ARO_category"] for i in card_json if not i.startswith("_") if card_json[i]["ARO_accession"]==a]
			if len(aro_category)>0:
				aro_category=aro_category[0]
				amr=""
				drug_class=""
				mechanism=""
				for i in aro_category:
					cat=aro_category[i]
					cat_name=cat["category_aro_class_name"] 
					aro_name=cat["category_aro_name"] 
					if cat_name=="AMR Gene Family":
						amr+=aro_name
					elif cat_name=="Drug Class": 
						drug_class+=aro_name+";" 
					elif cat_name=="Resistance Mechanism": 
						mechanism+=aro_name+";" 	
				drug_class=drug_class.rstrip(";") 	
				mechanism=mechanism.rstrip(";") 
				resfams_annot.write(ref+"\t"+name+"\t"+desc+"\t"+a+"\t"+amr+"\t"+drug_class+"\t"+mechanism+"\n") 
			else: 	
				try : 
					name=dic_cat[a]
					drug=dic_index[name]["drug"]
					mechanism=dic_index[name]["mechanism"] 
					drugs=treat_multiple(drug) 
					mechanisms=treat_multiple(mechanism) 
					resfams_annot.write(ref+"\t"+name+"\t"+desc+"\t"+a+"\t"+name+"\t"+";".join(list(drugs))+"\t"+";".join(list(mechanisms))+"\n") 
					if len(drug)>1: 
						aro_multipleDrug.write(ref+"\t"+a+"\n") 
					if len(mechanism)>1: 	
						aro_multipleMech.write(ref+"\t"+a+"\n") 
				except KeyError: 
					resfams_annot.write(ref+"\t"+name+"\t"+desc+"\t"+a+"\t-\t-\t-\n")
					no_aro_found.write(ref+"\t"+a+"\n") 			
	else: 
		resfams_annot.write(ref+"\t"+name+"\t"+desc+"\t-\t-\t-\t-\n")
		no_aro.write(ref+"\n")	

resfams.close() 
no_aro.close() 
no_aro_found.close() 
aro_multipleDrug.close()
aro_multipleMech.close() 

exit() 

aro_category=[card_json[i]["ARO_category"] for i in card_json if not i.startswith("_") if card_json[i]["ARO_accession"]=="0010001"][0]

for i in aro_category : 
	cat=aro_category[i] 
	cat_name=cat["category_aro_class_name"] 
	aro_name=cat["category_aro_name"] 
	print(cat_name,aro_name) 
