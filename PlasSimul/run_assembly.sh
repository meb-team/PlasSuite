set -e 

function usage(){
	echo 'usage : run_assembly.sh -i <short fastq reads> [options]     
	[options] : 
	--megahit : launch megahit assembly
	--metaspades : launch metaspades assembly
	--spades : launch spades assembly 
	--plasmidspades : launch plasmidspades assembly 
	--hybridspades : launch hybridspades assembly
	--unicycler : launch unicycler assembly 
	-o outdir (default : results/assembly)
	-l <long fastq reads> (required for --hybridspades and --unicycler) 
	--tmp <tmp directory> (default : tmp) 
	' 
}

function clean_spades(){
	current_dir=$(pwd)
	cd $1 
	rm -r K* 
	rm -r split_input
	rm -r tmp 
	rm -r misc
	rm contigs.*
	rm first_pe_contigs.fasta
	rm before_rr.fasta	
	cd $current_dir
}

TEMP=$(getopt -o h,o:,i:,l: -l megahit,metaspades,hybridspades,unicycler,tmp:,spades,plasmidspades -- "$@")

eval set -- "$TEMP" 

outdir=results/assembly 
tmp_dir=`mktemp -d -p .`
MEGAHIT=0
MEGAHIT_CAP=0
METASPADES=0
HYBRIDSPADES=0
UNICYCLER=0
IDBA=0 
SPADES=0
contamination_suffix=''

while true ; do 
	case "$1" in 
		--megahit)
			echo 'MEGAHIT' 
			MEGAHIT=1  
			shift;; 
		--metaspades)
			echo 'METASPADES' 
			METASPADES=1
			shift ;; 	
		--hybridspades) 
			echo 'HYBRIDSPADES' 
			HYBRIDSPADES=1
			shift ;; 
		--unicycler)
			echo 'UNICYCLER' 
			UNICYCLER=1
			shift ;; 		
		--spades) 
			SPADES=1 
			shift;; 
		--plasmidspades)
			PLASMIDSPADES=1
			shift;; 
		--tmp)
			tmp_dir=$2 
			shift 2;; 	
		
		-h) 
			usage 
			shift ;;
		-o) 
			outdir=$2
			shift 2;;	
		-i) 
			input_fq=$2 
			shift 2;; 	
		-l) 
			input_pacbio=$2
			shift 2;;	
		--)  
			shift ; break ;; 					
	esac 
done 	

mkdir -p $outdir 

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin

if [[ ! $input_fq ]]; then 
	usage 
	echo 'You have to specify short reads' 
	exit 1 
fi 	

if [ $MEGAHIT == 1 ]; then 
	echo "MEGAHIT"
	megahit --12 $input_fq -t 6 -o $outdir/megahit$contamination_suffix
	python3 $BIN/transform_assembly_id.py $outdir/megahit$contamination_suffix/final.contigs.fa $outdir/megahit$contamination_suffix/final.contigs.fa2 
	mv $outdir/megahit$contamination_suffix/final.contigs.fa2 $outdir/megahit$contamination_suffix/final.contigs.fa  
	rm -r $outdir/megahit/intermediate_contigs
fi 	

if [ $METASPADES == 1 ]; then 
	echo "METASPADES"  
	mkdir -p $outdir/metaspades
	/usr/local/SPAdes-3.9.0-Linux/bin/spades.py -o $outdir/metaspades$contamination_suffix --12 $input_fq --only-assembler -t 6 --meta 
	clean_spades $outdir/metaspades
fi 	

if [ $SPADES == 1 ]; then 
	echo "SPADES"  
	mkdir -p $outdir/spades
	/usr/local/SPAdes-3.9.0-Linux/bin/spades.py -o $outdir/spades$contamination_suffix --12 $input_fq --only-assembler -t 6 
	clean_spades $outdir/spades
fi 

if [ $HYBRIDSPADES == 1 ]; then 
	if [[ ! $input_pacbio ]]; then 
		usage 
		echo "You have to specify long reads for hybridspades" 
	fi 	
	echo "HYBRIDSPADES"  
	mkdir -p $outdir/hybridspades
	/usr/local/SPAdes-3.9.0-Linux/bin/spades.py -o $outdir/hybridspades$contamination_suffix --12 $input_fq --only-assembler -t 6 --pacbio $input_pacbio 
	clean_spades $outdir/hybridspades
	
fi 	

if [ $UNICYCLER == 1 ]; then 
	if [[ ! $input_pacbio ]]; then 
		usage 
		echo "You have to specify long reads for unicycler" 
	fi 	
	echo "UNICYCLER" 
	mkdir -p $outdir/unicycler 
	echo "parse reads" 
	if [ ! -f $tmp_dir/simulated_reads_r1.fastq ]; then  
		python3 $BIN/parse_paired_reads.py $input_fq $tmp_dir simulated_reads 
	fi	
	unicycler -1 $tmp_dir/simulated_reads_r1.fastq -2 $tmp_dir/simulated_reads_r2.fastq -l $input_pacbio -o $outdir/unicycler$contamination_suffix --spades_path /usr/local/SPAdes-3.9.0-Linux/bin/spades.py --racon_path ~/racon/bin/racon --samtools_path /usr/local/metabat-0.26.3/samtools-1.2/samtools --pilon_path ~/pilon-1.22.jar --no_correct	
	python3 $BIN/transform_assembly_id.py $outdir/unicycler/assembly.fasta $outdir/unicycler/assembly.fasta2 
	mv $outdir/unicycler/assembly.fasta2 $outdir/unicycler/assembly.fasta 
fi	
	
rm -r $tmp_dir 



			
	
