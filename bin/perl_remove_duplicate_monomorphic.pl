$prev="";
while(<STDIN>)
{
	split / /;
	if(($_[2] eq $prev && length($_[4]) eq length($prevl2) && length($_[3]) eq length($prevl1) && $prevl2 eq "0" && ($prevl1 eq $_[4] || $prevl1 eq $_[3])) || ($_[2] eq $prev && $_[3] eq $prevl1 && length($_[4]) eq length($prevl2) && $prevl2 =~ m/A|T|G|C/ && $_[4] =~ m/A|T|G|C/))
	{
		next;
	}
	else
	{	
		print $_;
	}	
	$prev=$_[2];
	$prevl1=$_[3];
	$prevl2=$_[4];
}
