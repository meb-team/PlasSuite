function usage(){
	echo 'usage : bash run_16Sclustering.sh <RNA seed sequences.fasta (query)> <RNA database sequences.fasta (subject)> <comma-separated list of id clustering> <outdir> <prefix> <parallel jobs>'  
}

if [[ $# -ne 6 ]]; then 
	usage 
	exit 1
fi 

rna_seed=$1 
rna_db=$2
ids=$3
out=$4/$5
p=$6

mkdir -p $4

tmp=$(mktemp -d -p .) 
echo $tmp

ids=$(echo $ids | tr "," " ")  


count=0
nb_file=0
for id in $ids; do 
	clusters=$out.id$id.tsv  
	if [[ $(($count%$p)) == 0 ]]; then
		nb_file=$(($nb_file+1))			 
		echo vsearch --usearch_global $rna_seed --db $rna_db --id $(echo $id | awk '{print $1/100}') --uc $clusters --maxaccepts 0 --uc_allhits --threads 6 > $tmp/clustering_commands.$nb_file.txt 
	else 
		echo vsearch --usearch_global $rna_seed --db $rna_db --id $(echo $id | awk '{print $1/100}') --uc $clusters --maxaccepts 0 --uc_allhits --threads 6 >> $tmp/clustering_commands.$nb_file.txt 	
	fi 	
	count=$(($count+1))
done 

for i in $(seq 1 $nb_file); do 
	parallel --no-notice < $tmp/clustering_commands.$i.txt 
done 	

for id in $ids; do
	clusters=$out.id$id.tsv 
	id_del=$out.chrm_to_delete.$id.txt 
	awk '{if ($10!="*") print $10}' $clusters | cut -f 1 -d "." | sort -u > $id_del
done 
		
rm -r $tmp
