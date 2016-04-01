#####################################################################################################################################################
#Purpose: To Convert vcf file to transpose plink set(tfam/tped)
#Date: 08-04-2014
#inputfile : vcf file
#outputfile: transpose plink files (tped & tfam file)
#input options:i= input file
#input options:o= output file
#input options:l= yes/no <lowqual filtering aplied if argument is yes>
#input options:c= coverage <must be number and >= 0>
#input options:d= yes/no <include indels if argument is yes>
#note: Lowqual filering not alipped to reference homozygote calls
#####################################################################################################################################################
#!/usr/bin/perl
use Getopt::Std;
getopt("i:o:l:c:d", \%args);
$infile = $args{i};
$outfile = $args{o};
$lowqual = $args{l};
$coverage = $args{c};
$indel = $args{d};
chomp($infile);
chomp($outfile);
chomp($lowqual);
chomp($coverage);
chomp($indel);
print "infile: $infile\n";
print "outfile: $outfile\n";
print "lowqual: $lowqual\n";
print "coverage: $coverage\n";
print "Indels : $indel\n";
if(!(-e $infile) || !($lowqual =~ m/yes/i || $lowqual =~ m/no/i) || !($indel =~ m/yes/i || $indel =~ m/no/i) || !($coverage eq $coverage+0 && $coverage>=0))
{
	print "perl VCF_to_plink_transpose_TPED_TFAM.pl -i <input vcf file (can be compressed gz file)> -o <Path to plink output set tfam & tped files will be generated> -d <YES/NO (Want to include indels or not)> -l <YES/NO(LowQual filtering will be applied if 'yes')> -c <cutoff coverage must be a number & greater than or equal to 0>>\n";
	die "Retry with correct arguments!\n";
}
if($infile =~ m/\.gz$/)
{
	open(BUFF,"gunzip -c $infile|") or die "no input file $infile found\n";
}
else
{
	open(BUFF,"$infile") or die "no input file $infile found\n";
}
open(WRTPED,">$outfile.tped") or die "not able to write the file $outfile.tped\n";
open(WRTFAM,">$outfile.tfam") or die "not able to write the file $outfile.tfam\n";

undef(%hash);
while($l=<BUFF>)
{
	chomp($l);
	$l =~ s/[\r,\n]+$//;
	if($l =~ m/^#/)
	{
		if($l =~ m/^#CHROM/)
		{
			my @line=split(/\t/,$l);
			for(my $i=9;$i<@line;$i++)
			{
				print WRTFAM "$line[$i] $line[$i] 0 0 -9 -9\n"; 
			}
		}
		next;
	}
	my @line=split(/\t/,$l);
	my $chr = $line[0];
	my $pos=$line[1];
	my $id=$line[2];
	if(length($id)<=1) 
	{
		$id=$chr . ":" . $pos;
	}
	$chr =~ s/chr//g;
	$chr =~ s/Y/24/g;
	$chr =~ s/X/23/g;
	my $ref=$line[3];
	if($ref eq '.')
	{
		print "ref cannot be empty.Skipping line $.\n";
		next;
	}
	my $alt=$line[4];
	my $gtstr=$line[9];
	my @gtline=split(":",$gtstr);
	my @gt=split(/\/|\|/,$gtline[0]);
	my $gtval="";
	if($gt[0] eq '.' || $gt[1] eq '.')
	{
		$gtval="0 0";
	}
	else
	{
		if(($gt[0] == 0 && $gt[1] == 1) || ($gt[0] == 1 && $gt[1] == 0)) 
		{
			$gtval="$ref $alt";
		} 
		elsif($gt[0] == 1 && $gt[1] == 1) 
		{
			$gtval="$alt $alt";
		} 
		elsif($gt[0] == 0 && $gt[1] == 0) 
		{
			$gtval="$ref $ref";
		}
	}
	if($line[6] eq "LowQual" && $lowqual =~ m/yes/i && ($gt[0] == 1 || $gt[1] == 1))
	{
		$gtval="0 0";
	}
	else
	{
		@fields=split(';',$line[7]);
		$num_DP =0;
		for($y=0;$y<@fields;$y++)
		{
			if($fields[$y] =~ m/DP=/)
			{
				$num_DP =$fields[$y];
				$num_DP =~ s/DP=//g;
			}
		}
		if($num_DP < $coverage)
		{
			$gtval="0 0";
		}
	}
	if(!exists($hash{$chr." ".$pos}) && (($indel =~ m/yes/i) || ($indel =~ m/no/i && length($ref)==1 && length($alt)==1)))
	{
		$hash{$chr." ".$pos}=1;
		print WRTPED "$chr $id 0 $pos $gtval\n";
	}
}
close(BUFF);
close(WRTPED);
close(WRTFAM);