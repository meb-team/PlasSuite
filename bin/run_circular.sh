set -e 

function usage(){ 
	echo "usage : bash run_circular.sh <input fasta> <output prefix>" 
}

if [[ "$#" -ne 2 ]]; then 
	usage
	exit 1 
fi 

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then
        tool_dir="."
elif [[ $tool_dir == $0 ]]; then
        tool_dir=".."
fi
BIN=$tool_dir/bin


tmp=`mktemp -d -p .`
echo $tmp
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' $1 > $tmp/oneline.fasta
$BIN/circular_detection.pl -f $tmp/oneline.fasta -k 100 --only_circular > $2.fasta
grep "^>" $2.fasta | cut -f 1 -d " " | tr -d ">" > $2.id  
#rm -r $tmp 
