set -e 

function usage(){ 
	echo "bash run_rna_search.sh -f <assembly.fasta> -o <outdir> -d <RNA database.fasta>
	Options : 
	--prefix <prefix> : prefix for results files, default : name of the fasta assembly
	--force : overwrite results if already exists" 
	 
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
	if [[ ! $rna_db ]]; then 
		quit=1
		echo "You must give rRNA database. Use -d option" 
	fi
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $assembly "[rna_search] Assembly file doesn't found in $assembly" "[rna_search] Assembly file found in $assembly"
	verif_file $rna_db 	"[rna_search] RNA database doesn't found in $rna_db" "[rna_search] RNA database found in $rna_db"
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi
}	

function treat_blast_rna(){
	blast=$1
	awk -F "\t" '{if ($3 >= 97 && $4 >= 300) print}' $blast.tsv > $blast.id97.length300.tsv
	awk -F "\t" '{if ($4 >= 1200 && $15 >= 80) print}' $blast.id97.length300.tsv > $blast.id97.length1200.cov80.tsv
	awk -F "\t" '{if (($7 == 1 || $7 == $14 || $8 == 1 || $8 == $14) && ($9 == 1 || $9 == $16 || $10 == 1 || $10 == $16)) print}' $blast.id97.length300.tsv > $blast.id97.length300.ends.tsv
	cut -f 2 $blast.id97.length1200.cov80.tsv | sort -u > $blast.id97.length1200.cov80.contigs.id 
	cut -f 2 $blast.id97.length300.ends.tsv | sort -u > $blast.id97.length300.ends.contigs.id
	cat $blast.id97.length1200.cov80.contigs.id $blast.id97.length300.ends.contigs.id | sort -u > $blast.all.contigs.id
	cat $blast.id97.length1200.cov80.tsv $blast.id97.length300.ends.tsv > $blast.all.contigs.tsv
	rm $blast.id97.length1200.cov80.tsv $blast.id97.length300.ends.tsv $blast.id97.length1200.cov80.contigs.id $blast.id97.length300.ends.contigs.id $blast.id97.length300.tsv $blast.tsv
}	

TEMP=$(getopt -o h,f:,o:,d: -l prefix:,force  -- "$@")
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
			rna_db=$2
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

mkdir -p $outdir

out=$outdir/$prefix.rna
verif_result $out.blast.tsv 
if [[ $file_exist == 1 ]]; then 
	echo "[rna_search] Blast results already exists. Use --force to overwrite it." 
else 
	verif_blast_db $assembly nucl "[rna_search] Make blast db for $assembly" "[rna_search] Blast db already exists for $assembly" 
	bash $BIN/parallelize_blast.sh $rna_db $assembly $out.blast.tsv 32 blastn
	echo "[rna_search] Treat Blast..." 
	treat_blast_rna $out.blast 
fi 




