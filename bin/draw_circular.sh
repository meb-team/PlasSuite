set -e 

function usage(){ 
	echo "usage : bash draw_circular.sh <circular fasta> <circular gff> <outfile>" 		
}	

if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 

BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev) 
BIN=$(readlink -f $BIN) 
assembly=$1
gff=$2
outfile=$3

tmp=$(mktemp -d -p .) 
echo $tmp 

python3 $BIN/sequences_length.py $assembly $assembly.length 

tail -n +2 $assembly.length | awk '{print $1"\t"$2-1000"\t"$3}' | sort -k 2 -n > $assembly.reallength 

python3 $BIN/format_genoplot_circular.py $gff $assembly.reallength $tmp 

grep -w -f $tmp/contigs.txt $assembly.reallength | cut -f 1 > $tmp/contigs2.txt 
mv $tmp/contigs2.txt $tmp/contigs.txt 

curdir=$(pwd)
outfile=$curdir/$outfile  

cd $tmp

Rscript --vanilla $BIN/draw_circular.R contigs.txt $outfile 

cd $curdir 

rm -r $tmp 
