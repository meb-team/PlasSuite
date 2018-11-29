set -e 

function usage(){
	echo 'usage : combined_file.sh <file1> <file2> <...> <fileN>'    
	
}

if [[ $# -lt 2 ]]; then 
	usage
	exit 1
fi	

first_file=$1
shift 

tmp=1
other_file=""
while [ $1 ]; do
	tail -n +2 $1 > $tmp.tmp
	other_file="$other_file $tmp.tmp" 
	tmp=$(($tmp+1))
	shift 
done

cat $first_file $other_file
rm *.tmp 

