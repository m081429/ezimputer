#####################################################################################################################################################
#Purpose: To generate the forwardstrand indicator file
#Date: 11-09-2012
#inputfile : tped file
#outputfile: Ambiguous forward strand indicator file
#####################################################################################################################################################
#!/usr/bin/perl
use Getopt::Long;
#reading input arguments
&Getopt::Long::GetOptions(
'INPUT_FILE=s' => \$inputfile,
'OUTPUTFILE=s'=> \$fwd_indicator,
);
chomp($inputfile);
chomp($fwd_indicator);

#checking for missing arguments
if($inputfile eq "" || $fwd_indicator eq "")
{
	die "missing arguments\n USAGE : perl Create_fwdstrd_ind_4ambiInputMarkers.pl -INPUT_FILE <INPUT TPED FILE> -OUTPUTFILE <OUTPUT FORWARD STRAND INDICATOR FILE>\n";
}
print "***********INPUT ARGUMENTS***********\n";
print "INPUT_FILE: $inputfile\n";
print "OUTPUTFILE : $fwd_indicator\n";
open(BUFF,"$inputfile") or die "no input file exists\n";
open(WRBUFF,">$fwd_indicator") or die "not able to write $fwd_indicator file\n";
while(<BUFF>)
{
	chomp($_);
	@a=split(' ',$_);
	#checking for ambiguous
	if($_ =~ m/ A T/ || $_ =~ m/ T A/ || $_ =~ m/ G C/ || $_ =~ m/ C G/)
	{	print WRBUFF $a[1]."\t"."3"."\n";
	} 
	else 
	{
		print WRBUFF $a[1]."\t"."0"."\n";
	}	
}
close(BUFF);
close(WRBUFF);
