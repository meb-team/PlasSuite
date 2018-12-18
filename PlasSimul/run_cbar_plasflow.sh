set -e 

function usage(){
	echo 'usage : run_cbar_plasflow.sh <plasflow thresold detection> <outdir> <comma-separated list of assembly(ies) name(s)> <contig fasta file 1> <contig fasta file 2> <...> <contig fasta file X>'
}

if [ "$#" -lt 4 ]
then 
	usage
	exit 1 
fi

thres=$1
shift 
outdir=$1
shift 
assemblies=($(echo $1 | tr "," " "))  
shift
contigs_all=($@)

nb=$((${#assemblies[@]}-1))

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin

mkdir -p $outdir 
for i in `seq 0 $nb`; do 
	assembly=${assemblies[$i]}
	echo $assembly 
	contigs=${contigs_all[$i]}
	echo $contigs 
	#RUN AND TREAT CBAR 
	bash $BIN/run_cbar.sh $assembly $contigs -o $outdir 
	cbar_plasmids=$outdir/$assembly.cbar.plasmids.id
	cbar_not_plasmids=$outdir/$assembly.cbar.notplasmids
	grep "Plasmid" $outdir/$assembly.cbar.prediction.txt | cut -f 1 > $cbar_plasmids
	grep "Chromosome" $outdir/$assembly.cbar.prediction.txt | cut -f 1 > $cbar_not_plasmids.id
	python3 $BIN/seq_from_list.py --input_fasta $contigs --keep $cbar_not_plasmids.id --output_fasta $cbar_not_plasmids.fasta
	
	#RUN PLASFLOW 
	bash $BIN/run_plasflow.sh $assembly $cbar_not_plasmids.fasta -o $outdir --thres $thres 
	plasflow_plasmids=$outdir/$assembly.plasflow$thres.plasmids.id 
	plasflow_chromosomes=$outdir/$assembly.plasflow$thres.chromosomes.id  
	plasflow_unclassified=$outdir/$assembly.plasflow$thres.unclassified.id

	grep ">" $outdir/$assembly.plasflow$thres.plasmids.fasta | tr -d '>' > $plasflow_plasmids
	grep ">" $outdir/$assembly.plasflow$thres.chromosomes.fasta | tr -d ">" > $plasflow_chromosomes

	cut -f 1 -d " " $plasflow_plasmids > $plasflow_plasmids\2
	combined_plasmids=$outdir/$assembly.cbar.plasflow$thres.plasmids 
	cat $plasflow_plasmids\2 $cbar_plasmids > $combined_plasmids.id
	
	rm $plasflow_plasmids\2
	
	combined_noplasmids=$outdir/$assembly.cbar.plasflow$thres.noplasmids
	cat $plasflow_chromosomes $plasflow_unclassified > $combined_noplasmids.id  
	combined_chromosomes=$outdir/$assembly.cbar.plasflow$thres.chromosomes.id
	mv $plasflow_chromosomes $combined_chromosomes
	
	python3 $BIN/seq_from_list.py --input_fasta $contigs --keep $combined_plasmids.id --output_fasta $combined_plasmids.fasta 
	rm $outdir/*.npy $outdir/$assembly.cbar.prediction.txt $cbar_plasmids $cbar_not_plasmids.id $cbar_not_plasmids.fasta $outdir/$assembly.plasflow*	
done
