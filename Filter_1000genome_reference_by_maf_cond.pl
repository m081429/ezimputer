#####################################################################################################################################################
#Purpose: To recreate the new 1000 genome reference with maf base filtering
#Date: 11-09-2012
#####################################################################################################################################################
#!/usr/bin/perl

#get current directory
use Cwd 'abs_path';
$line = abs_path($0);
chomp $line;
@DR_array = split('/',$line);
pop(@DR_array);
$dir = join("/",@DR_array);


use Getopt::Long;

&Getopt::Long::GetOptions(
'REF_GENOME_DIR=s' => \$refdir,
'OUTPUT_DIR=s' => \$outdir,
'INCLUDE_POP=s'=> \$include_pop,
'COND=s'=> \$cond,
'INCHR=s'=> \$inchr
);
if($include_pop eq ""  || $refdir eq "" || $outdir eq "" )
{
	die "missing arguments\n USAGE : perl Filter_1000genome_reference_by_maf_cond.pl  -INCLUDE_POP <POPULATIONS TO BE INCLUDE IN THE NEW REFERENCE>  -REF_GENOME_DIR <Reference Genome Directory or Path to Metainfo file> -OUTPUT_DIR <OUTPUT DIR> -INCHR <in chromsome number (optional)> -COND <Filtering CONDITION by different population : AFR,AMR,ASN,EUR (optional)>\n";
}
@include_pop=split(',',$include_pop);

$checkcond=$cond;
$checkcond =~ s/ALL|EUR|AMR|AFR|ASN|all|eur|amr|afr|asn|[0-9 "'\.&()><=_!|]//g;

if($checkcond ne "")
{
	die "characters $checkcond not permitted in the cond $cond\n";
}

if($cond eq "")
{
	$cond="($include_pop[0] >= 0 & $include_pop[0] <= 1)";
	for($i=1;$i<@include_pop;$i++)
	{
		$cond=$cond.' | '."($include_pop[$i] >= 0 & $include_pop[$i] <= 1)";
	}
}
#checking for equal number of popultion & maf
@pp=('EUR','AFR','ASN','AMR','ALL');
for($i=0;$i<@pp;$i++)
{
	if($cond =~ m/$pp[$i]/)
	{
		$pop{uc($pp[$i])}="";
	}
}	
for($i=0;$i<@include_pop;$i++)
{
	$include_pop{uc($include_pop[$i])}="";
	$pop{uc($include_pop[$i])}="";
}
print "***********INPUT ARGUMENTS***********\n";
print "REF_GENOME_DIR: $refdir\n";
print "OUTPUT_DIR : $outdir\n";
print "INCLUDE_POP : $include_pop\n";
print "COND : $cond\n";

unless((-d $refdir)||(-f $refdir))
{
    print "Directory doesn't exist $refdir\n";
}
$refdir =~ s/\/$//g;

#reading ref directory
require "$dir/bin/Read_reffile.pl";

getRef($refdir);

#check reference
for(my $chr=23;$chr>0;$chr--)
{
	if(exists($ref_meta{"chr$chr".'_'."genetic"}))
	{
		print "chr$chr".'_'."genetic"." ".$ref_meta{"chr$chr".'_'."genetic"}."\n";
	}
	else
	{
		die "there is a problem in the ref dir or metainfo file provided. No value for chr$chr".'_'."genetic\n";
	}
	if(exists($ref_meta{"chr$chr".'_'."hap"}))
	{
			print "chr$chr".'_'."hap"." ".$ref_meta{"chr$chr".'_'."hap"}."\n";
	}
	else
	{
			die "there is a problem in the ref dir or metainfo file provided. No value for chr$chr".'_'."hap\n";
	}
	if(exists($ref_meta{"chr$chr".'_'."legend"}))
	{
			print "chr$chr".'_'."legend"." ".$ref_meta{"chr$chr".'_'."legend"}."\n";
	}
	else
	{
			die "there is a problem in the ref dir or metainfo file provided. No value for chr$chr".'_'."legend\n";
	}
}
if(exists($ref_meta{"sample"}))
{
	print "sample"." ".$ref_meta{"sample"}."\n";
}
else
{
    die "there is a problem in the ref dir or metainfo file provided. No value for sample\n";
}



$outdir =~ s/\/$//g;
#creating output directory if not exists
mkdir "$outdir", unless -d "$outdir";

#opening the sample in the impute 1000 genome reference and extracting the columns for population and group
$file="$refdir/".$ref_meta{"sample"};
open(SAMP,$file) or die "no sample file found $file\n";
$basename_samp=`basename $ref_meta{"sample"}`;
chomp($basename_samp);
if(!(-e "$outdir/$basename_samp"))
{
	open(WRSAMP,">$outdir/$basename_samp") or die "no sample file found $outdir/$basename_samp\n";
}
$samp=<SAMP>;
print WRSAMP $samp; 
#print $samp."\n";
@samp=split(" ",$samp);
for($i=0;$i<@samp;$i++)
{
	if(lc($samp[$i]) eq "group")
	{
		$samp_pop=$i;
	}
}

#creating the hash for each population with individuals in it
$samp_order=0;
while(<SAMP>)
{
	#print WRSAMP $_;
	chomp($_);
	@samp=split(" ",$_);
	$samp1_a1=$samp_order++;
	$samp1_a2=$samp_order++;
	#print "$samp[$samp_pop]\n";
	if(exists($include_pop{"ALL"}) || exists($include_pop{uc($samp[$samp_pop])})  || exists($include_pop{uc($samp[$samp_group])}))
	{
			print WRSAMP $_."\n";
	}
	if(exists($pop{uc($samp[$samp_pop])}))
	{
		$pop{uc($samp[$samp_pop])}=$pop{uc($samp[$samp_pop])}." $samp1_a1 $samp1_a2";
		
	}
	if(exists($pop{"ALL"}))
	{
		$pop{"ALL"}=$pop{"ALL"}." $samp1_a1 $samp1_a2";
	}
	
}
close(SAMP);
#die "test ".$pop{"AFR"}."\n";
@final_combined=();
#combining the population for final printing
for($i=0;$i<@include_pop;$i++)
{
	@temp = split(" ",$pop{uc($include_pop[$i])});
	@final_combined=uniq(@final_combined,@temp);
}
@final_combined = sort {$a <=> $b} @final_combined;



@pp=keys %pop;

$startchr=$inchr;
if(!defined($inchr))
{
	$startchr=1;
	$inchr=23;
}
for($chr=$startchr;$chr<=$inchr;$chr++)
#for($chr=$inchr;$chr<=$inchr;$chr++)
{
	print "dealing with chr $chr\n";
	$file="$refdir/".$ref_meta{"chr$chr".'_'."hap"};
	open(HAP,"gunzip -c $file|") or die " no file found ".$file." \n";
	$file="$refdir/".$ref_meta{"chr$chr".'_'."legend"};
	open(LEGEND,"gunzip -c $file|") or die " no file found ".$file." \n";
	$file="$refdir/".$ref_meta{"chr$chr".'_'."genetic"};
	open(GEN,$file) or die " no file found ".$file." \n";
	$basename_hap=`basename $ref_meta{"chr$chr".'_'."hap"}`;
	$basename_legend=`basename $ref_meta{"chr$chr".'_'."legend"}`;
	$basename_genetic=`basename $ref_meta{"chr$chr".'_'."genetic"}`;
	chomp($basename_hap);
	chomp($basename_legend);
	chomp($basename_genetic);
	$file=$basename_legend;
	open(WRLEGEND,"| gzip -c > $outdir/$file") or die "unable to write $file\n";
	$file=$basename_hap;
	open(WRHAP,"| gzip -c > $outdir/$file") or die "unable to write $file\n";
	$file=$basename_genetic;
	open(WRGEN,">$outdir/$file") or die "unable to write $file\n";

	$line = <LEGEND>;
	print WRLEGEND $line;
	#die "$line\n";
	$line=<GEN>;
	print WRGEN $line;
	#die "$maf\n";
	undef(%pos);
	#reading the legend and haps file from the referece directory
	while(<LEGEND>)
	{
		chomp($_);
		@array=split(" ",$_);
		$haps=<HAP>;
		chomp($haps);
		#print "$chr $array[1]\n";
		@haps=split(" ",$haps);
		$k=1;	
		@tmp_pop=();
		#parsing through the each of the chromosome
		for($p=0;$p<@pp;$p++)
		{
			$key=$pp[$p];
			#print $key."\n";	
			$value=$pop{uc($key)};
			#print $value."\n";
			$tmp_pop ="";
			$tmp_maf="";
			undef(@tmp_pop);
			@tmp_pop=split(" ",$value);
			for($i=0;$i<@tmp_pop;$i++)
			{
				$tmp_pop =$tmp_pop." ".$haps[$tmp_pop[$i]];
			}
			#counting different alleles
			$tmp_pop_0 = ()=$tmp_pop=~ m/ 0/g;
			$tmp_pop_1 = ()=$tmp_pop=~ m/ 1/g;
			#calculating the maf
			#print "$tmp_pop_1 + $tmp_pop_0\n";
			if($tmp_pop_0 > $tmp_pop_1)
			{
					$tmp_maf=$tmp_pop_1/($tmp_pop_1 + $tmp_pop_0);
			}
			else
			{
				$tmp_maf=$tmp_pop_0/($tmp_pop_1 + $tmp_pop_0);
			}
			$pp1[$p]=$tmp_maf;
		}
		$cond1=$cond;
		for($i=0;$i<@pp;$i++)
		{
			if($cond =~ m/$pp[$i]/)
			{
				$cond1 =~ s/$pp[$i]/$pp1[$i]/g;
			}
		}	
		#checking cond
		if(eval($cond1))
		{
			$k=0;
		}
		#if k value is unchanged then the input maf conditions are agreed	
		if($k==0)
		{
			$selected{$array[1]} =1;
			my @write_haps;
			for($i=0;$i<@final_combined;$i++)
			{
				$write_haps[$i] = $haps[$final_combined[$i]];
			}
			$haps=join(" ",@write_haps);
			print WRLEGEND "$_\n";
			print WRHAP "$haps\n";
		}
			
	}
	#creating the new genetic map file with only markers satisfying the maf condition
	while(<GEN>)
	{
		chomp($_);
		@gen=split(" ",$_);
		if(exists($selected{$gen[0]}))
		{
			print WRGEN $_."\n";
			delete($selected{$gen[0]});
		}
	}
}
close(GEN);
close(HAP);
close(LEGEND);
close(WRGEN);
close(WRHAP);
close(WRLEGEND);
#########################SUBROUTINES####################################################
sub uniq {
    my %seen;
    grep { !$seen{$_}++ } @_;
}
