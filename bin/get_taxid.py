import sys 
from ete3 import NCBITaxa

def usage():
    print("usage : python get_taxid.py <org file>")
    print("<org file> is tsv file with organism name in first column and reference in second colum")

if len(sys.argv) != 2: 
    usage()
    exit()

ncbi = NCBITaxa()

with open(sys.argv[1]) as f:
    for l in f:
        name = l.split("\t")[0]
        ref = l.rstrip().split("\t")[1]
        taxid = ncbi.get_name_translator([name])
        if taxid:
            print(ref + "\t" + str(taxid[name][0]))
        else:
            sys.stderr.write(ref + " " + name + " not found\n") 