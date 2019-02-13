import sys 
import os

class CDS:
	def __init__(self,start,end,name,strand,col): 
		self.start=start
		self.end=end 
		self.name=name
		self.col=col 
		self.set_strand(strand) 
		
	def set_strand(self,strand): 
		if strand=="+":
			self.strand="1" 
		elif strand=="-":
			self.strand="-1" 	

def usage():
	print("usage : python3 format_genoplot.py <gff> <length file> <outdir>")

def set_dic_length(f):
	f=open(f,"r") 
	dic={}
	for l in f: 
		l_split=l.rstrip().split("\t") 
		dic[l_split[0]]=l_split[1]	
	f.close() 
	return dic 

def set_col(col,default_col,new_col):
	if col == default_col: 
		return new_col 	

if len(sys.argv)!=4:
	usage()
	exit() 
	
	
outdir=sys.argv[3] 
os.system("mkdir -p "+outdir) 
gff=open(sys.argv[1],"r") 
dic_length=set_dic_length(sys.argv[2]) 

dic_gff={}
for l in gff : 
	name=' '
	col="pink" 
	setCol=False
	l_split=l.rstrip().split("\t") 
	if len(l_split)==9:
		contig=l_split[0] 
		types=l_split[2]
		start=l_split[3]
		end=l_split[4]
		strand=l_split[6]
		if types != "repeat_region" and types != "CRISPR": 
			if types=="tRNA": 
				name="tRNA" 
				col="orange"
			elif types=="rRNA":
				name="rRNA" 
				col="red" 	 
			else:
				desc=l_split[8]
				if "Resfams" in desc or "ResFinder" in desc: 
					col="blue"
					if "gene=" in desc : 
						name=desc.split("gene=")[1].split(";")[0]
					else : 	
						try : 
							name="ARO:"+desc.split("[ARO:")[1].split(",")[0].rstrip("]")
						except : 
							name="Resfams:"+desc.split("Resfams:")[1].split(";")[0] 
				elif "mob_suite" in desc : 
					col="forestgreen" 
					if "gene=" in desc : 
						name=desc.split("gene=")[-1].split(";")[0]
					else: 
						name=desc.split("mob_suite:")[-1].split(":")[0]+"|"+desc.split("mob_suite:")[-1].split(":")[1].split("|")[-1].split(";")[0]	
				elif "gene=" in desc : 
					col="black" 	
					name=desc.split("gene=")[-1].split(";")[0]
				elif "UniProtKB" in desc : 
					uniprot_id=desc.split("UniProtKB:")[-1].split(";")[0]
					name="UniProtKB:"+uniprot_id
					col="purple" 	
				elif "ISfinder" in desc : 
					name=desc.split("ISfinder:")[-1].split(";")[0]
					col="magenta"  	
				elif "HAMAP" in desc : 
					hamap_id=desc.split("HAMAP:")[-1].split(";")[0]
					name="HAMAP:"+hamap_id
					col="brown"	
				elif "hypothetical protein" in desc : 
					col="grey" 			
				cds=CDS(start,end,name,strand,col)  
				if contig not in dic_gff : 
					dic_gff[contig]=[cds]
				else: 
					dic_gff[contig].append(cds) 			
		
				
for contig in dic_gff: 
	contig_name=contig 
	o=open(outdir+"/"+contig_name+".genoplot","w")
	contig=dic_gff[contig]		
	contig_length=dic_length[contig_name] 
	o.write("name\tstart\tend\tstrand\tcol\tgene_type\tfill\n") 
	o.write(contig_name+"\t0\t"+contig_length+"\t1\tblack\tlines\ttransparent\n") 	
	for c in contig: 
		o.write(c.name+"\t"+c.start+"\t"+c.end+"\t"+c.strand+"\t"+c.col+"\tarrows\t"+c.col+"\n") 
	o.close()
				
					
	
