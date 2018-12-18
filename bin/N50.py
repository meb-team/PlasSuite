import sys 

def usage():
	print("usage : python3 N50.py <INPUT>") 
	print("<INPUT> : tsv files with one line per contig and contig length in third column") 

def list_from_file(f):
	f=open(f,"r") 
	l=[int(l.split("\t")[2]) for l in f] 
	f.close() 
	return l

def N50_calc(list_length): 
	half_sum=sum(list_length)/2 
	list_length.sort(reverse=True) 
	sum_i=0 
	for i in list_length: 
		sum_i+=i 	
		if half_sum <= sum_i : 
			return(i)  

if len(sys.argv)!=2: 
	usage()
	exit() 
	
list_length=list_from_file(sys.argv[1])
print(N50_calc(list_length))
