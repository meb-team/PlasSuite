function usage(){
	echo "usage : bash add_abundance.sh <plasmids stats file> <abundance file>" 
	echo "--"
	echo "Modify plasmids stats file to add abundance of each plasmids" 
}

if [[ $# -ne 2 ]]; then 
	usage
	exit 1
fi

tmp=$(mktemp -d -p .) 
echo $tmp 

cut -f 5 $1 > $tmp/id 
for id in $(cat $tmp/id); do 
	grep $id $2 
done | cut -f 2 > $tmp/abundance

echo "Abundance" > $tmp/head 
cat $tmp/head $tmp/abundance > $tmp/abundance2

paste $1 $tmp/abundance2 > $tmp/plasmids_stats.withAb
mv $tmp/plasmids_stats.withAb $1  

rm -r $tmp  
