set -e 

function usage(){ 
	echo "usage : bash taxo_plasflow.sh <plasflow_plasmids.fasta> <plasflow_chromosomes.fasta> <plasflow_unclassified.fasta> <outdir> <outprefix>" 
}	

if [[ $# -ne 5 ]]; then 
	usage 
	exit 1 
fi 

plasmids=$1
chrm=$2
unclassif=$3
mkdir -p $4 
out=$4/$5

tmp=$(mktemp -d -p .) 

grep "^>" $plasmids | cut -f 1 -d " " | tr -d ">" > $tmp/plasmids.id 
grep "^>" $plasmids | cut -f 2 -d " " | cut -f 2 -d "." > $out.plasmids.taxo
paste $tmp/plasmids.id $out.plasmids.taxo > $tmp/taxo1 

grep "^>" $chrm | cut -f 1 -d " " | tr -d ">" > $tmp/chrm.id 
grep "^>" $chrm | cut -f 2 -d " " | cut -f 2 -d "." > $out.chrm.taxo
paste $tmp/chrm.id $out.chrm.taxo > $tmp/taxo2

grep "^>" $unclassif | cut -f 1 -d " " | tr -d ">" > $tmp/unclassif.id 
grep "^>" $unclassif | cut -f 2 -d " " | cut -f 2 -d "." > $out.unclassified.taxo 
paste $tmp/unclassif.id $out.unclassified.taxo > $tmp/taxo3

cat $tmp/taxo1 $tmp/taxo2 $tmp/taxo3 > $out.taxo 

rm -r $tmp 
