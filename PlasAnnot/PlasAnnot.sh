set -e 

function usage(){ 
	echo "usage : bash all_annotation.sh -f <contigs.fasta> -o <outdir> 
	If you have circular contigs in your assembly, their id must contains 'circ' to be identified and correctly treated. Be sure you have add enough bases to those circular contigs for complete protein detection.  
	options : 
	--prefix <prefix for results (default : assembly name)
	--force : overwrite results
	--resfam : resfam hmm you want to use first for prokka annotation (default : plasmidome_databases/Resfams/Resfams.hmm)
	--markers_db : plasmids markers databases directory (default : plasmidome_databases/plasmids_markers)" 
}	 

function treat_args(){
	if [[ ! $assembly ]];then
		quit=1
		echo "You must give fasta contigs. Use -f option"
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
	verif_file $assembly "[PlasAnnot] Contigs file doesn't found in $assembly. Use -f to specify an other." "[PlasAnnot] Contigs file found in $assembly"
	mkdir -p $outdir 
	if [[ ! $prefix ]]; then 
		prefix=$(echo $assembly | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
	fi
	if [[ ! $markers_db ]]; then 
		markers_db=plasmidome_databases/plasmids_markers
	fi
	if [[ ! $hmm ]]; then 
		hmm=plasmidome_databases/Resfams/Resfams.hmm 
	fi
	verif_file $hmm "[PlasAnnot] Resfam HMM profile doesn't found in $hmm. Use --resfam to specify an other." "[PlasAnnot] Resfam HMM profile found in $hmm"
	verif_dir $markers_db "[PlasAnnot] Plasmids markers database doesn't found in $markers_db. Use --markers_db to specify an other." "[PlasAnnot] Plasmids markers database found in $markers_db" 
	verif_file $markers_db/mob.proteins.faa "[PlasAnnot] Mob proteins doesn't found in $markers_db/mob.proteins.faa" "[PlasAnnot] Mob proteins found in $markers_db/mob.proteins.faa"
	verif_file $markers_db/mpf.proteins.faa "[PlasAnnot] Mpf proteins doesn't found in $markers_db/mpf.proteins.faa" "[PlasAnnot] Mpf proteins found in $markers_db/mpf.proteins.faa"
	verif_file $markers_db/rep.dna.fas "[PlasAnnot] Rep dna doesn't found in $markers_db/rep.dna.fas" "[PlasAnnot] Rep dna found in $markers_db/rep.dna.fas"
}

function set_default(){
	prokka_gff=$outdir/$prefix.gff
	prokka_gff_markers=$outdir/$prefix.markers.gff
	prokka_gff_circular=$outdir/$prefix.markers.circular.gff
	prokka_gff_linear=$outdir/$prefix.markers.linear.gff
	prokka_gff_resistance=$outdir/$prefix.markers.resfinder.resistance.gff
	resistance_contigs=$outdir/$prefix.resistance_contigs.id
	prokka_gff_resfinder=$outdir/$prefix.markers.resfinder.gff
	draw_contigs_resistance=$outdir/$prefix.contigs.resistance.pdf 
	draw_contigs_10kb=$outdir/$prefix.linear.10kb.pdf 
	draw_contigs_circular=$outdir/$prefix.circular.pdf 
}	

TEMP=$(getopt -o h,f:,o: -l prefix:,force,resfam:,markers_db: -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-f) 
			assembly=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		--prefix) 
			prefix=$2 
			shift 2;;
		--force)
			FORCE=1
			shift ;; 
		--resfam)
			hmm=$2
			shift 2;; 
		--markers_db) 
			markers_db=$2
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
BIN=$tool_dir/bin

source $BIN/common_functions.sh 
treat_args
verif_args
set_default 

current_dir=$(pwd) 
echo "STEP 1 : PROKKA ANNOTATION" 
verif_result $prokka_gff 
if [[ $file_exist == 1 ]]; then
	echo "Prokka annotation results already exists. Use --force to overwrite" 
else 
	source activate plasmidome 
	if [[ ! -f $hmm.h3f ]]; then 
		hmmpress $hmm 
	fi
	echo "[annotation] Run Prokka..." 
	prokka $assembly --outdir $outdir --prefix $prefix --metagenome --hmms $hmm --quiet --rawproduct --force
	source deactivate plasmidome 
	rm $outdir/$prefix.sqn $outdir/$prefix.fna $outdir/$prefix.fsa $outdir/$prefix.tbl $outdir/$prefix.gbk 
fi

echo "STEP 2 : RETRIEVE PLASMIDS MARKERS" 
verif_result $prokka_gff_markers
if [[ $file_exist == 1 ]]; then
	echo "Retrieve plasmids results already exists. Use --force to overwrite" 
else 
	bash $BIN/search_plasmids_markers_prokka.sh -p $outdir/$prefix.faa -o $outdir/markers --db $markers_db -g $prokka_gff --prefix $prefix -d $outdir/$prefix.ffn --force
fi

mv $prokka_gff_markers $prokka_gff 
rm -r $outdir/markers 

grep -P '_circ\t' $prokka_gff > $prokka_gff.circular 
grep -v -P '_circ\t' $prokka_gff > $prokka_gff.linear

echo "STEP 3 : DRAW >10KB CONTIGS" 
verif_result $draw_contigs_10kb
if [[ $file_exist == 1 ]]; then 
	echo ">10kb contigs are already representated. Use --force to overwrite" 
else
	bash $BIN/draw_linear.sh $assembly $prokka_gff.linear $draw_contigs_10kb 
fi 
rm $prokka_gff.linear 

verif_result $draw_contigs_circular 
if [[ $file_exist == 1 ]]; then 
	echo "Circular contigs draws are already exists. Use --force to overwrite" 
else 
	bash $BIN/draw_circular.sh $assembly $prokka_gff.circular $draw_contigs_circular
fi
rm $prokka_gff.circular

