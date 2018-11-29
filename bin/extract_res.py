import sys 

def usage(): 
	print("usage : python3 extract_res.py <gff>") 
	
if len(sys.argv)!=2: 
	usage()
	exit() 
	
gff=open(sys.argv[1],"r") 

print("CDS_id\tResfams_profile") 
for l in gff : 
	l_split=l.split("\t") 
	if len(l_split)==9: 
		desc=l_split[8]
		if "Resfams" in desc : 
			ref=desc.split("ID=")[1].split(";")[0]
			resfams=desc.split("Resfams:")[1].split(";")[0]
			print(ref+"\t"+resfams) 

gff.close() 		
