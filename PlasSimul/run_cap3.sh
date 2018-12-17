set -e 

function usage(){
	echo 'usage : run_cap3.sh <fasta_assembly_file1> <fasta_assembly_file2> <...> [options]    
	[options] : 
	-o outdir 
	--l_fq fastq file with long reads 
	--l_fa fasta file with long reads  
	--ov_length : overlap length cutoff (cap 3 default : 40) 
	--ov_percent : overlap percent identity cutoff (cap 3 default : 90) 
	' 
}

TEMP=$(getopt -o o:,h -l l_fq:,l_fa:,ov_length:,ov_percent: -- "$@")
eval set -- "$TEMP"

ov_length=40
ov_percent=90
tmp_dir=`mktemp -d -p .`
l_file=''
tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin

while true ; do 
	case "$1" in 
		--l_fq) 
			l_fq=$2
			shift 2;; 
		--l_fa)
			l_fa=$2 
			shift 2;; 
		--ov_length)
			ov_length=$2
			shift 2;; 
		--ov_percent)
			ov_percent=$2
			shift 2;; 	
		-h) 
			usage
			shift ;;
		-o) 
			outdir=$2
			shift 2;;		
		--)  
			shift ; break ;; 					
	esac 
done 	

if [ "$#" -eq 0 ]
then 
	usage
	echo 'give fasta assembly file(s)'  
	exit 1
fi	 

if [[ ! $outdir ]]; then
	usage 
	echo "give outdir" 
	exit 1 
fi	

mkdir -p $outdir 

if [[ $l_fa ]]; then 
	l_file=$l_fa
elif [[ $l_fq ]]; then  
	sed -n '1~4s/^@/>/p;2~4p' $l_fq > $tmp_dir/long_reads.fasta
	l_file=$tmp_dir/long_reads.fasta
else 
	echo 'You give no long read file' 	
fi 

cat $@ $l_file > $outdir/combined_reads.fasta

cap3 $outdir/combined_reads.fasta -o $ov_length -p $ov_percent

grep "^>" $outdir/combined_reads.fasta.cap.singlets | grep -v "reference" | cut -f 2 -d ">" > $outdir/combined_reads.fasta.cap.singlets.SR.id 

python3 $BIN/seq_from_list.py --input_fasta $outdir/combined_reads.fasta.cap.singlets --keep $outdir/combined_reads.fasta.cap.singlets.SR.id --output_fasta $outdir/combined_reads.fasta.cap.singlets.SR

cat $outdir/combined_reads.fasta.cap.contigs $outdir/combined_reads.fasta.cap.singlets.SR > $outdir/cap3_assembly_wsinglets_SR.fasta

rm -r $tmp_dir 



