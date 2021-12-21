use strict;
use warnings;

# Remove putative chromosomic sequences and sequence without taxonomy


my $li; 
my $id;
my $seq=0;
my @ligne;
my %db=();
my %taxo=();
my $acc;



#~ taxo file
open(TAXO, $ARGV[0]."/all_plasmids.taxo.tsv");

while($li=<TAXO>){
	chomp($li);
	@ligne=split("\t", $li);
	$taxo{$ligne[0]}=$li;
	
}

open(FASTA, $ARGV[0]."/all_plasmids.fasta");
open (ERR, ">".$ARGV[0]."/all_plasmids.error");
print ERR "# Sequences removed: putative chromosomes, taxonomy error....\n";

while($li=<FASTA>){
	
	if ($li =~ />.*/ ){
		
			chomp($li);
			@ligne=split(" ", $li);
			$id=$li;
			$acc=$ligne[0];
			$acc =~ s/>//;
			
			if($li =~ />.*plasmid.*/i && exists($taxo{$acc}) ){
			$seq=1;
			}
			else{
			$seq=0;
			print "Sequence removed:  ".$id."\n";
			print ERR $id."\n";
			}
		} 
		else{
				
				if($seq){
					$db{$id}.=$li;
				}
				
		}

}


#~ Write clean sequences
open(NEW, ">".$ARGV[0]."/all_plasmids.fasta");

foreach my $seed (keys %db){
	print NEW $seed."\n".$db{$seed}."\n";
}
