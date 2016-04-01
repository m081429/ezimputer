#####################################################################################################################################################
#Purpose: To upgrade build 36 positions to build 37 positions 
#Date: 10-24-2012
#inputfile : build36 tped file
#outputfile: new build37 tped file & left over build 36 tped file
#####################################################################################################################################################
#!/usr/bin/perl
use Getopt::Long;
#reading input arguments
&Getopt::Long::GetOptions(
'DBSNP_DOWNLOADLINK=s' => \$dbsnp_ver,
'DBSNP_DIR=s' => \$dbsnp_dir,
'INPUT_FILE=s' => \$inputfile,
'REMAPPED_CURRENT_BUILD=s'=> \$outputfile_37,
'NOTMAPPED_OLD_BUILD=s' => \$outputfile_36,
);
chomp($inputfile);
chomp($dbsnp_ver);
chomp($dbsnp_dir);
$dbsnp_dir =~ s/\/$//g;
chomp($outputfile_37);
chomp($outputfile_36);

$inputfile =~ s/\s|\t|\r|\n//g;
$dbsnp_ver =~ s/\s|\t|\r|\n//g;
$dbsnp_dir =~ s/\s|\t|\r|\n//g;
$outputfile_37 =~ s/\s|\t|\r|\n//g;
@temp_sort=split(/\//,$outputfile_37);
pop(@temp_sort);
$temp_sort=join('/',@temp_sort);
if($temp_sort !~ m/\w/)
{
	$temp_sort=`pwd`;
}
#die "$temp_sort\n";
$outputfile_36 =~ s/\s|\t|\r|\n//g;
#checking for missing arguments
if( $dbsnp_dir eq "" || $dbsnp_ver eq "" || $inputfile eq "" || $outputfile_37 eq "" || $outputfile_36 eq "")
{
	die "missing arguments\n USAGE : perl Upgrade_inputmarkers_to_build37_by_DBSNP.pl  -DBSNP_DIR <DBSNP DIR> -DBSNP_DOWNLOADLINK <DBSNP VERSION>  -INPUT_FILE <INPUT TPED FILE> -REMAPPED_CURRENT_BUILD <NEW OUTPUT TPED FILE MAPPED> -NOTMAPPED_OLD_BUILD <OUTPUT TPED FILE FOR UNMAPPED>\n";
}
print "***********INPUT ARGUMENTS***********\n";
print "DBSNP_DOWNLOAD LINK: $dbsnp_ver\n";
print "INPUT_FILE: $inputfile\n";
print "REMAPPED_CURRENT_BUILD : $outputfile_37\n";
print "NOTMAPPED_OLD_BUILD : $outputfile_36\n";
print "DBSNP_DIR : $dbsnp_dir\n";
#downloading the dnsnp file 
#$file1="b".$dbsnp_ver."_SNPChrPosOnRef.bcp.gz";
#$file2="RsMergeArch.bcp.gz";
$hyperlink1=$dbsnp_ver;
#for build 141 ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b141_GRCh37p13/database/organism_data/b141_SNPChrPosOnRef_GRCh37p13.bcp.gz
@hyperlink1 = split(/\//,$hyperlink1);
$file1=pop(@hyperlink1);
unless(-d "$dbsnp_dir")
{
    system("mkdir -p $dbsnp_dir");
}
chdir("$dbsnp_dir/");

if((-e $file1))
{
	#$sys="gunzip -c $dbsnp_dir/$file1|awk '{if(NF==4)print \$0}'|gzip > $dbsnp_dir/temp.gz";
    #system($sys);
    #system("mv $dbsnp_dir/temp.gz $dbsnp_dir/$file1");
	$count =`gunzip -c $dbsnp_dir/$file1|wc -l`;
    if($count < 1000)
    {
		print "removing existing dbsnp file it has very few markers or no markers\n";
		system("rm $dbsnp_dir/$file1");
	}
}
if(!(-e $file1))
{
	$exitcode=system("wget $hyperlink1"); 
	if($exitcode != 0)
	{
			die "command wget $hyperlink1failed\nexitcode $exitcode\n";
	}
	#$sys="gunzip -c $dbsnp_dir/$file1|awk '{if(NF==4)print \$0}'|gzip > $dbsnp_dir/temp.gz";
	#system($sys);
	#system("mv $dbsnp_dir/temp.gz $dbsnp_dir/$file1");
	$count =`gunzip -c $dbsnp_dir/$file1|wc -l`;
	if($count < 1000)
	{
		die "something wrong with process DBSNP file.Number of markers in the file are less than 1000\ntry this command manually\nwget $hyperlink1\ngunzip -c $dbsnp_dir/$file1|awk '{if(NF==4)print \$0}'|gzip > $dbsnp_dir/temp.gz\nmv $dbsnp_dir/temp.gz $dbsnp_dir/$file1\n";
	}
}

if(!(-e $file1))
{
	
	die "$file1 not downloaded properly.Please change the hyperlink in the script $hyperlink1\n";
}
print "Done downloading file $file1\n";

open(BUFF,"$inputfile") or die "no file exists $inputfile\n";
open(WRBUFF1,">$outputfile_37") or die "not able write to $outputfile_37\n";
open(WRBUFF2,">$outputfile_36") or die "not able write to $outputfile_36\n";
open(WRBUFF3,">$outputfile_36.log") or die "not able write to $outputfile_36\n";
my %hash,%db;
#parsing through input tped file and separatin the markers based on the marker ID type (starts with rs)
$num_25=0;
$num_0=0;
$num_rs=0;
$num_nors=0;
while(<BUFF>)
{
	#print "$.\n";
	chomp($_);
	$_ =~ s/\t/ /g;
	@a = split(" ",$_);
	if($a[0] eq "25" || $a[0] eq "XY")
	{
		$num_25++
	}
	elsif($a[0] eq "0" )
	{
		$num_0++;
	}
	elsif($a[1] =~ m/^rs\d+$/)
	{
		$a[1] =~ s/rs//g;
		$hash{$a[1]} = $a[0]."_".$a[3];
		$num_rs++;
	}
	else
	{
		$num_nors++;
	}
} 
close(BUFF);
print "Number of Markers Mapped to chr25 : $num_25\n";
print "Number of Markers Mapped to chr0 : $num_0\n";
print "Number of Markers have rsids: $num_rs\n";
print "Number of Markers with no rsid : $num_nors\n";

$num_db=0;
#parsing through the dbsnp file
open(DB,"gunzip -c $dbsnp_dir/$file1 |") or die " no file exists $file1\n";
$num="";
while($db=<DB>)
{
	chomp($db);
	$db =~ s/\t\t//g;
	@db=split("\t",$db);
	if($num eq "")
	{
		$num=@db;
	}
	if(exists($hash{$db[0]}) && @db ==$num)
	{
		$db[1] =~ s/X/23/g;
		$db[1] =~ s/Y/24/g;
		$db[1] =~ s/MT/26/g;
		$db[2]++;
		$db{$db[0]} =$db[1]."_".$db[2];
		$num_db++;
		delete $hash{$db[0]};
	}
}
print "Number of Markers exist in DBSNP: $num_db\n";
close(DB);
$num=0;
open(BUFF,"$inputfile") or die "no file exists $inputfile\n";
while(<BUFF>)
{
	#print "$.\n";
	chomp($_);
	$_ =~ s/\t/ /g;
	@a = split(" ",$_);
	$a[0] =~ s/X/23/g;
	$a[0] =~ s/Y/24/g;
	$a[0] =~ s/MT/26/g;
	$a[0] =~ s/M/26/g;
	$_ = join(" ",@a);
#markers mapped chr 25	
	if($a[0] eq "25" || $a[0] eq "XY")
	{
		print WRBUFF2 "$_\n";
		print WRBUFF3 "$a[1] chr25\n";
	}
#markers mapped chr 0	
	elsif($a[0] eq "0" )
	{
		print WRBUFF2 "$_\n";
		print WRBUFF3 "$a[1] chr0\n";
	}
#markers with RSid	
	elsif($a[1] =~ m/^rs\d+$/)
	{
		$a[1] =~ s/rs//g;
#markers with RSid but not in DBsnp
		if(exists($hash{$a[1]}))
		{
			print WRBUFF2 "$_\n";
			print WRBUFF3 "rs$a[1] NOT_MAP_DBSNP\n";
			$num++;
		}
#markers with RSid in DBsnp		
		elsif(exists($db{$a[1]}))
		{
			@b=split("_",$db{$a[1]});
			if($b[0] !~ m/\d/)
			{
				print WRBUFF3 "rs$a[1] MAP_DBSNP_BUT_DBSNPCHR_$b[0]\n";
				print WRBUFF2 "$_\n";
			}
			else
			{
				$a[0] = $b[0];
				$a[1]="rs".$a[1];
				$a[3]=$b[1];
				$_=join(" ",@a);
				print WRBUFF1 "$_\n";
			}
		}
#unknown condition		
		else
		{
			print WRBUFF2 "$_\n";
			print WRBUFF3 "rs$a[1] UNKNOWN\n";
		}
	}
#markers with no RSid
	else
	{
		print WRBUFF2 "$_\n";
		print WRBUFF3 "$a[1] No_RSID\n";
	}	
}	
print "Number of Markers with RSids but not in DBSNP: $num\n";
close(WRBUFF);
close(WRBUFF1);
close(WRBUFF2);
close(WRBUFF3);
print "Update done\n";

