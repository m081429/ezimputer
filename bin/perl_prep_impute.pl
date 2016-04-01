#$input = "snps_chr8";
$input = $ARGV[0];
chomp($input);
open(TPED,"$input.tped") or die "no input tped file\n";
#system("head -1 GE.txt > SNP.txt");
#system("sed 's/gene/rs/g' SNP.txt > SNP1.txt");
#system("mv SNP1.txt SNP.txt");
open(MISS,"$input.imiss") or die "no input miss file\n";
$line=<MISS>;
open(WRGNT,">$input.genotype");
open(WRSAMP,">$input.sample");
print WRSAMP "ID_1 ID_2 missing\n";
print WRSAMP "0 0 0\n";
while($line=<MISS>)
{
	#$line =<MISS>;
	chomp($line);
	$line =~ s/\s+/ /g;
	@miss =  split(" ",$line);
	print WRSAMP "$miss[0] $miss[1] $miss[5]\n";
}
close(MISS);

while(<TPED>)
{
	chomp($_);
	@array = split(" ",$_);
	$chr = shift(@array);
	if($chr ne "0")
	{
	$snp = shift(@array);
	shift(@array);
	$pos = shift(@array);
	print WRGNT "SNP$. $snp $pos";
	@uniq = uniq(@array);
	@uniq = sort(@uniq);
	if($uniq[0] eq "0")
	{
		shift(@uniq);
	}
	$gnt1 = $uniq[0];
	$gnt2 = $uniq[1];
	print WRGNT " $gnt1 $gnt2";
	for($i=0;$i<@array;$i++)
	{
		$snp1 = $array[$i];
		$i++;
		$snp2 = $array[$i];
		if($snp1 eq $gnt1 && $snp2 eq $gnt1)
		{
			print WRGNT " 1 0 0";
		}
		elsif($snp1 eq $gnt2 && $snp2 eq $gnt2)
                {
                        print WRGNT " 0 0 1";
                }
		elsif($snp1 eq "0" && $snp2 eq "0")
                {
                        print WRGNT " 0 0 0";
                }
		else
		{
			print WRGNT " 0 1 0";
		}	
	}
	print WRGNT "\n";
	#print "$snp\t@uniq\n"; 
#die;	
	}
}
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

