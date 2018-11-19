set -e 

function usage(){ 
	echo "bash search_plasmids_markers.sh -f <assembly.fasta> -o <outdir> -d <Plasmids markers database directory> -p <predicted proteins>
	Options : 
	--prefix <prefix> : prefix for results files, default : name of the fasta assembly
	--force : overwrite results if already exists
	
	In the directory given by -d, mob database must be called mob.proteins.faa, mpf database mpf.proteins.faa, rep database rep.dna.fas and oriT database orit.fas"
	
}

function treat_args(){
	if [[ ! $assembly ]];then
		quit=1
		echo "You must give fasta assembly. Use -f option"
	fi		
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi
	if [[ ! $db ]]; then 
		quit=1
		echo "You must give plasmids markers databases directory. Use -d option" 
	fi
	if [[ ! $predicted_proteins ]]; then 
		quit=1
		echo "You must give predict proteins file. Use -p option" 
	fi
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $assembly "[plasmids_markers] Assembly file doesn't found in $assembly" "[plasmids_markers] Assembly file found in $assembly"
	verif_file $db/mob.proteins.faa "[plasmids_markers] Mob database doesn't found in $db/mob.proteins.faa" "[plasmids_markers] Mob database found in $db/mob.proteins.faa"
	verif_file $db/mpf.proteins.faa "[plasmids_markers] Mpf database doesn't found in $db/mpf.proteins.faa" "[plasmids_markers] Mpf database found in $db/mpf.proteins.faa"
	verif_file $db/rep.dna.fas "[plasmids_markers] Rep database doesn't found in $db/rep.dna.fas" "[plasmids_markers] Mpf database found in $db/rep.dna.fas"
	verif_file $db/orit.fas "[plasmids_markers] OriT database doesn't found in $db/orit.fas" "[plasmids_markers] OriT database found in $db/orit.fas"
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi
}	

function run_proteins_prediction(){
	mkdir -p $outdir/protein_prediction 
	out=$outdir/protein_prediction/$prefix.predicted_proteins
	echo "[protein_prediction] Use $assembly" 
	echo "[protein_prediction] Run Prodigal..."
	prodigal -i $assembly -c -m -p meta -f gff -a $out.faa -o $out.gff -q
	predicted_proteins=$out.faa
}	

function treat_blast(){
	echo "TREAT" 
	blast=$1
	id=$2
	cov=$3
	type=$4
	awk '{if ($13 >= '$id' && $15 >= '$cov') print}' $blast.tsv > $blast.conserve.tsv
	if [[ $type == "raw" ]]; then 
		cut -f 2 $blast.conserve.tsv | sort -u > $blast.conserve.contigs.id
		cut -f 1 $blast.conserve.tsv | sort -u > $blast.conserve.searched.id 
	elif [[ $type == "predicted" ]]; then 
		cut -f 1 $blast.conserve.tsv | sort -u > $blast.conserve.predicted_proteins.id 
		cut -f 2 $blast.conserve.tsv | sort -u > $blast.conserve.searched.id 
		cat $blast.conserve.predicted_proteins.id | rev | cut -f 2- -d "_" | rev > $blast.conserve.contigs.id 
	fi   
}		

TEMP=$(getopt -o h,f:,o:,d:,p: -l prefix:,force  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-f)
			assembly=$2
			shift 2;; 
		-o)
			outdir=$2
			shift 2;; 
		-d) 
			db=$2
			shift 2;; 
		-p)
			predicted_proteins=$2
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

BIN=/databis/hilpert/plasmidome_project/bin
BIN2=/databis/hilpert/plasmidome_realdata2/bin

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
	echo "[plasmids_markers] Use $assembly" 
	verif_blast_db $assembly nucl "[plasmids_markers] Make blast db for $assembly..." "[plasmids_markers] Blast db found for $assembly"
	echo "[plasmids_markers] Run Blast..." 
	bash $BIN2/parallelize_blast.sh $db/rep.dna.fas $assembly $out.tsv 32 blastn
	echo "[plasmids_markers] Treat Blast..."
	treat_blast $out 80 80 raw
fi

echo "# Search oriT DNA"
out=$outdir/$prefix.orit.blast
verif_result $out.tsv 
if [[ $file_exist == 1 ]]; then 
	echo "[plasmids_markers] Searching oriT DNA results already exists. Use --force to overwrite it" 
else 
	echo "[plasmids_markers] Use $assembly" 
	verif_blast_db $assembly nucl "[plasmids_markers] Make blast db for $assembly..." "[plasmids_markers] Blast db found for $assembly"
	echo "[plasmids_markers] Run Blast..." 
	bash $BIN2/parallelize_blast.sh $db/orit.fas $assembly $out.tsv 32 blastn
	echo "[plasmids_markers] Treat Blast..."
	treat_blast $out 90 90 raw
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
	bash $BIN2/parallelize_blast.sh $predicted_proteins $db/mob.proteins.faa $out.tsv 32 blastp
	echo "[plasmids_markers] Treat Blast..."
	treat_blast $out 80 80 predicted
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
	bash $BIN2/parallelize_blast.sh $predicted_proteins $db/mpf.proteins.faa $out.tsv 32 blastp
	echo "[plasmids_markers] Treat Blast..."
	treat_blast $out 80 80 predicted
fi

cat $outdir/*.contigs.id | sort -u > $outdir/$prefix.all_markers.contigs.id
python3 $BIN/delete_seq_from_file.py $assembly $outdir/$prefix.all_markers.contigs.id $outdir/$prefix.nomarkers.fasta normal
