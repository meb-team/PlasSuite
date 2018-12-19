function usage(){
		echo "usage : bash stats_plasmid_detection.sh <real plasmids> <real chromosomes> <predict plasmids> <predict chromosomes> <assembly> <sample> <outfile>" 
}	

if [[ $# -ne 7 ]]; then
	usage 
	exit 1 
fi 

BIN2=/databis/hilpert/plasmidome_realdata2/bin
BIN=/databis/hilpert/plasmidome_project/bin

tmp=$(mktemp -d -p ".") 
echo $tmp

real_plasmids=$1
real_chrm=$2
predict_plasmids=$3
predict_chrm=$4
assembly=$5
sample=$6
outfile=$7

python3 $BIN2/intersect_files.py $real_plasmids $predict_plasmids $tmp real_plasmids.predict_plasmids real_plasmids predict_plasmids
python3 $BIN2/intersect_files.py $real_chrm $predict_chrm $tmp real_chrm.predict_chrm real_chrm predict_chrm
python3 $BIN2/intersect_files.py $real_chrm $predict_plasmids $tmp real_chrm.predict_plasmids real_chrm predict_plasmids
python3 $BIN2/intersect_files.py $real_plasmids $predict_chrm $tmp real_plasmids.predict_chrm real_plasmids predict_chrm

VP=$(python3 $BIN/total_length_contig_list.py $assembly $tmp/real_plasmids.predict_plasmids.common.txt) 
VN=$(python3 $BIN/total_length_contig_list.py $assembly $tmp/real_chrm.predict_chrm.common.txt) 
FP=$(python3 $BIN/total_length_contig_list.py $assembly $tmp/real_chrm.predict_plasmids.common.txt) 
FN=$(python3 $BIN/total_length_contig_list.py $assembly $tmp/real_plasmids.predict_chrm.common.txt) 

Acc=$(echo $VP $VN $FP $FN | awk '{print ($1+$2)/($1+$2+$3+$4)}')
Precision=$(echo $VP $FP | awk '{print $1/($1+$2)}')  
Recall=$(echo $VP $FN | awk '{print $1/($1+$2)}') 
F1=$(echo $Precision $Recall | awk '{print (2*$1*$2)/($1+$2)}') 
F05=$(echo $VP $FN $FP | awk '{print (1.25*$1)/(1.25*$1+0.25*$2+$3)}')

echo -e "Sample\tTrue positives\tTrue negatives\tFalse positives\tFalse negatives\tAccuracy\tPrecision\tRecall\tF1-Score\tF0.5-Score" > $outfile
echo -e "$sample\t$VP\t$VN\t$FP\t$FN\t$Acc\t$Precision\t$Recall\t$F1\t$F05" >> $outfile

#rm -r $tmp
