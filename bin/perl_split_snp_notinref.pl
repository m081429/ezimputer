#!/usr/bin/perl
use Getopt::Std;
#getopt("e:d:m:n:t:p", \%args);
getopt("e:d:m:n", \%args);
$extra = $args{e};
chomp $extra;
$dbsnp = $args{d};
chomp $dbsnp;
$finalout = $args{m};
chomp $extra;
$finalextra = $args{n};
chomp $extra;
#$path = $args{p};
#chomp $path;
if($extra eq "")
{
        die "entered extrafile $extra file name  is empty\n";
}
if($dbsnp eq "")
{
        die "entered dbsnp $dbsnp file name  is empty\n";
}
if($finalout eq "")
{
        die "entered final out dosage $finalout file name  is empty\n";
}
if($finalextra eq "")
{
        die "entered final extra $finalextra file name  is empty\n";
}
#if($path  eq "")
#{
#        die "entered path name  is empty\n";
#}

open(IN,"gunzip -c $extra |") or die "no extrafile $extra file exists\n";
#open(DB,"$dbsnp") or die "no dbsnp $dbsnp file exists\n";
open(WRDB,"|gzip >$finalout") or die "no $finalout file exists\n";
open(WREXTRA,"|gzip > $finalextra") or die "no $finalextra file exists\n";
for($i=1;$i<=23;$i++)
{
	$j = $i;
	if($i ==23)
	{
		$j = 'X';
	}
	$db_chr{$j}=1;
}
#while(<IN>)
#{
#	chomp($_);
#	@in = split(" ",$_);
#	$db_chr{$in[0]} =1 ;
#}
#while(my($key,$value)=each %db_chr)
#{
#	print "$key\n";
#}
open(IN,"gunzip -c $extra |") or die "no extrafile $extra file exists\n";

$prevchr = "";
$counter = 0;
while(<IN>)
{
	chomp($_);
	@in = split(" ",$_);
	#print $counter++." $in[0] $in[1] $in[2] $in[3] ";
	$ou = "EXTRA";
	
	if($in[0] == 23)
	{
		$in[0]='X';
	}
	elsif($in[0] == 24)
	{
		$in[0]='Y';
	}
	elsif($in[0] == 26)
	{
		$in[0]='M';
	}
	else
	{
	}
	
	if($prevchr ne $in[0])
	{
		$k = 0;
		if(exists($db_chr{$in[0]}))
		{
			#$grep = 'grep -P "^'.$in[0].'\t"'." $dbsnp";
			#$grep = "$path/tabix/tabix $dbsnp $in[0]\n";
			#print "$grep\n";
			#open(DB,"$grep |") or die "no file found\n";
			$grep="chr".$in[0]."_1K_nonimpute_ref.txt";
			open(DB,"$dbsnp/$grep") or die "no file $dbsnp/$grep found\n";		
			$db = <DB>;
			chomp($db);
			@db = split("\t",$db);
			$k = 1;
		}
		#print $_."\t$k\n";
	}
	if($k ==1)
	{
		#print " $in[3] $db[1]\n";
		while($in[3] > $db[2])
		{
			$db = <DB>;
            chomp($db);
			if($db !~ m/\w/)
			{
				last;
			}
            @db = split("\t",$db);
		}
		#print " $in[3] $db[2]\n";
		if($in[3] == $db[2])
		{
			$ou = "DB";	
		}
	}
	$line=join(" ",@in);
	print WRDB $line."\n";
	print WREXTRA "$in[1] $in[0] $in[3] $ou\n";
	$prevchr = $in[0];
}	
=head	
	#converting to dosage and printing
	#die "$ou\n";
	$num_tped =0;
    @tp_array = @in;
    undef(@array_tped_snps);
	$num_tped =0;
	@tp_array1 = @tp_array ;
	shift(@tp_array1);
	shift(@tp_array1);
	shift(@tp_array1);
	shift(@tp_array1);
	$tline1 = join("",@tp_array1);
	@tp_array1=();
        	if($tline1 =~ m/A/)
                {
                        $array_tped_snps[$num_tped] = "A";
                        $num_tped++;
                }
                if($tline1 =~ m/C/)
                {
                        $array_tped_snps[$num_tped] = "C";
                        $num_tped++;
                }
                if($tline1 =~ m/G/)
                {
                        $array_tped_snps[$num_tped] = "G";
                        $num_tped++;
                }
                if($tline1 =~ m/T/)
                {
                        $array_tped_snps[$num_tped] = "T";
                        $num_tped++;
                }
                if($num_tped == 1)
                {
                        $tped_snp1 = $array_tped_snps[0];
			$tped_snp2 = "-";
                }
		elsif($num_tped ==0)
		{
				$tped_snp1 = "-";
				$tped_snp2 = "-";
		}
                else
                {
                         $tped_snp1 = $array_tped_snps[0];
                         $tped_snp2 = $array_tped_snps[1];
                }
		@mainar=();
		push(@mainar,$tp_array[0]);
		push(@mainar,$tp_array[1]);
		push(@mainar,$tp_array[2]);
		push(@mainar,$tp_array[3]);	
		push(@mainar,$tped_snp1);
		push(@mainar,$tped_snp2);
        for($g=4;$g<@tp_array;$g++)
        {
            $ssnp1 = $tp_array[$g];
            $g++;
            $ssnp2 = $tp_array[$g];
            if($ssnp1 eq $tped_snp1 && $ssnp2  eq $tped_snp1)
            {
				push(@mainar,1);
				push(@mainar,0);
            }
            elsif($ssnp1 eq $tped_snp2 && $ssnp2  eq $tped_snp2)
            {
				push(@mainar,0);
				push(@mainar,0);
            }
			elsif($ssnp1 eq "0" && $ssnp2  eq "0")
			{
				push(@mainar,'-');
				push(@mainar,'-');
			}
            else
			{
				push(@mainar,0);
                push(@mainar,1);
            }
        }
		$line = join(" ",@mainar);
		if($num_tped != 0)
		{
			print WRDB $line."\n";
			print WREXTRA "$in[1] $in[0] $in[3] $ou\n";
		}
    $numm_count++;
	
#	print WRDB $line."\n";
#	print WREXTRA "in[1] in[0] in[3] $ou\n";
	$prevchr = $in[0];
}
=cut