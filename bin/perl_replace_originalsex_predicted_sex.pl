$sexcheck_file = $ARGV[0];
$inputtfam = $ARGV[1];
$outputtfam = $ARGV[2];
chomp($sexcheck_file);
chomp($inputtfam);
chomp($outputtfam);
open BUFF,"< $sexcheck_file" or die "sex check file $sexcheck_file doesn't exist\n";
open BUFF1,"< $inputtfam" or die "tfam file $inputtfam doesn't exist\n";
open OUT,"> $outputtfam" or die "tfam file $outputtfam doesn't exist\n";
$line = <BUFF>;
while($line = <BUFF>)
{
	chomp($line);
	$line =~ s/\s+/ /g;
	@array = split(" ",$line);
	#if(!($line =~ m/OK/ ))
	if($array[2] ne "1" && $array[2] ne "2")
	{
			$hash{$array[1]} = $line;
	}
}
while($line = <BUFF1>)
{
        chomp($line);
	@array = split(" ",$line);
	if(exists($hash{$array[1]}))
	{
		@array1 = split(" ",$hash{$array[1]});
		if($array1[2] eq "1" || $array1[2] eq "2")
		{
			#print "success\n$line\n$hash{$array[1]}\n";
			$array[4] = $array1[2];
			$line = join(" ",@array);
		}
	}	
		print OUT $line."\n";
}
close(BUFF);
close(BUFF1);
close(OUT);
