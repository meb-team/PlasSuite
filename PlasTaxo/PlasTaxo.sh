set -e 

function usage(){
	echo 'usage : bash PlasTaxo.sh --plasflow_taxo <plasflow_taxonomy.tsv> --plasmids_align <plasmids_alignment.paf> --chrm_align <chrm_alignment.paf> --rna_align <rna_alignment.paf> -o <outdir>
	plasflow_taxonomy.tsv is tsv file with sequence reference in first column and plasflow predicted phylum in 2nd column. This file is generated by run_plasflow.sh 
	[OPTIONS]
	-h : print help
	--force : overwrite results if already exists 
	#Output  
	--prefix <prefix> : prefix for output files
	#Databases 
	--plasmids_db <fasta> : fasta file with plasmids
	--chrm_db <fasta> : fasta file with chromosomes 
	--rna_db <fasta> : fasta file with rRNA 
	--plasmids_info <tsv> NCBI file for plasmids (ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/plasmids.txt). Can be any other file with sequence organism name in 1st column and sequences references in 6th column. (default : databases/plasmids.ncbi.txt)' 
}

function treat_args(){
	if [[ ! $plasflow_taxo ]];then
		quit=1
		echo "You must give plasflow taxonomy file. Use --plasflow_taxo option"
	fi	
	if [[ ! $plasmids_align ]];then
		quit=1
		echo "You must give plasmids alignment file. Use --plasmids_align option"
	fi	
	if [[ ! $chrm_align ]];then
		quit=1
		echo "You must give chromosomes alignment file. Use --chrm_align option"
	fi
	if [[ ! $rna_align ]];then
		quit=1
		echo "You must give rRNA alignment file. Use --rna_align option"
	fi	
	if [[ ! $outdir ]]; then 
		quit=1 
		echo "You must give output directory. Use -o option" 
	fi
	if [[ ! $prefix ]]; then 
		quit=1 
		echo "You must give output prefix. Use --prefix option" 
	fi	
	
	if [[ $quit ]]; then 
		exit 1
	fi 
}	

function verif_args(){
	verif_file $plasflow_taxo "[PlasTaxo] Plasflow PlasTaxo doesn't found in $plasflow_taxo" "[PlasTaxo] Plasflow PlasTaxo found in $plasflow_taxo"
	verif_file $plasmids_align "[PlasTaxo] Plasmids alignment doesn't found in $plasmids_align" "[PlasTaxo] Plasmids alignment found in $plasmids_align"
	verif_file $chrm_align "[PlasTaxo] Chromosomes alignment doesn't found in $chrm_align" "[PlasTaxo] Chromosomes alignment found in $chrm_align"
	verif_file $rna_align "[PlasTaxo] rRNA alignment doesn't found in $rna_align" "[PlasTaxo] rRNA alignment found in $rna_align"	
	mkdir -p $outdir 
	if [[ ! $plasmids_db ]]; then 
		plasmids_db=/databis/hilpert/plasmidome_databases/all_plasmids.fasta 
	fi
	if [[ ! $plasmids_info ]]; then 
		plasmids_info=/databis/hilpert/plasmidome_databases/plasmids.ncbi.txt 
	fi
	if [[ ! $chrm_db ]]; then 
		chrm_db=/databis/hilpert/plasmidome_databases/all_prokaryotes.fasta 
	fi
	if [[ ! $rna_db ]]; then 
		rna_db=/databis/hilpert/plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.fasta
	fi
	verif_file $plasmids_db "[PlasTaxo] Plasmids db doesn't found in $plasmids_db" "[PlasTaxo] Plasmids db found in $plasmids_db"
	verif_file $plasmids_info "[PlasTaxo] Plasmids info doesn't found in $plasmids_info" "[PlasTaxo] Plasmids info found in $plasmids_info"
	verif_file $chrm_db "[PlasTaxo] chrm db doesn't found in $chrm_db" "[PlasTaxo] chrm db found in $chrm_db"
	verif_file $rna_db "[PlasTaxo] rna db doesn't found in $rna_db" "[PlasTaxo] rna db found in $rna_db"


}

TEMP=$(getopt -o h,f:,o: -l prefix:,force,plasflow_taxo:,plasmids_align:,plasmids_db:,plasmids_info:,chrm_align:,chrm_db:,rna_align:,rna_db: -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-f) 
			assembly=$2
			shift 2;; 
		-o) 
			outdir=$2
			shift 2;; 
		--prefix) 
			prefix=$2 
			shift 2;;
		--force)
			FORCE=1
			shift ;; 
		--plasflow_taxo) 
			plasflow_taxo=$2
			shift 2;;
		--plasmids_align) 
			plasmids_align=$2
			shift 2;;	
		--plasmids_db) 
			plasmids_db=$2
			shift 2;;	
		--plasmids_info) 
			plasmids_info=$2
			shift 2;;	
		--chrm_align) 
			chrm_align=$2
			shift 2;; 
		--rna_align)
			rna_align=$2
			shift 2;; 
		--chrm_db)
			chrm_db=$2
			shift 2;; 
		--rna_db)
			rna_db=$2
			shift 2;; 
		-h) 
			usage 
			shift ;;
		--)  
			shift ; break ;; 					
	esac 
done


BIN=/databis/hilpert/plasmidome_scripts/bin
BIN2=/databis/hilpert/plasmidome_realdata2/bin
source $BIN/common_functions.sh 
treat_args 
verif_args 

plasmids_db_pref=$(echo $plasmids_db | rev | cut -f 1 -d "/" | cut -f 2- -d"." | rev)
plasmids_db_dir=$(echo $plasmids_db | rev | cut -f 2- -d "/" | rev) 
chrm_db_pref=$(echo $chrm_db | rev | cut -f 1 -d "/" | cut -f 2- -d"." | rev)
chrm_db_dir=$(echo $chrm_db | rev | cut -f 2- -d "/" | rev) 
rna_db_pref=$(echo $rna_db | rev | cut -f 1 -d "/" | cut -f 2- -d"." | rev)
rna_db_dir=$(echo $rna_db | rev | cut -f 2- -d "/" | rev) 

plasmids_taxo=$plasmids_db_dir/$plasmids_db_pref.taxo.tsv
chrm_taxo=$chrm_db_dir/$chrm_db_pref.taxo.tsv
rna_taxo=$rna_db_dir/$rna_db_pref.taxo.tsv

echo "=== REFERENCES TAXONOMY ==="
pref=$plasmids_db_dir/$plasmids_db_pref
if [[ ! -f $plasmids_db_pref.id ]]; then 
	grep "^>" $plasmids_db | cut -f 1 -d " " | tr -d ">" > $pref.id 
fi  

if [[ ! -f $pref.taxo.tsv ]]; then 
	python3 $BIN2/taxo_plasmids.py $plasmids_db_pref.id $plasmids_info $plasmids_db_dir $plasmids_db_pref.taxo 
	if [ -s $pref.taxo.notfound.id ]; then 
		l=$(grep -w -f $pref.taxo.notfound.id $plasmids_db)
		grep -w -f $pref.taxo.notfound.id $plasmids_db | cut -f 2-3 -d " " > $pref.taxo.notfound.org 
		python3 $BIN2/taxo_from_org_name.py $pref.taxo.notfound.org > $pref.taxo.notfound.org_taxo 
		paste $pref.taxo.notfound.id $pref.taxo.notfound.org_taxo > $pref.taxo.notfound.taxo 
		cat $pref.taxo.tsv $pref.taxo.notfound.taxo > $pref.taxo.tsv2 
		mv $pref.taxo.tsv2 $pref.taxo.tsv 
		rm $pref.taxo.notfound.org $pref.taxo.notfound.org_taxo 
	fi
fi 

echo "=== TREAT ASSEMBLY TAXONOMY ===" 
taxo=$outdir/$prefix.taxo 

python3 $BIN/treat_taxo.py $chrm_align $chrm_taxo $plasflow_taxo $rna_align $rna_taxo $plasmids_align $plasmids_taxo > $taxo
python3 $BIN/comp_taxo.py $taxo 

tail -n +2 $taxo > $taxo.tmp
all=$(awk -F "\t" '{if ($3!="-" || $4 != "-" || $5 != "-") print }' $taxo.tmp | wc -l | cut -f 1 -d " ")  
same=$(wc -l $taxo.sameTaxo | cut -f 1 -d " ")   
diff=$(wc -l $taxo.differentTaxo | cut -f 1 -d " ") 

echo -e "Taxon\tNumber of contigs" > $taxo.sameTaxo.count
cut -f 2 $taxo.sameTaxo| sort | uniq -c | awk '{print $2"\t"$1}'>> $taxo.sameTaxo.count
echo -e "Taxon\tNumber of contigs" > $taxo.differentTaxo.count
cut -f 2 $taxo.differentTaxo | sort | uniq -c | awk '{print $2"\t"$1}' >> $taxo.differentTaxo.count

python3 $BIN/count_taxo.py $taxo.sameTaxo.count $taxo.differentTaxo.count $taxo.plasflowPrediction.stats

exit 

python3 $BIN2/treat_taxo_plasmids.py $plasmids_align $pref.taxo.tsv $plasflow_taxo > $taxo 
python3 $BIN2/comp_taxo_plasmids.py $taxo 

tail -n +2 $taxo > $taxo.tmp
all=$(awk -F "\t" '{if ($3!="-" || $4 != "-" || $5 != "-") print }' $taxo.tmp | wc -l | cut -f 1 -d " ")  
same=$(wc -l $taxo.sameTaxo | cut -f 1 -d " ")   
diff=$(wc -l $taxo.differentTaxo | cut -f 1 -d " ") 

echo -e "Taxon\tNumber of contigs" > $taxo.sameTaxo.count
cut -f 2 $taxo.sameTaxo| sort | uniq -c | awk '{print $2"\t"$1}'>> $taxo.sameTaxo.count
echo -e "Taxon\tNumber of contigs" > $out.differentTaxo.count
cut -f 2 $taxo.differentTaxo | sort | uniq -c | awk '{print $2"\t"$1}' >> $taxo.differentTaxo.count

python3 $BIN2/count_taxo.py $taxo.sameTaxo.count $taxo.differentTaxo.count $taxo.plasflowPrediction.stats

rm $outdir/*.tmp 
