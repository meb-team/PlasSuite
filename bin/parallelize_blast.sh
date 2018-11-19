set -e 

function usage(){
	echo 'usage : parallelize_blast.sh <query> <db> <output> <threads> <blast type>' 
}

if [ "$#" -ne 5 ]
then 
	usage  
	exit 1 
fi

tmp=`mktemp -p . -d`
tmp=`readlink -f $tmp`

query=$1 
db=$2
out=$3 
t=$4
blast=$5

nb_seq=`grep "^>" -c $query`

seq_per_file=$(($nb_seq/($t)))

awk 'BEGIN {n_seq=0;n=0;} /^>/ {if(n_seq%'$seq_per_file'==0){n++;file=sprintf("'$tmp'/myseq%d.fa",n);} print >> file; n_seq++; next;} { print >> file; }' < $query 

for i in `seq $t`; do 
	echo $blast -query $tmp/myseq$i.fa -db $db -evalue 1e-6 -outfmt '"6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore ppos qlen qcovhsp slen" >' $tmp/results$i.tsv >> $tmp/commands.txt 	
done

parallel --no-notice < $tmp/commands.txt

cat $tmp/results* > $out 

rm -r $tmp
