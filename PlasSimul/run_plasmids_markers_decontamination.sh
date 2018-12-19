set -e 

function usage(){
	echo "usage : bash run_plasmids_markers_decontamination.sh -i <assembly.fasta> -o <output_directory> --real_plasmids <real plasmids id> --real_chrm <real chrm id> [options] 
	[Options]
	--markers_db <directory> (default : $HOME/plasmidome_databases/plasmids_markers)
	--prefix <prefix> : prefix for output files (default : assembly.fasta name)
	--force : overwrite results
	
	Markers database directory must contains mob.proteins.faa, mpf.proteins.faa, orit.fas and rep.dna.fas
	"
}

function treat_args(){ 
	if [[ ! $assembly ]];then
		quit=1
		echo "You must give fasta contigs. Use -i option"
	fi		
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi
	if [[ ! $real_plasmids ]]; then 
		quit=1 
		echo "You must give real plasmids, provided by run_assembly_treatment. Use --real_plasmids option" 
	fi 
	if [[ ! $real_chrm ]]; then 
		quit=1 
		echo "You must give real chromosomes, provided by run_assembly_treatment. Use --real_chrm option" 
	fi 
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $assembly "Assembly doesn't found in $assembly." "Assembly found in $assembly." 
	verif_file $real_plasmids "Real plasmids doesn't found in $real_plasmids." "Real plasmids found in $real_plasmids"  
	verif_file $real_chrm "Real chromosomes doesn't found in $real_chrm" "Real chromosomes found in $real_chrm" 
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi 
	if [[ ! $markers_db ]]; then 
		markers_db=$HOME/plasmidome_databases/plasmids_markers
	fi 
	verif_file $markers_db/mob.proteins.faa "Mob proteins doesn't found in $markers_db/mob.proteins.faa." "Mob proteins found in $markers_db/mob.proteins.faa." 	
	verif_file $markers_db/mpf.proteins.faa "Mpf proteins doesn't found in $markers_db/mpf.proteins.faa" "Mpf proteins found in $markers_db/mpf.proteins.faa" 
	verif_file $markers_db/orit.fas "OriT doesn't found in $markers_db/orit.fas" "OriT found in $markers_db/orit.fas" 
	verif_file $markers_db/rep.dna.fas "Rep DNA doesn't found in $markers_db/rep.dna.fas", "Rep DNA found in $markers_db/rep.dna.fas"  
}	

TEMP=$(getopt -o h,i:,o:,c: -l cont_db:,prefix:,force,chrm_db:,rna_db:,real_plasmids:,real_chrm:  -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-i) 
			assembly=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		--prefix) 
			prefix=$2 
			shift 2;; 
		--markers_db) 
			rna_db=$2
			shift 2;; 
		--real_plasmids)
			real_plasmids=$2
			shift 2;; 
		--real_chrm) 
			real_chrm=$2
			shift 2;; 
		--force)
			FORCE=1
			shift ;; 
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
BIN=$tool_dir/bin

CURDIR=$(echo $(readlink -f $0) | rev | cut -f 2- -d "/" | rev) 

#tmp=$(mktemp -d -p .) 

source $BIN/common_functions.sh 

treat_args
verif_args	

echo "# PREDICT PROTEINS" 
predict_proteins=$assembly.predict_proteins
verif_result $predict_proteins 
if [[ $file_exist == 1 ]]; then 
	echo "Predicted proteins already exists. Use --force to overwrite" 
else 
	prodigal -i $assembly -c -m -p meta -a $predict_proteins -o $predict_proteins.gff -q
	rm $predict_proteins.gff
fi

echo "# PLASMIDS MARKERS ALIGNMENT" 
if [[ ! -f $assembly.id ]]; then 
	grep "^>" $assembly | cut -f 1 -d " " | tr -d ">" > $assembly.id 
fi 
plasmids=$outdir/$prefix.markers_decont.plasmids 
chrm=$outdir/$prefix.markers_decont.chrm 
stats=$outdir/$prefix.markers_decont.stats 
verif_result $plasmids 
if [[ $file_exist == 1 ]]; then 
	echo "Plasmids markers alignment already exists. Use --force to overwrite" 
else 
	bash $BIN/search_plasmids_markers.sh -f $assembly -p $predict_proteins -d $markers_db -o $outdir --prefix $prefix 
	mv $outdir/$prefix.all_markers.contigs.id $plasmids.id 
	python3 $BIN/seq_from_list.py --input_fasta $assembly --keep $plasmids.id --output_fasta $plasmids.fasta 
	rm $outdir/*.blast.tsv 
	python3 $BIN/delete_id.py $assembly.id $plasmids.id $chrm.id 
	bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $plasmids.id $chrm.id $assembly $prefix.plasmidsMarkersDecont $stats
fi
