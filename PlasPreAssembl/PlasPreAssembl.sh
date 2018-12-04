set -e 

function usage(){
	echo 'usage : PlasPreAssembl.sh -r <reads directory> -o <outdir> -p <out prefix>
	[OPTIONS]
	-h : print help
	--force : overwrite results'
}

function treat_args(){
	if [[ ! $reads_dir ]];then
		quit=1
		echo "You must give reads directory. Use -r option"
	fi		
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi
	if [[ ! $prefix ]]; then 
		quit=1
		echo "You must give output prefix. Use -p option" 
	fi
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_dir $reads_dir "[PlasPreAssembl] Reads directory doesn't found in $reads_dir" "[PlasPreAssembl] Reads directory found in $reads_dir"
	mkdir -p $outdir 
}

function run_fastqc(){
	dir=$1 
	input_reads=$2
	echo $input_reads
	mkdir -p $dir 
	fastqc -o $dir -t 6 $input_reads
	
}		

function run_cleaning(){
	mkdir $1 
	dir=$1/$prefix
	mkdir -p $dir 
	input_reads=$2 
	cp $input_reads $dir/ 	
	r1="$(ls $dir/*_1.fastq.gz)" 
	gunzip $r1  
	r1="$(ls $dir/*_1.fastq)" 
	cat $r1 > $dir/$prefix.R1.fastq 
	rm $r1 
	r2="$(ls $dir/*_2.fastq.gz)" 
	gunzip $r2 
	r2="$(ls $dir/*_2.fastq)" 
	cat $r2 > $dir/$prefix.R2.fastq 
	rm $r2 
	bash $BIN/run_trimmomatic.sh $dir/$prefix.R1.fastq $dir/$prefix.R2.fastq $dir $prefix
	rm $dir/$prefix.R1.fastq $dir/$prefix.R2.fastq
}	

TEMP=$(getopt -o h,r:,o:,p: -l force  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-r) 
			reads_dir=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		-p) 
			prefix=$2 
			shift 2;; 
		--force)
			FORCE=1
			shift ;; 
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

tmp=$(mktemp -d -p .) 


echo "# FASTQC" 
run_fastqc $outdir/fastqc "$(ls $reads_dir/*.gz)" 

echo "# CLEANING" 
run_cleaning $outdir/cleaned_reads "$(ls $reads_dir/*.gz)" 

echo "# NON PAREIL" 
dir=$outdir/nonpareil
mkdir -p $dir
bash $BIN/run_nonpareil.sh $outdir/cleaned_reads/$prefix/$prefix\_R1_trimmed_pe.fastq $dir $prefix

rm -r $tmp 



