set -e 

function usage(){ 
	echo "usage : bash run_circular.sh <input fasta> <output prefix>" 
}

if [[ "$#" -ne 2 ]]; then 
	usage
	exit 1 
fi 

tmp=`mktemp -d -p .`
BIN=/databis/hilpert/plasmidome_project/bin
BIN2=/databis/hilpert/plasmidome_realdata2/bin


awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' $1 > $tmp/oneline.fasta
/data/chochart/lib/circular_detection/bin/circular_detection.pl -f $tmp/oneline.fasta -k 100 --only_circular > $2.fasta
grep "^>" $2.fasta | cut -f 1 -d " " | tr -d ">" > $2.id  
rm -r $tmp 
