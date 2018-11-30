set -e 

function usage(){
	echo "usage : bash resistances_abundance.sh -i <INPUT> -o <outdir> 
	Required : 
	<INPUT> : tsv file with sample prefix
	Options :   
	--resfams_metadata <tsv> : Resfams metadata to categorize resistances. (default : plasmidome_databases/Resfams/Resfams.info)
	--annot_dir <dir> : Directory where annotation results are stored (default : resultsPlasAnnot)
	--reads_dir <dir> : Directory where cleaned reads are stored (default : resultsPreAssembl/cleaned_reads)  
	--force : overwrite results"  
}

function treat_args(){
	if [[ ! $i ]];then
		quit=1
		echo "You must give input file. Use -i option"
	fi	
	if [[ ! $outdir ]];then
		quit=1
		echo "You must give output directory. Use -o option"
	fi	
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $i "[PlasResist] $i doesn't found" "[PlasResist] $i found"
	mkdir -p $outdir 
	if [[ ! $resfams_info ]]; then 
		resfams_info=plasmidome_databases/Resfams/Resfams.info 
	fi
	if [[ ! $annot_dir ]]; then 
		annot_dir=resultsPlasAnnot
	fi 
	if [[ ! $reads_dir ]]; then 
		reads_dir=resultsPreAssembl/cleaned_reads
	fi
	verif_file $resfams_info "[PlasResist] Resfams metadata doesn't found in $resfams_info" "[PlasResist] Resfams metadata found in $resfams_info"
	verif_dir $annot_dir "[PlasResist] $annot_dir doesn't exists. Give an other with --annot_dir." "[PlasResist] $annot_dir found" 
	verif_dir $reads_dir "[PlasResist] $reads_dir doesn't exists. Give an other with --reads_dir" "[PlasResist] $reads_dir found"
}

function define_paths(){
	all_resistances=$outdir/all_predicted_resistances 
	clust_resistances=$outdir/all_predicted_resistances.clust
}	

function extract_resistances(){
	all_ffn=""
	all_res=""
	for prefix in $(cat $i); do 
		resistances=$annot_dir/$prefix.predicted_plasmids.resistances
		gff=$annot_dir/$prefix.predicted_plasmids.gff
		ffn=$annot_dir/$prefix.predicted_plasmids.ffn 
		python3 $BIN/seq_from_list.py --input_fasta $ffn --output_fasta $ffn.resistances --keep $resistances.id 
		all_ffn=$all_ffn" "$ffn.resistances
		all_res=$all_res" "$resistances
	done 
	cat $all_ffn > $all_resistances.ffn
	bash $BIN/combined_files.sh $all_res > $all_resistances.tsv 
}	

function treat_matrix(){
	head -n 1 $all_resistances.tsv | cut -f 2-
	for ref in $(tail -n +2 $1 | cut -f 1); do 
		grep -w $ref $all_resistances.tsv | cut -f 2- 
	done 
}	 

TEMP=$(getopt -o h,i:,o: -l resfams_metadata:,force,annot_dir:,reads_dir: -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-i) 
			i=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		--force)
			FORCE=1
			shift ;; 
		--resfams_metadata) 
			resfams_info=$2
			shift 2;;
		--annot_dir)
			annot_dir=$2
			shift 2;;
		--reads_dir) 	
			reads_dir=$2
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
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin
source $BIN/common_functions.sh

treat_args 
verif_args 
define_paths 

echo "# EXTRACT RESISTANCES" 
verif_result $all_resistances.ffn 
if [[ $file_exist == 1 ]]; then 
	echo "Extract resistances have already been done. Use --force to overwrite" 
else	
	extract_resistances 
fi		

echo "# CLUSTER RESISTANCES" 
verif_result $clust_resistances.ffn 
if [[ $file_exist == 1 ]]; then 
	echo "Resistances are already clustered. Use --force to overwrite" 
else 
	cd-hit-est -i $all_resistances.ffn -o $clust_resistances.ffn -g 1 -T 6 -M 20000 -d 0 -c 0.95 -aS 0.90
fi 

echo "# REALIGN READS TO RESISTANCES" 
dir=$outdir/mapping 
mkdir -p $dir 
for prefix in $(ls $reads_dir); do 
	echo $dir/$prefix.sorted.markdup.sorted.bam 
	if [[ ! -f $dir/$prefix.sorted.markdup.sorted.bam ]];then
		all_align=1 
	fi   
done 
if [[ $all_align || $FORCE ]]; then 
	/data/chochart/lib/MAPme/bin/MAPme -s $all_resistances.ffn --reads $reads_dir -o $dir --remove_duplicates -t 16
	rm $dir/*.sam	
else
	echo "Reads realignments already exists. Use --force to overwrite"
fi 

echo "# ABUNDANCE MATRIX" 
ab_dir=$outdir/abundance_matrix
mkdir -p $ab_dir 
matrix=$ab_dir/resistance_matrix
verif_result $matrix.matrix 
if [[ $file_exist == 1 ]];then 
	echo "Abundance matrix already exists. Use --force to overwrite" 
else 
	for prefix in $(cat $i); do
		read_prefix=$(echo $prefix | cut -f 1 -d ".") 
		cur_read_dir=$reads_dir/$read_prefix
		cumul_length=0
		for file in $(ls $cur_read_dir); do 
			length=$(zcat $cur_read_dir/$file | paste - - - - | cut -f 2 | wc -c )
			cumul_length=$(($cumul_length+length)) 		 
		done 
		echo -e "$dir/$read_prefix.sorted.bam,$cumul_length"  
	done > $ab_dir/mama_input.txt 
	/data/chochart/lib/MAMa/bin/MAMa.py -a $matrix.matrix -r $matrix.relative.matrix -n $matrix.normalized.matrix $all_resistances.ffn.fai $ab_dir/mama_input.txt  
fi

echo "# TREAT MATRIX" 

treat_matrix $matrix.matrix > $matrix.matrix.desc 
paste $matrix.matrix $matrix.matrix.desc > $matrix.matrix.detailed 

treat_matrix $matrix.normalized.matrix > $matrix.normalized.matrix.desc  
paste $matrix.normalized.matrix $matrix.normalized.matrix.desc > $matrix.normalized.matrix.detailed 

treat_matrix $matrix.relative.matrix > $matrix.relative.matrix.desc 
paste $matrix.relative.matrix $matrix.relative.matrix.desc > $matrix.relative.matrix.detailed 

rm $matrix.*.desc 

exit 

echo "# TREAT MATRIX" 
desc=$(grep "$(tail -n +2 $matrix.normalized.matrix | cut -f 1 $matrix.normalized.matrix)" $all_resistances.desc | cut -f 5)

set +e
res_present=$(head -n 1 $matrix.matrix | grep "resistance_description") 
set -e

if [[ $res_present == "" ]]; then 
	echo "resistance_description" > $matrix.desc 
	echo "$desc" >> $matrix.desc 
	paste $matrix.matrix $matrix.desc > $matrix.matrix2
	mv $matrix.matrix2 $matrix.matrix 
	paste $matrix.relative.matrix $matrix.desc > $matrix.matrix2
	mv $matrix.matrix2 $matrix.relative.matrix 
	paste $matrix.normalized.matrix $matrix.desc > $matrix.matrix2
	mv $matrix.matrix2 $matrix.normalized.matrix 
fi

python3 $BIN/sum_resistance_matrix.py $matrix.matrix > $matrix.desc_matrix
python3 $BIN/sum_resistance_matrix.py $matrix.normalized.matrix > $matrix.normalized.desc_matrix
python3 $BIN/sum_resistance_matrix.py $matrix.relative.matrix > $matrix.relative.desc_matrix






