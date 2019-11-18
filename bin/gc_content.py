import sys 
from Bio import SeqIO
from Bio.SeqUtils import GC

def usage():
    print("usage : python gc_content.py <fasta file>")

if len(sys.argv) != 2: 
    usage()
    exit()

print("#Id\t%GC")
for record in SeqIO.parse(sys.argv[1], "fasta"):
    print(record.id + "\t" + str(GC(record.seq)))