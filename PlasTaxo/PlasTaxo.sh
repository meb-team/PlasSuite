set -e 

function usage(){
	echo 'usage : bash PlasTaxo.sh --predicted_plasmids_dir <input directory> --predicted_plasmids_prefix <input prefix> -o <output directory> --prefix <output prefix>
	[OPTIONS]
	-h : print help
	--force : overwrite results if already exists 
	#Databases 
	--plasmids_taxo <fasta> : plasmids database taxonomy file 
	--chrm_taxo <fasta> : chromosomes database taxonomy file 
	--rna_taxo <fasta> : rRNA database taxonomy file'
}

function treat_args(){
	if [[ ! $inpdir ]]; then
		quit=1
		echo "You must give input predicted plasmids directory. Use --predicted_plasmids_dir option" 
	fi 
	if [[ ! $inpprefix ]]; then 
		quit=1
		echo "You must give input predicted plasmids prefix. Use --predicted_plasmids_prefix option" 
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
	verif_dir $inpdir "[PlasTaxo] Input directory doesn't found in $inpdir" "[PlasTaxo] Input directory found in $inpdir"
	mkdir -p $outdir 
	if [[ ! $plasmids_taxo ]]; then 
		plasmids_taxo=plasmidome_databases/all_plasmids.taxo.tsv
	fi 
	if [[ ! $chrm_taxo ]];then
		chrm_taxo=plasmidome_databases/all_prokaryotes.taxo.tsv 
	fi
	if [[ ! $rna_taxo ]]; then 
		rna_taxo=plasmidome_databases/rRNA/SILVA_132_SSUParc_LSUParc_tax_silva_trunc.T.taxo.tsv
	fi 
	chrm_align=$inpdir/chrm_search/$inpprefix.0.8.paf 
	plasflow_taxo=$inpdir/learning/$inpprefix.plasflow0.7.taxo 
	rna_align=$inpdir/rna_search/$inpprefix.rna.blast.all.contigs.tsv 
	plasmids_align=$inpdir/plasmids_search/$inpprefix.0.8.paf
	
	verif_file $plasmids_taxo "[PlasTaxo] Plasmids taxonomy doesn't found in $plasmids_taxo. Use --plasmids_taxo to specify it." "[PlasTaxo] Plasmids taxonomy found in $plasmids_taxo"
	verif_file $chrm_taxo "[PlasTaxo] Chromosomes taxonomy doesn't found in $chrm_taxo. Use --chrm_taxo to specify it." "[PlasTaxo] Chromosomes taxonomy found in $chrm_taxo"
	verif_file $rna_taxo "[PlasTaxo] RNA taxonomy doesn't found in $rna_taxo. Use --rna_taxo to specify it." "[PlasTaxo] RNA taxonomy found in $rna_taxo"
	verif_file $chrm_align "[PlasTaxo] Chromosomes alignment doesn't found in $chrm_align." "[PlasTaxo] Chromosomes alignment found in $chrm_align" 
	verif_file $plasflow_taxo "[PlasTaxo] PlasFlow taxonomy doesn't found in $plasflow_taxo." "[PlasTaxo] PlasFlow taxonomy found in $plasflow_taxo"
	verif_file $rna_align "[PlasTaxo] rRNA alignment doesn't found in $rna_align." "[PlasTaxo] rRNA alignment found in $rna_align"
	verif_file $plasmids_align "[PlasTaxo] Plasmids alignment doesn't found in $plasmids_align." "[PlasTaxo] Plasmids alignment found in $plasmids_align"
}

TEMP=$(getopt -o h,o: -l prefix:,force,plasmids_taxo:,rna_taxo:,chrm_taxo:,predicted_plasmids_dir:,predicted_plasmids_prefix: -- "$@")
eval set -- "$TEMP" 
while true ; do 
	case "$1" in 
		-o) 
			outdir=$2
			shift 2;; 
		--prefix) 
			prefix=$2 
			shift 2;;
		--force)
			FORCE=1
			shift ;; 
		--plasmids_taxo) 
			plasmids_taxo=$2
			shift 2;;
		--chrm_taxo) 
			chrm_taxo=$2
			shift 2;;	
		--rna_taxo) 
			plasmids_taxo=$2
			shift 2;;	
		--predicted_plasmids_dir)
			inpdir=$2 
			shift 2;; 
		--predicted_plasmids_prefix)
			inpprefix=$2
			shift 2;; 
		-h) 
			usage 
			exit
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

python3 $BIN/keep_taxo.py $taxo $predicted_plasmids > $taxo.predicted_plasmids

rm $outdir/*.tmp 
