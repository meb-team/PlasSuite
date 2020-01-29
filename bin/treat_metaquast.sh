function usage(){
	echo "usage : bash treat_metaquast.sh <metaquast treatment dir> <SR coverage value> <LR coverage value> <contamination value>" 
}

function count_length(){
	if [[ -s $1 ]]; then
		local length=$(cut -f 3 $1 | awk '{s+=$1} END {print s}')
	else 
		local length=0
	fi
	echo $length
}

function count_contig(){
	if [[ -s $1 ]]; then
		local contigs=$(wc -l $1 | cut -f 1 -d " ")
	else 
		local contigs=0
	fi
	echo $contigs
}	

function max_length(){
	if [[ -s $1 ]]; then
		local max_length=$(cut -f 3 $1 | sort -n | tail -n 1)
	else 
		local max_length=0
	fi
	echo $max_length	
}	

if [[ $# -ne 4 ]]; then 
	usage
	exit 1
fi

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink $tool_dir)

cd $1 

echo -e "Assembly\tIllumina coverage\tPacBio coverage\tContamination\tTotal length\tCorrect length\tAmbiguous length\tMisassembled length\tUnaligned length\tOthers_length\tTotal contigs\tCorrect contigs\tAmbiguous contigs\tMisassembled contigs\tUnaligned contigs\tOthers contigs\tMax contig length\tMax good contig length\tN50 all\tN50 good contigs\t%Plasmids coverage (correct contigs)\t%Plasmids coverage (all contigs)\tNumber plasmids complete\tPlasmids complete length\t%Plasmids complete (length)\tContamination length\tNumber contaminated contigs" > assemblies_stats.tsv

echo -e "Assembly\tIllumina coverage\tPacBio coverage\tContamination\tContig\tLength\tNumber" > contigs_stats.tsv

param="all correct ambiguous misassembled unaligned others" 

for f in $(ls all_alignments*); do 
	suf=$(echo $f | awk -F "all_alignments" '{print $2}' | cut -f 1 -d "." | sed 's/_//g')
	list_length=""
	list_contigs=""
	for p in $param; do 
		length=$(count_length $p\_contigs.$suf.tsv) 
		contigs=$(count_contig $p\_contigs.$suf.tsv) 
		echo -e "$suf\t$2\t$3\t$4\t$p\t$length\t$contigs" >> contigs_stats.tsv
		list_length="$list_length $length"
		list_contigs="$list_contigs $contigs" 
		
	done 	
	list_length=$(echo $list_length | sed "s/ /	/g") 
	list_contigs=$(echo $list_contigs | sed "s/ /	/g") 
	
	max_length=$(max_length all_contigs.$suf.tsv)	
	max_good_length=$(max_length good_contigs.$suf.tsv)
	
	N50=$(python3 $BIN/N50.py all_contigs.$suf.tsv) 
	N50_good=$(python3 $BIN/N50.py good_contigs.$suf.tsv)  
	
	grep -w $suf plasmids_stats.tsv > $suf.plasmids
	
	plasmids_cov=$(Rscript --vanilla $BIN/plasmids_coverage.R $suf.plasmids | cut -f 2 -d " ") 
	correct_cov=$(echo $plasmids_cov | cut -f 1 -d " ")
	all_cov=$(echo $plasmids_cov | cut -f 2 -d " ")
	
	plasmids_complete=$(grep -w $suf summary_plasmids_stats.tsv | cut -f 2-)
	
	length_cont=$(count_length contamination_contigs.$suf.tsv)
	contigs_cont=$(count_contig contamination_contigs.$suf.tsv)
	
	echo -e "$suf\t$2\t$3\t$4\t$list_length\t$list_contigs\t$max_length\t$max_good_length\t$N50\t$N50_good\t$correct_cov\t$all_cov\t$plasmids_complete\t$length_cont\t$contigs_cont" >> assemblies_stats.tsv
done 	

grep -v -w "all" contigs_stats.tsv > contigs_stats.tsv2 
mv contigs_stats.tsv2 contigs_stats.tsv
