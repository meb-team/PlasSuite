set -e 

function usage(){
	echo "usage : bash update_database.sh -o <output.fasta> --info <output.ncbi.info> 
	Options : 
	--db <fasta> : existing database to update. If not provided, create database.
	--clean : delete deprecated sequences which exists in current database but not in new NCBI plasmids databases.
	-h : display this help and quit"
}

function treat_args(){		
	if [[ ! $outdb ]]; then 
		quit=1 
		echo "You must give output file. Use -o option" 
	fi
	if [[ ! $info ]]; then 
		quit=1
		echo "You must give output ncbi info file. Use --info option" 
	fi	
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	if [[ $current_db ]]; then 
		verif_file $current_db "[update_database] $current_db doesn't found" "[update_database] $current_db found." 
	fi 
}



TEMP=$(getopt -o h,o: -l db:,clean,info: -- "$@")
eval set -- "$TEMP" 

while true ; do 
	case "$1" in 
		-o) 
			outdb=$2
			shift 2;;
		--db)	
			current_db=$2 
			shift 2;; 	
		--clean)
			clean=1 
			shift ;;
		--info) 
			info=$2
			shift 2;; 
		-h) 
			usage
			exit 1 
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

tmp=$(mktemp -d -p .) 

source $BIN/common_functions.sh 

treat_args
verif_args

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/plasmids.txt -O $info 

tail -n +2 $info | cut -f 6 | grep -v "-" > $tmp/plasmids.id 

if [[ $current_db ]]; then 
	echo "# Compare old and new database" 
	grep "^>" $current_db | cut -f 1 -d " " | tr -d ">" > $tmp/old_plasmids.id 
	python3 $BIN/intersect_files.py $tmp/old_plasmids.id $tmp/plasmids.id $tmp comp old new
	new_seq=$tmp/comp.new.specific.txt 
	if [[ $clean ]]; then 
		echo "# Delete deprecated sequences" 
		deprecated=$tmp/comp.old.specific.txt 
		echo "-- $(wc -l $deprecated | cut -f 1 -d " ") sequences"  
		bash $BIN/delete_seq_parallel.sh $current_db $deprecated $tmp/plasmids.nodeprec.fasta normal 6
		current_db=$tmp/plasmids.nodeprec.fasta 
	fi 
	echo "# Download new sequences" 
	echo "-- $(wc -l $new_seq | cut -f 1 -d " ") sequences provided"  
	python3 $BIN/download_plasmids.py $new_seq $tmp/new_plasmids.fasta
	echo "-- $(grep "^>" -c $tmp/new_plasmids.fasta) downloaded by BioPython Entrez Module" 
	cat $current_db $tmp/new_plasmids.fasta > $outdb 
	echo "-- $(grep "^>" -c $outdb) plasmids in new database"
fi 

rm -r $tmp 




