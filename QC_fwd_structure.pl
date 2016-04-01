#####################################################################################################################################################
#Purpose: To perform QC,ForwardStarnd & Structure
#Date: 01-04-2013
#####################################################################################################################################################
#!/usr/bin/perl
use Getopt::Long;
&Getopt::Long::GetOptions(
'run_config=s'      => \$config,
'tool_config=s'      => \$toolconfig
);
if($config eq "" || $toolconfig eq "")
{
	print "config file missing.Check for this program manual and create a config file \n";
	
	die "Retry with : perl QC_fwd_structure.pl -run_config <PATH TO THE RUN CONFIG FILE> -tool_config <PATH TO THE TOOL INFO CONFIG FILE>\n";
}
#to know the path of this script 
use Cwd 'abs_path';
$line = abs_path($0);
chomp $line;

@DR_array = split('/',$line);
pop(@DR_array);
$dir = join("/",@DR_array);



require "$dir/bin/CONFIG.pl";
getDetails($config);
my $tped= $config{"TPED"};
my $tfam = $config{"TFAM"};
my $outdir = $config{"OUTPUT_FOLDER"};
my $dirtemp = $config{"TEMP_FOLDER"};
my $impute_ref = $config{"IMPUTE_REF"};
my $ref_keyword = $config{"IMPUTEREF_VERSION"};
my $geno = $config{"GENOTYPE_PERCENT_CUTOFF"};
my $mind = $config{"SAMPLE_PERCENT_CUTOFF"};
my $rounded = $config{"INNER_DIR"};
my $db=$config{"BEAGLE_REF_DB"};
my $option=$config{"OPTION"}; 

getDetails($toolconfig);
my $PLINK= $config{"PLINK"};
my $STRUCTURE= $config{"STRUCTURE"};
my $STRUCTURE_PARAM= $config{"STRUCTURE_PARAM"};
my $CHECK_STRAND= $config{"CHECK_STRAND"};
my $PERL= $config{"PERL"};
my $PYTHON=$config{"PYTHON"};

$dirtemp =~ s/\s|\t|\r|\n//g;
$tped =~ s/\s|\t|\r|\n//g;
$tfam =~ s/\s|\t|\r|\n//g;
$outdir =~ s/\s|\t|\r|\n//g;
$impute_ref =~ s/\s|\t|\r|\n//g;
$ref_keyword =~ s/\s|\t|\r|\n//g;
$geno =~ s/\s|\t|\r|\n//g;
$mind =~ s/\s|\t|\r|\n//g;
$rounded =~ s/\s|\t|\r|\n//g;
$db =~ s/\s|\t|\r|\n//g;
$PLINK =~ s/\s|\t|\r|\n//g;
$STRUCTURE =~ s/\s|\t|\r|\n//g;
$STRUCTURE_PARAM =~ s/\s|\t|\r|\n//g;
$CHECK_STRAND =~ s/\s|\t|\r|\n//g;
$PERL =~ s/\s|\t|\r|\n//g;
$PYTHON =~ s/\s|\t|\r|\n//g;
$option =~ s/\s|\t|\r|\n//g;

print "***********INPUT ARGUMENTS FOR RUN CONFIG FILE***********\n";
print "TPED: $tped\n";
print "TFAM: $tfam\n";
print "OUTPUT_FOLDER: $outdir\n";
print "TEMP_FOLDER: $dirtemp\n";
print "IMPUTE_REF: $impute_ref\n";
print "IMPUTEREF VERSION: $ref_keyword\n";
print "GENOTYPE_PERCENT_CUTOFF: $geno\n";
print "SAMPLE_PERCENT_CUTOFF: $mind\n";
print "INNER_DIR : $rounded\n";
print "BEAGLE_REF_DB : $db\n";
print "OPTION : $option\n";

print "***********INPUT ARGUMENTS FOR TOOL CONFIG FILE***********\n";
print "PLINK: $PLINK\n";
print "STRUCTURE: $STRUCTURE\n";
print "STRUCTURE_PARAM: $STRUCTURE_PARAM\n";
print "CHECK_STRAND: $CHECK_STRAND\n";  
print "PERL: $PERL\n";
print "PYTHON: $PYTHON\n";

if($db eq "" |$rounded eq "" |  $dirtemp eq "" | $tped eq "" | $tfam eq "" | $outdir eq "" | $impute_ref eq "" | $ref_keyword eq "")
{
	die "input RUN CONFIG arguments empty please correct arguments and retry\n";
}
if($option eq "")
{
	die "$option canot be empty\n";
}
elsif($option =~ m/MISSING/i)
{
	if($geno eq "" |$mind eq "" )
	{
		die "you selected the MISSING option! So 'GENOTYPE_PERCENT_CUTOFF' and 'SAMPLE_PERCENT_CUTOFF' cannot be empty! \n"; 
	}
}

if($PLINK eq "" | $STRUCTURE eq "" |  $STRUCTURE_PARAM eq "" | $CHECK_STRAND eq "" |$PERL eq "" |$PYTHON eq "" )
{
	die "input TOOL CONFIG FILE arguments empty please correct arguments and retry\n";
} 

if(!(-e $PYTHON) | !(-e $PLINK) | !(-e $STRUCTURE) | !(-e $STRUCTURE_PARAM) | !(-e $STRUCTURE_PARAM) | !(-e $CHECK_STRAND) | !(-e $PERL))
{
	die "input TOOL config file executable doesnot exist.Please recheck for input config file executables\n";
}
if(!(-e $tped) | !(-e $tfam))
{
	 die "input tfam or tped file does not exist\n";
}
unless(-d $dirtemp)
{
    system("mkdir -p $dirtemp");
}
unless(-d "$dirtemp/$rounded")
{
    system("mkdir -p $dirtemp/$rounded");
}
unless(-d $outdir)
{
    system("mkdir -p $outdir");
}
if(!(-d $impute_ref) && !(-f $impute_ref))
{
	die "impute ref directory not found\n";
}
if(uc($rounded) eq "NA")
{
	$round = sprintf("%.0f", rand()*time());
	$rounded = "temp".$round;
}
if(!(-e "$dirtemp/$rounded/temp.tped"))
{
	system("cp $tped $dirtemp/$rounded/temp.tped");
	system("cp $tfam $dirtemp/$rounded/temp.tfam");
}
if(!(-e "$dirtemp/$rounded/temp.bim"))
{
	system("$PLINK --tfile $dirtemp/$rounded/temp --make-bed --out $dirtemp/$rounded/temp > $dirtemp/$rounded/temp.log");
}
if($option =~ m/MISSING/i)
{
		print "geno: $geno mind: $mind\n";
		#Running plink to get the missing information
		print "\n\n\n\n\n***********Running plink to get the missing information**************\n";
		$exitcode=system("$PLINK  --tfile $dirtemp/$rounded/temp --missing --out $dirtemp/$rounded/miss>$dirtemp/$rounded/miss.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/miss.log\n";
		}
		if (!(-e "$dirtemp/$rounded/miss.imiss")) {
				die "something wrong in the plink input files --tfile $dirtemp/$rounded/temp\n";
		}
		 #Removing SNPs that fail in all the samples and Removing Samples with % specified missing in the config file
		print "\n\n\n\n\n***********Removing SNPs that fail in all the samples and Removing Samples with >$mind % missing***********\n"; 
		$exitcode=system("$PLINK  --bfile $dirtemp/$rounded/temp --missing --geno 0.999 --mind $mind --make-bed --out $dirtemp/$rounded/intialqc > $dirtemp/$rounded/intialqc.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/intialqc.log\n";
		}
		if (!(-e "$dirtemp/$rounded/intialqc.fam")) {
				die "something wrong in the plink input files --tfile $dirtemp/$rounded/temp \n";
		}
		system("rm $dirtemp/$rounded/temp.fam $dirtemp/$rounded/temp.bed $dirtemp/$rounded/temp.bim"); 

		#Removingemove SNPs that failed in >=$geno % (90% for illumina and >=10% for affy) of remaining samples
		print "\n\n\n\n\n***********Removingemove SNPs that failed in >=$geno % (90% for illumina and >=10% for affy) of remaining samples***********\n"; 
		$exitcode=system("$PLINK  --bfile $dirtemp/$rounded/intialqc --missing --geno $geno --make-bed --out $dirtemp/$rounded/geno > $dirtemp/$rounded/geno.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/geno.log\n";
		}
		if (!(-e "$dirtemp/$rounded/geno.fam")) {
				die "something wrong in the plink command geno\n";
		}
		system("rm $dirtemp/$rounded/intialqc.*");

		#Flag Samples with a lot of missing>$mind %(5% Affy and 2% Illumina
		print "\n\n\n\n\n***********Flag Samples with a lot of missing>$mind %(5% Affy and 2% Illumina***********\n";
		$exitcode=system("$PLINK --bfile $dirtemp/$rounded/geno --missing --mind $mind --make-bed --out $dirtemp/$rounded/mind > $dirtemp/$rounded/mind.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/mind.log\n";
		}
		if (!(-e "$dirtemp/$rounded/mind.fam")) {
				die "something wrong in the plink command mind\n";
		}
		system("rm $dirtemp/$rounded/geno.*");
		
		$exitcode=system("$PLINK --bfile $dirtemp/$rounded/mind --make-bed --out $dirtemp/$rounded/temp>$dirtemp/$rounded/temp.log"); 
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/temp.log\n";
		}
		system("rm $dirtemp/$rounded/mind.bed $dirtemp/$rounded/mind.bim $dirtemp/$rounded/mind.fam $dirtemp/$rounded/mind.hh $dirtemp/$rounded/mind.log"); 
		#system("mv $dirtemp/$rounded/miss.imiss $dirtemp/$rounded/samples.qc");
		$sys = "$PERL $dir/bin/sexcheck.pl -i $dirtemp/$rounded/miss.imiss -v $mind -o $dirtemp/$rounded/samples.qc";
		#print "executing $sys\n";
		$exitcode=system($sys);
		if($exitcode != 0)
		{
			die "command $sys failed\nexitcode $exitcode\n";
		}
		
		system("rm $dirtemp/$rounded/mind.*");
		#system("rm $dirtemp/$rounded/miss.*");
		
}
if($option =~ m/SEXCHECK/i)
{
	#Imputing the sex information to cross check with the given one
	print "\n\n\n\n\n***********Imputing the sex information to cross check with the given one	***********\n";
	if(!(-e "$dirtemp/$rounded/miss.imiss"))
	{
		$exitcode=system("$PLINK  --tfile $dirtemp/$rounded/temp --missing --out $dirtemp/$rounded/miss > $dirtemp/$rounded/miss.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/miss.log\n";
		}
	}
	$exitcode=system("$PLINK  --bfile $dirtemp/$rounded/temp --impute-sex  --recode --transpose --out $dirtemp/$rounded/imputesex > $dirtemp/$rounded/imputesex.log");
	if($exitcode != 0)
	{
		die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/imputesex.log\n";
	}
	if (!(-e "$dirtemp/$rounded/imputesex.tfam")) 
	{
			die "something wrong in the plink command impute sex\n";
	}
	system("mv $dirtemp/$rounded/imputesex.sexcheck $dirtemp/$rounded/sexcheck.txt");
	system("mv $dirtemp/$rounded/imputesex.tped $dirtemp/$rounded/unprocessed_input.tped");

	#replacing the plink predicted gender with original if not missing
	$sys = "$PERL $dir/bin/perl_replace_originalsex_predicted_sex.pl $dirtemp/$rounded/sexcheck.txt $dirtemp/$rounded/temp.tfam $dirtemp/$rounded/unprocessed_input.tfam";
	#print "executing $sys\n";
	$exitcode=system($sys);
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	#generating the Qc file with gender related indicators included

	$sys = "$PERL $dir/bin/sexcheck.pl -i $dirtemp/$rounded/miss.imiss -d $dirtemp/$rounded/sexcheck.txt -v $mind -o $dirtemp/$rounded/samples1.qc";
	#print "executing $sys\n";
	$exitcode=system($sys);
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	
	$sys="mv $dirtemp/$rounded/samples1.qc $dirtemp/$rounded/samples.qc";
	#print "executing $sys\n";
	$exitcode=system($sys);
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	
	$exitcode=system("$PLINK --tfile $dirtemp/$rounded/unprocessed_input --make-bed --out $dirtemp/$rounded/temp > $dirtemp/$rounded/temp.log"); 
	if($exitcode != 0)
	{
		die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/temp.log\n";
	}	
	system("rm $dirtemp/$rounded/imputesex.*");
	system("rm $dirtemp/$rounded/unprocessed_input.*");
	system("rm $dirtemp/$rounded/sexcheck.txt");
}
if($option =~ m/FORWARD_STRAND/i)
{
	$exitcode=system("$PLINK --bfile $dirtemp/$rounded/temp --transpose --recode --out $dirtemp/$rounded/unprocessed_input > $dirtemp/$rounded/unprocessed_input.log");
	if($exitcode != 0)
	{
		die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/unprocessed_input.log\n";
	}	
	#forwards strand mapping
	$sys="$PERL $dir/bin/perl_script_fwd_strand_mapping.pl -DB $db -REF_GENOME_DIR $impute_ref -IMPUTEREF_VERSION $ref_keyword -INPUT_FILE $dirtemp/$rounded/unprocessed_input.tped -OUTPUTFILE $dirtemp/$rounded/ -TEMP $dirtemp/$rounded/temp -CHECK_STRAND $CHECK_STRAND -PYTHON $PYTHON";
	#print $sys."\n";
	$exitcode=system($sys);
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	
	if(-e "$dirtemp/$rounded/temp_input.tped")
	{
		system("mv $dirtemp/$rounded/temp_input.tped $dirtemp/$rounded/unprocessed_input.tped");
		$exitcode=system("$PLINK --tfile $dirtemp/$rounded/unprocessed_input --make-bed --out $dirtemp/$rounded/temp > $dirtemp/$rounded/temp.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/temp.log\n";
		}
		system("mv $dirtemp/$rounded/temp_input.ind $outdir/fwdStrandResults_input.ind");
		system("mv $dirtemp/$rounded/temp_input.ignored  $outdir/markers.ignored");
	}
	else
	{
		die "Something wrong with Forward strand mapping step.$dirtemp/$rounded/temp_input.tped not found\n";
	}
}	
else
{
	system("cp $dirtemp/$rounded/samples.qc $outdir/sample.qc");
}
$exitcode=system("$PLINK --bfile $dirtemp/$rounded/temp --transpose --recode --out $outdir/processed_input > $outdir/processed_input.log");
if($exitcode != 0)
{
	die "plink command failed\nexitcode $exitcode\nPlease check the log file $outdir/processed_input.log\n";
}
		
#include Structure
if($option =~ m/STRUCTURE/i)
{
	$exitcode=system("$PLINK --bfile $dirtemp/$rounded/temp --transpose --recode --out $dirtemp/$rounded/fwdStrandResults_unprocessed_input > $dirtemp/$rounded/fwdStrandResults_unprocessed_input.log");
	if($exitcode != 0)
	{
		die "plink command failed\nexitcode $exitcode\nPlease check the log file $outdir/processed_input.log\n";
	}
	#extract input markers ids to snps_inputdata
	system("cut -f2 -d ' ' $dirtemp/$rounded/fwdStrandResults_unprocessed_input.tped > $dirtemp/$rounded/snps_inputdata");
	#extract marker reference id's to distanct_snps
	system("cut -f2 $dir/bin/reference.bim > $dirtemp/$rounded/distanct_snps");
	#extracting commons markers from both reference & input data
	
	system("cat $dirtemp/$rounded/snps_inputdata $dirtemp/$rounded/distanct_snps |sort -T $dirtemp/$rounded/ |uniq -d > $dirtemp/$rounded/snps_common_input_and_distainct_selected"); 
	#extracting common markers from reference
	$exitcode=system("$PLINK --bfile $dir/bin/reference --keep $dir/bin/selected_1000genome_hapmap_refknown --extract $dirtemp/$rounded/snps_common_input_and_distainct_selected --make-bed --out $dirtemp/$rounded/reference > $dirtemp/$rounded/reference.log");
	if($exitcode != 0)
	{
		die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/reference.log\n";
	}
	#extracting common markers from input
	$exitcode=system("$PLINK --tfile $dirtemp/$rounded/fwdStrandResults_unprocessed_input --extract $dirtemp/$rounded/snps_common_input_and_distainct_selected --make-bed --out $dirtemp/$rounded/inputdata > $dirtemp/$rounded/inputdata.log");
	if($exitcode != 0)
	{
		die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/inputdata.log\n";
	}
	#fliping snp in input comparing to hapmap
	open(BUFF,"$dirtemp/$rounded/inputdata.bim") or die "no file found $dirtemp/$rounded/inputdata.bim\n";
	open(REF,"$dirtemp/$rounded/reference.bim") or die "no file found $dirtemp/$rounded/reference.bim\n";
	open(WRBUFF1,">$dirtemp/$rounded/combined_ref_input.missnp") or die "not able to write $dirtemp/$rounded/combined_ref_input.missnp\n";
	open(WRBUFF2,">$dirtemp/$rounded/combined_ref_input.drop") or die "not able to write $dirtemp/$rounded/combined_ref_input.drop\n";
	$drop = 0;
	$flip = 0;
	$totalnum =0;
	while(<REF>)
	{
		chomp($_);
		@ref = split("\t",$_);
		$REF{$ref[1]} = $_;
		$totalnum++;
	}
	if($totalnum < 500)
	{
		die "not enough snps present to do structure analysis\n";
	}
	while(<BUFF>)
	{
		#$line = <REF>;
		chomp($_);
		#chomp($line);
		@input = split("\t",$_);
		if(exists($REF{$input[1]}))
		{
			@ref = split("\t",$REF{$input[1]});
		}
		else
		{
			die "snp in input but not in the hapmap reference : structure :dataset prep step\n";
		}
	#if monomorphic condition	
		if($input[4] ne "0")
		{
			if(($input[5] eq $ref[5] && $input[4] eq $ref[4]) ||($input[4] eq $ref[5] && $input[5] eq $ref[4]))
			{
			}
			else
			{
				$input[5] =~ tr/ATGC/TACG/;
				$input[4] =~ tr/ATGC/TACG/;
				if(($input[5] eq $ref[5] && $input[4] eq $ref[4]) ||($input[4] eq $ref[5] && $input[5] eq $ref[4]))
				{
					print WRBUFF1 $input[1]."\n";
					$flip++;	
				}
				else
				{
					print WRBUFF2 $input[1]."\n";
					$drop++;
				}		
			}	
		}
		else
		{
			if($input[5] eq $ref[5] || $input[5] eq $ref[4])
			{
			}
			else
			{
				$input[5] =~ tr/ATGC/TACG/;
				if($input[5] eq $ref[5] || $input[5] eq $ref[4])
				{
					print WRBUFF1 $input[1]."\n";
					$flip++;	
				}
				else
				{
					print WRBUFF2 $input[1]."\n";
					$drop++;
				}		
			}	
		
		}
	}	
	close(WRBUFF1);
	close(WRBUFF2);
	close(REF);
	close(BUFF);

	if($flip >1 && $drop > 1)
	{
		$exitcode=system("$PLINK --bfile $dirtemp/$rounded/inputdata --exclude $dirtemp/$rounded/combined_ref_input.drop --flip $dirtemp/$rounded/combined_ref_input.missnp --make-bed --out $dirtemp/$rounded/inputdata1 > $dirtemp/$rounded/inputdata1.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/inputdata1.log\n";
		}
		system(" mv $dirtemp/$rounded/inputdata1.bim $dirtemp/$rounded/inputdata.bim");
		system(" mv $dirtemp/$rounded/inputdata1.bed $dirtemp/$rounded/inputdata.bed");
		system(" mv $dirtemp/$rounded/inputdata1.fam $dirtemp/$rounded/inputdata.fam");	
		$exitcode=system("$PLINK --bfile  $dirtemp/$rounded/reference  --bmerge $dirtemp/$rounded/inputdata.bed $dirtemp/$rounded/inputdata.bim $dirtemp/$rounded/inputdata.fam --recode12 --output-missing-genotype -9 --out $dirtemp/$rounded/combined_ref_input > $dirtemp/$rounded/combined_ref_input.log"); 
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/combined_ref_input.log\n";
		}
	}
	elsif($flip >1)
	{
		$exitcode=system("$PLINK --bfile $dirtemp/$rounded/inputdata  --flip $dirtemp/$rounded/combined_ref_input.missnp --make-bed --out $dirtemp/$rounded/inputdata1 > $dirtemp/$rounded/inputdata1.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/inputdata1.log\n";
		}
		system(" mv $dirtemp/$rounded/inputdata1.bim $dirtemp/$rounded/inputdata.bim");
		system(" mv $dirtemp/$rounded/inputdata1.bed $dirtemp/$rounded/inputdata.bed");
		system(" mv $dirtemp/$rounded/inputdata1.fam $dirtemp/$rounded/inputdata.fam");	
		$exitcode=system("$PLINK --bfile  $dirtemp/$rounded/reference  --bmerge $dirtemp/$rounded/inputdata.bed $dirtemp/$rounded/inputdata.bim $dirtemp/$rounded/inputdata.fam --recode12 --output-missing-genotype -9 --out $dirtemp/$rounded/combined_ref_input > $dirtemp/$rounded/combined_ref_input.log"); 
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/combined_ref_input.log\n";
		}
	}
	elsif($drop > 1)
	{
		$exitcode=system("$PLINK --bfile $dirtemp/$rounded/inputdata --exclude $dirtemp/$rounded/combined_ref_input.drop  --make-bed --out $dirtemp/$rounded/inputdata1 > $dirtemp/$rounded/inputdata1.log");
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/inputdata1.log\n";
		}
		system(" mv $dirtemp/$rounded/inputdata1.bim $dirtemp/$rounded/inputdata.bim");
		system(" mv $dirtemp/$rounded/inputdata1.bed $dirtemp/$rounded/inputdata.bed");
		system(" mv $dirtemp/$rounded/inputdata1.fam $dirtemp/$rounded/inputdata.fam");	
		$exitcode=system("$PLINK --bfile  $dirtemp/$rounded/reference  --bmerge $dirtemp/$rounded/inputdata.bed $dirtemp/$rounded/inputdata.bim $dirtemp/$rounded/inputdata.fam --recode12 --output-missing-genotype -9 --out $dirtemp/$rounded/combined_ref_input > $dirtemp/$rounded/combined_ref_input.log"); 
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/combined_ref_input.log\n";
		}
	}
	else
	{
		$exitcode=system("$PLINK --bfile  $dirtemp/$rounded/reference  --bmerge $dirtemp/$rounded/inputdata.bed $dirtemp/$rounded/inputdata.bim $dirtemp/$rounded/inputdata.fam --recode12 --output-missing-genotype -9 --out $dirtemp/$rounded/combined_ref_input > $dirtemp/$rounded/combined_ref_input.log"); 
		if($exitcode != 0)
		{
			die "plink command failed\nexitcode $exitcode\nPlease check the log file $dirtemp/$rounded/combined_ref_input.log\n";
		}
	}
	#preparing the structure program
	system("mkdir $dirtemp/$rounded/workdir");
	system("cut -d ' ' -f2,6- $dirtemp/$rounded/combined_ref_input.ped >  $dirtemp/$rounded/workdir/temp.geno");

	#renaming the population column(second) hapmap  samples in the structure dataset
	open BUFF,"$dir/bin/referencesamples" or die "no file $dir/bin/referencesamples found\n";
	while($line = <BUFF>)
	{
			chomp($line);

			@array = split(/\t/,$line);
			#print "@array\n";
			$hash{$array[0]} = $array[2];
	}

	open BUFF,"$dirtemp/$rounded/workdir/temp.geno" or die "no file infile found\n";
	open(WRBUFF,">$dirtemp/$rounded/workdir/temp1.geno") or die "unable to write file\n";
	$total_samp_num = 0;
	$totalnum = 0;
	while($line = <BUFF>)
	{
			if($total_samp_num == 0)
			{
				@totalnum = split(" ",$line);
				$totalnum = (@totalnum -2)/2;
			}
			$total_samp_num++;
			$line =~ s/\t+/ /g;
			$line =~ s/\s+/ /g;
			chomp($line);
			@array = split(/ /,$line);
			if(exists($hash{$array[0]}))
			{
					$array[1] = $hash{$array[0]};
			}
			else
			{
					$array[1] = 0;
			}
			$line = join(" ",@array);
			print WRBUFF $line."\n";
	}
	close(BUFF);
	close(WRBUFF);
	system("mv $dirtemp/$rounded/workdir/temp1.geno $dirtemp/$rounded/workdir/temp.geno");
	#creating the extraparam file
	system("cp $STRUCTURE_PARAM $dirtemp/$rounded/workdir/structure.extraparams");
	#creating the main param file
	open(WRBUFF,">$dirtemp/$rounded/workdir/structure.mainparams") or die "unable to write main param file\n";
	print WRBUFF '#define INFILE'." $dirtemp/$rounded/workdir/temp.geno\n";
	print WRBUFF '#define OUTFILE '."$dirtemp/$rounded/workdir/temp_structure.out\n";
	print WRBUFF '#define NUMINDS '."$total_samp_num\n";
	print WRBUFF '#define NUMLOCI '."$totalnum\n";
	print WRBUFF '#define LABEL     1'."\n";
	print WRBUFF '#define POPDATA   1'."\n";
	print WRBUFF '#define POPFLAG   0'."\n";
	print WRBUFF '#define PHENOTYPE 0'."\n";
	print WRBUFF '#define EXTRACOLS 0'."\n";
	print WRBUFF '#define PHASEINFO 0'."\n";
	print WRBUFF '#define MISSING      -9'."\n";
	print WRBUFF '#define PLOIDY       2'."\n";
	print WRBUFF '#define ONEROWPERIND 1'."\n";
	print WRBUFF '#define MARKERNAMES  0'."\n";
	print WRBUFF '#define MAPDISTANCES 0'."\n";
	print WRBUFF '#define MAXPOPS    3'."\n";
	print WRBUFF '#define BURNIN    4000'."\n";
	print WRBUFF '#define NUMREPS   4000'."\n";
	system("$STRUCTURE -m $dirtemp/$rounded/workdir/structure.mainparams -e $dirtemp/$rounded/workdir/structure.extraparams -K 3"); 

	if(!(-e "$dirtemp/$rounded/workdir/temp_structure.out_f"))
	{
		die "out file $dirtemp/$rounded/workdir/temp_structure.out_f does not exists\n";
	}
	$sys = "$PERL $dir/bin/perl_process_after_result_structure_out.pl $dirtemp/$rounded/workdir/temp_structure.out_f $dirtemp/$rounded/QC_output_structure $dir/bin/newreference_info";
	#print "$sys\n";
	$exitcode=system($sys);
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	
	#combining result with QC result with struture result
	open(BUFF,"$dirtemp/$rounded/QC_output_structure") or die " no file $dirtemp/$rounded/QC_output_structure structure output exists\n";
	open(INPUT,"$dirtemp/$rounded/inputdata.fam") or die  " no file $dirtemp/$rounded/inputdata.fam exists\n";
	open(QCIN,"$dirtemp/$rounded/samples.qc " ) or die  " no QC output file $dirtemp/$rounded/sample.qc exists\n";
	open(QCOUT,">$dirtemp/$rounded/temp.qc" ) or die  " no able to write structure output file\n";
	$line=<BUFF>;
	chomp($line);
	$line =~ s/Sample\t//g;
	$qcin = <QCIN>;
	chomp($qcin);
	print QCOUT "$qcin\t$line\n";
	while(<BUFF>)
	{
		chomp($_);
		@line = split(" ",$_);
		shift(@line);
		$_ = join("\t",@line);
		$input = <INPUT>;
		@input = split(" ",$input);
		$structure{$input[1]}= $_;
		#print "$input\t$_\n";
	}

	while($qcin = <QCIN>)
	{
		chomp($qcin);
		@qcin = split("\t",$qcin);
		if(exists($structure{$qcin[0]}))
		{
			print QCOUT "$qcin\t".$structure{$qcin[0]}."\n";
		}
		else
		{
			print QCOUT "$qcin\tNA\tNA\tNA\n";
		}
	}
	close(BUFF);
	close(INPUT);
	close(QCIN);
	close(QCOUT);
	system("mv $dirtemp/$rounded/temp.qc $outdir/sample.qc");
}
	#moving the results
	
	#system("mv $dirtemp/$rounded/fwdStrandResults_unprocessed_input.tped $outdir/fwdStrandResults_input.tped");
	 #system("mv $dirtemp/$rounded/fwdStrandResults_unprocessed_input.tfam $outdir/fwdStrandResults_input.tfam");
	 
