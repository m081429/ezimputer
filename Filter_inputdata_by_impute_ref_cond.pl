#####################################################################################################################################################
#Purpose: To filter the input plink data based various population MAF's on 1000 genome data
#Date: 11-09-2012
#inputfile : Input tped file
#outputfile: Output tped file
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
#reading input arguments
&Getopt::Long::GetOptions(
'REF_GENOME_DIR=s' => \$reffile_dir,
'INPUT_FILE=s' => \$inputfile,
'OUTPUT_FILE=s'=> \$outputfile,
'COND=s'=> \$cond
);
chomp($inputfile);
chomp($reffile_dir);
$reffile_dir =~ s/\/$//g;
chomp($outputfile);


#checking for missing arguments
if( $reffile_dir eq "" || $inputfile eq "" || $outputfile eq "" || $cond eq "")
{
	die "missing arguments\n USAGE : perl Filter_inputdata_by_impute_ref_cond.pl   -REF_GENOME_DIR <Reference Genome Directory or  or Path to Metainfo file> -INPUT_FILE <INPUT TPED FILE> -OUTPUT_FILE <OUTPUT TPED FILE>  -COND <Filtering CONDITION by different population : ALL,AFR,AMR,ASN,EUR>\n";
}

$checkcond=$cond;
$checkcond =~ s/ALL|EUR|AMR|AFR|ASN|all|eur|amr|afr|asn|[0-9 "'\.&()><=_!|]//g;

if($checkcond ne "")
{
	die "characters $checkcond not permitted in the cond $cond\n";
}

if($cond eq "")
{
	die "cond $cond cannot be empty permitted\n";
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

print "***********INPUT ARGUMENTS***********\n";
print "REF_GENOME_DIR: $reffile_dir\n";
print "INPUT_FILE: $inputfile\n";
print "OUTPUTFILE : $outputfile\n";
print "COND : $cond\n";



unless((-d $reffile_dir))
{
    print "Directory doesn't exist $reffile_dir\n";
}
$refdir =~ s/\/$//g;

#reading ref directory
require "$dir/bin/Read_reffile.pl";

getRef($reffile_dir);

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

#opening the sample in the impute 1000 genome reference and extracting the columns for population and group
$file="$reffile_dir/".$ref_meta{"sample"};
open(SAMP,"$file") or die "no sample file found $file in the reference directory provided\n";
$samp=<SAMP>;
#print $samp."\n";
@samp=split(" ",$samp);
for($i=0;$i<@samp;$i++)
{
	if(lc($samp[$i]) eq "population")
	{
		$samp_pop=$i;
	}
	if(lc($samp[$i]) eq "group")
	{
		$samp_group=$i;
	}
}

#creating the hash for each population with individuals in it
$samp_order=0;
while(<SAMP>)
{
	chomp($_);
	@samp=split(" ",$_);
	$samp1_a1=$samp_order++;
	$samp1_a2=$samp_order++;
	if(exists($pop{uc($samp[$samp_pop])}))
	{
		$pop{uc($samp[$samp_pop])}=$pop{uc($samp[$samp_pop])}." $samp1_a1 $samp1_a2";
	}
	if(exists($pop{uc($samp[$samp_group])}))
	{
		$pop{uc($samp[$samp_group])}=$pop{uc($samp[$samp_group])}." $samp1_a1 $samp1_a2";
	}
	if(exists($pop{"ALL"}))
	{
		$pop{"ALL"}=$pop{"ALL"}." $samp1_a1 $samp1_a2";
	}
}



#storing the chr and position in the hash for the input data
open(BUFF,"$inputfile") or die " no file $inputfile found\n";
while(<BUFF>)
{
	chomp($_);
	@array=split(" ",$_);
	$pos{"$array[0]_$array[3]"}=1;
	$chr{$array[0]}=1;
}

@pp=keys %pop;
@pop=keys %pop;

#parsing through the each 1kg chromosome file (present in the input data)
while(my($chr,$value)=each %chr)
{
	#opening the legend and haps file in the reference file directory
	if($chr <24)
	{
		#$ref="/data4/bsi/refdata/genetics/1000Genomes/downloaded_data/release/20110521/impute/ALL_1000G_phase1integrated_feb2012_impute/ALL_1000G_phase1integrated_feb2012_chr".$chr."_impute.legend.gz";
		$ref_hap="$reffile_dir/".$ref_meta{"chr$chr".'_'."hap"};
		$ref="$reffile_dir/".$ref_meta{"chr$chr".'_'."legend"};
	}
	else
	{
		next;
	}
	if(!(-e $ref))
	{
		die " file $ref not exists\n";
	}
	if(!(-e $ref_hap))
	{
		die " file $ref_hap not exists\n";
	}
	#opening the haps and legend file
	open(BUFF,"gunzip -c $ref|") or die " no file exists $ref\n";
	open(HAP,"gunzip -c $ref_hap|") or die " no file exists $ref_hap\n";
	$line=<BUFF>;
	#die "$ref $line\n";
	chomp($line);
	
	while(<BUFF>)
	{
		chomp($_);
		@array=split(" ",$_);
		$haps=<HAP>;
		chomp($haps);
		#print "$chr $array[1]\n";
		$tmp=$chr."_".$array[1];
		#checking if exists in the input data
		if(exists($pos{$tmp}))
		{
			
			@haps=split(" ",$haps);
			$k=1;	
			@tmp_pop=();
			#parsing through the each of the chromosome
			for($p=0;$p<@pop;$p++)
			{
				$key=$pop[$p];
				$value=$pop{uc($key)};
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
			#print "$tmp $cond $cond1 $k\n";
			#if k value is unchanged then the input maf conditions are agreed	
			if($k==0)
			{
				$selected{"$tmp"} =1;
			}	
		}
		delete $pos{$tmp};
	}
}	
undef(%pos);
#filtering the input markers based on the selected ones
open(BUFF,"$inputfile") or die " no file $inputfile found\n";
open(WRBUFF,">$outputfile") or die "not able to write $outputfile\n";
while(<BUFF>)
{
	chomp($_);
	@array=split(" ",$_);
	if(exists($selected{"$array[0]_$array[3]"}))
	{
		print WRBUFF $_."\n";
	}
}
close(BUFF);
close(WRBUFF);
undef(%selected);
