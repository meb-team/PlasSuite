import sys 

def usage():
	print("usage : python3 delete_id.py <initial file> <id to delete> <output file>")
	
def list_from_file(f): 
	f=open(f,"r") 
	s=set()
	for l in f: 
		s.add(l.rstrip()) 
	f.close() 	
	return s 	
	
def write_file(o,s): 
	o=open(o,"w")
	for id in s : 
		o.write(id+"\n") 
	o.close() 	
	
if len(sys.argv) != 4: 
	usage() 
	exit() 

s1=list_from_file(sys.argv[1])
s2=list_from_file(sys.argv[2]) 
s3=s1.difference(s2) 

write_file(sys.argv[3],s3)
