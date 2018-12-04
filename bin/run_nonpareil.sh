set -e 

function usage(){
	echo "usage : bash run_nonpareil.sh <reads1 corrected> <outdir> <prefix>"	
}	

if [[ $# -ne 3 ]]; then 
	usage
	exit 1 
fi 

r1=$1
mkdir -p $2
outprefix=$2/$3
tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
BIN=$tool_dir/bin

nonpareil -s $r1 -T kmer -f fastq -b $outprefix -t 6 -L 75

Rscript --vanilla $BIN/run_nonpareil.R $outprefix.npo $outprefix.nonPareil.pdf

