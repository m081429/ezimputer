#!/usr/bin/perl
sub getDetails
{
	my ($configFile) = @_;
  	open(BUFF,"$configFile");
	while($line = <BUFF>)
	{
		chomp($line);
		my @arr = split('=',$line);
		chomp($arr[0]);
		chomp($arr[1]);
		$arr[1] =~ s/"//g;
		my $key=shift(@arr);
		my $value=join('=',@arr);
		$config{$key} = $value;			
	}
}
return \%config;
#getDetails("kk.txt","geneEXP");
