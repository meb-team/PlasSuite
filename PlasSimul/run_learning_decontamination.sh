set -e 

function usage(){
	echo 'usage : bash run_learning_decontamination.sh -f <assembly fasta> -o <outdir>  [options]
	[options] 
	--plasflow <comma-separated list of threshold to test> : launch plasflow decontamination
	--cbar : launch cbar decontamination
	--cbar_plasflow <comma-separated list of plasflow threshold to test>: launch cbar+plasflow decontamination  
	--prefix <prefix for results files> : optional (default : assembly fasta name) 
	--real_plasmids : real plasmids id for evaluation 
	--real_chrm : real chrm id for evaluation
	-t : number of threads for tools : optional (default : 6) 
	'
}	

function args_gestion(){ 
	if [[ ! $contigs ]]; then 
		quit=1
		echo " ! You must give assembly contigs fasta file (-f)"
	fi
	if [[ ! $outdir ]]; then 
		quit=1
		echo " ! You must give outdir path (-o)"
	fi
	if [[ ! $plasflow_thres ]] && [[ ! $cbar ]] && [[ ! $cbar_plas_thres ]] && [[ ! $chrm_alignment ]] && [[ ! $plasmark ]]; then 
		quit=1
		echo " ! You must give at least one decontamination method"
	fi  
	
	if [[ ! $pref ]]; then 
		pref=$(echo $contigs | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi 
	
	if [[ ! $real_plasmids ]]; then 
		quit=1
		echo "You must give --real_plasmids" 
	fi 
	
	if [[ ! $real_chrm ]]; then 
		quit=1
		echo "You must give --real_chrm" 
	fi
	
	if [[ $quit ]]; then 
		exit 1 
	fi
	
}	

function thres_gestion(){ 
	thresholds=$(echo $1 | tr "," " ")  

}	

t=6

TEMP=$(getopt -o h,o:,f:,t: -l plasflow:,cbar,cbar_plasflow:,prefix:,real_plasmids:,real_chrm: -- "$@")

eval set -- "$TEMP" 

while true ; do 
	case "$1" in 
		--plasflow)
			plasflow_thres=$2
			shift 2;; 
		--cbar)
			cbar=1
			shift;;	
		--cbar_plasflow)
			cbar_plas_thres=$2
			shift 2;;
		--prefix)
			pref=$2
			shift 2;; 
		--real_plasmids)
			real_plasmids=$2
			shift 2;; 
		--real_chrm)
			real_chrm=$2
			shift 2;; 
		-t)
			t=$2 
			shift 2;;
		-h) 
			usage 
			shift ;;
		-o) 
			outdir=$2
			shift 2;;	
		-f) 
			contigs=$2 
			shift 2;; 	
		--)  
			shift ; break ;; 					
	esac 
done


args_gestion
 
tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/BIN

tmp=`mktemp -d -p .`
mkdir -p $outdir 

if [[ ! -f $contigs.1kb ]]; then 
	$BIN/filter_sequences_by_length.pl -input $contigs -output $contigs.1kb -thres 1000 
fi 	
contigs=$contigs.1kb
grep "^>" $contigs | tr -d ">" > $contigs.id 

if [[ $plasflow_thres ]]; then 
	dir=$outdir/plasflow
	mkdir -p $dir 
	thres_gestion $plasflow_thres 
	count=0
	nb_file=0
	for thr in $thresholds; do 
		thr=$(echo $thr | awk '{print $1/100}') 
		predict_plasmids=$dir/$pref.plasflow$thr.plasmids.id
		predict_chrm=$dir/$pref.plasflow$thr.chromosomes.id
		if [[ $(($count%$t)) == 0 ]]; then
			nb_file=$(($nb_file+1)) 
			echo bash $BIN/run_plasflow.sh $pref $contigs -o $dir --thres $thr ';' bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $predict_plasmids $predict_chrm $contigs $pref.plasflow$thr $dir/$pref.plasflow$thr.stats > $tmp/plasflow_commands.$nb_file.txt
			 
		else 
			echo bash $BIN/run_plasflow.sh $pref $contigs -o $dir --thres $thr ';' bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $predict_plasmids $predict_chrm $contigs $pref.plasflow$thr $dir/$pref.plasflow$thr.stats >> $tmp/plasflow_commands.$nb_file.txt
		fi 	
		count=$(($count+1))
	done 	
	echo "## PREDICTION" 
	for commands in $(ls $tmp/plasflow_commands.*); do 
		parallel --no-notice < $commands 
	done
	
	grep "^>" $contigs | tr -d ">" > $tmp/assembly.id 
	
	for thr in $thresholds; do
		thr=$(echo $thr | awk '{print $1/100}') 
		grep "^>" $dir/$pref.plasflow$thr.unclassified.fasta | tr -d ">" > $dir/$pref.plasflow$thr.unclassified.id
		predict_plasmids=$dir/$pref.plasflow$thr.plasmids.id
		predict_noplasmids=$dir/$pref.plasflow$thr.noplasmids.id 
		cat $dir/$pref.plasflow$thr.unclassified.id $dir/$pref.plasflow$thr.chromosomes.id > $predict_noplasmids
		bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $predict_plasmids $predict_noplasmids $contigs $pref.plasflow$thr.withunclassified $dir/$pref.plasflow$thr.withunclassified.stats
	done 
	
	
fi 

if [[ $cbar ]]; then 
	dir=$outdir/cbar 
	mkdir -p $dir 
	bash $BIN/run_cbar.sh $pref $contigs -o $dir 
	predict_plasmids=$dir/$pref.cbar.plasmids.id 
	predict_chrm=$dir/$pref.cbar.chrm.id
	awk '{if ($3 == "Plasmid") print $1}' $dir/$pref.cbar.prediction.txt > $predict_plasmids
	awk '{if ($3 == "Chromosome") print $1}' $dir/$pref.cbar.prediction.txt > $predict_chrm
	bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $predict_plasmids $predict_chrm $contigs $pref.cbar $dir/$pref.cbar.stats
fi 

if [[ $cbar_plas_thres ]]; then 
	dir=$outdir/cbar_plasflow 
	mkdir -p $dir 
	thres_gestion $cbar_plas_thres 
	count=0
	nb_file=0
	for thr in $thresholds; do 
		thr=$(echo $thr | awk '{print $1/100}') 
		predict_plasmids=$dir/$pref.cbar.plasflow$thr.plasmids.id
		predict_noplasmids=$dir/$pref.cbar.plasflow$thr.noplasmids.id
		if [[ $(($count%$t)) == 0 ]]; then
			nb_file=$(($nb_file+1)) 
			echo bash $BIN/run_cbar_plasflow.sh $thr $dir $pref $contigs ";" bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $predict_plasmids $predict_noplasmids $contigs $pref.cbar.plasflow$thr.withunclassified $dir/$pref.cbar.plasflow$thr.withunclassified.stats > $tmp/cbar_plasflow_commands.$nb_file.txt
			 
		else 
			echo bash $BIN/run_cbar_plasflow.sh $thr $dir $pref $contigs ";" bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $predict_plasmids $predict_noplasmids $contigs $pref.cbar.plasflow$thr.withunclassified $dir/$pref.cbar.plasflow$thr.withunclassified.stats >> $tmp/cbar_plasflow_commands.$nb_file.txt	
		fi 	
		count=$(($count+1))
	done 	
	for commands in $(ls $tmp/cbar_plasflow_commands.*); do 
		parallel --no-notice < $commands 
	done 	
fi 	
	
rm -r $tmp 
