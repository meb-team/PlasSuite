set -e 

function usage(){ 
	echo "bash search_plasmids_markers.sh -p <proteins.fasta> -o <outdir> -d <cds_dna.fasta> -g <prokka gff> --db <plasmids markers database directory>
	Options : 
	--prefix <prefix> : prefix for results files, default : name of the fasta assembly
	--force : overwrite results if already exists
	
	In the directory given by -d, mob database must be called mob.proteins.faa, mpf database mpf.proteins.faa, rep database rep.dna.fas and oriT database orit.fas"
	
}

function treat_args(){
	if [[ ! $proteins ]];then
		quit=1
		echo "You must give fasta proteins. Use -p option"
	fi		
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi
	if [[ ! $db ]]; then 
		quit=1
		echo "You must give plasmids markers databases directory. Use --db option" 
	fi
	if [[ ! $cds ]]; then 
		quit=1
		echo "You must give DNA CDS. Use -d option" 
	fi
	if [[ ! $prefix ]]; then 
		quit=1 
		echo "You must give prefix for results. Use --prefix option" 
	fi 
	if [[ ! $gff ]]; then
		quit=1
		echo "You must give prokka gff. Use -g option" 
	fi
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $proteins "[plasmids_markers] Proteins file doesn't found in $proteins" "[plasmids_markers] Proteins file found in $proteins"
	verif_file $cds "[plasmids_markers] CDS file doesn't found in $cds" "[plasmids_markers] CDS file found in $cds"
	verif_file $db/mob.proteins.faa "[plasmids_markers] Mob database doesn't found in $db/mob.proteins.faa" "[plasmids_markers] Mob database found in $db/mob.proteins.faa"
	verif_file $db/mpf.proteins.faa "[plasmids_markers] Mpf database doesn't found in $db/mpf.proteins.faa" "[plasmids_markers] Mpf database found in $db/mpf.proteins.faa"
	verif_file $db/rep.dna.fas "[plasmids_markers] Rep database doesn't found in $db/rep.dna.fas" "[plasmids_markers] Mpf database found in $db/rep.dna.fas"
	verif_file $gff "[plasmids_markers] Prokka gff doesn't found in $gff" "[plasmids_markers] Prokka gff found in $gff"
	mkdir -p $outdir 
}	

function treat_blast(){
	blast=$1
	id=$2
	cov=$3
	awk '{if ($13 >= '$id' && $15 >= '$cov') print}' $blast.tsv > $blast.conserve.tsv
}		

TEMP=$(getopt -o h,p:,d:,o:,g: -l prefix:,force,db:  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-p)
			proteins=$2
			shift 2;; 
		-o)
			outdir=$2
			shift 2;; 
		-g)
			gff=$2
			shift 2;; 	
		--db) 
			db=$2
			shift 2;; 
		-d)
			cds=$2
			shift 2;; 	
		--prefix)
			prefix=$2 
			shift 2;; 
		--force) 
			FORCE=1
			shift;; 
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

echo "## SEARCH PLASMIDS MARKERS" 
echo "# Search rep DNA"
out=$outdir/$prefix.rep.blast
verif_result $out.tsv 
if [[ $file_exist == 1 ]]; then 
	echo "[plasmids_markers] Searching rep DNA results already exists. Use --force to overwrite it" 
else 
	current_db=$db/rep.dna.fas
	verif_blast_db $current_db nucl "[plasmids_markers] Make blast db for $current_db..." "[plasmids_markers] Blast db found for $current_db"
	echo "[plasmids_markers] Run Blast..." 
	bash $BIN/parallelize_blast.sh $cds $current_db $out.tsv 32 blastn
	echo "[plasmids_markers] Treat blast..." 
	treat_blast $out 80 80 raw
	echo "[plasmids_markers] Modif gff..."
	python3 $BIN/add_markers_to_prokka_results.py $out.conserve.tsv $gff $gff.2 rep_dna
	
fi

echo "Search MOB proteins..."
out=$outdir/$prefix.mob.blast
verif_result $out.tsv 
if [[ $file_exist == 1 ]]; then 
	echo "[plasmids_markers] Searching MOB proteins results already exists. Use --force to overwrite it" 
else 
	echo "[plasmids_markers] Use $predicted_proteins" 
	verif_blast_db $db/mob.proteins.faa prot "[plasmids_markers] Make blast db for $db/mob.proteins.faa..." "[plasmids_markers] Blast db found for $db/mob.proteins.faa"
	echo "[plasmids_markers] Run Blast..." 
	bash $BIN/parallelize_blast.sh $proteins $db/mob.proteins.faa $out.tsv 32 blastp
	echo "[plasmids_markers] Treat Blast..."
	treat_blast $out 80 80 predicted
	python3 $BIN/add_markers_to_prokka_results.py $out.conserve.tsv $gff.2 $gff.3 mob_prot
fi

echo "# Search MPF proteins..."
out=$outdir/$prefix.mpf.blast
verif_result $out.tsv 
if [[ $file_exist == 1 ]]; then 
	echo "[plasmids_markers] Searching mpf proteins results already exists. Use --force to overwrite it" 
else 
	echo "[plasmids_markers] Use $predicted_proteins" 
	verif_blast_db $db/mpf.proteins.faa prot "[plasmids_markers] Make blast db for $db/mpf.proteins.faa..." "[plasmids_markers] Blast db found for $db/mpf.proteins.faa"
	echo "[plasmids_markers] Run Blast..." 
	bash $BIN/parallelize_blast.sh $proteins $db/mpf.proteins.faa $out.tsv 32 blastp
	echo "[plasmids_markers] Treat Blast..."
	treat_blast $out 80 80 predicted
	python3 $BIN/add_markers_to_prokka_results.py $out.conserve.tsv $gff.3 $gff.4 mpf_prot
fi

mv $gff.4 $(echo $gff | rev | cut -f 2- -d "." | rev).markers.gff 
rm $gff.*
