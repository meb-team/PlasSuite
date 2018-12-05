import sys 

def usage(): 
	print("usage : python3 format_circular_gff.py <circular.gff>") 
	
if len(sys.argv)!=2: 
	usage()
	exit() 
	
gff=open(sys.argv[1],"r") 

dic_length={}
for l in gff : 
	l_split=l.split("\t")
	if l.startswith("##sequence-region"):
		l_split=l.rstrip().split(" ") 
		if "_circ" in l_split[1]: 
			dic_length[l_split[1]]=int(l_split[3])-1000
			print(" ".join(l_split[:3])+" "+str(int(l_split[3])-1000)) 
		else: 
			print(l.rstrip()) 	
	elif len(l_split)==9: 
		if "_circ" in l_split[0]: 
			if int(l_split[3])<dic_length[l_split[0]]: 
				print(l.rstrip()) 
		else : 
			print(l.rstrip()) 			
	else: 
		print(l.rstrip()) 		
gff.close() 		
