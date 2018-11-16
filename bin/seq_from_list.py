from Bio import SeqIO 
import argparse 

def args_gestion(): 
	parser = argparse.ArgumentParser()
	parser.add_argument("--input_fasta", help="Input fasta file where seq to keep are present")
	parser.add_argument("--keep", help="File with only id of seq to keep")
	parser.add_argument("--output_fasta",help="Output fasta file with seq to keep")
	parser.add_argument('--silva', help='search in silva fasta database (True or False, default : false)',default="False")
	args = parser.parse_args()
	if(args.input_fasta==None): 
		print("You must give --input_fasta") 
		exit() 
	if(args.keep==None): 
		print("You must give --keep") 
		exit()
	if(args.output_fasta==None): 
		print("You must give --output_fasta") 
		exit() 		 
	if (args.silva != "True" and args.silva != "False"): 
		print("--silva is True or False") 
		exit() 	
	return args.input_fasta,args.keep,args.output_fasta,args.silva	
	
	
	
def give_list_id(f):  
	f=open(f,"r") 
	list_id=set()
	for l in f : 
		list_id.add(l.rstrip()) 
	f.close() 
	return list_id	
		
	
def research_silva(inp,output,list_id): 
	for record in SeqIO.parse(inp,"fasta"):
		id=record.id.split(".")[0] 
		if id in list_id:
			SeqIO.write(record,output,"fasta")  
	
def research_classic(inp,output,list_id):  
	for record in SeqIO.parse(inp,"fasta"):  
		#print(record.id) 
		if record.id in list_id:
			SeqIO.write(record,output,"fasta")  			
	
	
inp,keep,out,silva=args_gestion() 	
	 	
list_id=give_list_id(keep)	
output=open(out,"w") 
	
if silva=="True": 
	research_silva(inp,output,list_id) 
else : 
	research_classic(inp,output,list_id) 

output.close() 
	
