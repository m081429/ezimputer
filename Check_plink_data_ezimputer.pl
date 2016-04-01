#####################################################################################################################################################
#Purpose: To prepare the dataset for ezimputer QC & Imputer scripts
#Date: 11-09-2012
#inputfile : plink file
#outputfile: input ezimputer plink file
#####################################################################################################################################################
#!/usr/bin/perl
use Getopt::Long;
#reading input arguments
&Getopt::Long::GetOptions(
'INPUT_FILE=s' => \$inputfile,
'OUTPUT_FILE=s'=> \$outputfile,
);
chomp($inputfile);
chomp($outputfile);
$inputfile =~ s/\s|\t|\r|\n//g;
$outputfile =~ s/\s|\t|\r|\n//g;
#checking for missing arguments
if( $inputfile eq "" || $outputfile eq "")
{
        die "missing arguments\n USAGE : perl Check_plink_data_ezimputer.pl -INPUT_FILE <INPUT PLINK TRANSPOSE FILES> -OUTPUT_FILE <OUTPUT PLINK TRANSPOSE FILES>\n";
}
print "***********INPUT ARGUMENTS***********\n";
print "INPUT_FILE: $inputfile\n";
print "OUTPUT_FILE : $outputfile\n";

$file=$inputfile.'.tfam';
open(TFAM,"$file") or die "no tfam file found $file\n";
$file=$inputfile.'.tped';
open(TPED,"$file") or die "no tped file found $file\n";
$file=$outputfile.'.tfam';
open(WRTFAM,">$file") or die "not able to write tfam file found $file\n";
$file=$outputfile.'.tped';
open(WRTPED,">$file") or die "not able to write tped file found $file\n";
print "\n\n\n\n\n";

print "Chekcing for duplicate sample id's.If found then '_incrementalnumber' will be added to the sample ID and making mother and father id to '0'\n";
while(<TFAM>)
{
	chomp($_);
	@tfam=split(" ",$_);
	if(exists($sample{$tfam[1]}))
	{
		print "Duplicate sample found so modifying the sample id $tfam[1] to $tfam[1]__$sample{$tfam[1]}\n";
		$tfam[1] ="$tfam[1]__$sample{$tfam[1]}";
		$sample{$tfam[1]}++;	
	}
	else
	{
		$sample{$tfam[1]}=1;
	}
	$tfam[2]=0;
	$tfam[3]=0;
	$_ = join(" ",@tfam);
	print WRTFAM $_."\n";
}
close(TFAM);
close(WRTFAM);
print "\n\n\n\n\n";
print "Chekcing for duplicate rsids and positions.If duplicate rsid is found then '_duplicatenumber' will be added to rsid name.If duplicate position is found then it will be excluded\n";
undef(%sample);
while(<TPED>)
{
    chomp($_);
	@tped=split(" ",$_);
	if(exists($rsid{$tped[1]}))
    {
        $tped[1]="$tped[1]__$rsid{$tped[1]}";
		$rsid{$tped[1]}++;
	}
	else
	{
        $rsid{$tped[1]}=1;
    }
	if(!exists($pos{$tped[0].' '.$tped[3]}))
	{
		$pos{$tped[0].' '.$tped[3]}=1;
		$_ = join(" ",@tped);
		print WRTPED $_."\n";
	}
}
close(TPED);
close(WRTPED);
