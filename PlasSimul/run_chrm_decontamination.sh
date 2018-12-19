function usage(){
	echo "usage : bash run_chrm_decontamination.sh -i <assembly.fasta> -o <output_directory> -c <comma separated list of clustering threshold> --cont_db <contaminants.fasta> --chrm_db <all chromosomes.fasta> --real_plasmids <real plasmids id> --real_chrm <real chrm id> [options] 
	[Options]
	--rna_db <fasta> : fasta with rRNA sequences. (default : $HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta)
	--prefix <prefix> : prefix for output files (default : assembly.fasta name)
	--force : overwrite results
	
	Clustering threshold : between 0 and 100, 0 means no clustering" 
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
	if [[ ! $clustering ]]; then 
		quit=1 
		echo "You must give clustering threshold(s). Use -c option" 
	fi 
	if [[ ! $cont_db ]]; then 
		quit=1 
		echo "You must give contaminants sequences. Use --cont_db option" 
	fi 
	if [[ ! $chrm_db ]]; then 
		quit=1 
		echo "You must give chromosomes sequences. Use --chrm_db option" 
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
	verif_file $cont_db "Contaminants database doesn't found in $cont_db" "Contaminants database found in $cont_db" 
	verif_file $chrm_db "Chromosomes database doesn't found in $chrm_db." "Chromosomes database found in $chrm_db." 
	verif_file $real_plasmids "Real plasmids doesn't found in $real_plasmids." "Real plasmids found in $real_plasmids"  
	verif_file $real_chrm "Real chromosomes doesn't found in $real_chrm" "Real chromosomes found in $real_chrm" 
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi 
	if [[ ! $rna_db ]]; then 
		rna_db=$HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta
	fi 
	verif_file $rna_db "RNA database doesn't found in $rna_db. Use --rna_db to specify an other." "RNA database found in $rna_db" 	
	clustering=$(echo $clustering | tr "," " ") 
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
		-c) 
			clustering=$2
			shift 2;; 
		--prefix) 
			prefix=$2 
			shift 2;; 
		--cont_db)
			cont_db=$2
			shift 2;; 
		--chrm_db) 
			chrm_db=$2
			shift 2;; 
		--rna_db) 
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

tmp=$(mktemp -d -p .) 

source $BIN/common_functions.sh 

treat_args
verif_args	

echo "# DELETE CONTAMINANTS FROM CHROMOSOMES DATABASE" 
grep "^>" $cont_db | cut -f 1 -d " " | tr -d ">" > $tmp/contaminants.id 
verif_result $chrm_db.noCont
if [[ $file_exist == 1 ]]; then 
	echo "Contaminants are already deleted from chromosomes database. Use --force to overwrite" 
else 
	rm -f $chrm_db.noCont
	python3 $BIN/delete_seq_from_file.py $chrm_db $tmp/contaminants.id $chrm_db.noCont normal
fi 

chrm_db=$chrm_db.noCont

echo "# EXTRACT RNA"
echo "-- From chromosome database" 
verif_result $chrm_db.rna 
if [[ $file_exist == 1 ]]; then 
	echo "RNA are already extract from chromosome database. Use --force to overwrite" 
else 
	rm -f $chrm_db.rna 
	grep "^>" $chrm_db | cut -f 1 -d "." | tr -d ">" > $tmp/chrm.simpleId
	python3 $BIN/seq_from_list.py --input_fasta $rna_db --output_fasta $chrm_db.rna --keep $tmp/chrm.simpleId --silva True
fi  
echo "-- From contaminants database" 
verif_result $cont_db.rna 
if [[ $file_exist == 1 ]];then 
	echo "RNA are already extract from contaminants database. Use --force to overwrite" 
else 
	rm -f $cont_db.rna 
	grep "^>" $cont_db | cut -f 1 -d "." | tr -d ">" > $tmp/contaminants.simpleId
	python3 $BIN/seq_from_list.py --input_fasta $rna_db --output_fasta $cont_db.rna --keep $tmp/contaminants.simpleId --silva True
fi 	

echo "# CLUSTERING" 
thr_not_exist='' 
for thr in $clustering; do 
	verif_result $chrm_db.clust$thr 
	if [[ $file_exist == 0 && $thr != 0 ]]; then 
		thr_not_exist=$thr_not_exist" "$thr 
	fi
done 	

dir_chrm=$(echo $chrm_db | rev | cut -f 2- -d "/" | rev) 
name_chrm=$(echo $chrm_db | rev | cut -f 1 -d "/" | rev) 
if [[ $dir_chrm == $name_chrm ]]; then 
	dir_chrm="." 
fi 

if [[ $thr_not_exist ]]; then 
	bash $CURDIR/run_16Sclustering_with_seeds.sh $cont_db.rna $chrm_db.rna $(echo $thr_not_exist | tr " " ",") $dir_chrm $name_chrm 4
	for thr in $clustering; do 
		echo "-- Delete similar RNA $thr % threshold" 
		if [[ $thr != 0 ]]; then 
			python3 $BIN/delete_seq_from_file.py $chrm_db $chrm_db.chrm_to_delete.$thr.txt $chrm_db.clust$thr simple
		fi	
	done   
else 
	echo "Clustering already exists. Use --force to overwrite" 
fi 

echo "# CHROMOSOMES ALIGNMENT" 

if [[ ! -f $assembly.id ]]; then 
	grep "^>" $assembly | cut -f 1 -d " " | tr -d ">" > $assembly.id 
fi 

grep "^>" $assembly | cut -f 1 -d " " | tr -d ">" > $assembly.id 

for thr in $clustering; do 
	echo "-- with $thr % clustering" 
	paf=$outdir/$prefix.chrm_alignment.clust$thr.paf
	chrm_id=$outdir/$prefix.chrm_decont.clust$thr.chrm.id 
	plasmids_id=$outdir/$prefix.chrm_decont.clust$thr.plasmids.id 
	stats=$outdir/$prefix.chrm_decont.clust$thr.stats 
	if [[ $thr == 0 ]]; then 
		current_db=$chrm_db 
	else 
		current_db=$chrm_db.clust$thr
	fi
	verif_result $stats 
	if [[ $file_exist == 1 ]]; then 
		echo "Chromosomes alignment already exists. Use --force to overwrite" 
	else 
		number_chrm=$(grep "^>" -c $current_db)
		minimap2 -x asm5 -N $number_chrm $current_db $assembly > $paf  
		awk '{if ($10/$2 >= 0.8) print}' $paf > $paf.keep 
		cut -f 1 $paf.keep | sort -u > $outdir/$prefix.chrm_decont.clust$thr.chrm.id 
		python3 $BIN/delete_id.py $assembly.id $chrm_id $plasmids_id 
		bash $BIN/stats_plasmid_detection.sh $real_plasmids $real_chrm $plasmids_id $chrm_id $assembly clust$thr $stats
	fi
	
done 

rm -r $tmp 
	
