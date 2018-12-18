set -e 

function usage(){
	echo 'usage : run_cbar.sh <list of assemblies names> <contig fasta file 1> <contig fasta file 2> <...> [options]    
	[options] : 
	-o outdir (default : results/cbar)   
	--tmp tmp dir (default : tmp) 
	' 
}

TEMP=$(getopt -o o:,h -l tmp: -- "$@")
eval set -- "$TEMP" 

outdir=results/cbar 
tmp_dir=`mktemp -d -p .` 

while true ; do 
	case "$1" in 
		-h) 
			usage
			shift ;;
		-o) 
			outdir=$2
			shift 2;;	
		--tmp) 
			tmp_dir=$2
			shift 2;; 
		--)  
			shift ; break ;; 					
	esac 
done 	

if [ "$#" -eq 0 ]
then 
	usage
	echo 'give list of assemblies'  
	exit 1 
elif [ "$#" -eq 1 ]
then 
	usage 
	echo 'give contigs fasta files' 	
	exit 1 
fi 

mkdir -p $outdir 

assemblies_format=$(echo $1 | tr "," " ")  
shift

assemblies_contigs="" 

while [[ $@ ]]; do 
	assemblies_contigs=$assemblies_contigs" "$1 
	shift 
done 

arr_assemblies_names=($assemblies_format) 
arr_assemblies_contigs=($assemblies_contigs) 	

len=$((${#arr_assemblies_names[@]}-1)) 

for i in `seq 0 $len` ; do 
	contigs=${arr_assemblies_contigs[$i]}
	name=${arr_assemblies_names[$i]}
	echo "== cbar $name"
	cbar_pred=$outdir/$name.cbar.prediction.txt
	~/cBar.1.2/cBar.pl $contigs $cbar_pred 
done 	

rm -r $tmp_dir 
