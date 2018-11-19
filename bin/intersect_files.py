import sys 

def usage(): 
	print("usage : python3 back_transcribe.py <file1> <file2> <outdir> <prefix> <name1> <name2>") 
	print("---")
	print("Intersect two files and give 3 output : one with common elements, one with elements only in file1 and one with elements only in file2")

def create_set(f): 
	f=open(f,"r") 
	s=set() 
	for l in f : 
		s.add(l.rstrip()) 
	f.close() 	
	return s 
	
def write_file(o,s): 
	o=open(o,"w") 
	for e in s : 
		o.write(e+"\n") 	
	o.close() 	
	
def delete_extension(f): 
	new_f=".".join(f.split("/")[-1].split(".")[:-1]) 
	return new_f 	
	
if len(sys.argv)!=7: 
	usage()
	exit() 		
	
print("# Intersect "+sys.argv[1]+" and "+sys.argv[2]) 	

s1=create_set(sys.argv[1]) 
s2=create_set(sys.argv[2])
common=s1.intersection(s2)
just1=s1.difference(s2)
just2=s2.difference(s1)

out=sys.argv[3]+"/"+sys.argv[4] 
o_common=out+".common.txt" 
o_just1=out+"."+sys.argv[5]+".specific.txt"
o_just2=out+"."+sys.argv[6]+".specific.txt" 

write_file(o_common,common)  
write_file(o_just1,just1) 
write_file(o_just2,just2) 
