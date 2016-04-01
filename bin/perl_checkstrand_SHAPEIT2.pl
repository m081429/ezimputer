###script to rescue the single sample reference homozygote(rescue the monomorphic)
##the output will be used after shapeit program got executed to backfill the reference markers
$infile=$ARGV[0];
chomp($infile);
$outfile_regained=$ARGV[1];
$outfile_report=$ARGV[2];
$outfile_rescued_marker_id=$ARGV[3];
chomp($outfile_regained);
chomp($outfile_report);
chomp($outfile_rescued_marker_id);
open(BUFF,$infile) or die "no input file found $infile\n";
open(WREX,">$outfile_regained") or die "not able to write the file $outfile_regained\n";
open(WRREP,">$outfile_report") or die "not  able to write the file $outfile_report\n";
open(WRRESID,">$outfile_rescued_marker_id") or die "not able to write the file $outfile_rescued_marker_id\n";
$header=<BUFF>;
chomp($header);
print WRREP $header."\n";
@header=split("\t",$header);
for($i=0;$i<@header;$i++)
{
	if($header[$i] eq "pos")
	{
		$num_pos=$i;
	}
	if($header[$i] eq "main_A")
	{
		$num_main_A=$i;
	}
	if($header[$i] eq "main_B")
	{
		$num_main_B=$i;
	}
	if($header[$i] eq "ref_A")
	{
		$num_ref_A=$i;
	}
	if($header[$i] eq "ref_B")
	{
		$num_ref_B=$i;
	}
	
	if($header[$i] eq "main_id")
	{
		$num_id=$i;
	}
}
$line=<BUFF>;
chomp($line);
@a=split("\t",$line);
if(@a == @header+1)
{
	$num_pos=$num_pos+1;
	$num_main_A=$num_main_A+1;
	$num_main_B=$num_main_B+1;
	$num_ref_A=$num_ref_A+1;
	$num_ref_B=$num_ref_B+1;
	$num_id=$num_id+1;
}
#print "num_pos:$num_pos\n";
#print "num_main_A:$num_main_A\n";
#print "num_main_B:$num_main_B\n";
#print "num_ref_A:$num_ref_A\n";
#print "num_ref_B:$num_ref_B\n";

do
{
	chomp($line);	
	@a=split("\t",$line);
	if($line =~ m/^strand/i && $a[$num_main_A] eq "0" &&( $a[$num_main_B] eq $a[$num_ref_A] || $a[$num_main_B] eq $a[$num_ref_B] ))
	{
		print WREX $line."\n";
		print WRRESID  $a[$num_id]."\n";
	}
	else
	{
		print WRREP $line."\n";
	}
}while($line=<BUFF>);	
close(WREX);
close(WRREP);
close(WRRESID);