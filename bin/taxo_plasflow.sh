set -e 

function usage(){ 
	echo "usage : bash taxo_plasflow.sh <plasflow_plasmids.fasta> <plasflow_chromosomes.fasta> <plasflow_unclassified.fasta> <outfile.tsv>" 
}	

if [[ $# -ne 4 ]]; then 
	usage 
	exit 1 
fi 

plasmids=$1
chrm=$2
unclassif=$3
out=$4

tmp=$(mktemp -d -p .) 

grep "^>" $plasmids | cut -f 1 -d " " | tr -d ">" > $tmp/plasmids.id 
grep "^>" $plasmids | cut -f 2 -d " " | cut -f 2 -d "." > $tmp/plasmids.taxo 
paste $tmp/plasmids.id $tmp/plasmids.taxo > $tmp/taxo1 

grep "^>" $chrm | cut -f 1 -d " " | tr -d ">" > $tmp/chrm.id 
grep "^>" $chrm | cut -f 2 -d " " | cut -f 2 -d "." > $tmp/chrm.taxo 
paste $tmp/chrm.id $tmp/chrm.taxo > $tmp/taxo2


grep "^>" $unclassif | cut -f 1 -d " " | tr -d ">" > $tmp/unclassif.id 
grep "^>" $unclassif | cut -f 2 -d " " | cut -f 2 -d "." > $tmp/unclassif.taxo 
paste $tmp/unclassif.id $tmp/unclassif.taxo > $tmp/taxo3

cat $tmp/taxo1 $tmp/taxo2 $tmp/taxo3 > $out 

rm -r $tmp 
