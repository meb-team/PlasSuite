set -e 

function usage(){
	echo 'usage : simulate_reads.sh <input.fasta> -o <outdir> [options]    
	[options] : 
	-p parallelization (number of threads, default 4) 
	--pacbio coverage_value : generate pacbio simulation (error free, 6kb).  
	--illumina coverage_value : generate illumina simulation (error free, 2x150kb, insert 350)   
	--ab_file : abundance file for each species in simulated reads (required) 
	--diversity : value of powerlaw for diversity (default : 0.1)
	--contamination : contamination level (between 0 and 1)  
	--contamination_f : fasta file with contaminants (required if --contamination) 
	--ab_file_cont : abundance for each contaminants (required if --contamination) 
	' 
}

function treat_args(){
	if [[ ! $input ]];then
		quit=1
		echo "You must give input."
	fi		
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi
	if [[ $ILLUMINA == 0 && $PACBIO == 0 ]]; then 
		quit=1 
		echo "You must use --illumina and/or --pacbio"
	fi 
	if [[ ! $ab_file ]]; then 
		quit=1 
		echo "You must give abundance file. Use --ab_file option" 
	fi 	
	if [[ $contamination ]]; then 
		if [[ ! $contamination_f ]]; then 
			quit=1
			echo "You must give contaminants fasta file. Use --contamination_f option." 
		fi 
		if [[ ! $ab_file_cont ]]; then 
			quit=1 
			echo "You must give contaminants abundance file. Use --ab_file_cont option" 
		fi
	fi 
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $input "[SequencingSimulation] Input doesn't found in $input." "[SequencingSimulation] Input found in $input"
	mkdir -p $outdir 
}

function run_illumina(){
	echo "# Run Illumina simulation $coverage_illumina" 
	nb_seq=`grep "^>" -c $input`
	seq_per_file=$(($nb_seq/($p-1))) 
	awk 'BEGIN {n_seq=0;n=0;} /^>/ {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/myseq%d.fa",n);} print >> file; n_seq++; next;} { print >> file; }' < $input
	ls $tmp 
	awk 'BEGIN {n_seq=0;n=0;} {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/id%d.txt",n)} print >> file; n_seq++; next;} { print >> file; }' < $input.id 
	ls $tmp 
	for i in `seq $p`; do 
		grep -w -f $tmp/id$i.txt $ab_file > $tmp/abfile$i.txt 
		echo grinder -rf $tmp/myseq$i.fa -cf $coverage_illumina -rd 150 -id 350 -fq 1 -ql 30 10 -od $outdir -bn grinder-illumina-$coverage_illumina\X-am$diversity.$i -af $tmp/abfile$i.txt >> $tmp/commands.txt  
	done
	ls $tmp 
	parallel < $tmp/commands.txt 
	cd $outdir 
	cat grinder-illumina-$coverage_illumina\X-am$diversity.*-reads.fastq > grinder-illumina-$coverage_illumina\X-am$diversity-reads.fastq	
	rm grinder-illumina-$coverage_illumina\X-am$diversity.*-reads.fastq
	rm grinder-illumina-$coverage_illumina\X-am$diversity.*-ranks.txt 
	cd $tmp 
	rm * 
	cd $CURDIR
	
}	

	
function run_illumina_cont(){
	read=`grep "^@" -c $outdir/grinder-illumina-$coverage_illumina\X-am$diversity-reads.fastq`
	read_cont=$(echo $read $contamination | awk '{printf "%i\n",$1*$2}')
	tot_length=`python3 $BIN/total_length_fasta.py $contamination_f`
	cov=$(echo $read_cont $tot_length | awk '{print (150*$1)/$2}') 
	
	nb_seq=`grep "^>" -c $contamination_f`
	if [[ $(($nb_seq%($p-1))) == 0 ]]; then 
		seq_per_file=$(($nb_seq/$p))
	else 
		seq_per_file=$(($nb_seq/($p-1)))	
	fi 
	echo $seq_per_file 
	awk 'BEGIN {n_seq=0;n=0;} /^>/ {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/cont%d.fa",n);} print >> file; n_seq++; next;} { print >> file; }' < $contamination_f
	awk 'BEGIN {n_seq=0;n=0;} {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/contid%d.txt",n)} print >> file; n_seq++; next;} { print >> file; }' < $contamination_f.id

	for i in `seq $p`; do 
		grep -w -f $tmp/contid$i.txt $ab_file_cont > $tmp/abfilecont$i.txt 
		echo grinder -rf $tmp/cont$i.fa -cf $cov -rd 150 -id 350 -fq 1 -ql 30 10 -od $outdir -bn grinder-illumina-$coverage_illumina\X-am$diversity-cont$contamination.$i -af $tmp/abfilecont$i.txt >> $tmp/commands_cont.txt  	
	done
	parallel < $tmp/commands_cont.txt 
	cd $outdir 
	cat grinder-illumina-$coverage_illumina\X-am$diversity-cont$contamination.*-reads.fastq > grinder-illumina-$coverage_illumina\X-am$diversity-cont$contamination\-reads.fastq	
	rm grinder-illumina-$coverage_illumina\X-am$diversity-cont$contamination.*-reads.fastq
	rm grinder-illumina-$coverage_illumina\X-am$diversity-cont$contamination.*-ranks.txt

	cat grinder-illumina-$coverage_illumina\X-am$diversity-reads.fastq grinder-illumina-$coverage_illumina\X-am$diversity-cont$contamination\-reads.fastq > grinder-illumina-$coverage_illumina\X-am$diversity-with-cont$contamination\-reads.fastq 
	
	cd $tmp 
	rm *
	cd $CURDIR
}	

function run_pacbio(){
	nb_seq=`grep "^>" -c $input`
	seq_per_file=$(($nb_seq/($p-1))) 
	awk 'BEGIN {n_seq=0;n=0;} /^>/ {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/myseq%d.fa",n);} print >> file; n_seq++; next;} { print >> file; }' < $input
	awk 'BEGIN {n_seq=0;n=0;} {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/id%d.txt",n)} print >> file; n_seq++; next;} { print >> file; }' < $input.id
	for i in `seq $p`; do 
		grep -w -f $tmp/id$i.txt $ab_file > $tmp/abfile$i.txt 
		echo grinder -rf $tmp/myseq$i.fa -cf $coverage_pacbio -rd 6000 -fq 1 -ql 30 10 -od $outdir -bn grinder-pacbio-$coverage_pacbio\X-am$diversity.$i -af $tmp/abfile$i.txt >> $tmp/commands.txt  	
	done
	parallel < $tmp/commands.txt 
	cd $outdir 
	cat grinder-pacbio-$coverage_pacbio\X-am$diversity.*-reads.fastq > grinder-pacbio-$coverage_pacbio\X-am$diversity-reads.fastq	
	rm grinder-pacbio-$coverage_pacbio\X-am$diversity.*-reads.fastq
	rm grinder-pacbio-$coverage_pacbio\X-am$diversity.*-ranks.txt 
	cd $tmp 
	rm * 
	cd $CURDIR
}	

	
function run_pacbio_cont(){
	read=`grep "^@" -c $outdir/grinder-pacbio-$coverage_pacbio\X-am$diversity-reads.fastq`
	read_cont=$(echo $read $contamination | awk '{printf "%i\n",$1*$2}')
	tot_length=`python3 $BIN/total_length_fasta.py $contamination_f`
	cov=$(echo $read_cont $tot_length | awk '{print (6000*$1)/$2}') 
	
	nb_seq=`grep "^>" -c $contamination_f`
	if [[ $(($nb_seq%($p-1))) == 0 ]]; then 
		seq_per_file=$(($nb_seq/$p))
	else 
		seq_per_file=$(($nb_seq/($p-1)))	
	fi 
	echo $seq_per_file 
	awk 'BEGIN {n_seq=0;n=0;} /^>/ {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/cont%d.fa",n);} print >> file; n_seq++; next;} { print >> file; }' < $contamination_f
	awk 'BEGIN {n_seq=0;n=0;} {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/contid%d.txt",n)} print >> file; n_seq++; next;} { print >> file; }' < $contamination_f.id 

	for i in `seq $p`; do 
		grep -w -f $tmp/contid$i.txt $ab_file_cont > $tmp/abfilecont$i.txt 
		echo grinder -rf $tmp/cont$i.fa -cf $cov -rd 6000 -fq 1 -ql 30 10 -od $outdir -bn grinder-pacbio-$coverage_pacbio\X-am$diversity-cont$contamination.$i -af $tmp/abfilecont$i.txt >> $tmp/commands_cont.txt  	
	done
	parallel < $tmp/commands_cont.txt 
	cd $outdir 
	cat grinder-pacbio-$coverage_pacbio\X-am$diversity-cont$contamination.*-reads.fastq > grinder-pacbio-$coverage_pacbio\X-am$diversity-cont$contamination\-reads.fastq	
	rm grinder-pacbio-$coverage_pacbio\X-am$diversity-cont$contamination.*-reads.fastq
	rm grinder-pacbio-$coverage_pacbio\X-am$diversity-cont$contamination.*-ranks.txt

	cat grinder-pacbio-$coverage_pacbio\X-am$diversity-reads.fastq grinder-pacbio-$coverage_pacbio\X-am$diversity-cont$contamination\-reads.fastq > grinder-pacbio-$coverage_pacbio\X-am$diversity-with-cont$contamination\-reads.fastq 
	
	cd $tmp 
	rm *
	cd $CURDIR 
}	

ILLUMINA=0
PACBIO=0  
diversity=0.1
p=4

TEMP=$(getopt -o o:,h,p: -l illumina:,pacbio:,ab_file:,diversity:,contamination:,contamination_f:,contamination_id:,ab_file_cont: -- "$@")

eval set -- "$TEMP" 

while true ; do 
	case "$1" in  
		-o)	
			outdir=$2 
			shift 2;; 
		-p)
			p=$2
			shift 2;; 
		--illumina)
			ILLUMINA=1
			coverage_illumina=$2
			shift 2;; 
		--pacbio) 	
			PACBIO=1 
			coverage_pacbio=$2
			shift 2 ;; 
		--ab_file) 
			ab_file=$2
			shift 2 ;; 	
		--diversity)
			diversity=$2 
			shift 2 ;; 
		--contamination)
			contamination=$2
			shift 2 ;; 
		--contamination_f) 
			contamination_f=$2	
			shift 2 ;; 
		--contamination_id) 
			contamination_id=$2
			shift 2 ;;
		--ab_file_cont) 
			ab_file_cont=$2	
			shift 2 ;;
		-h) 
			usage
			exit 0;;	
		--)  
			shift ; break ;; 					
	esac 
done 	

if [ "$#" -ne 1 ]
then 
	usage  
	exit 1 
fi

tmp=`mktemp -p . -d`
tmp=`readlink -f $tmp`
tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin
CURDIR=$(pwd)

source $BIN/common_functions.sh 

input=$1
treat_args
verif_args 

if [[ ! -f $input.id ]]; then 
	grep "^>" $input | cut -f 1 -d " " | tr -d ">" > $input.id 
fi

if [[ $contamination ]]; then 
	if [[ ! -f $contamination_f.id ]]; then 
		grep "^>" $contamination_f | cut -f 1 -d " " | tr -d ">" > $contamination_f.id 
	fi 
fi 
 
if [[ $ILLUMINA == 1 ]]; then 
	if [[ -f $outdir/grinder-illumina-$coverage_illumina\X-am$diversity\-reads.fastq ]]; then 
		echo "Simulated illumina read files already exists" 
	else
		run_illumina 
	fi	
	if [[ $contamination ]]; then 
		if [[ -f $outdir/grinder-illumina-$coverage_illumina\X-am$diversity\-cont$contamination\-reads.fastq ]]; then 
			echo "Simulated illumina contaminants read files already exists" 
		else	
			run_illumina_cont		
		fi 	
	fi 	
fi 

if [[ $PACBIO == 1 ]]; then 
	if [[ -f $outdir/grinder-pacbio-$coverage_pacbio\X-am$diversity\-reads.fastq ]]; then 
		echo "Simulated pacbio read files already exists" 
	else
		run_pacbio 
	fi	
	if [[ $contamination ]]; then 
		if [[ -f $outdir/grinder-pacbio-$coverage_pacbio\X-am$diversity\-cont$contamination\-reads.fastq ]]; then 
			echo "Simulated pacbio contaminants read files already exists" 
		else	
			run_pacbio_cont		
		fi 	
	fi 	
fi 
 
  
rm -r $tmp 




