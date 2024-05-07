set -e 

function usage(){ 
	echo "bash run_minimap.sh -q <query.fasta> -s <subject.fasta> -o <outdir>  --prefix <prefix>
	Options : 
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

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
BIN=$tool_dir/bin

source $BIN/common_functions.sh 

treat_args
verif_args

echo "[minimap] Coverage : $cov" 
out=$outdir/$prefix
verif_result $out.paf 
if [[ $file_exist == 1 ]]; then 
	echo "Chromosomes search results already exists. Use --force to overwrite" 
else 
	 
	if [ -e "$subject.ct" ]
	then
	nb_seq=$(cat $subject.ct)
	else
	echo "[minimap] Count subject sequences..."
	nb_seq=$(grep "^>" -c $subject) 
	fi
	
	echo "[minimap] Run minimap2..." 
	minimap2 -t 32 -x asm5 -N $nb_seq $subject $query 1> $out.paf
	echo "[minimap2] Treat minimap2..." 
	awk '{if ($10/$2 >= '$cov') print}' $out.paf > $out.$cov.paf 
	cut -f 1 $out.$cov.paf | sort -u > $out.$cov.id
	rm $out.paf
fi	


