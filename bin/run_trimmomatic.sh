function usage(){
	echo 'usage : bash run_trimmomatic.sh <fastq reads1> <fastq reads2> <outdir> <prefix>'
}

if [[ $# -ne 4 ]]; then 
	usage
	exit
fi 

r1=$1
r2=$2
out=$3/$4
mkdir -p $3

java -jar /usr/local/Trimmomatic-0.33/trimmomatic-0.33.jar PE -threads 6 -phred33 $r1 $r2 $out\_R1_trimmed_pe.fastq $out\_R1_trimmed_se.fastq $out\_R2_trimmed_pe.fastq $out\_R2_trimmed_se.fastq LEADING:28 TRAILING:28 SLIDINGWINDOW:4:15 MINLEN:30
cat $out\_R1_trimmed_se.fastq $out\_R2_trimmed_se.fastq > $out\_trimmed_se.fastq
rm $out\_R1_trimmed_se.fastq $out\_R2_trimmed_se.fastq 	
