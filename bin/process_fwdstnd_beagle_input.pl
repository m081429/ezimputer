#!/usr/bin/perl

#get current directory
use Cwd 'abs_path';
$line = abs_path($0);
chomp $line;
@DR_array = split('/',$line);
pop(@DR_array);
$dir = join("/",@DR_array);


use Getopt::Std;
#input arguments
#getopt("f:t:h:n:e:a:u", \%args); 
getopt("f:h:n:e:a:u:i:r:o:v:b:l", \%args);
my $sample = $args{f};
#my $marker= $args{t};
my $reference= $args{h};
my $name_tped = $args{n};
my $name_excluded_snps = $args{e};
my $ambi_excluded = $args{a};
my $unsure_snp_allels_ref_data = $args{u};
my $marker = $args{i};
my $less_num_samp = $args{l};

print "sample\t$sample\n";
print "reference\t$reference\n";
print "name_tped\t$name_tped\n";
print "name_excluded_snps\t$name_excluded_snps\n";
print "ambi_excluded\t$ambi_excluded\n";
print "unsure_snp_allels_ref_data\t$unsure_snp_allels_ref_data\n";
print "marker\t$marker\n";
print "LESS_NUM_SAMP\t$less_num_samp\n";

if($sample eq "")
{
	die "entered forward strand tped file name  is empty\n";
	
}
if($marker eq "")
{
        die "entered forward strand indication file is empty\n";

}
if($reference eq "")
{
        die "entered reference snps file name is empty\n";

}
if($name_tped eq "")
{
        die "entered new tped file name is empty\n";

}
if($name_excluded_snps eq "")
{
        die "entered new excluded snps file name is empty\n";

}
if($ambi_excluded eq "")
{
        die "entered new ambi excluded snps file name is empty\n";

}
if($unsure_snp_allels_ref_data eq "")
{
        die "entered unsure forward strand excluded snps file name is empty\n";

}


#reading ref directory
require "$dir/Read_reffile.pl";

getRef($reference);

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

open(WRBUFF_TPED,">$name_tped");
open(WRBUFF_NOREF,"|gzip >$name_excluded_snps");
open(WRBUFF_AMBI,"|gzip >$ambi_excluded");
open(WRBUFF4,"|gzip >$unsure_snp_allels_ref_data");


#dirtemp
$dirtemp=$name_tped;
@dirtemp=split(/\//,$dirtemp);
pop(@dirtemp);
$dirtemp=join('/',@dirtemp);

@ls = `ls -d $dirtemp/*`;
for($i=0;$i<@ls;$i++)
{
	chomp($ls[$i]);
	@array = split(/\//,$ls[$i]);
	$chr = pop(@array);
	if($chr =~ m/^\d+$/ && $chr <24)
	{
		#print "$chr\n";
		#push(@check_chr,$chr);
		$check_chr{$chr} =1;
	}
	undef(@array);
	#print "$ls[$i]\n";
}
#@check_chr = keys %check_chr;
#die "@check_chr\n";
#loading fwd strand indicator file in to the hash
if(uc($marker) ne "NA")
{
	open MBUFF,"<$marker" or die "Can't open fwd strand indicator$marker : $!";
	while($line = <MBUFF>)
	{
		$line =~ s/\n//g;
		$line =~ s/\r//g;
		@array = split("\t",$line);
		if($array[1] != 1 && $array[1] != 0)
		{
			$hash2{$array[0]} =1;
		}	 
	}
}

$prevchr="";
@dir = split(/\//,$sample);
pop(@dir);
$dir = join('/',@dir);
#opening and reading the tped file
if(!(-e $sample))
{
	die "no file exists input tped $sample\n";
}
open TBUFF,"gunzip -c $sample|" or die  "Can't open $sample : $!";

while($line = <TBUFF>)
{
	$line =~ s/\n//g;
	$line =~ s/\r//g;
	@array = split(" ",$line);
	$ch = shift(@array);
	$rsid = shift(@array);
	shift(@array);
	$pos = shift(@array);
	$line_temp = join(" ",@array);
	#when new chr starts creating hash with 1000 genome ref file for that chr
	if($ch != $prevchr)
	{
		if($ch < 24 && exists($check_chr{$ch}))
		{
			$refer_1000="$reference/".$ref_meta{"chr$ch".'_'."legend"};
		}
		else
		{
			$refer_1000 = "NA";
		}
		#storing the allel info in tha hash
		if($refer_1000 ne "NA")
		{
			if(!(-e $refer_1000))
			{
				die "ref file $refer_1000 not exists ---process forwardstnd beagle input program\n";
			}
			open(RBUFF,"gunzip -c $refer_1000|") or die "Can't open $refer_1000 : $!";
			$line_r = <RBUFF>;
			#print "ref $refer_1000 $line_r\n";
			#loading hapmap snps in to tha hash
			undef(%hash1);
			while($line_r = <RBUFF>)
			{
				$line_r =~ s/\n//g;
				$line_r =~ s/\r//g;
				@array_r = split(" ",$line_r);
				if(length($array_r[2])==1 && length($array_r[3])==1 && $array_r[2] =~ m/A|T|G|C/ && $array_r[3] =~ m/A|T|G|C/)
				{
					@genotype_line=();
					if($array_r[2] =~ m/A|T|G|C/)
					{
						$genotype_line[0] = $array_r[2];
					}	
					else
					{
						$genotype_line[0] = "";
					}
					if($array_r[3] =~ m/A|T|G|C/)
					{
						$genotype_line[1] = $array_r[3];
					}
					else
					{
						$genotype_line[1] = "";
					}
					@genotype_line = sort(@genotype_line);
					$genotype_line = join("",@genotype_line);
					#print "test $array[1]\n";	
					$hash1{$array_r[1]} =$genotype_line;
				}
			}
			
			$hap_count=`gunzip -c $dir/$ch/snps_chr$ch.haps.gz|wc -l`;
			chomp($hap_count);
			#print $hap_count."\n";
			$plinkfile_count=`grep -P "^$ch\t" $dir/processed_beagle_input.bim|wc -l`;
			chomp($plinkfile_count);
			#print $plinkfile_count."\n";
			if($hap_count  != $plinkfile_count )
			{
					#print "NOT AN ERROR OR WARNING: number of rows in the haps file and plink file doesn't match for chr $ch :haps-$hap_count plinkfile-$plinkfile_count && less_num_samp eq $less_num_samp \n";
			}

			#$sys="mv $dir/$ch/snps_chr$ch.haps.gz  $dir/$ch/temp_snps_chr$ch.haps.gz";
			#print "$sys\n";
			
			if(-e "$dir/$ch/snps_chr$ch.haps.gz")
			{
				#system("mv $dir/$ch/snps_chr$ch.haps.gz  $dir/$ch/temp_snps_chr$ch.haps.gz"); 
			}
			else
			{
				die "$dir/$ch/snps_chr$ch.haps.gz not exists cannot move\n";
			}
			#opening the haps file for corresponding chr
			undef(%low_samp);
			if($less_num_samp =~ m/YES/i)
			{
				#open(HAPS,"gunzip -c $dir/$ch/temp_snps_chr$ch.haps.gz |") or die "no haps file exists for chr $ch\n";
				open(HAPS,"gunzip -c $dir/$ch/snps_chr$ch.haps.gz |") or die "no haps file exists for chr $ch\n";
				while($haps = <HAPS>)
				{
					chomp($haps);
					@haps = split(" ",$haps);
					$low_samp{$haps[2]}=1;
				}
			}
			close(HAPS);	
			#open(HAPS,"gunzip -c $dir/$ch/temp_snps_chr$ch.haps.gz |") or die "no haps file exists for chr $ch\n";
			#open(WRHAPS,"|gzip > $dir/$ch/snps_chr$ch.haps.gz ") or die " not able to write the haps $dir/$ch/snps_chr$ch.haps.gz file\n";
			open(HAPS,"gunzip -c $dir/$ch/snps_chr$ch.haps.gz |") or die "no haps file exists for chr $ch\n";
			open(WRHAPS,"|gzip > $dir/$ch/imp_ref_snps_chr$ch.haps.gz ") or die " not able to write the haps $dir/$ch/snps_chr$ch.haps.gz file\n";
		}
	}
	#if chr is greater than 23 than directly write to the extra file
	if($refer_1000 eq "NA")
	{
		print WRBUFF_NOREF $line."\n";
	}
	#elsif($less_num_samp eq "YES" && (!exists($low_samp{$pos})))
	#{
	#	next;
	#}
	else
	{
		if(!($less_num_samp =~  m/YES/i && (!exists($low_samp{$pos}))))
		{
			
		
			$haps = <HAPS>;
			chomp($haps);
			@haps = split(" ",$haps);
			#if($pos == 29092777)
			#{
			#	print "test : $pos\t$haps[2]\t$hash1{$pos}\n";
			#}
			if($haps[2] ne $pos)
			{
				die "$ch $prev_chr haps file position $haps[2] not match to tped file position $pos\n";
				system("rm $dir/$ch/snps_chr$ch.haps.gz");
			}
			$genotype_line ="";
			if($line_temp =~ m/A/)
			{
				$genotype_line =$genotype_line."A";
			}
			if($line_temp =~ m/C/)
			{
				$genotype_line =$genotype_line."C";
			}
			if($line_temp =~ m/G/)
			{
				$genotype_line =$genotype_line."G";
			}
			if($line_temp =~ m/T/)
			{
				$genotype_line =$genotype_line."T";
			}
			#print $genotype_line."\n";
			$gnt_snp1 = $hash1{$pos};
			$gnt_snp2 = $genotype_line;
			if(!(exists($hash1{$pos})))
			{	
				print WRBUFF_NOREF $line."\n";
				#print "y\n";
			}
			elsif((($line =~ m/A T/ || $line =~ m/T A/ || $line =~ m/G C/  || $line =~ m/C G/ )||(length($genotype_line)==1)) && $hash2{$rsid} ==1)
			#elsif($hash2{$rsid} ==1)
			{	
				print WRBUFF_AMBI $line."\n";
			}
			#checking for alleles that do not match reference and fliping the input if necessary
			elsif($gnt_snp1 !~ m/$gnt_snp2/ && $gnt_snp2 !~ m/$gnt_snp1/)
			{
				$flip_gnt = $genotype_line;
				$flip_gnt =~ tr/TGCA/ACGT/;
				@arr_gnt = split(//,$flip_gnt);
				@arr_gnt = sort(@arr_gnt);
				$flip_gnt =join("",@arr_gnt);
				#print "sucess\t".$flip_gnt."\t".$genotype_line."\n";
				if($hash1{$pos} =~ m/$flip_gnt/ || $flip_gnt =~ m/$hash1{$pos}/)
				{
					if($hash1{$pos} ne "")
					{
						$line =~ tr/TGCA/ACGT/;
						$haps[3]  =~ tr/TGCA/ACGT/;
						$haps[4]  =~ tr/TGCA/ACGT/;
						$haps =join(" ",@haps);
						#print " test ma $gnt_snp1 $gnt_snp2 $array[1] sucess2\n";
						print WRBUFF_TPED $line."\n";
						print WRHAPS $haps."\n";
					}
				}
				else
				{
					print WRBUFF4 $line."\n";
				}
			}
			else
			{
				print WRBUFF_TPED $line."\n";
				print WRHAPS $haps."\n";
			}
		}
	}
	$prevchr = $ch;
}	
