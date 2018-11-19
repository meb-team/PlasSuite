set -e 

function usage(){
	echo 'usage : all_analysis.sh -a assembly.fasta -o outdir 
	[OPTIONS]
	-h : print help
	#Output  
	--prefix <prefix> : prefix for output files (default : assembly fasta name) 
	#Databases 
	--chrm_db <fasta> : fasta file with bacterial chromosomes sequences you want to use (default : databases/all_chrm.fasta) 
	--rna_db <fasta> : fasta file with rRNA sequences (must be back transcribed) you want to use (default : /databis/hilpert/databases/rRNA/SILVA_132_LSUParc_SSUParc_tax_silva_trunc.T.fasta) 
	--phylo_db <hmm> : hmm profile(s) with phylogenetic markers (default : /databis/hilpert/databases/phylogenetic_markers/wu2013/bacteria_and_archaea_dir/BA.hmm)
	--markers_db <dir> : dir where plasmids markers databases are stored (mob.proteins.faa,mpf.proteins.faa,rep.dna.fas and orit.fas) (default : /databis/hilpert/databases/plasmids_markers) 
	--plasmids_db <fasta> : fasta file with complete plasmids sequences you want to use (default : /databis/hilpert/databases/all_plasmids.fasta)
	' 
}


function treat_args(){
	if [[ ! $assembly ]];then
		quit=1
		echo "You must give fasta contigs. Use -a option"
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
	verif_file $assembly "[PlasPredict] Contigs file doesn't found in $assembly" "[PlasPredict] Contigs file found in $assembly"
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi
	if [[ ! $markers_db ]]; then 
		markers_db=/databis/hilpert/plasmidome_databases/plasmids_markers
	fi
	if [[ ! $chrm_db ]]; then 
		chrm_db=/databis/hilpert/plasmidome_databases/all_prokaryotes.fasta 
	fi 
	if [[ ! $rna_db ]]; then 
		rna_db=/databis/hilpert/plasmidome_databases/rRNA/SILVA_132_LSUParc_SSUParc_tax_silva_trunc.T.fasta
	fi 
	if [[ ! $phylo_db ]]; then 
		phylo_db=/databis/hilpert/plasmidome_databases/phylogenetic_markers/wu2013/bacteria_and_archaea_dir/BA.hmm	
	fi 
	if [[ ! $plasmids_db ]]; then 
		plasmids_db=/databis/hilpert/plasmidome_databases/all_plasmids.fasta 
	fi 
	verif_file $chrm_db "[PlasPredict] Chromosomes database doesn't found in $chrm_db" "[PlasPredict] Chromosomes database found in $chrm_db"
	verif_file $rna_db "[PlasPredict] rRNA database doesn't found in $rna_db" "[PlasPredict] rRNA database found in $rna_db"
	verif_file $phylo_db "[PlasPredict] Phylogenetic markers database doesn't found in $phylo_db" "[PlasPredict] Phylogenetic markers database found in $phylo_db"
	verif_file $plasmids_db "[PlasPredict] Plasmids database doesn't found in $plasmids_db" "[PlasPredict] Plasmids database found in $plasmids_db"
	verif_dir $markers_db "[PlasPredict] Plasmids markers database doesn't found in $markers_db" "[PlasPredict] Plasmids markers database found in $markers_db"
}


function define_paths(){ 
	predicted_proteins=$outdir/proteins_prediction/$prefix.predicted_proteins.faa
	contigs_phylomark=$outdir/phylogenetic_markers/$prefix.phylo_markers.hmm.contigs
	contigs_chrm=$outdir/chrm_search/$prefix.0.8
	contigs_rna=$outdir/rna_search/$prefix.rna.blast.all.contigs
	contigs_plasmark=$outdir/plasmids_markers/$prefix.all_markers.contigs
	contigs_circular=$outdir/circular/$prefix.circular
	contigs_plasmids=$outdir/plasmids_search/$prefix.0.8
	learning_plasmids=$outdir/learning/$prefix.plasflow0.7.plasmids
	learning_chrm=$outdir/learning/$prefix.plasflow0.7.chromosomes
	learning_unclassified=$outdir/learning/$prefix.plasflow0.7.unclassified
}	

function complete_resume(){
	name=$1
	nb_contigs=$2
	length_contigs=$3	
	path=$4
	echo -e "$name\t$nb_contigs\t$length_contigs\t$path" >> $resume 
}	

function run_proteins_prediction(){
	dir=$1
	prefix=$2
	assembly=$3
	out=$dir/$prefix.predicted_proteins
	echo "[protein_prediction] Run Prodigal..."
	prodigal -i $assembly -c -m -p meta -a $out.faa -o $out.gff -q
	rm $out.gff
}	

TEMP=$(getopt -o h,a:,o: -l prefix:,chrm_db:,rna_db:,phylo_db:,force,markers_db:,plasmids_db:  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-a) 
			assembly=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		--prefix) 
			PREFIX=1
			prefix=$2 
			shift 2;; 
		--chrm_db) 
			CHRM_DB=1
			chrm_db=$2
			shift 2;;	
		--rna_db)
			RNA_DB=1
			rna_db=$2
			shift 2;;
		--phylo_db)
			PHYLO_DB=1 
			phylo_db=$2
			shift 2;; 
		--markers_db) 
			MARKERS_DB=1 
			markers_db=$2
			shift 2;;
		--plasmids_db) 
			PLASMIDS_DB=1 
			plasmids_db=$2
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
define_paths

mkdir -p $outdir 
resume=$outdir/$prefix.resume.tsv

tmp=$(mktemp -d -p .) 

echo -e "step\tcontigs_number\tcontigs_length" > $resume 

echo "==== PRELIMINARY STEP ====" 
echo "## STEP 1 : LENGTH FILTER"
start=$(date +%s)
if [[ ! -f $assembly.1kb ]]; then 
	$BIN/filter_sequences_by_length.pl -input $assembly -thres 1000 -output $assembly.1kb 
fi  
assembly=$assembly.1kb
complete_resume "All contigs" $(grep "^>" -c $assembly) $(python3 $BIN/total_length_fasta.py $assembly)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "## STEP 2 : PROTEIN PREDICTION" 
dir=$outdir/proteins_prediction 
mkdir -p $dir 
start=$(date +%s)
verif_result $predicted_proteins 
if [[ $file_exist == 1 ]]; then 
	echo "Proteins prediction results already exists. Use --force to overwrite" 
else 
	run_proteins_prediction $dir $prefix $assembly 
fi
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "==== IDENTIFY CHROMOSOMES ===="
echo "## STEP 1 : PHYLOGENETIC MARKERS SEARCH" 
start=$(date +%s)
dir=$outdir/phylogenetic_markers
mkdir -p $dir 
verif_result $contigs_phylomark.id  
if [[ $file_exist == 1 ]];then 
	echo "Phylogenetic markers search already exists. Use --force to overwrite." 
else 
	bash $BIN/search_phylogenetic_markers.sh -p $predicted_proteins -o $dir -d $phylo_db --prefix $prefix --force
fi 	
complete_resume "Contigs with phylogenetic markers" $(wc -l $contigs_phylomark.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $contigs_phylomark.id)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "## STEP 2 : CHROMOSOMES SEARCH" 
start=$(date +%s)
dir=$outdir/chrm_search
mkdir -p $dir 
verif_result $contigs_chrm.id
if [[ $file_exist == 1 ]];then 
	echo "Chromosomes search results already exists. Use --force to overwrite." 
else 
	bash $BIN/run_minimap.sh -q $assembly -o $dir -s $chrm_db --prefix $prefix --force	
fi 	
complete_resume "Contigs with chromosomes" $(wc -l $contigs_chrm.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $contigs_chrm.id)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "## STEP 3 : rRNA SEARCH" 
start=$(date +%s)
dir=$outdir/rna_search
mkdir -p $dir 
verif_result $contigs_rna.id
if [[ $file_exist == 1 ]];then 
	echo "rRNA search results already exists. Use --force to overwrite." 
else 
	bash $BIN/run_rna_search.sh -f $assembly -o $dir -d $rna_db --force --prefix $prefix 
fi 
complete_resume "Contigs with rRNA" $(wc -l $contigs_rna.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $contigs_rna.id)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "==== IDENTIFY PLASMIDS ===="

echo "## STEP 1 : PLASMIDS MARKERS SEARCH" 
start=$(date +%s)
dir=$outdir/plasmids_markers
mkdir -p $dir 
verif_result $contigs_plasmark.id
if [[ $file_exist == 1 ]];then 
	echo "Plasmids markers results already exists. Use --force to overwrite" 
else 
	bash $BIN/search_plasmids_markers.sh -f $assembly -o $dir --prefix $prefix -d $markers_db -p $predicted_proteins
fi 
complete_resume "Contigs with plasmids markers" $(wc -l $contigs_plasmark.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $contigs_plasmark.id)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "## STEP 2 : CIRCULAR CONTIGS" 
start=$(date +%s)
dir=$outdir/circular
mkdir -p $dir
verif_result $contigs_circular.fasta 
if [[ $file_exist == 1 ]]; then 
	echo "Circular contigs already exists. Use --force to overwrite" 
else 	
	echo "[circular] Run..." 
	bash $BIN/run_circular.sh $assembly $contigs_circular	 
fi
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "## STEP 3 : PLASMIDS ALIGNMENT" 
start=$(date +%s)
dir=$outdir/plasmids_search
mkdir -p $dir 
verif_result $contigs_plasmids.id
if [[ $file_exist == 1 ]];then 
	echo "Plasmids search results already exists. Use --force to overwrite." 
else 
	bash $BIN/run_minimap.sh -q $assembly -o $dir -s $plasmids_db --prefix $prefix --force	
fi 	
complete_resume "Contigs with db plasmids" $(wc -l $contigs_plasmids.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $contigs_plasmids.id)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "==== PREDICT PLASMIDS ===="

echo "## STEP 1 : LEARNING" 
start=$(date +%s)
dir=$outdir/learning
mkdir -p $dir 
verif_result $learning_plasmids.id
if [[ $file_exist == 1 ]];then 
	echo "Learning results already exists. Use --force to overwrite" 
else 
	echo "[learning] Run PlasFlow..." 
	bash $BIN/run_plasflow.sh $prefix $assembly -o $dir
fi 
complete_resume "Learning plasmids" $(wc -l $learning_plasmids.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $learning_plasmids.id)
complete_resume "Learning chromosomes" $(wc -l $learning_chrm.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $learning_chrm.id)
complete_resume "Learning unclassified" $(wc -l $learning_unclassified.id | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $learning_unclassified.id)
end=$(date +%s)
echo "Time elapsed : $((end-start)) s" 

echo "=== TREATMENT ====" 

echo "## VERIF LEARNING" 
echo "TO DO" 
#bash $BIN/treat_verif_learning.sh -f $assembly -o $outdir -r $outdir -p $prefix --thres 70

echo "==== CLEANING LEARNING PLASMIDS ====" 
predicted_plasmids=$outdir/$prefix.predicted_plasmids
echo "# Delete chromosomes contigs" 
python3 $BIN/delete_id.py $learning_plasmids.id $contigs_chrm.id $predicted_plasmids.nochrm.id
echo "# Delete rna contigs" 
python3 $BIN/delete_id.py $predicted_plasmids.nochrm.id $contigs_rna.id $predicted_plasmids.nochrm_norna.id 
echo "# Delete phylogenetic markers contigs" 
python3 $BIN/delete_id.py $predicted_plasmids.nochrm_norna.id $contigs_phylomark.id $predicted_plasmids.nochrm_norna_nophylomark.id 

echo "=== ADD OTHERS PLASMIDS TO LEARNING ====" 
cat $predicted_plasmids.nochrm_norna_nophylomark.id $contigs_plasmids.id $contigs_plasmark.id | sort -u > $predicted_plasmids.linear.id
python3 $BIN/intersect_files.py $predicted_plasmids.linear.id $contigs_circular.id $tmp linear_circular linear circular
mv $tmp/linear_circular.linear.specific.txt $predicted_plasmids.linear.id  
complete_resume "Linear selected plasmids" $(wc -l $predicted_plasmids.linear.id  | cut -f 1 -d " ") $(python3 $BIN/total_length_contig_list.py $assembly $predicted_plasmids.linear.id)
complete_resume "Circular selected plasmids" $(grep "^>" -c $contigs_circular.fasta) $(python3 $BIN/total_length_fasta.py $contigs_circular.fasta)"#not_exact" 
python3 $BIN/seq_from_list.py --input_fasta $assembly --output_fasta $predicted_plasmids.linear.fasta --keep $predicted_plasmids.linear.id 
cat $predicted_plasmids.linear.fasta $contigs_circular.fasta > $predicted_plasmids.fasta 
rm $predicted_plasmids.linear.fasta

rm -r $tmp 

