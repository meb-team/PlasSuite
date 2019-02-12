set -e 
set -e 

function usage(){
	echo "usage : bash resistances_abundance.sh -i <INPUT> -o <outdir> 
	Required : 
	<INPUT> : tsv file with sample prefix
	Options :   
	--resfams_metadata <tsv> : Resfams metadata to categorize resistances. (default : plasmidome_databases/Resfams/Resfams.info)
	--annot_dir <dir> : Directory where annotation results are stored (default : resultsPlasAnnot)
	--reads_dir <dir> : Directory where cleaned reads are stored (default : resultsPreAssembl/cleaned_reads)  
	--cluster_id <int[0:1]> : Identity percentage for cd-hit clustering (default : 0.95) 
	--force : overwrite results
	--all_db <dir> : path to directory with plasmidome databases"  
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
	if [[ ! $all_db ]]; then 
		all_db=$HOME/plasmidome_databases
	fi
	if [[ ! $resfams_info ]]; then 
		resfams_info=$all_db/Resfams/Resfams.info 
	fi
	if [[ ! $annot_dir ]]; then 
		annot_dir=resultsPlasAnnot
	fi 
	if [[ ! $reads_dir ]]; then 
		reads_dir=resultsPreAssembl/cleaned_reads
	fi
	if [[ ! $cluster_id ]]; then 
		cluster_id=0.95 
	fi
	verif_file $resfams_info "[PlasResist] Resfams metadata doesn't found in $resfams_info" "[PlasResist] Resfams metadata found in $resfams_info"
	verif_dir $annot_dir "[PlasResist] $annot_dir doesn't exists. Give an other with --annot_dir." "[PlasResist] $annot_dir found" 
	verif_dir $reads_dir "[PlasResist] $reads_dir doesn't exists. Give an other with --reads_dir" "[PlasResist] $reads_dir found"
}

function define_paths(){
	all_prot=$outdir/all_prot.ffn 
	clust_prot=$outdir/all_prot.$(echo $cluster_id | awk '{print $1*100}')
	all_resistances=$outdir/all_resistances
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

TEMP=$(getopt -o h,i:,o: -l resfams_metadata:,force,annot_dir:,reads_dir:,cluster_id:,all_db: -- "$@")
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
		--cluster_id) 
			cluster_id=$2
			shift 2;; 
		--all_db)
			all_db=$2
			shift 2;; 
		-h) 
			usage 
			exit 
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

echo "# CONCATENATE PREDICTED PROTEINS" 
verif_result $all_prot 
if [[ $file_exist == 1 ]]; then 
	echo "Predicted proteins are already concatenated. Use --force to overwrite"
else 
	rm -f $all_prot 
	cat_cmd=''
	for p in $(cat $i); do 
		cat_cmd=$(echo $cat_cmd $annot_dir/$p.predicted_plasmids.ffn)  
	done 	
	cat $cat_cmd > $all_prot 	
fi 

echo "# CLUSTER PREDICTED PROTEINS" 
verif_result $clust_prot.ffn
if [[ $file_exist == 1 ]]; then 
	echo "Predicted proteins are already clustered. Use --force to overwrite" 
else 
	rm -f $clust_prot.ffn $clust_prot.ffn.clstr $clust_prot.tsv $clust_prot.count 
	cd-hit-est -i $all_prot -o $clust_prot.ffn -g 1 -T 6 -M 20000 -d 0 -c $cluster_id -aS 0.90
	python3 $BIN/treat_cdhit.py $clust_prot.ffn.clstr $clust_prot.ffn $all_prot > $clust_prot.tsv
	mv $clust_prot.ffn.correct $clust_prot.ffn 
	clusters_count=$(tail -n +2 $clust_prot.tsv | cut -f 2 | sort | uniq -c | awk '{print $1"\t"$2}' | sort -n -k 2)
	echo -e "Number of clusters\tNumber of proteins in cluster\n$clusters_count" > $clust_prot.count  
fi 

echo "# ALIGN READS TO PROTEINS" 
dir=$outdir/mapping 
mkdir -p $dir 
for prefix in $(ls $reads_dir); do  
	if [[ ! -f $dir/$prefix.sorted.markdup.sorted.bam ]];then
		all_align=1 
	fi   
done 
if [[ $all_align || $FORCE ]]; then 
	rm -r $dir 
	mkdir $dir 
	/data/chochart/lib/MAPme/bin/MAPme -s $clust_prot.ffn --reads $reads_dir -o $dir --remove_duplicates -t 16
else
	echo "Reads alignments already exists. Use --force to overwrite"
fi 

echo "# ABUNDANCE MATRIX" 
ab_dir=$outdir/abundance_matrix
mkdir -p $ab_dir 
matrix=$ab_dir/abundance
verif_result $matrix.matrix 
if [[ $file_exist == 1 ]];then 
	echo "Abundance matrix already exists. Use --force to overwrite" 
else 
	rm -f $matrix.* 
	for prefix in $(cat $i); do
		read_prefix=$(echo $prefix | cut -f 1 -d ".") 
		cur_read_dir=$reads_dir/$read_prefix
		cumul_length=0
		for file in $(ls $cur_read_dir); do 
			length=$(zcat $cur_read_dir/$file | paste - - - - | cut -f 2 | wc -c )
			cumul_length=$(($cumul_length+length)) 		 
		done 
		echo -e "$dir/$read_prefix.sorted.markdup.sorted.bam,$cumul_length"  
	done > $ab_dir/mama_input.txt 
	/data/chochart/lib/MAMa/bin/MAMa.py -a $matrix.matrix -r $matrix.relative.matrix -n $matrix.normalized.matrix $clust_prot.ffn.fai $ab_dir/mama_input.txt  
fi

echo "# CONCATENATE RESISTANCES" 
verif_result $all_resistances.tsv
if [[ $file_exist == 1 ]]; then 
	echo "Resistances are already gathered. Use --force to overwrite" 
else
	rm -f $all_resistances 
	cat_cmd=''
	for p in $(cat $i); do 
		cat_cmd=$(echo $cat_cmd $annot_dir/$p.predicted_plasmids.resistances)  
	done 
	bash $BIN/combined_files.sh $cat_cmd > $all_resistances.tsv
	tail -n +2 $all_resistances.tsv | cut -f 1 > $all_resistances.id   
fi	 

echo "# ABUNDANCE MATRIX RESISTANCES" 
resistances_matrix=$ab_dir/resistances_abundance
verif_result $resistances_matrix.matrix 
if [[ $file_exist == 1 ]]; then 
	echo "Resistances abundance matrix already exists. Use --force to overwrite" 
else 
	rm -f $resistances_matrix.* 
	echo -e "$(head -n 1 $matrix.matrix)\n$(grep -w -f $all_resistances.id $matrix.matrix)" > $resistances_matrix.matrix
fi

echo "# TREAT RESISTANCES MATRIX" 

verif_result $resistances_matrix.matrix.sum
if [[ $file_exist == 1 ]]; then 
	echo "Resistances matrix are already treated. Use --force to overwrite" 
else 
	treat_matrix $resistances_matrix.matrix > $resistances_matrix.matrix.desc 
	paste $resistances_matrix.matrix $resistances_matrix.matrix.desc > $resistances_matrix.matrix.detailed 
	rm $resistances_matrix.*.desc
	python3 $BIN/sum_resistance_matrix.py $resistances_matrix.matrix.detailed $resistances_matrix.matrix.sum $ab_dir/mama_input.txt 
fi 	





