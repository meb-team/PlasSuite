function verif_file(){
	f=$1 
	message=$2
	message2=$3
	if [[ ! -f $f ]]; then 
		echo $message 
		exit 1
	else 
		echo $message2	
	fi
}

function verif_dir(){
	d=$1 
	message=$2
	message2=$3
	if [[ ! -d $d ]]; then 
		echo $message 
		exit 1
	else 
		echo $message2	
	fi		
}	

function verif_blast_db(){
	file=$1 
	type=$2
	message_create=$3
	message_found=$4
	
	if [[ $type == "prot" ]]; then 
		local pref="phr" 	
	elif [[	$type == "nucl" ]]; then 
		local pref="nhr" 	
	fi
	
	if [ ! -f $file.$pref ];then 
		echo $message_create
		makeblastdb -in $file -dbtype $type
	else	
		echo $message_found	
	fi
}

function verif_result(){
	if [[ -f $1 && ! $FORCE ]]; then
		file_exist=1
	else 
		file_exist=0	
	fi 	
}


function launch_last(){
	query=$1
	db=$2
	out=$3
	source activate last
	echo "## LAST" 
	if [[ ! -f $db.tis ]]; then 
		echo "# Make last db" 
		lastdb $db $db
	fi	
	echo "# Launch last" 
	echo $out
	lastal $db $query -f BlastTab+ -P 12 > $out
	source deactivate last	
}
