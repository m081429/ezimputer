#####################################################################################################################################################
#Purpose: To download impute reference files
#Date: 01-08-2013
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
'OUT_REF_DIR=s'=> \$outdir,
'DOWNLOAD_LINK=s' => \$downloadlink,
);
$outdir =~ s/\s|\t|\r|\n//g;
$downloadlink=~ s/\s|\t|\r|\n//g;
#input arguments
#$outdir="/data4/bsi/RandD/Workflow/temp/v3/";
#$downloadlink="http://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz";

#checking for missing arguments
if($outdir eq "" || $downloadlink eq "" )
{
	die "missing arguments\n USAGE : perl Get_impute_reference.pl -OUT_REF_DIR <TARGET IMPUTE REFERENCE DIRECTORY> -DOWNLOAD_LINK <DOWNLOAD LINK>\n";
}

#parsing the arguments
$outdir=~ s/\/$//g;
unless(-d $outdir)
{
	system("mkdir -p $outdir");
}
chdir($outdir);
@download=split(/\//,$downloadlink);
$file=pop(@download);
#download the reference files
$sys="wget ".'--quiet '." $downloadlink";
$exitcode=system($sys);
#system($sys);
if($exitcode != 0)
{
	die "command $sys failed\nexitcode $exitcode\ncheck log file $outdir/wget_ref.log";
}
#checking if the file exists
if(!(-e $file))
{
	die "file $file not downloaded sucessfully.Check for the Download link\n";
}
#untar and gunzip the reference files
system("tar -zxvf $file");
$file=~ s/.tgz$//g;
$file=~ s/.tar.gz$//g;

$output_impute="$outdir/$file";
$files=`ls $outdir/$file`;
@files=split("\n",$files);
#print "@files\n";
print "NOTEDOWN BELOW DETAILS FOR FUTURE USE\n";
print "IMPUTE REF DIRECTORY : $output_impute\n";

#reading ref directory
require "$dir/bin/Read_reffile.pl";

getRef($output_impute);

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

