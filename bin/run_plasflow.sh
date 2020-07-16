set -e 

function usage(){
	echo 'usage : run_plasflow.sh <list of assemblies names> <contig fasta file 1> <contig fasta file 2> <...> [options]    
	[options] : 
	-o outdir (default : results/plasflow)   
	--thres thresold for plasflow classification (default 0.7) 
	--min_contigs : min contigs size to be classified (default:1000)
	' 
}

TEMP=$(getopt -o o:,h -l thres:,min_contigs: -- "$@")
eval set -- "$TEMP" 

outdir=results/plasflow 
thres=0.7
min_contigs=1000


while true ; do 
	case "$1" in 
		-h) 
			usage
			shift ;;
		-o) 
			outdir=$2
			shift 2;;	
		--thres) 
			thres=$2
			shift 2;;	
		--min_contigs) 
			min_contigs=$2
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

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
BIN=$tool_dir/bin

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
	echo $contigs 
	name=${arr_assemblies_names[$i]} 
	echo $name 
	outfile=$outdir/$name.plasflow$thres
	echo "== plasflow $name"
	PlasFlow.py --input $contigs --output $outfile --thres $thres --models $BIN/PlasFlow_models
	mv $outfile\_plasmids.fasta $outfile.plasmids.fasta 
	mv $outfile\_chromosomes.fasta $outfile.chromosomes.fasta
	mv $outfile\_unclassified.fasta $outfile.unclassified.fasta  
	grep "^>" $outfile.plasmids.fasta | cut -f 1 -d " " | cut -f 2 -d ">" > $outfile.plasmids.id 
	grep "^>" $outfile.chromosomes.fasta | cut -f 1 -d " " | cut -f 2 -d ">" > $outfile.chromosomes.id 
	grep "^>" $outfile.unclassified.fasta | cut -f 1 -d " " | cut -f 2 -d ">" > $outfile.unclassified.id
done 	

bash $BIN/taxo_plasflow.sh $outfile.plasmids.fasta $outfile.chromosomes.fasta $outfile.unclassified.fasta $outdir $name.plasflow$thres 
