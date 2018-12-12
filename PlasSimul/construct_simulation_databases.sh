function usage(){
	echo "bash construct_simulation_databases.sh --plasmids_db <plasmids.fasta> --chrm_db <chrm.fasta> --plasmids_taxo <plasmids.taxo.tsv> --chrm_taxo <chrm.taxo.tsv> -o <output directory>
	[Options]:
	--n_plasmids <int> : number of plasmids to select (default:2000)
	--n_chrm <int> : number of chromosomes to select (default:500)
	--rna_db : rna_databases (default : $HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta" 
}	

function treat_args(){
	if [[ ! $plasmids_db ]];then
		quit=1
		echo "You must give plasmids database. Use --plasmids_db option"
	fi	
	if [[ ! $chrm_db ]];then
		quit=1
		echo "You must give chromosomes database. Use --chrm_db option"
	fi	
	if [[ ! $plasmids_taxo ]]; then 
		quit=1
		echo "You must give plasmids taxonomy. Use --plasmids_taxo option" 
	fi 
	if [[ ! $chrm_taxo ]]; then 
		quit=1 
		echo "You must give chromosomes taxonomy. Use --chrm_taxo option" 
	fi 
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directroy. Use -o option"  
	fi 
	if [[ $quit ]]; then 
		exit 1
	fi 
}	


function verif_args(){
	verif_file $plasmids_db "[ConstructDatabase] Plasmids database doesn't found in $plasmids_db" "[ConstructDatabase] Plasmids database found in $plasmids_db"
	verif_file $chrm_db "[ConstructDatabase] Chromosomes database doesn't found in $chrm_db" "[ConstructDatabase] Chromosomes database found in $chrm_db"
	verif_file $plasmids_taxo "[ConstructDatabase] Plasmids taxonomy doesn't found in $plasmids_taxo" "[ConstructDatabase] Plasmids taxonomy found in $plasmids_taxo"
	verif_file $chrm_taxo "[ConstructDatabase] Chromosomes taxonomy doesn't found in $chrm_taxo" "[ConstructDatabase] Chromosomes taxonomy found in $chrm_taxo"
	mkdir -p $outdir 
	if [[ ! $n_chrm ]]; then 
		n_chrm=500
	fi 
	if [[ ! $n_plasmids ]]; then 
		n_plasmids=2000
	fi 
	if [[ ! $rna_db ]]; then 
		rna_db=$HOME/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta
	fi 
	verif_file $rna_db "[ConstructDatabase] rRNA database doesn't found in $rna_db" "[ConstructDatabase] rRNA database found in $rna_db"
}

TEMP=$(getopt -o h,o: -l plasmids_db:,chrm_db:,plasmids_taxo:,chrm_taxo:,n_chrm:,n_plasmids: -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		--plasmids_db) 
			plasmids_db=$2
			shift 2;;
		--chrm_db)
			chrm_db=$2
			shift 2;;
		--plasmids_taxo) 	
			plasmids_taxo=$2
			shift 2;; 
		--chrm_taxo) 
			chrm_taxo=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		--n_chrm)
			n_chrm=$2
			shift 2;; 
		--n_plasmids) 
			n_plasmids=$2
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

tmp=$(mktemp -d -p .) 

echo "# PLASMIDS SELECTION" 
tail -n +2 $plasmids_taxo | sort -u -k 8 > $plasmids_taxo.oneSpecie 
shuf -n $n_plasmids $plasmids_taxo.oneSpecie | cut -f 1 > $plasmids_taxo.oneSpecie.select$n_plasmids 
python3 $BIN/seq_from_list.py --keep $plasmids_taxo.oneSpecie.select$n_plasmids --input_fasta $plasmids_db --output_fasta $outdir/plasmids.select$n_plasmids.fasta

echo "# CHRM SELECTION" 
cut -f 1 $chrm_taxo | cut -f 1 -d "." > $chrm_taxo.simpleId
grep "^>" $rna_db | cut -f 1 -d "." | tr -d ">" > $rna_db.simpleId 
python3 $BIN/intersect_files.py $chrm_taxo.simpleId $rna_db.simpleId $tmp chrm_rna chrm rna
grep -f $tmp/chrm_rna.common.txt $chrm_taxo > $chrm_taxo.withRNA
sort -u -k 9 $chrm_taxo.withRNA | cut -f 1 > $chrm_taxo.withRNA.oneSpecie
shuf -n $n_chrm $chrm_taxo.withRNA.oneSpecie > $chrm_taxo.withRNA.oneSpecie.select$n_chrm 
python3 $BIN/seq_from_list.py --keep $chrm_taxo.withRNA.oneSpecie.select$n_chrm --input_fasta $chrm_db --output_fasta $outdir/prokaryotes.select$n_chrm.fasta
rm -r $tmp 
