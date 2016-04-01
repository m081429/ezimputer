#get current directory
use Cwd 'abs_path';
$line = abs_path($0);
chomp $line;
@DR_array = split('/',$line);
pop(@DR_array);
$dir = join("/",@DR_array);

require "$dir/bin/Read_reffile.pl";
$impute_ref="/data5/bsi/RandD/Workflow/temp/hugues_test_shapeit/ALL.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nomono";
$impute_ref="/data5/bsi/refdata/genetics/1000Genomes/downloaded_data/release/20110521/impute/ALL_1000G_phase1integrated_v3_impute/";
$impute_ref="/data5/bsi/refdata/genetics/1000Genomes/downloaded_data/release/20110521/impute/ALL_1000G_phase1integrated_feb2012_impute/";
getRef($impute_ref);

#check reference
for(my $chr=23;$chr>0;$chr--)
{
	if(exists($ref_meta{"chr$chr".'_'."genetic"}))
	{
		print "chr$chr".'_'."genetic"." ".$ref_meta{"chr$chr".'_'."genetic"}."\n";
	}
	else
	{
		die "there is a problem in the ref dir ot metainfo file provided. No value for chr$chr".'_'."genetic\n";
	}
	if(exists($ref_meta{"chr$chr".'_'."hap"}))
        {
                print "chr$chr".'_'."hap"." ".$ref_meta{"chr$chr".'_'."hap"}."\n";
        }
        else
        {
                die "there is a problem in the ref dir ot metainfo file provided. No value for chr$chr".'_'."hap\n";
        }
	if(exists($ref_meta{"chr$chr".'_'."legend"}))
        {
                print "chr$chr".'_'."legend"." ".$ref_meta{"chr$chr".'_'."legend"}."\n";
        }
        else
        {
                die "there is a problem in the ref dir ot metainfo file provided. No value for chr$chr".'_'."legend\n";
        }
}
if(exists($ref_meta{"sample"}))
{
	print "sample"." ".$ref_meta{"sample"}."\n";
}
else
{
       die "there is a problem in the ref dir ot metainfo file provided. No value for sample\n";
}
