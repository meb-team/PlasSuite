set -e 

function usage(){
	echo 'usage : treat_verif_learning.sh -f <assembly.fasta> -o <output dir> -r <results dir> -p <prefix of results files> --thres <comma-separated list of learning thresholds to treat>' 
}

function treat_args(){
	if [[ ! $out ]]; then 
		quit=1
		echo "You must give output directory. Use -o option"
	fi 
	if [[ ! $assembly ]]; then 
		quit=1
		echo "You must give assembly. Use -f option"
	fi 
	if [[ ! $results ]];then
		quit=1
		echo "You must give results directory. Use -r option"
	fi		
	if [[ ! $prefix ]]; then 
		quit=1 
		echo "You must give results prefix. Use -p option" 
	fi
	if [[ ! $thresholds ]]; then 
		quit=1 
		echo "You must give thresholds list. Use --thres option" 
	else 
		thresholds=$(echo $thresholds | tr "," " ")  
	fi
		
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	for thr in $thresholds; do 
		thr=$(echo $thr | awk '{print $1/100}') 
		learning=$results/learning/$prefix.plasflow$thr.plasmids.id
		verif_file $learning "[treat_verif_learning] Learning results doesn't found in $learning" "[treat_verif_learning] Learning results found in $learning"
	done 
	chrm=$results/chrm_search/$prefix.0.8.id
	phylo_markers=$results/phylogenetic_markers/$prefix.phylo_markers.hmm.contigs.id
	rna=$results/rna_search/$prefix.rna.blast.all.contigs.id
	plas_markers=$results/plasmids_markers/$prefix.all_markers.contigs.id
	circular=$results/circular/$prefix.circular.id
	plasmids=$results/plasmids_search/$prefix.0.8.id 
	
	verif_file $chrm "[treat_verif_learning] Chromosomes results doesn't found in $chrm" "[treat_verif_Chromosomes] Chromosomes results found in $chrm" 
	verif_file $phylo_markers "[treat_verif_learning] Phylogenetic markers results doesn't found in $phylo_markers" "[treat_verif_learning] Phylogenetic markers results found in $phylo_markers" 
	verif_file $rna "[treat_verif_learning] rRNA results doesn't found in $rna" "[treat_verif_learning] rRNA results found in $rna" 
	verif_file $plas_markers "[treat_verif_learning] Plasmids markers results doesn't found in $plas_markers" "[treat_verif_learning] Plasmids markers results found in $plas_markers" 
	verif_file $circular "[treat_verif_learning] Circular results doesn't found in $circular" "[treat_verif_learning] Circular results found in $circular" 
	verif_file $plasmids "[treat_verif_learning] Plasmids results doesn't found in $plasmids" "[treat_verif_learning] Plasmids results found in $plasmids" 
}

TEMP=$(getopt -o h,r:,p:,f:,o: -l thres:  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-f)
			assembly=$2
			shift 2;; 
		-p)
			prefix=$2
			shift 2;; 
		--thres) 
			thresholds=$2
			shift 2;; 
		-r) 
			results=$2
			shift 2;; 	
		-o) 
			out=$2
			shift 2;;
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

mkdir -p $results/treat

all_chrm_id=$results/$prefix.all_chrm_identification.id
all_plasmids_id=$results/$prefix.all_plasmids_identification.id
cat $phylo_markers $rna $chrm | sort -u > $all_chrm_id 
cat $plas_markers $circular $plasmids | sort -u > $all_plasmids_id
all_chrm_length=$(python3 $BIN/total_length_contig_list.py $assembly $all_chrm_id)
all_plasmids_length=$(python3 $BIN/total_length_contig_list.py $assembly $all_plasmids_id)

out2=$out/$prefix.verif_learning.tsv

echo -e "sample\tinput\ttype\tlength\tpercent" > $out2
total_length=$(python3 $BIN/total_length_fasta.py $assembly)
echo -e "$prefix\tall\tall\t$total_length\t100" >> $out2 
chrm_length=$(python3 $BIN/total_length_contig_list.py $assembly $chrm)
echo -e "$prefix\tall\tchrm\t$chrm_length\t"$(echo $total_length $chrm_length | awk '{print $2/$1*100}') >> $out2
rna_length=$(python3 $BIN/total_length_contig_list.py $assembly $rna)
echo -e "$prefix\tall\trna\t$rna_length\t"$(echo $total_length $rna_length | awk '{print $2/$1*100}') >> $out2
phylo_markers_length=$(python3 $BIN/total_length_contig_list.py $assembly $phylo_markers)
echo -e "$prefix\tall\tphylo_markers\t$phylo_markers_length\t"$(echo $total_length $phylo_markers_length | awk '{print $2/$1*100}') >> $out2
echo -e "$prefix\tall\tall_chrm\t$all_chrm_length\t"$(echo $total_length $all_chrm_length | awk '{print $2/$1*100}') >> $out2
markers_length=$(python3 $BIN/total_length_contig_list.py $assembly $plas_markers)
echo -e "$prefix\tall\tplasmids_markers\t$markers_length\t"$(echo $total_length $markers_length | awk '{print $2/$1*100}') >> $out2
circular_length=$(python3 $BIN/total_length_contig_list.py $assembly $circular)
echo -e "$prefix\tall\tcircular\t$circular_length\t"$(echo $total_length $circular_length | awk '{print $2/$1*100}') >> $out2
plasmids_length=$(python3 $BIN/total_length_contig_list.py $assembly $plasmids)
echo -e "$prefix\tall\tplasmids\t$plasmids_length\t"$(echo $total_length $plasmids_length | awk '{print $2/$1*100}') >> $out2
echo -e "$prefix\tall\tall_plasmids\t$all_plasmids_length\t"$(echo $total_length $all_plasmids_length | awk '{print $2/$1*100}') >> $out2

for thr in $thresholds; do 
	thr_p=$(echo $thr | awk '{print $1/100}') 
	learning=$results/learning/$prefix.plasflow$thr_p.plasmids.fasta
	total_length=$(python3 $BIN/total_length_fasta.py $learning)
	echo -e "$prefix\tlearning$thr\tall\t$total_length\t100" >> $out2  
	chrm_length=$(python3 $BIN/total_length_contig_list.py $learning $chrm)
	echo -e "$prefix\tlearning$thr\tchrm\t$chrm_length\t"$(echo $total_length $chrm_length | awk '{print $2/$1*100}') >> $out2
	rna_length=$(python3 $BIN/total_length_contig_list.py $learning $rna)
	echo -e "$prefix\tlearning$thr\trna\t$rna_length\t"$(echo $total_length $rna_length | awk '{print $2/$1*100}') >> $out2
	phylo_markers_length=$(python3 $BIN/total_length_contig_list.py $learning $phylo_markers)
	echo -e "$prefix\tlearning$thr\tphylo_markers\t$phylo_markers_length\t"$(echo $total_length $phylo_markers_length | awk '{print $2/$1*100}') >> $out2
	all_chrm_length=$(python3 $BIN/total_length_contig_list.py $learning $all_chrm_id)
	echo -e "$prefix\tlearning$thr\tall_chrm\t$all_chrm_length\t"$(echo $total_length $all_chrm_length | awk '{print $2/$1*100}') >> $out2
	markers_length=$(python3 $BIN/total_length_contig_list.py $learning $plas_markers)
	echo -e "$prefix\tlearning$thr\tplasmids_markers\t$markers_length\t"$(echo $total_length $markers_length | awk '{print $2/$1*100}') >> $out2
	circular_length=$(python3 $BIN/total_length_contig_list.py $learning $circular)
	echo -e "$prefix\tlearning$thr\tcircular\t$circular_length\t"$(echo $total_length $circular_length | awk '{print $2/$1*100}') >> $out2
	plasmids_length=$(python3 $BIN/total_length_contig_list.py $learning $plasmids)
	echo -e "$prefix\tlearning$thr\tplasmids\t$plasmids_length\t"$(echo $total_length $plasmids_length | awk '{print $2/$1*100}') >> $out2
	echo -e "$prefix\tlearning$thr\tall_plasmids\t$all_plasmids_length\t"$(echo $total_length $all_plasmids_length | awk '{print $2/$1*100}') >> $out2
done 
