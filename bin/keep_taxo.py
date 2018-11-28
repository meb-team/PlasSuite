import sys 

def usage(): 
	print("usage : python3 keep_taxo.py <taxo file> <id to keep>")
	
def give_list_id(f): 
	'''Transform file to set, where each set's elements is a line''' 
	f=open(f,"r") 
	list_id=set()
	for l in f : 
		list_id.add(l.rstrip()) 
	f.close() 
	return list_id		
	
if len(sys.argv)!=3: 
	usage()
	exit() 
	
		
id_list=give_list_id(sys.argv[2])

f=open(sys.argv[1],"r") 

for l in f : 
	if l.split("\t")[0] in id_list:
		print(l.rstrip()) 	
