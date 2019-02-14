set -e 

function usage(){ 
	echo "usage : bash draw_circular.sh <circular fasta> <circular gff> <outfile>" 		
}	

if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin

assembly=$1
gff=$2
outfile=$3

tmp=$(mktemp -d -p .) 

python3 $BIN/sequences_length.py $assembly $assembly.length 

tail -n +2 $assembly.length | awk '{print $1"\t"$2-1000"\t"$3}' | sort -k 2 -n > $assembly.reallength 

python3 $BIN/format_genoplot_circular.py $gff $assembly.reallength $tmp 

grep -w -f $tmp/contigs.txt $assembly.reallength | cut -f 1 > $tmp/contigs2.txt 
mv $tmp/contigs2.txt $tmp/contigs.txt 

curdir=$(pwd) 

cd $tmp

Rscript --vanilla $BIN/draw_circular.R contigs.txt circular_contigs.pdf > R.log

cd $curdir 

mv $tmp/circular_contigs.pdf $outfile

rm -r $tmp 
