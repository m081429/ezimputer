#$input = "beagle";
#$input = $ARGV[0];
#chomp($input);
$infile = $ARGV[0];
chomp($infile);
open(BUFF,"gunzip -c $infile|") or die "no file exists\n";
#if($input eq "beagle")
#{
	$line = <BUFF>;
#}
while(<BUFF>)
{
	chomp($_);
	@array = split(" ",$_);
	#if($input ne "beagle")
	#{
		shift(@array);
	#}
	$snp = shift(@array);
	#if($input ne "beagle")
        #{
        #        shift(@array);
        #}

	print "$snp";
	$gnt1 = shift(@array);
	$gnt2 = shift(@array);	
	print " $gnt1 $gnt2";
	for($i=0;$i<@array;$i++)
	{
		$val1 = $array[$i];
		$i++;
		$val2 = $array[$i];
		$i++;
		$val3 = $array[$i];
		$val= 2*$val3+$val2;
		print " $val";
		#die;
		#die "$val1 $val2 $val3 ";
		#if($val1 > 0.5)
		#{
		#	print " $gnt1 $gnt1";
		#}
		#elsif($val2 > 0.5)
		#{
		#	print " $gnt1 $gnt2";
		#}	
		#elsif($val3 >0.5)
		#{
		#	print " $gnt2 $gnt2";
		#}
		#else
		#{
		#	print " 0 0";
		#}
	}
	print "\n";	
}
