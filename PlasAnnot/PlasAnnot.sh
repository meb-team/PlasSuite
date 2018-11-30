set -e 

function usage(){ 
	echo "usage : bash all_annotation.sh -f <contigs.fasta> -o <outdir> 
	If you have circular contigs in your assembly, their id must contains 'circ' to be identified and correctly treated. Be sure you have add enough bases to those circular contigs for complete protein detection.  
	options : 
	--prefix <prefix for results (default : assembly name)
	--force : overwrite results
	--resfam : resfam hmm you want to use first for prokka annotation (default : plasmidome_databases/Resfams/Resfams.hmm)
	--resfam_annot : resfam annotations (default : plasmidome_databases/Resfams/Resfams.annot) 
	--resfam_info : Resfams metadata (default : plasmidome_databases/Resfams/Resfams.info) 
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
	if [[ ! $resfam_annot ]]; then 
		resfam_annot=plasmidome_databases/Resfams/Resfams.annot
	fi 
	if [[ ! $resfam_info ]]; then 
		resfam_info=plasmidome_databases/Resfams/Resfams.info 
	fi 
	verif_file $hmm "[PlasAnnot] Resfam HMM profile doesn't found in $hmm. Use --resfam to specify an other." "[PlasAnnot] Resfam HMM profile found in $hmm"
	verif_dir $markers_db "[PlasAnnot] Plasmids markers database doesn't found in $markers_db. Use --markers_db to specify an other." "[PlasAnnot] Plasmids markers database found in $markers_db" 
	verif_file $markers_db/mob.proteins.faa "[PlasAnnot] Mob proteins doesn't found in $markers_db/mob.proteins.faa" "[PlasAnnot] Mob proteins found in $markers_db/mob.proteins.faa"
	verif_file $markers_db/mpf.proteins.faa "[PlasAnnot] Mpf proteins doesn't found in $markers_db/mpf.proteins.faa" "[PlasAnnot] Mpf proteins found in $markers_db/mpf.proteins.faa"
	verif_file $markers_db/rep.dna.fas "[PlasAnnot] Rep dna doesn't found in $markers_db/rep.dna.fas" "[PlasAnnot] Rep dna found in $markers_db/rep.dna.fas"
	verif_file $resfam_annot "[PlasAnnot] Resfam annotations doesn't found in $resfam_annot. Use --resfam_annot to specify an other." "[PlasAnnot] Resfam annotations found in $resfam_annot"
	verif_file $resfam_info "[PlasAnnot] Resfam metadata doesn't found in $resfam_info. Use --resfam_info to specify an other." "[PlasAnnot] Resfam metadata found in $resfam_info" 
}

function set_default(){
	stats=$outdir/$prefix.stats 
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
	markers=$outdir/$prefix.markers.id
}	

TEMP=$(getopt -o h,f:,o: -l prefix:,force,resfam:,markers_db:,resfam_annot:,resfam_info: -- "$@")
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
		--resfam_annot)
			resfam_annot=$2
			shift 2 ;; 
		--resfam_info)
			resfam_info=$2 
			shift 2 ;; 
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

echo -e "Sample\tCDS with resistances\tLength CDS with resistances (nt)\t%resistances\tCDS with plasmids markers\tLength CDS with plasmids markers\t%plasmids markers" > $stats 

current_dir=$(pwd) 
echo "STEP 1 : PROKKA ANNOTATION" 
verif_result $prokka_gff 
if [[ $file_exist == 1 ]]; then
	echo "Prokka annotation results already exists. Use --force to overwrite" 
else 
	if [[ ! -f $hmm.h3f ]]; then 
		hmmpress $hmm 
	fi
	echo "[annotation] Run Prokka..." 
	prokka $assembly --outdir $outdir --prefix $prefix --metagenome --hmms $hmm --quiet --rawproduct --force
	rm $outdir/$prefix.sqn $outdir/$prefix.fna $outdir/$prefix.fsa $outdir/$prefix.tbl $outdir/$prefix.gbk 
fi

echo "STEP 2 : RETRIEVE PLASMIDS MARKERS" 
verif_result $markers
if [[ $file_exist == 1 ]]; then
	echo "Retrieve plasmids results already exists. Use --force to overwrite" 
else 
	bash $BIN/search_plasmids_markers_prokka.sh -p $outdir/$prefix.faa -o $outdir/markers --db $markers_db -g $prokka_gff --prefix $prefix -d $outdir/$prefix.ffn --force
	grep "mob_suite" $prokka_gff_markers | cut -f 9 | cut -f 2 -d "=" | cut -f 1 -d ";" | sort -u > $markers 
	mv $prokka_gff_markers $prokka_gff 
	rm -r $outdir/markers 
fi

echo "STEP 3 : ISOLATE RESISTANCES" 
resistances=$outdir/$prefix.resistances
python3 $BIN/extract_res.py $prokka_gff > $resistances 
tail -n +2 $resistances > $resistances.nohead
echo -e "$(head -n 1 $resistances)\tResfams_Ab_classif\t$(head -n 1 $resfam_annot | cut -f 2-)" > $resistances.head
for profile in $(tail -n +2 $resistances | cut -f 2); do
	echo -e "$(grep -w $profile $resfam_info | cut -f 7)\t$(grep -w $profile $resfam_annot | cut -f 2-)" 
done > $resistances.desc 
paste $resistances.nohead $resistances.desc > $resistances.all_desc
cat $resistances.head $resistances.all_desc > $resistances.detailed 
rm $resistances.head $resistances.desc $resistances.nohead $resistances.all_desc
mv $resistances.detailed $resistances 

echo "STEP 4 : STATS" 
all=$outdir/$prefix.ffn
nb_all=$(grep "^>" -c $all) 
tail -n +2 $resistances | cut -f 1 > $resistances.id 
nb_resistances=$(wc -l $resistances.id | cut -f 1 -d " ") 
nb_markers=$(wc -l $markers | cut -f 1 -d " ") 
length_all=$(python3 $BIN/total_length_fasta.py $all) 
length_resistances=$(python3 $BIN/total_length_contig_list.py $all $resistances.id) 
length_markers=$(python3 $BIN/total_length_contig_list.py $all $markers) 
perc_resistances=$(echo $length_all $length_resistances | awk '{print $2/$1*100}') 
perc_markers=$(echo $length_all $length_markers | awk '{print $2/$1*100}') 
echo -e "$prefix\t$nb_resistances\t$length_resistances\t$perc_resistances\t$nb_markers\t$length_markers\t$perc_markers" >> $stats

set +e 
grep -P '_circ\t' $prokka_gff > $prokka_gff.circular 
grep -v -P '_circ\t' $prokka_gff > $prokka_gff.linear
set -e 

echo "STEP 5 : DRAW >10KB CONTIGS" 
verif_result $draw_contigs_10kb
if [[ $file_exist == 1 ]]; then 
	echo ">10kb contigs are already representated. Use --force to overwrite" 
else
	bash $BIN/draw_linear.sh $assembly $prokka_gff.linear $draw_contigs_10kb 
fi 
rm $prokka_gff.linear 

if [[ -s $prokka_gff.circular ]]; then 
	echo "STEP 6 : DRAW CIRCULAR CONTIGS" 
	verif_result $draw_contigs_circular 
	if [[ $file_exist == 1 ]]; then 
		echo "Circular contigs draws are already exists. Use --force to overwrite" 
	else 
		bash $BIN/draw_circular.sh $assembly $prokka_gff.circular $draw_contigs_circular
	fi	
fi
rm $prokka_gff.circular
