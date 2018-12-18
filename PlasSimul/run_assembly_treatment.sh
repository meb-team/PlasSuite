set -e 

function usage(){
	echo 'usage : run_assembly_treatment.sh <list_of_assemblies_names> <assembly_file1> <assembly_file2> <...> [options]    
	[options] : 
	-o outdir (default : assembly_evaluation)  
	--metaquast : run metaquast
	--metaquast_treatment : run metaquast results treatment 
	--metaquast_cont : launch metaquast for contamination 
	--suffix : suffix for results dir (default : none) 
	--sr_cov <short reads coverage> : for output files info (default : "-")
	--lr_cov <long reads coverage> : for output files info (default : "-")
	--cont <contamination level> : for output files info (default : "-")
	--plasmid_db <plasmids database> : directory with separate plasmids sequences (default : databases/plasmids_sequences) 
	--cont_db <contaminants database> : directory with separate contaminants sequences (default : databases/contaminants_sequences)
	--plasmids_length <plasmids_length.tsv> : file with length informations for plasmids, generate by sequences_length.py (default : databases/plasmids.length)
	--plasmids_ab <plasmids_abundance.tsv> : file with plasmids abundance in simulated sequencing (default : simulated_reads/plasmids_abundance.txt)' 
}

function treat_args(){
	if [[ ! $outdir ]]; then 
		echo "You must give output directory. Use -o option" 
		quit=1
	fi  

	if [[ ! $metaquast ]] && [[ ! $metaquast_treatment  ]] && [[ ! $metaquast_cont ]]  
	then  
		quit=1
		echo 'You must select --metaquast and/or --metaquast_treatment and/or --metaquast_cont' 
	fi 		
	
	if [[ $quit ]]; then 
		exit 1
	fi 
	
	mkdir -p $outdir
}	

function verif_args(){
	for assembly in $assemblies_files; do 
		verif_file $assembly "[assembly_treatment] $assembly doesn't found" "[assembly_treatment] $assembly found"   
	done 
	verif_dir $plasmid_db "[assembly_treatment] Plasmids database doesn't found in $plasmid_db. Use --plasmid_db to provide it." "[assembly_treatment] Plasmids database found in $plasmid_db"
	verif_dir $cont_db "[assembly_treatment] Contaminants database doesn't found in $cont_db. Use --cont_db to provide it." "[assembly_treatment] Contaminants database found in $cont_db"
	verif_file $plasmids_length "[assembly_treatment] Plasmids length file doesn't found in $plasmids_length. Use --plasmids_length to provide it." "[assembly_treatment] Plasmids length file found in $plasmids_length" 
	verif_file $plasmids_ab "[assembly_treatment] Plasmids abundance file doesn't found in $plasmids_ab. Use --plasmids_ab to provide it." "[assembly_treatment] Plasmids abundance file found in $plasmids_ab" 
}	

TEMP=$(getopt -o o:,h -l metaquast,metaquast_treatment,assembly_dir:,db_dir:,suffix:,mode:,sr_cov:,lr_cov:,cont:,metaquast_cont,plasmid_db:,cont_db:,plasmids_length:,plasmids_ab: -- "$@")
eval set -- "$TEMP" 

plasmids_ab=simulated_reads/plasmids_abundance.txt 
suffix=''
cont="-"
sr_coverage="-"
lr_coverage="-"
plasmid_db="databases/plasmids_sequences" 
cont_db="databases/contaminants_sequences" 
plasmids_length="databases/plasmids.length" 

while true ; do 
	case "$1" in 
		--metaquast) 
			metaquast=1 
			shift;; 
		--metaquast_treatment)
			metaquast_treatment=1 
			shift ;; 		
		-h) 
			usage
			shift ;;
		-o) 
			outdir=$2
			shift 2;;	
		--suffix) 
			suffix=$2
			shift 2 ;; 	
		--plasmid_db)
			plasmid_db=$2
			shift 2;; 
		--cont_db)	
			cont_db=$2
			shift 2;;
		--plasmids_length) 
			plasmids_length=$2
			shift 2;;	
		--sr_cov)
			sr_coverage=$2
			shift 2;; 
		--lr_cov)
			lr_coverage=$2
			shift 2;; 
		--cont) 		
			cont=$2
			shift 2;; 
		--metaquast_cont)
			metaquast_cont=1
			shift;; 
		--plasmids_ab) 
			plasmids_ab=$2 
			shift 2 ;; 
		--)  
			shift ; break ;; 
								
	esac 
done 	

if [ "$#" -eq 0 ]
then 
	usage
	echo 'give list of assemblies'  
	exit 1 
elif [ "$#" -eq 1 ]
then 
	usage 
	echo 'give assemblies files' 	
	exit 1 
fi

list_of_assemblies_names=$1
assemblies_format=$(echo $list_of_assemblies_names | tr "," " ")  
 
shift 

assemblies_files="" 
 
while [[ $@ ]]; do 
	assemblies_files=$assemblies_files" "$1 
	shift 
done 

treat_args 

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin

source $BIN/common_functions.sh 

verif_args

treatment_dir=$outdir/metaquast_treatment_$suffix 
mkdir -p $treatment_dir 
assemblies_format_ar=($assemblies_format) 
assemblies_files_ar=($assemblies_files) 
nb=$((${#assemblies_files_ar[@]}-1)) 

if [[ $metaquast ]]; then 
	db=$plasmid_db 
	~/quast/metaquast.py -R $db -l $list_of_assemblies_names -o $outdir/metaquast_$suffix $assemblies_files -m 1000 --no-plots --fast
	for a in $assemblies_format ; do 
		tail -n +2 $outdir/metaquast_$suffix/combined_reference/contigs_reports/all_alignments_$a.tsv | tac > $treatment_dir/all_alignments_$a.rev.tsv
	done 
fi 	

if [[ $metaquast_cont ]]; then 
	echo "METAQUAST CONT" 
	db=$cont_db
	unaligned_files=""
	for i in `seq 0 $nb`; do 
		assembly=${assemblies_format_ar[$i]} 
		contigs=${assemblies_files_ar[$i]}
		echo $assembly 
		echo $contigs 
		unaligned_contigs=$treatment_dir/$assembly\_unaligned_contigs 
		if [ ! -f $treatment_dir/all_alignments_$assembly\.rev.tsv ]; then 
			usage 
			echo "Metaquast results doesn't exists, launch --metaquast" 
			exit 
		fi 	
		echo $unaligned_contigs.txt  
		grep "CONTIG" $treatment_dir/all_alignments_$assembly.rev.tsv | awk '{if($4=="unaligned")print}' | cut -f 2 > $unaligned_contigs.txt 
		python3 $BIN/seq_from_list.py --input_fasta $contigs --keep $unaligned_contigs.txt --output_fasta $unaligned_contigs.fasta
		unaligned_files=$unaligned_files" "$unaligned_contigs.fasta 		
	done 
	~/quast/metaquast.py -R $db -l $list_of_assemblies_names -o $outdir/metaquast_$suffix\_cont $unaligned_files -m 1000 --no-plots --fast 		
	for a in $assemblies_format ; do 
		if [[ -f $outdir/metaquast_$suffix\_cont/combined_reference/contigs_reports/all_alignments_$a.tsv ]]; then 
			tail -n +2 $outdir/metaquast_$suffix\_cont/combined_reference/contigs_reports/all_alignments_$a.tsv | tac > $treatment_dir/cont_all_alignments_$a.rev.tsv
		fi	
	done 
fi 
	

if [[ $metaquast_treatment ]]; then 
	mode_cont="nocont"
	for i in `seq 0 $nb`; do 
		assembly=${assemblies_format_ar[$i]} 
		if [ ! -f $treatment_dir/all_alignments_$assembly\.rev.tsv ];then
			usage
			echo "Metaquast results doesn't exit, launch --metaquast first" 
			exit 
		fi
	done	
	
	if [[ $metaquast_cont ]]; then 
		mode_cont="cont"
		for i in `seq 0 $nb`; do 
			assembly=${assemblies_format_ar[$i]} 
			if [ ! -f $treatment_dir/cont_all_alignments_$assembly\.rev.tsv ];then
				usage
				echo "Metaquast contamination results doesn't exit, launch --metaquast_cont first" 
				exit
			fi
		done	
	fi	
	
	curdir=$(pwd)
	cd $treatment_dir
	set +e
	for f in $(ls all_alignments*); do 
		suf=$(echo $f | awk -F "all_alignments" '{print $2}' | cut -f 1 -d "." | sed 's/_//g')
		grep "CONTIG" $f > all_contigs.$suf.tsv
		grep "CONTIG" $f | grep -w "correct" > correct_contigs.$suf.tsv
		grep "CONTIG" $f | grep -w "ambiguous" > ambiguous_contigs.$suf.tsv
		grep "CONTIG" $f | grep -w "misassembled" > misassembled_contigs.$suf.tsv
		cat correct_contigs.$suf.tsv ambiguous_contigs.$suf.tsv misassembled_contigs.$suf.tsv > plasmids_contigs.$suf.tsv
		cut -f 2 plasmids_contigs.$suf.tsv > plasmids_contigs.$suf.id
		grep "CONTIG" $f | grep -w "unaligned" > unaligned_contigs.$suf.tsv 
		grep "CONTIG" $f | grep -w -v "unaligned" | grep -w -v "correct" | grep -w -v "ambiguous" | grep -w -v "misassembled" > others_contigs.$suf.tsv 
		cat correct_contigs.$suf.tsv ambiguous_contigs.$suf.tsv > good_contigs.$suf.tsv
		if [[ $mode_cont == "cont" ]]; then 
			grep "CONTIG" cont_all_alignments_$suf.rev.tsv | grep -w "correct" > contamination_contigs.correct.$suf.tsv
			grep "CONTIG" cont_all_alignments_$suf.rev.tsv | grep -w "ambiguous" > contamination_contigs.ambiguous.$suf.tsv
			grep "CONTIG" cont_all_alignments_$suf.rev.tsv | grep -w "misassembled" > contamination_contigs.misassembled.$suf.tsv
			cat contamination_contigs.correct.$suf.tsv contamination_contigs.ambiguous.$suf.tsv contamination_contigs.misassembled.$suf.tsv > contamination_contigs.$suf.tsv 
			cut -f 2 contamination_contigs.$suf.tsv > chromosomes_contigs.$suf.id
		fi
	done	
	set -e 

	cd $curdir
	
	python3 $BIN/treat_metaquast.py $treatment_dir $plasmids_length $list_of_assemblies_names $sr_coverage $lr_coverage $cont
	bash $BIN/treat_metaquast.sh $treatment_dir $sr_coverage $lr_coverage $cont 	
	bash $BIN/add_abundance.sh $treatment_dir/plasmids_stats.tsv $plasmids_ab
	
fi 
	 	




