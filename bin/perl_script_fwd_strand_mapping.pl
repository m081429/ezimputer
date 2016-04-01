#####################################################################################################################################################
#Purpose: QC_fwd_structure : perl_scri[t_fwd_strand_mapping
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
use Getopt::Long;
#reading input arguments
&Getopt::Long::GetOptions(
'REF_GENOME_DIR=s' => \$reffile_dir,
'INPUT_FILE_TPED=s' => \$inputfile,
'OUTPUTFILE_DIR=s'=> \$outputfile,
'IMPUTEREF_VERSION=s' => \$ref_keyword,
'TEMP=s' => \$temp,
'DB=s' => \$ann_db,
'CHECK_STRAND=s' => \$CHECK_STRAND,
'PYTHON=s' => \$PYTHON
);
chomp($inputfile);
chomp($reffile_dir);
$reffile_dir =~ s/\/$//g;
chomp($outputfile);
chomp($ref_keyword);
chomp($temp);
chomp($ann_db);
chomp($CHECK_STRAND);
chomp($PYTHON);
#checking for missing arguments
if($PYTHON eq "" || $CHECK_STRAND eq "" || $ann_db eq "" || $ref_keyword eq "" || $reffile_dir eq "" || $inputfile eq "" || $outputfile eq "" || $temp eq "" )
{
	die "missing arguments\n USAGE : perl perl_script_fwd_strand_mapping.pl -PYTHON <PATH TO PYTHON> -CHECK_STRAND <PATH to check strand> -DB <PATH TO CREATE BEAGLE REF FILES> -REF_GENOME_DIR <Reference Genome Directory> -IMPUTEREF_VERSION <IMPUTE REFERNCE REF KEYWORD like feb2012 > -INPUT_FILE <INPUT TPED FILE> -OUTPUTFILE <OUTPUT FOLDER> -TEMP <TEMP DIRECTORY>\n";
}

print "***********INPUT ARGUMENTS***********\n";
print "REF_GENOME_DIR: $reffile_dir\n";
print "INPUT_FILE: $inputfile\n";
print "OUTPUTFILE : $outputfile\n";
print "IMPUTEREF_VERSION : $ref_keyword\n";
print "TEMPDIR : $temp\n";
print "DB : $ann_db\n";
print "CHECK_STRAND : $CHECK_STRAND\n";
print "PYTHON : $PYTHON\n";


#reading ref directory
require "$dir/Read_reffile.pl";

getRef($reffile_dir);

#check reference
for(my $chr=23;$chr>0;$chr--)
{
	if(exists($ref_meta{"chr$chr".'_'."genetic"}))
	{
		#print "chr$chr".'_'."genetic"." ".$ref_meta{"chr$chr".'_'."genetic"}."\n";
	}
	else
	{
		die "there is a problem in the ref dir or metainfo file provided. No value for chr$chr".'_'."genetic\n";
	}
	if(exists($ref_meta{"chr$chr".'_'."hap"}))
	{
			#print "chr$chr".'_'."hap"." ".$ref_meta{"chr$chr".'_'."hap"}."\n";
	}
	else
	{
			die "there is a problem in the ref dir or metainfo file provided. No value for chr$chr".'_'."hap\n";
	}
	if(exists($ref_meta{"chr$chr".'_'."legend"}))
	{
			#print "chr$chr".'_'."legend"." ".$ref_meta{"chr$chr".'_'."legend"}."\n";
	}
	else
	{
			die "there is a problem in the ref dir or metainfo file provided. No value for chr$chr".'_'."legend\n";
	}
}
if(exists($ref_meta{"sample"}))
{
	#print "sample"." ".$ref_meta{"sample"}."\n";
}
else
{
    die "there is a problem in the ref dir or metainfo file provided. No value for sample\n";
}

#checking if input file exists
if(!(-e $inputfile))
{
	die "Inputfile $inputfile not exists\n";
}
print "Checking & preparing(if required) the beagle ref files\n";
unless(-d $ann_db)
{
    system("mkdir -p $ann_db");
}
unless(-d "$ann_db/beagle_impute_$ref_keyword")
{
	 system("mkdir -p $ann_db/beagle_impute_$ref_keyword");
}

for($chr=1;$chr<=23;$chr++)
{
	$ref_hap="$reffile_dir/".$ref_meta{"chr$chr".'_'."hap"};
	$ref="$reffile_dir/".$ref_meta{"chr$chr".'_'."legend"};
	$k=0;
	if(!(-e "$ann_db/beagle_impute_$ref_keyword/ref_$chr.bgl.gz") && !(-e "$ann_db/beagle_impute_$ref_keyword/ref_$chr.markers.gz"))
	{
		$k =1;
	}
	else
	{
		$num=`gunzip -c $ref|awk -F ' ' '{if(length(\$3)==1 && length(\$4)==1  && \$3 != "-" && \$4 != "-")print \$0}' |wc -l`;
		chomp($num);
		$num1=`gunzip -c $ann_db/beagle_impute_$ref_keyword/ref_$chr.markers.gz|wc -l`;
		chomp($num1);
		if($num == $num1)
		{
			$k=0;
		}
		else
		{
			$k=1;
		}
	}
	if($k == 1)
	{
		#opening the haps and legend file
		print "Preparing files for $chr\n";
		open(LEGEND,"gunzip -c $ref|") or die " no file exists $ref\n";
		open(HAP,"gunzip -c $ref_hap|") or die " no file exists $ref_hap\n";
		$legend=<LEGEND>;
		open(WR_REF_BGL,"|gzip >$ann_db/beagle_impute_$ref_keyword/ref_$chr.bgl.gz") or die "not able to write file $temp/ref_$chr.bgl\n";
		open(WR_REF_MRK,"|gzip >$ann_db/beagle_impute_$ref_keyword/ref_$chr.markers.gz") or die "no able to write file  $temp/ref_$chr.markers\n";
		
		$num=`gunzip -c $ref_hap|head -1|wc -w`;
		chomp($num);
		print WR_REF_BGL "I id";
		for($i=0;$i<$num;$i++)
		{
			print WR_REF_BGL " ".$i." ".$i;
			$i++;
		}
		print WR_REF_BGL "\n";
		
		while($legend=<LEGEND>)
		{
			chomp($legend);
			$haps=<HAP>;
			chomp($haps);
			@legend=split(" ",$legend);
			if(length($legend[2])==1 && length($legend[3])==1 && $legend[2] ne '-' && $legend[3] ne '-')
			{
				@haps=split(" ",$haps);
				print WR_REF_BGL "M $legend[0]";
				$haps =~ s/0/$legend[2]/g;
				$haps =~ s/1/$legend[3]/g;
				print WR_REF_BGL " $haps\n";
				print WR_REF_MRK "$legend[0] $legend[1] $legend[2] $legend[3]\n";
			}
		}
		close(WR_REF_MRK);
		close(WR_REF_BGL);
	}	
}

print "done preparing the beagle ref file\n";

#create temp directory unless it is created
unless(-d $temp)
{
    system("mkdir -p $temp");
}
#sorting the input data
system("sort -T $temp -k1,1n -k4,4n $inputfile > $temp/input.tped");


open(BUFF,"$temp/input.tped") or die " no file $temp/input.tped found\n";
open(WRBUFF,">$temp/temp_input.tped") or die "not able to write the file $temp/temp_input.tped\n";
open(WRIND,">$temp/temp_input.ind") or die "not able to write the file $temp/temp_input.ind\n";
open(WRAMBI,">$temp/temp_input.ambi") or die "not able to write the file $temp/temp_input.ambi\n";
open(WRIGNOR,">$temp/temp_input.ignored") or die "not able to write the file $temp/temp_input.ambi\n";
$prevchr="";
#parsing through the input data
$num=0;
while(<BUFF>)
{
	$num++;
	chomp($_);
	$_ =~ tr/atgc/ATGC/;
	@array=split(" ",$_);
	$chr=$array[0];
	#chromsome is greater than 23 then write marker not found in the reference
	if($chr > 23)
	{
		print WRBUFF $_."\n";
		print WRIND "$array[1]\t2\n";
	}
	else
	{
		#if encounters new chromosome then reference files are opened, if required changed the format of the reference file names
		if($chr ne $prevchr)
		{
			#print "$num $chr opening the legend and haps file in the reference file directory\n";
			print "Processing chromsome $chr\n";
			if($chr ==23)
			{
				$flag=0;
				$ref_hap="$reffile_dir/".$ref_meta{"chr$chr".'_'."hap"};
				$ref="$reffile_dir/".$ref_meta{"chr$chr".'_'."legend"};
	
			}
			elsif($chr <23)
			{
				$ref_hap="$reffile_dir/".$ref_meta{"chr$chr".'_'."hap"};
				$ref="$reffile_dir/".$ref_meta{"chr$chr".'_'."legend"};
	
			}
			#opening the haps and legend file
			open(LEGEND,"gunzip -c $ref|") or die " no file exists $ref\n";
			open(HAP,"gunzip -c $ref_hap|") or die " no file exists $ref_hap\n";
			$legend=<LEGEND>;
			$legend=<LEGEND>;
			$haps=<HAP>;
			#die "$legend\n$haps\n";
			chomp($legend);
			chomp($haps);
			@legend=split(" ",$legend);
		}
		#print "$num $array[3] > $legend[1]\n";
		#if input marker position is greater than reference or if reference marker is not a snp, then iterate through the reference
		while($array[3] > $legend[1] || length($legend[3]) !=1 || length($legend[2]) !=1)
		{
			$legend=<LEGEND>;
			$haps=<HAP>;
			chomp($legend);
			chomp($haps);
			if($legend !~ m/\w/)
			{
				last;
			}
			@legend=split(" ",$legend);
		}
		#print  "$num $array[3] > $legend[1]\n";
		#both input and reference marker position are equal
		if($array[3] == $legend[1])
		{
			#print "$array[3] == $legend[1] $legend[0] ne $array[1] $legend[2] $legend[3]\n"; 
			if($legend[0] ne $array[1])
			{
				#print "rsid in the input $array[1] not equal to rsid in the reference $legend[0].Please check for build issues\n";
				print WRIGNOR $_."\n";	
			}
			else
			{
				#if found ambiguous then written to a separate file
				if( "$legend[2] $legend[3]" eq "A T" || "$legend[2] $legend[3]" eq "T A" || "$legend[2] $legend[3]" eq "G C" || "$legend[2] $legend[3]" eq "C G")
				{
						#print "sucess\n";
						print WRAMBI $_."\n";
				}
				else
				{
					#flip input and store in $temp
					$temp1=$_;
					$temp1 =~ tr/ATGC/TACG/;
					$t1=$legend[2];
					$t1 =~ tr/ATGC/TACG/;
					$t2=$legend[3];
					$t2 =~ tr/ATGC/TACG/;
					@allele_input=();
					undef(@allele_input);
					@allele_input=sort(uniq(@array));
					
					if($allele_input[0] eq "0")
					{
						shift(@allele_input);
					}
					#if monomorphic marker then two reference alleles are equal
					if(@allele_input == 1 && ($allele_input[0] eq $legend[2] || $allele_input[0] eq $t1))
					{
						$legend[3] = $allele_input[0];
					}
					elsif(@allele_input == 1 && ($allele_input[0] eq $legend[3]  || $allele_input[0] eq $t2))
					{
						$legend[2] = $allele_input[0];
					}
					# if($array[1] eq "rs2651925")
					# {
						# die "$legend $legend[2] $legend[3] $temp\n";
					# }
					if($_ =~ m/ $legend[2]/ && $_ =~ m/ $legend[3]/)
					{
						print WRBUFF $_."\n";
						print WRIND "$array[1]\t0\n";
					}	
					elsif($temp1 =~ m/ $legend[2]/ && $temp1 =~ m/ $legend[3]/)
					{
						print WRBUFF $temp1."\n";
						print WRIND "$array[1]\t1\n";
					}
					else
					{
						#print WRBUFF $_."\n";
						#print WRIND "$array[1]\t3\n";
						print WRIGNOR $_."\n";
						print "SNP NOT MATCHED refernce $array[1]\n";
					}
				}
			}	
		}
		#input marker not in the reference
		else
		{
			print WRBUFF $_."\n";
			print WRIND "$array[1]\t2\n";	
		}
		#print "$num done\n";
	}
	$prevchr=$array[0];
}
close(BUFF);
close(WRBUFF);
close(WRIND);
close(WRAMBI);

$num_ambi_markers=`wc -l $temp/temp_input.ambi`;
chomp($num_ambi_markers);
 $num_ambi_markers=~ s/ .*//g;
if($num_ambi_markers == 0)
{
	print "There are no ambiguous markers in the data\n";
}
else
{
	#storing the chr and position in the hash for the input data
	open(BUFF,"$temp/temp_input.ambi") or die "not found file $temp/temp_input.ambi\n";
	$prevchr="";
	chdir($temp);
	open(WRBUFF,">final_ambi.bgl");
	open(WRBUFF,">final_ambi.log");
	close(WRBUFF);

	while(<BUFF>)
	{
		chomp($_);
		@array=split(" ",$_);
		$chr=$array[0];
		if($chr ne $prevchr)
		{
			if($prevchr ne "")
			{
				system("gunzip -c $ann_db/beagle_impute_$ref_keyword/ref_$prevchr.bgl.gz > $temp/ref_$prevchr.bgl");
				system("gunzip -c $ann_db/beagle_impute_$ref_keyword/ref_$prevchr.markers.gz> $temp/ref_$prevchr.markers");
				$sys="$PYTHON $CHECK_STRAND ref_$prevchr geno_$prevchr output";
				system($sys);
				$tmpfile_name_geno="geno_$prevchr"."_mod.bgl";
				$num=`wc -l $tmpfile_name_geno`;
				$num=~ s/ .*//g;
				$num=$num-1;
				$tmpfile_name_ref="ref_$prevchr"."_mod.bgl";
				system("cat $tmpfile_name_geno|tail -$num >> $temp/final_ambi.bgl");
				system("cat output.log >> $temp/final_ambi.log");
				close(WR_REF_MRK);
				close(WR_REF_BGL);
				system("rm geno_$prevchr.bgl geno_$prevchr.markers ref_$prevchr.bgl ref_$prevchr.markers output.log output.markers $tmpfile_name_ref $tmpfile_name_geno");
			}
			#die $legend."\n";
			open(WR_IN_BGL,">$temp/geno_$chr.bgl") or die "not able to write file $temp/geno_$chr.bgl\n";
			open(WR_IN_MRK,">$temp/geno_$chr.markers") or die "no able to write file  $temp/geno_$chr.markers\n";
			$num=0;
		}
		if($num==0)
		{
			$num++;
			print WR_IN_BGL "I id";
			for($i=0;$i<@array-4;$i++)
			{
				print WR_IN_BGL " ".$i." ".$i;
				$i++;
			}
			print WR_IN_BGL "\n";
		}
		print WR_IN_BGL "M $array[1]";
		for($i=4;$i<@array;$i++)
		{
			print WR_IN_BGL " ".$array[$i++]." ".$array[$i];
		}
		print WR_IN_BGL "\n";
		print WR_IN_MRK "$array[1] $array[3]";
		@alleles=();
		if($_ =~ m/ A/)
		{
			push(@alleles,"A");
		}
		if($_ =~ m/ G/)
		{
			push(@alleles,"G");
		}
		if($_ =~ m/ C/)
		{
			push(@alleles,"C");
		}
		if($_ =~ m/ T/)
		{
			push(@alleles,"T");
		}
		if(@alleles ==2)
		{
			print WR_IN_MRK " $alleles[0] $alleles[1]\n";
		}
		else
		{
			print WR_IN_MRK " $alleles[0] $alleles[0]\n";
		}
		$prevchr=$array[0];
	}
	#last chromsome
	system("gunzip -c $ann_db/beagle_impute_$ref_keyword/ref_$prevchr.bgl.gz > $temp/ref_$prevchr.bgl");
	system("gunzip -c $ann_db/beagle_impute_$ref_keyword/ref_$prevchr.markers.gz > $temp/ref_$prevchr.markers");
	$sys="$PYTHON $CHECK_STRAND ref_$prevchr geno_$prevchr output";
	system($sys);
	$tmpfile_name_geno="geno_$prevchr"."_mod.bgl";
	$num=`wc -l $tmpfile_name_geno`;
	$num=~ s/ .*//g;
	$num=$num-1;
	$tmpfile_name_ref="ref_$prevchr"."_mod.bgl";
	system("cat $tmpfile_name_geno|tail -$num >> $temp/final_ambi.bgl");
	system("cat output.log >> $temp/final_ambi.log");
	close(WR_REF_MRK);
	close(WR_REF_BGL);
	system("rm geno_$prevchr.bgl geno_$prevchr.markers ref_$prevchr.bgl ref_$prevchr.markers output.log output.markers $tmpfile_name_ref $tmpfile_name_geno");

	open(WRBUFF,">>$temp/temp_input.tped") or die "not able to write the file $temp/temp_input.tped\n";
	open(WRIND,">>$temp/temp_input.ind") or die "not able to write the file $temp/temp_input.ind\n";
	open(WRIGNORE,">>$temp/temp_input.ignored") or die "not able to write the file $temp/temp_input.ignored\n";
	open(AMBI_TPED,"$temp/temp_input.ambi") or die "not found file $temp/temp_input.ambi\n";
	open(AMBI_BGL,"$temp/final_ambi.bgl") or die "not found file $temp/final_ambi.bgl\n";
	$line=<AMBI_BGL>;
	chomp($line);
	@bgl=split(" ",$line);
	while(<AMBI_TPED>)
	{	
		chomp($_);
		@array=split(" ",$_);
		if($array[1] eq $bgl[1])
		{
			$chr=shift(@array);
			$rsid=shift(@array);
			$dist=shift(@array);
			$pos=shift(@array);
			print WRBUFF "$chr $rsid $dist $pos";
			$tm=join(" ",@array);
			shift(@bgl);
			shift(@bgl);
			if($bgl[0] eq $array[0])
			{
				print WRBUFF " $tm\n";
				print WRIND "$rsid\t0\n";
			}
			else
			{
				$tm=~tr/ATGC/TACG/;
				print WRBUFF " $tm\n";
				print WRIND "$rsid\t1\n";
			}
			$line=<AMBI_BGL>;
			chomp($line);
			@bgl=split(" ",$line);
		}
		else
		{
			print WRIGNORE $_."\n";
		}
	}
}	
close(AMBI_TPED);
close(AMBI_BGL);
close(WRIND);
close(WRBUFF);
unless(-d $outputfile)
{
    system("mkdir -p $outputfile");
}	
system("mv $temp/temp_input.tped $outputfile");
system("mv $temp/temp_input.ind $outputfile");
system("mv $temp/temp_input.ignored $outputfile");
##############################################################SUBROUTINES######################################################
sub uniq {
        shift(@_);
        shift(@_);
        shift(@_);
        shift(@_);
    return keys %{{ map { $_ => 1 } @_ }};
}
