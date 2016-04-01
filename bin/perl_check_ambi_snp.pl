#!/usr/bin/perl
use Getopt::Std;
getopt("a:c:d:n:m", \%args);
$ambi = $args{a};
chomp $ambi;
$chr = $args{c};
chomp $chr;
$dosage = $args{d};
chomp $dosage;
$newdosage = $args{n};
chomp $newdosage;
$indel = $args{m};
chomp $indel;
if($ambi eq "")
{
        die "entered ambi snps file name  is empty\n";
}
if($chr eq "")
{
        die "entered  $chr  is empty\n";
}
if($dosage eq "")
{
        die "entered dosage file name is empty\n";
}
if($indel eq "")
{
        die "entered indel file name is empty\n";
}
#$grep = "grep -P '^".$chr." ' $ambi |";
if(!(-e $ambi))
{
	die "$ambi file not exists\n";
}
$grep = "gunzip -c $ambi|grep -P '^".$chr." ' |";
#die $grep."\n";
open(SAM,"$grep") or die "no file found $ambi\n";
#open SAM,"grep -P $ambi" ;
open DOS,"gunzip -c $dosage|" or die "no file found $dosage\n";
open(WRBUFF1,"|gzip >$newdosage") or die "unable to write to ambi dosage file\n"; 
open(WRBUFF2,"|gzip >$indel") or die "unable to write to $indel file\n";
#$line = <DOS>;

#reading all the ambiguous snp positions in to hash

while($line = <SAM>)
{
	chomp $line;
	$line =~ s/\n//g;
	$line =~ s/\r//g;
	@array_sam = split(/\s/,$line);
	#print $array_sam[3]."\n";
	$hash_sam{$array_sam[3]} =$line;
}

undef(@array_sam);
$num_samp = 0;
#reading the dosage file
while($line = <DOS>)
{	
	chomp($line);
	@array = split(" ",$line);
	if(length($array[3]) == 1 && $array[3] =~ m/A|T|G|C/ &&  $array[4] eq "0")
	{
		$array[4]=$array[3];
	}
	if(length($array[3]) == 1 && length($array[4]) == 1 && $array[4] =~ m/A|T|G|C/ && $array[3] =~ m/A|T|G|C/)
	{
		if($num_samp ==0)
		{
			#START: create header to simulate beagle dosage file
			$num_samp = @array;
			$header = "position marker alleleA alleleB";
			#print "$num_samp\n";
			$num_samp =($num_samp-5)/3;
			for($i=1;$i<=$num_samp;$i++)
			{
				$header=$header." $i $i $i";
			}
			print WRBUFF1 $header."\n";
			#STOP: create header to simulate beagle dosage file
		}
		if(exists($hash_sam{$array[2]}))
		{
			#print "$line\n";
			$line1 = $hash_sam{$array[2]};
			@array_sam = split(/\s/,$line1);
			$a1 = $array[3];
			$a2 = $array[4];
			$count_fwd = 0;
			$count_rev = 0;
			shift(@array_sam);
			shift(@array_sam);
			shift(@array_sam);
			shift(@array_sam);
			$line1 = join(" ",@array_sam);
			$j = 0;
			#print "$line\n$line1\n";
=head			
			#count the maf and checking should be greater than 30%
			$maf_check = $line1;
			
			if($line1 =~ m/A/ || $line1 =~ m/T/)
			{
				$allele1_count_1 =$maf_check=~ tr/A//;
				$allele1_count_2 =$maf_check=~ tr/T//;
			#	$print = "A T";
			}
			else{
				$allele1_count_1 =$maf_check=~ tr/G//;
				$allele1_count_2 =$maf_check=~ tr/C//;
			#	$print ="G C";
			}
			#print "$print $line1 $allele1_count_1 $allele1_count_2\n";
			if($allele1_count_1 < $allele1_count_2)
			{
				$cutoff = $allele1_count_1/($allele1_count_2+$allele1_count_1);
				#print "$print $allele1_count_1 $allele1_count_2 $cutoff\n";
			}
			else
			{
				$cutoff = $allele1_count_2/($allele1_count_2+$allele1_count_1);
				#print "$print $allele1_count_2 $allele1_count_1 $cutoff\n";
			}
=cut			
			#if($cutoff < 0.4)
			{
				#print "counting the matches of homozygotes in both strands\n";
				for($i=5;$i<@array;$i++)
				{
					$d1 = $array[$i++];
					$d2 = $array[$i++];
					$d3 = $array[$i];
					$gnt1 = $array_sam[$j++]." ".$array_sam[$j++];
					$gnt1_flip = $gnt1;
					$gnt1_flip =~ tr/ATGC/TACG/;
					if($d1 >0.5)
					{
						$gnt2 = "$a1 $a1";
					}
					elsif($d2 > 0.5)
					{
						$gnt2 ="$a1 $a2";
					}
					elsif($d3 > 0.5)
					{
						$gnt2 = "$a2 $a2";
					}
					else
					{
						$gnt2 = "0 0";
					}
					@g1 = split(" ",$gnt1);
					@g1_f = split(" ",$gnt1_flip);
					@g2 = split(" ",$gnt2);
					#print "gnt1:$gnt1\t@g1\t\t\t\tgnt-flip:$gnt1_flip\t@g1_f\t\t\t\t\tgnt2:$gnt2\t@g2\n";
					#print "$gnt1\n";
					if($g1[0] eq $g1[1] && $gnt1 ne "0 0" && $g2[0] eq $g2[1] && $gnt2 ne "0 0" && $gnt1 eq $gnt2)
					{
						$count_fwd++;
					}
					if($g1_f[0] eq $g1_f[1] && $gnt1_flip ne "0 0" && $g2[0] eq $g2[1] && $gnt2 ne "0 0" && $gnt1_flip eq $gnt2)
					{
						$count_rev++;
					}
				}
				undef(@array_sam);
				#fliping the input genotype according to counts
				if($count_fwd > $count_rev)
				{
					$finalgnt = $line1;
				}
				else
				{
					$line1 =~ tr/ATGC/TACG/;
					$finalgnt = $line1;
				}	
				#print "$count_fwd \t $count_rev\n$finalgnt\n";
				#replacing the doage with selected forward or reverse original genotypes
				@array_sam = split(/\s/,$finalgnt);
				$i = 5;
				for($j=0;$j<@array_sam;$j++)
				{
					$A1 = $array_sam[$j++];
					$A2 = $array_sam[$j];
					$i1 = $i++;
					$i2 = $i++;
					$i3 = $i++;
					#die "$finalgnt\n $j $A1 $A2 $a1 $a2 $i1 $i2 $i3\n";
					if($A1 eq $a1 && $A2 eq $a1)
					{
						$array[$i1] = 1;
						$array[$i2] = 0;
						$array[$i3] = 0;
					}
					elsif($A1 eq $a2 && $A2 eq $a2)
					{
						$array[$i1] = 0;
						$array[$i2] = 0;
						$array[$i3] = 1;
					}
					elsif($A1 eq $a2 && $A2 eq $a1 || $A1 eq $a1 && $A2 eq $a2)
					{
						$array[$i1] = 0;
						$array[$i2] = 1;
						$array[$i3] = 0;
					}
					else
					{
					
					}
				}
			}	
		}
		shift(@array);
		$rsid = shift(@array);
		$pos = shift(@array);
		$line = join(" ",@array);
		print WRBUFF1 "$pos $rsid $line\n";
	}
	else
	{	shift(@array);
		$rsid = shift(@array);
		$pos = shift(@array);
		$a1 = shift(@array);
		$a2 = shift(@array);
		#$line = join(" ",@array);
		print WRBUFF2 "$chr $rsid 0 $pos $a1 $a2";
		for($i=0;$i<@array;$i++)
		{
			$a1 = $array[$i++];
			$a2 = $array[$i++];
			$a3 = $array[$i];
			print WRBUFF2 " $a1 $a2"; 
		}
		print WRBUFF2 "\n";
	}
}
