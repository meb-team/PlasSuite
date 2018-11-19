set -e 

function usage(){ 
	echo "bash eliminate_chrm.sh -q <query.fasta> -s <subject.fasta> -o <outdir> 
	Options : 
	--prefix <prefix> : prefix for results files, default : name of the fasta assembly
	--force : overwrite results if already exists"
}

function treat_args(){
	if [[ ! $query ]];then
		quit=1
		echo "You must give fasta query. Use -q option"
	fi		
	if [[ ! $subject ]]; then 
		quit=1
		echo "You must give fasta subject. Use -s option" 
	fi
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi

	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $query "[minimap] Query file doesn't found in $query" "[minimap] Query file found in $query"
	verif_file $subject  "[minimap] Subject file doesn't found in $subject" "[minimap] Subject file found in $subject"
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi
	if [[ ! $cov ]]; then 
		cov=0.8
	fi	
}

TEMP=$(getopt -o h,q:,o:,s: -l prefix:,force,cov:  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-q)
			query=$2
			shift 2;; 
		-o)
			outdir=$2
			shift 2;; 
		-s) 
			subject=$2
			shift 2;; 
		--prefix)
			prefix=$2 
			shift 2;; 
		--force) 
			FORCE=1
			shift;; 	
		--cov)
			cov=$2
			shift 2;;	
		-h) 
			usage 
			shift ;;
		--)  
			shift ; break ;; 					
	esac 
done	

BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev) 

source $BIN/common_functions.sh 

treat_args
verif_args

echo "[minimap] Coverage : $cov" 
out=$outdir/$prefix
verif_result $out.paf 
if [[ $file_exist == 1 ]]; then 
	echo "Chromosomes search results already exists. Use --force to overwrite" 
else 
	echo "[minimap] Count subject sequences..." 
	nb_seq=$(grep "^>" -c $subject) 
	echo "[minimap] Run minimap2..." 
	source activate plasmidome 
	minimap2 -x asm5 -N $nb_seq $subject $query 1> $out.paf
	source deactivate plasmidome
	echo "[minimap2] Treat minimap2..." 
	awk '{if ($10/$2 >= '$cov') print}' $out.paf > $out.$cov.paf 
	cut -f 1 $out.$cov.paf | sort -u > $out.$cov.id
	rm $out.paf
fi	


