#!/usr/bin/perl
###################################################
### Wrapper for ezimputer
#
### Previous version Author   : mrh2117, olswold
### modified for the paper m081429,Naresh prodduturi
### Created  : 6/25/2013
### Modified : 5/1/2014
#
# Argumentatives: 1, a config file that is flexible, 
#                 allowing all configs in the workflow,
#                 and the tool info file
#######################################################
#get current directory
use Cwd 'abs_path';
$line = abs_path($0);
chomp $line;
@DR_array = split('/',$line);
pop(@DR_array);
$dir = join("/",@DR_array);

use Getopt::Long;
&Getopt::Long::GetOptions(
'wrapper_config=s'      => \$config,
'tool_config=s'      => \$toolconfig
);
if($config eq "" || $toolconfig  eq "" || (!(-e $config)) || (!(-e $toolconfig)))
{
	print "config file missing.Check for this program manual and create a config file \n";
	
	die "Retry with : perl  Wrapper.pl  -wrapper_config <PATH TO THE RUN CONFIG FILE> -tool_config <PATH TO THE TOOL CONFIG FILE>\n";
}
require "$dir/bin/CONFIG.pl";

getDetails($config);
my $INPUT_PLINK= $config{"INPUT_PLINK"};
my $IMP2_OUT_DIR= $config{"IMP2_OUT_DIR"};
my $MODULES_NEEDED= $config{"MODULES_NEEDED"};
my $DEAL_AMBIGUOUS= $config{"DEAL_AMBIGUOUS"};

my $dbsnp_ver= $config{"DBSNP_DOWNLOADLINK"};
my $dbsnp_dir= $config{"DBSNP_DIR"};

my $include_pop= $config{"INCLUDE_POP"};
my $impute_ref= $config{"IMPUTE_REF"};
my $cond= $config{"COND"};

my $geno = $config{"GENOTYPE_PERCENT_CUTOFF"};
my $mind = $config{"SAMPLE_PERCENT_CUTOFF"};
my $db=$config{"BEAGLE_REF_DB"};
my $option=$config{"OPTION"};

my $impute_window = $config{"IMPUTE_WINDOW"};
my $impute_edge = $config{"IMPUTE_EDGE"};
my $haps = $config{"HAPS"};
my $email = $config{"EMAIL"};
my $shapeit_mem = $config{"SGE_SHAPEIT_MEM"};
my $shapeit_queue = $config{"SGE_SHAPEIT_QUEUE"};
my $impute_mem = $config{"SGE_IMPUTE_MEM"};
my $impute_queue = $config{"SGE_IMPUTE_QUEUE"};
my $restart_impute = $config{"RESTART"};
my $shapit_only = $config{"SHAPEITONLY"};
my $shapeit_states_param=$config{"SHAPEIT_EXTRA_PARAM"};
my $envr=$config{"ENVR"};
my $pbs_option=$config{"PBS_PARAM"};
my $chr_start_input=$config{"CHR_START_INPUT"};
my $small_region_extn_start=$config{"SMALL_REGION_EXTN_START"};
my $small_region_extn_stop=$config{"SMALL_REGION_EXTN_STOP"};
my $cutoff =$config{"WINDOW_CUTOFF_NUM_MARKERS"};
my $edge_cutoff=$config{"EDGE_CUTOFF_NUM_MARKERS"};
my $less_num_samp=$config{"LESS_NUM_SAMP"};

#reading tool info parameters
getDetails($toolconfig);
my $PLINK= $config{"PLINK"};
my $PERL= $config{"PERL"};
my $SHAPEIT= $config{"SHAPEIT"};
my $IMPUTE= $config{"IMPUTE"};
my $GPROBS= $config{"GPROBS"};
my $JAVA= $config{"JAVA"};
my $QSUB= $config{"QSUB"};
my $SH= $config{"SH"};
my $PYTHON= $config{"PYTHON"};
my $CHECK_STRAND= $config{"CHECK_STRAND"};
my $STRUCTURE= $config{"STRUCTURE"}; 
my $STRUCTURE_PARAM= $config{"STRUCTURE_PARAM"};

#cleaning the config param
$INPUT_PLINK=~ s/\t|\r|\n//g;
$IMP2_OUT_DIR=~ s/\t|\r|\n//g;
$MODULES_NEEDED=~ s/\t|\r|\n//g;
$DEAL_AMBIGUOUS=~ s/\t|\r|\n//g;
$dbsnp_ver=~ s/\t|\r|\n//g;
$dbsnp_dir=~ s/\t|\r|\n//g;
$include_pop=~ s/\t|\r|\n//g;
$impute_ref =~ s/\t|\r|\n//g;
$geno =~ s/\t|\r|\n//g;
$mind =~ s/\t|\r|\n//g;
$db=~ s/\t|\r|\n//g;
$option=~ s/\t|\r|\n//g;
$impute_window =~ s/\t|\r|\n//g;
$impute_edge =~ s/\t|\r|\n//g;
$haps =~ s/\t|\r|\n//g;
$email =~ s/\t|\r|\n//g;
$shapeit_mem =~ s/\t|\r|\n//g;
$shapeit_queue =~ s/\t|\r|\n//g;
$impute_mem =~ s/\t|\r|\n//g;
$impute_queue =~ s/\t|\r|\n//g;
$restart_impute =~ s/\t|\r|\n//g;
$shapit_only =~ s/\t|\r|\n//g;
$shapeit_states_param=~ s/\t|\r|\n//g;
$envr=~ s/\t|\r|\n//g;
$pbs_option=~ s/\t|\r|\n//g;
$chr_start_input=~ s/\t|\r|\n//g;
$small_region_extn_start=~ s/\t|\r|\n//g;
$small_region_extn_stop=~ s/\t|\r|\n//g;
$cutoff =~ s/\t|\r|\n//g;
$edge_cutoff=~ s/\t|\r|\n//g;
$less_num_samp=~ s/\t|\r|\n//g;
$cond=~ s/\t|\r|\n//g;

#cleaning the tools param
$PLINK=~ s/\s|\t|\r|\n//g;
$PERL=~ s/\s|\t|\r|\n//g;
$SHAPEIT=~ s/\s|\t|\r|\n//g;
$IMPUTE=~ s/\s|\t|\r|\n//g;
$GPROBS=~ s/\s|\t|\r|\n//g;
$JAVA=~ s/\s|\t|\r|\n//g;
$QSUB=~ s/\s|\t|\r|\n//g;
$SH=~ s/\s|\t|\r|\n//g;
$PYTHON=~ s/\s|\t|\r|\n//g;
$CHECK_STRAND=~ s/\s|\t|\r|\n//g;
$STRUCTURE=~ s/\s|\t|\r|\n//g; 
$STRUCTURE_PARAM=~ s/\s|\t|\r|\n//g;

print "***********INPUT ARGUMENTS FOR TOOL CONFIG FILE***********\n";
print "PLINK: $PLINK\n";
print "PERL: $PERL\n";
print "SHAPEIT: $SHAPEIT\n";
print "IMPUTE: $IMPUTE\n";
print "GPROBS: $GPROBS\n";
print "JAVA: $JAVA\n";
print "QSUB: $QSUB\n";
print "SH: $SH\n";
print "PYTHON: $PYTHON\n";
print "CHECK_STRAND: $CHECK_STRAND\n";
print "STRUCTURE: $STRUCTURE\n";
print "STRUCTURE_PARAM: $STRUCTURE_PARAM\n";

print "\n\n\n\n\n\n";
print "***********RUNINFO CONFIG INPUT ARGUMENTS***********\n";
print "INPUT_PLINK: $INPUT_PLINK\n";
print "IMP2_OUT_DIR: $IMP2_OUT_DIR\n";
print "MODULES_NEEDED: $MODULES_NEEDED\n";
print "DEAL_AMBIGUOUS: $DEAL_AMBIGUOUS\n";
print "\n\n\n\n\n\n";
$parameterflag=0;
if($MODULES_NEEDED =~ m/UPGRADE_BUILD/)
{
	print "PARAMETER FOR MODULE : UPGRADE_BUILD\n";
	print "DBSNP_DOWNLOADLINK: $dbsnp_ver\n";
	print "DBSNP_DIR: $dbsnp_dir\n";
	if(not defined($dbsnp_ver) )
	{
		print "MODULE_NEEDED has UPGRADE_BUILD, so PARAMETER DBSNP_DOWNLOADLINK cannot be empty\n";
		$parameterflag++;
	}
	if(not defined($dbsnp_dir) )
	{
		print "MODULE_NEEDED has UPGRADE_BUILD, so PARAMETER DBSNP_DIR cannot be empty\n";
		$parameterflag++;
	}
}
print "\n\n\n\n\n\n";
if($MODULES_NEEDED =~ m/REF_FILTER/)
{
	print "PARAMETER FOR MODULE : REF_FILTER\n";
	
	#defaults
	
	if(not defined($include_pop) )
	{
		$include_pop="AFR,AMR,ASN,EUR";
	}
	if(not defined($cond) )
	{
		print "MODULE_NEEDED has REF_FILTER, so PARAMETER COND cannot be empty\n";
		$parameterflag++;
	}
	print "INCLUDE_POP: $include_pop\n";
	print "IMPUTE_REF: $impute_ref\n";
	print "COND: $cond\n";
	if(not defined($impute_ref) )
	{
		print "MODULE_NEEDED has REF_FILTER, so PARAMETER IMPUTE_REF cannot be empty\n";
		$parameterflag++;
	}
}
print "\n\n\n\n\n\n";
if($MODULES_NEEDED =~ m/QC_REQUIRED/)
{
	#defaults
	if(not defined($geno) )
	{
		$geno=1;
	}
	if(not defined($mind) )
	{
		$mind=1;
	}
	if(not defined($option) )
	{
		$option="forward_strand";
	}
	if(not defined($db) )
	{
		$db="$IMP2_OUT_DIR/BEAGLE_REF_DB";
	}
	print "PARAMETER FOR MODULE : QC_REQUIRED\n";
	print "IMPUTE_REF: $impute_ref\n";
	print "GENOTYPE_PERCENT_CUTOFF: $geno\n"; 
	print "SAMPLE_PERCENT_CUTOFF: $mind\n"; 
	print "BEAGLE_REF_DB: $db\n";
	print "OPTION: $option\n";
	
	if(not defined($impute_ref) )
	{
		print "MODULE_NEEDED has QC_REQUIRED, so PARAMETER IMPUTE_REF cannot be empty\n";
		$parameterflag++;
	}
	if(not defined($ref_keyword) )
	{
		print "MODULE_NEEDED has QC_REQUIRED, so PARAMETER IMPUTEREF_VERSION cannot be empty\n";
		$parameterflag++;
	}
	if(not defined($db) )
	{
		print "MODULE_NEEDED has QC_REQUIRED, so PARAMETER BEAGLE_REF_DB cannot be empty\n";
		$parameterflag++;
	}
}
print "\n\n\n\n\n\n";
if($MODULES_NEEDED =~ m/IMPUTE/)
{
	print "PARAMETER FOR MODULE : IMPUTE\n";
	if(not defined($impute_window) )
	{
		$impute_window=5000000;
	}
	if(not defined($impute_edge) )
	{
		$impute_edge=125;
	}
	if(not defined($haps) )
	{
		$haps="NA";
	}
	if(not defined($shapeit_mem) )
	{
		$shapeit_mem="15G";
	}
	if(not defined($shapeit_queue) )
	{
		$shapeit_queue="4-days";
	}
	if(not defined($impute_mem) )
	{
		$impute_mem="15G";
	}
	if(not defined($impute_queue))
	{
		$impute_queue="1-day";
	}
	if(not defined($restart_impute) )
	{
		$restart_impute="NO";
	}
	if(not defined($shapit_only) )
	{
		$shapit_only="NO";
	}
	if(not defined($shapeit_states_param) )
	{
		$shapeit_states_param="--seed 123456789 --states 100 --thread 4";
	}
	if(not defined($envr) )
	{
		$envr="SGE";
	}
	if(not defined($chr_start_input) )
	{
		$chr_start_input="NO";
	}
	if(not defined($cutoff) )
	{
		$cutoff=50;
	}
	if(not defined($edge_cutoff) )
	{
		$edge_cutoff=10;
	}
	if(not defined($less_num_samp) )
	{
		$less_num_samp="NO";
	}
	
	
	print "IMPUTE_WINDOW: $impute_window\n"; 
	print "IMPUTE_EDGE: $impute_edge\n"; 
	print "HAPS: $haps\n"; 
	print "EMAIL: $email\n"; 
	print "SGE_SHAPEIT_MEM: $shapeit_mem\n"; 
	print "SGE_SHAPEIT_QUEUE: $shapeit_queue\n"; 
	print "SGE_IMPUTE_MEM: $impute_mem\n"; 
	print "SGE_IMPUTE_QUEUE: $impute_queue\n"; 
	print "RESTART: $restart_impute\n"; 
	print "SHAPEITONLY: $shapit_only\n"; 
	print "SHAPEIT_EXTRA_PARAM: $shapeit_states_param\n";
	print "ENVR: $envr\n";
	if($ENVR =~ m/PBS/)
	{
		print "PBS_PARAM: $pbs_option\n";
	}
	print "CHR_START_INPUT: $chr_start_input\n";
	if($chr_start_input =~ m/YES/)
	{
		print "SMALL_REGION_EXTN_START: $small_region_extn_start\n";
		print "SMALL_REGION_EXTN_STOP: $small_region_extn_stop\n";
	}
	print "WINDOW_CUTOFF_NUM_MARKERS: $cutoff\n"; 
	print "EDGE_CUTOFF_NUM_MARKERS: $edge_cutoff\n";
	print "LESS_NUM_SAMP: $less_num_samp\n";
	if(not defined($email) )
	{
		print "MODULE_NEEDED has QC_REQUIRED, so PARAMETER EMAIL cannot be empty\n";
		$parameterflag++;
	}

	
}		

if($parameterflag != 0)
{
	die "Please see above error;Number of required parameters to be filled $parameterflag\n";
}

### Is Sex-Check Requested? If yes, then don't exit upon data check, If No, then exit if any non 1 or 2 
if($option =~ m/sexcheck/)
{
	$DOSEXCHK=1;	 ##1=yes
}
else
{
	$DOSEXCHK=0;	 ##0=no
}

$STATS="$IMP2_OUT_DIR/impute2_stats.txt";
$SORTTMP="$IMP2_OUT_DIR/$USER.EZsortmp";
system("mkdir -p $IMP2_OUT_DIR"); 
system("mkdir $SORTTMP"); 
system("mkdir $IMP2_OUT_DIR/BEAGLE_REF_DB");
system("mkdir $IMP2_OUT_DIR/LOCAL_TEMP");
$PLINKDSN=`basename  $INPUT_PLINK`;
chomp($PLINKDSN);
print "Verifying Data: Individuals...\n";

print "1) Data Verification: Individuals\n";
print "---------------------------------\n";

print "\n\n\n\n\n";
$NIND=`wc -l $INPUT_PLINK.fam | awk '{print \$1}'`;
$NUIND=`awk '{print \$1,\$2}' $INPUT_PLINK.fam | sort -T $SORTTMP | uniq | wc -l | awk '{print \$1}'`;
chomp($NIND);
chomp($NUIND);

print "N Unique Individuals: $NUIND/$NIND\n";
if($NIND !~ m/^\d+$/ || $NUIND !~ m/^\d+$/)
{
	die "cannot the count the number of samples or unique samples in the file $INPUT_PLINK.fam $NIND != $NUIND\n";
} 
if($NIND != $NUIND)
{
	$sys="awk '{print \$1,\$2}' $INPUT_PLINK.fam | sort -T $SORTTMP | uniq -D > $IMP2_OUT_DIR/nonunique.ind";
	$exitcode=system("awk '{print \$1,\$2}' $INPUT_PLINK.fam | sort -T $SORTTMP | uniq -D > $IMP2_OUT_DIR/nonunique.ind");
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
    print "******************************************************************\n";
    print "*** Non-Unique Individuals Found\n";
    print " Please see $IMP2_OUT_DIR/nonunique.ind\n";
    print " to correct the issue, then re-run\n";
    print "Now exiting\n";
    print "******************************************************************\n";
    die;
} 

print "\n\n\n\n\n";

print "######NUMBER OF CASES & CONTROLS################\n";
$NCASE=0;
$NCTLS=0;
$NUNKN=0;

open(FAM,"$INPUT_PLINK.fam") or die " no fam file found\n";
while(<FAM>)
{
	chomp($_);
	@fam=split(" ",$_);
	if($fam[5] == 2)
	{
		$NCASE++;
	}
	elsif($fam[5] == 1)
	{
		$NCTLS++;
	}
	else
	{
		$NUNKN++;
	}
}
close(FAM);
print "N Cases: $NCASE\n";
print "N Controls: $NCTLS\n";
print "N Case/Control Unknown: $NUNKN\n";

print "\n\n\n\n\n";

print "############### GENDER#########################\n";
$NMALE=0;
$NFEML=0;
$NUGEN=0;
open(FAM,"$INPUT_PLINK.fam") or die " no fam file found\n";
open(WRNOSEX,">$IMP2_OUT_DIR/unknowngender.ind") or die "not able to write the file $IMP2_OUT_DIR/unknowngender.ind\n";
while(<FAM>)
{
	chomp($_);
	@fam=split(" ",$_);
	if($fam[4] == 2)
	{
		$NFEML++;
	}
	elsif($fam[4] == 1)
	{
		$NMALE++;
	}
	else
	{
		$NUGEN++;
		print WRNOSEX $_."\n";
	}
}
close(FAM);
close(WRNOSEX);
print "N Males: $NMALE\n";
print "N Females: $NFEML\n";
print "N Gender Unknown: $NUGEN\n";
print "\n\n\n\n\n";

if($NUGEN > 0)
{
	print "******************************************************************\n";
	print "*** Unknown Gendered Individuals Found\n";
	print " Please see $IMP2_OUT_DIR/unknowngender.ind\n";
	if($DOSEXCHK != 1)
	{
		print "Sex Check was NOT specified in OPTION parameter";
		print " please correct or specify 'sexcheck' in OPTION, then re-run";
		print "Now exiting.";
		print "******************************************************************";
		die;
	}
	else
	{
		print "Sex Check was Specified in OPTION parameter\n";
		print "Missing Sex will be imputed by plink\n";
		print "Continuing...\n";
		print "******************************************************************\n";
	}
}
print "\n\n\n\n\n";

print "creating the plink dataset in the temp folder\n";
$sys="$PLINK --noweb --bfile  $INPUT_PLINK  --recode --transpose --out $IMP2_OUT_DIR/$PLINKDSN > $IMP2_OUT_DIR/$PLINKDSN.log";
#print "$sys\n";
system($sys);
if(!((-e "$IMP2_OUT_DIR/$PLINKDSN.tped") && (-e "$IMP2_OUT_DIR/$PLINKDSN.tfam")))
{
	die "Above plink command failed.Files $IMP2_OUT_DIR/$PLINKDSN.tped or $IMP2_OUT_DIR/$PLINKDSN.tfam no found\n";
}

$CURRDSN="$IMP2_OUT_DIR/$PLINKDSN";
#$CURRDSN="$IMP2_OUT_DIR/$PLINKDSN"."_PREPDATA";
$CURRTPED="$CURRDSN.tped";
$CURRTFAM="$CURRDSN.tfam";
#$sys="$PERL $dir/Check_plink_data_ezimputer.pl -INPUT_FILE $IMP2_OUT_DIR/$PLINKDSN -OUTPUT_FILE $CURRDSN";
#print "$sys\n";
#$exitcode=system($sys);
#if(!($exitcode==0 && (-e "$CURRTPED") && (-e "$CURRTFAM")))
#{
#	die "Above script Check_plink_data_ezimputer.pl failed.Files $CURRTPED or $CURRTFAM not found\n";
#}
$TOTSNPS=`wc -l $CURRTPED | cut -d' ' -f1`;
chomp($_);
######################################################
### Below is where we start grooving through the workflow
##########################################################
print "\n\n\n\n\n";
# Convert Build 36 to Build 37, Currently, it seems to need to be downloaded

if($MODULES_NEEDED =~ m/UPGRADE_BUILD/)
{
	#chromosomes before Build conversion
	$chr_before_build=`cut -f1 -d ' ' $CURRDSN.tped|sort -T $IMP2_OUT_DIR|uniq`;
	chomp($chr_before_build);
	@chr_before_build=split("\n",$chr_before_build);
	for($u=0;$u<@chr_before_build;$u++)
	{
		$chr_before_build{$chr_before_build[$u]}=1;
	}
	$sys="$PERL $dir/Upgrade_inputmarkers_to_newbuild_by_DBSNP.pl   -DBSNP_DIR  $dbsnp_dir -DBSNP_DOWNLOADLINK  $dbsnp_ver -INPUT_FILE $CURRDSN.tped -REMAPPED_CURRENT_BUILD  $CURRDSN.newbuild.tped -NOTMAPPED_OLD_BUILD $CURRDSN.oldbuild.tped";
	#print "$sys\n";
	$exitcode=system($sys);
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	$CURRTPED="$CURRDSN.newbuild.tped";
	$CURRTFAM="$CURRDSN.tfam";
	system("mv $CURRDSN.tfam $CURRDSN.newbuild.tfam");
	$CURRTFAM="$CURRDSN.newbuild.tfam";
	$NB37SNPS=`wc -l $CURRTPED  | cut -d' ' -f1`;                                           
    $NB36SNPS=`wc -l $CURRDSN.oldbuild.tped  | cut -d' ' -f1`;
	chomp($NB37SNPS);
	chomp($NB36SNPS);
	print "Num of  SNPs on the new build: $NB37SNPS/$TOTSNPS\n";
    print "Num of SNPs not able to map to newbuild: $NB36SNPS/$TOTSNPS (Unable to convert, dropped)\n";
	
	#removing newly added chromsomes after remapping
	open(TPED,"$CURRDSN.newbuild.tped") or die "no file found $CURRDSN.newbuild.tped\n";
	open(WRTPED,">$CURRDSN.newbuild.tped.tmp") or die "no file found $CURRDSN.newbuild.tped.tmp\n";
	while(<TPED>)
	{
		@a=split(/ /,$_);
		if(exists($chr_before_build{$a[0]}))
		{
			print WRTPED $_;
		}
	}
	close(TPED);
	close(WRTPED);
	system("mv $CURRDSN.newbuild.tped.tmp $CURRDSN.newbuild.tped");
	$CURRDSN="$CURRDSN.newbuild";
}

print "\n\n\n\n\n\n";
#sorting the plink files
$sys="sort -T $IMP2_OUT_DIR -k1,1 -k4,4n $CURRTPED >$CURRTPED.sort";
 #print $sys."\n";
 #system($sys);
$exitcode=system($sys);
if($exitcode != 0)
{
	die "command $sys failed\nexitcode $exitcode\n";
}
 system("mv $CURRTPED.sort $CURRTPED");



$CURRDSN_CLN="$CURRDSN.clean";
$CURRDSN_CLN_TPED="$CURRDSN_CLN.tped";
$CURRDSN_CLN_TFAM="$CURRDSN_CLN.tfam";
$sys="$PERL $dir/Check_plink_data_ezimputer.pl -INPUT_FILE $CURRDSN -OUTPUT_FILE $CURRDSN_CLN";
print "$sys\n";
$exitcode=system($sys);
if(!($exitcode==0 && (-e "$CURRDSN_CLN_TPED") && (-e "$CURRDSN_CLN_TFAM")))
{
	die "Above script Check_plink_data_ezimputer.pl failed.Files $CURRDSN_CLN_TPED or $CURRDSN_CLN_TFAM not found\n";
}
$TOTSNPS_BFR=`wc -l $CURRDSN.tped | cut -d' ' -f1`;
$TOTSNPS=`wc -l $CURRDSN_CLN_TPED | cut -d' ' -f1`;
chomp($TOTSNPS);
print "TOTAL NUMBER OF SNPS PRESENT BEFORE CLEANING $TOTSNPS_BFR\n";
print "TOTAL NUMBER OF SNPS PRESENT AFTER CLEANING $TOTSNPS\n";
 
$CURRDSN="$CURRDSN_CLN";
$CURRTPED="$CURRDSN.tped";
$CURRTFAM="$CURRDSN.tfam";

# QC, Sex Check, Forward Strand, and Structure --> does have multiple switches
if($MODULES_NEEDED =~ m/QC_REQUIRED/)
{
	print "QCing, Sex Checking, Forward Stranding, and Structure for input data...\n";
	print "creating ToolInfo and RunInfo files for the QC script\n";
	open(WR_QC_RUN,">$IMP2_OUT_DIR/qcfwdstruc_run.cfg");
	print WR_QC_RUN "TPED=$CURRTPED\n";
	print WR_QC_RUN "TFAM=$CURRTFAM\n";
	print WR_QC_RUN "TEMP_FOLDER=$IMP2_OUT_DIR/qcfwdstruc_tmp\n";
	print WR_QC_RUN "INNER_DIR=tmp\n";
	print WR_QC_RUN "IMPUTE_REF=$impute_ref\n";
	print WR_QC_RUN "OUTPUT_FOLDER=$IMP2_OUT_DIR/qcfwdstruc\n";
	print WR_QC_RUN "IMPUTEREF_VERSION=$ref_keyword\n";
	print WR_QC_RUN "GENOTYPE_PERCENT_CUTOFF=$geno\n";
	print WR_QC_RUN "SAMPLE_PERCENT_CUTOFF=$mind\n";
	print WR_QC_RUN "BEAGLE_REF_DB=$db\n";
	print WR_QC_RUN "OPTION=$option\n";
	close(WR_QC_RUN);
	open(WR_QC_TOOL,">$IMP2_OUT_DIR/qcfwdstruc_tool.cfg");
	print WR_QC_TOOL "PLINK=$PLINK\n";
	print WR_QC_TOOL "PERL=$PERL\n";
	print WR_QC_TOOL "SHAPEIT=$SHAPEIT\n";
	print WR_QC_TOOL "IMPUTE=$IMPUTE\n";
	print WR_QC_TOOL "GPROBS=$GPROBS\n";
	print WR_QC_TOOL "JAVA=$JAVA\n";
	print WR_QC_TOOL "QSUB=$QSUB\n";
	print WR_QC_TOOL "SH=$SH\n";
	print WR_QC_TOOL "PYTHON=$PYTHON\n";
	print WR_QC_TOOL "CHECK_STRAND=$CHECK_STRAND\n";
	print WR_QC_TOOL "STRUCTURE=$STRUCTURE\n";
	print WR_QC_TOOL "STRUCTURE_PARAM=$STRUCTURE_PARAM\n";
	close(WR_QC_TOOL);
	#print "$sys\n";
	#system($sys);
	open(ARRAY_SHAPEIT,">$IMP2_OUT_DIR/QC_Submit.csh")  or die "no file found $IMP2_OUT_DIR/QC_Submit.csh\n";
	$sys="$PERL $dir/QC_fwd_structure.pl -run_config $IMP2_OUT_DIR/qcfwdstruc_run.cfg -tool_config $IMP2_OUT_DIR/qcfwdstruc_tool.cfg";
	print ARRAY_SHAPEIT "$sys\n";
	close(ARRAY_SHAPEIT);
	$sys="sh $IMP2_OUT_DIR/QC_Submit.csh";
	$exitcode=system("sh $IMP2_OUT_DIR/QC_Submit.csh");
	if($exitcode != 0)
	{
		die "command $sys failed\nexitcode $exitcode\n";
	}
	$NFWSTRND=`wc -l $IMP2_OUT_DIR/qcfwdstruc/processed_input.tped | cut -d' ' -f1`;
    	$NIGNORED=`wc -l $IMP2_OUT_DIR/qcfwdstruc/markers.ignored | cut -d' ' -f1`;
    	$NNOFLIP=`awk '{print \$2}' $IMP2_OUT_DIR/qcfwdstruc/fwdStrandResults_input.ind | grep '0' | wc -l | cut -d' ' -f1`;
    	$NFLIP=`awk '{print \$2}' $IMP2_OUT_DIR/qcfwdstruc/fwdStrandResults_input.ind | grep '1' | wc -l | cut -d' ' -f1`;
    	$NNOREF=`awk '{print \$2}' $IMP2_OUT_DIR/qcfwdstruc/fwdStrandResults_input.ind | grep '2' | wc -l | cut -d' ' -f1`;
	chomp($NFWSTRND);
	chomp($NIGNORED);
	chomp($NNOFLIP);
	chomp($NFLIP);
	chomp($NNOREF);
	print "QC process results\n";
    print "N SNPs Forward Stranded: $NFWSTRND/$NB37SNPS\n";
    print "N SNPs Ignored/Removed : $NIGNORED/$NB37SNPS\n";
    print "N SNPs Not Flipped     : $NNOFLIP/$NFWSTRND\n";
    print "N SNPs Flipped         : $NFLIP/$NFWSTRND\n";
    print "N SNPs Not in Reference: $NNOREF/$NFWSTRND\n";
	$CURRTPED="$IMP2_OUT_DIR/qcfwdstruc/processed_input.tped";
	$CURRTFAM="$IMP2_OUT_DIR/qcfwdstruc/processed_input.tfam";
	
	if($option =~ m/SEXCHECK/i)
	{
		$NMALE=0;
		$NFEML=0;
		$NUGEN=0;
		open(FAM,"$CURRTFAM") or die " no fam file $CURRTFAM found\n";
		while(<FAM>)
		{
			chomp($_);
			@fam=split(" ",$_);
			if($fam[4] == 2)
			{
				$NFEML++;
			}
			elsif($fam[4] == 1)
			{
				$NMALE++;
			}
			else
			{
				$NUGEN++;
			}
		}
		close(FAM);
		print "N Males: $NMALE\n";
		print "N Females: $NFEML\n";
		print "N Gender Unknown: $NUGEN\n";
		if($NUGEN > 0)
		{
			print "*********************************************************************\n";
			print "After Imputation and Attempting to Fill in Missing Sex\n";
			print " with Observed Sex, there still exists $NUGEN Subjects missing sex\n";
			print "Here is the fam file $CURRTFAM\n";
			print "Now Exiting\n";
			print "*********************************************************************\n";
			die;
		}	
		print "\n\n\n\n\n";
	}
}
#creating the indictaor file for the ambiguous
if($DEAL_AMBIGUOUS =~ m/YES/i)
{
	open(TPED,$CURRTPED) or die "no tped file found $CURRTPED\n";
	open(WRAMBI,">$IMP2_OUT_DIR/imp2_b37_filter_ambistrand.txt") or die "not able to write the file $IMP2_OUT_DIR/imp2_b37_filter_ambistrand.txt\n";
	while(<TPED>)
	{
		chomp($_);
		@array=split(" ",$_);
		print WRAMBI $array[1]."\t2\n";
	}
	close(TPED);
	close(WRAMBI);
	$fwd_strnd_file="$IMP2_OUT_DIR/imp2_b37_filter_ambistrand.txt";
}
else
{
	$fwd_strnd_file="NA";
}

#reference filtering
if($MODULES_NEEDED =~ m/REF_FILTER/)
{
		
#this code for paralizing this step
	if($envr !~ m/SGE_MAYO/i ) 
	{
		$sys="$PERL $dir/Filter_1000genome_reference_by_maf_cond.pl -COND $cond -REF_GENOME_DIR $impute_ref -OUTPUT_DIR $IMP2_OUT_DIR/refdat_filtered  -INCLUDE_POP  $include_pop ";
		print "$sys\n";
		$exitcode=system($sys);
		if($exitcode != 0)
		{
			die "command $sys failed\nexitcode $exitcode\n";
		}
		
	}
	else
	{
		system("mkdir $IMP2_OUT_DIR/Parallel_ref_filter_sgelog");
		open(ARRAY_SHAPEIT,">$IMP2_OUT_DIR/Parallel_ref_filter.csh")  or die "no file found $IMP2_OUT_DIR/Parallel_ref_filter.csh\n";
		$com = '#!';
		print ARRAY_SHAPEIT "$com $SH\n";
		$com = '#$';
		print ARRAY_SHAPEIT "$com -q $shapeit_queue\n";
		print ARRAY_SHAPEIT "$com -l h_vmem=$shapeit_mem\n";
		print ARRAY_SHAPEIT "$com -t 1-23:1\n";
		print ARRAY_SHAPEIT "$com -M $email\n";
		print ARRAY_SHAPEIT "$com -m a\n";
		print ARRAY_SHAPEIT "$com -e $IMP2_OUT_DIR/Parallel_ref_filter_sgelog\n";
		print ARRAY_SHAPEIT "$com -o $IMP2_OUT_DIR/Parallel_ref_filter_sgelog\n";
		$sys="$PERL $dir/Filter_1000genome_reference_by_maf_cond.pl -COND $cond -REF_GENOME_DIR $impute_ref -OUTPUT_DIR $IMP2_OUT_DIR/refdat_filtered  -INCLUDE_POP  $include_pop -INCHR ".'$SGE_TASK_ID';
		print ARRAY_SHAPEIT "$sys\n";
		close(ARRAY_SHAPEIT);
		$jobid=`$QSUB $IMP2_OUT_DIR/Parallel_ref_filter.csh`;
		chomp($jobid);
		
		#readin job id from submit_shapeit
		@shapeit =split(" ",$jobid);
		@shapeit1 =split(/\./,$shapeit[2]);
		print "JOB ID extracted: $shapeit1[0]\n";
		#system($sys);
	}
	$impute_ref="$IMP2_OUT_DIR/refdat_filtered";
}

#imputation
print "\n\n\n\n\n\n";
if($MODULES_NEEDED =~ m/IMPUTE/)
{
	$rounded="impute";
	print "Imputation...\n";
	print "creating ToolInfo and RunInfo files for the Imputation script\n";
	open(WR_QC_RUN,">$IMP2_OUT_DIR/Impute_run.cfg");
	print WR_QC_RUN "TPED=$CURRTPED\n";
	print WR_QC_RUN "TFAM=$CURRTFAM\n";
	print WR_QC_RUN "TEMP_FOLDER=$IMP2_OUT_DIR/Impute_tmp\n";
	print WR_QC_RUN "FORWARDSTRAND_IND=$fwd_strnd_file\n";
	print WR_QC_RUN "INNER_DIR=$rounded\n";
	print WR_QC_RUN "IMPUTE_REF=$impute_ref\n"; 
	print WR_QC_RUN "IMPUTE_WINDOW=$impute_window\n"; 
	print WR_QC_RUN "IMPUTE_EDGE=$impute_edge\n"; 
	print WR_QC_RUN "HAPS=$haps\n"; 
	print WR_QC_RUN "EMAIL=$email\n"; 
	print WR_QC_RUN "SGE_SHAPEIT_MEM=$shapeit_mem\n"; 
	print WR_QC_RUN "SGE_SHAPEIT_QUEUE=$shapeit_queue\n"; 
	print WR_QC_RUN "SGE_IMPUTE_MEM=$impute_mem\n"; 
	print WR_QC_RUN "SGE_IMPUTE_QUEUE=$impute_queue\n"; 
	print WR_QC_RUN "RESTART=$restart_impute\n"; 
	print WR_QC_RUN "SHAPEITONLY=$shapit_only\n"; 
	print WR_QC_RUN "SHAPEIT_EXTRA_PARAM=$shapeit_states_param\n";
	print WR_QC_RUN "ENVR=$envr\n";
	if($ENVR =~ m/PBS/)
	{
		print WR_QC_RUN "PBS_PARAM=$pbs_option\n";
	}
	print WR_QC_RUN "CHR_START_INPUT=$chr_start_input\n";
	if($chr_start_input =~ m/YES/)
	{
		print WR_QC_RUN "SMALL_REGION_EXTN_START=$small_region_extn_start\n";
		print WR_QC_RUN "SMALL_REGION_EXTN_STOP=$small_region_extn_stop\n";
	}
	print WR_QC_RUN "WINDOW_CUTOFF_NUM_MARKERS=$cutoff\n"; 
	print WR_QC_RUN "EDGE_CUTOFF_NUM_MARKERS=$edge_cutoff\n";
	print WR_QC_RUN "LESS_NUM_SAMP=$less_num_samp\n";
	close(WR_QC_RUN);
	open(WR_QC_TOOL,">$IMP2_OUT_DIR/Impute_tool.cfg");
	print WR_QC_TOOL "PLINK=$PLINK\n";
	print WR_QC_TOOL "PERL=$PERL\n";
	print WR_QC_TOOL "SHAPEIT=$SHAPEIT\n";
	print WR_QC_TOOL "IMPUTE=$IMPUTE\n";
	print WR_QC_TOOL "GPROBS=$GPROBS\n";
	print WR_QC_TOOL "JAVA=$JAVA\n";
	print WR_QC_TOOL "QSUB=$QSUB\n";
	print WR_QC_TOOL "SH=$SH\n";
	print WR_QC_TOOL "PYTHON=$PYTHON\n";
	print WR_QC_TOOL "CHECK_STRAND=$CHECK_STRAND\n";
	print WR_QC_TOOL "STRUCTURE=$STRUCTURE\n";
	print WR_QC_TOOL "STRUCTURE_PARAM=$STRUCTURE_PARAM\n";
	close(WR_QC_TOOL);
	open(ARRAY_SHAPEIT,">$IMP2_OUT_DIR/Impute_Submit.csh")  or die "no file found $IMP2_OUT_DIR/Impute_Submit.csh\n";
	if($MODULES_NEEDED =~ m/REF_FILTER/ && $envr =~ m/SGE_MAYO/i)
	{	
		$com = '#!';
		print ARRAY_SHAPEIT "$com $SH\n";
		$com = '#$';
		print ARRAY_SHAPEIT "$com -q $shapeit_queue\n";
		print ARRAY_SHAPEIT "$com -l h_vmem=$shapeit_mem\n";
		print ARRAY_SHAPEIT "$com -M $email\n";
		print ARRAY_SHAPEIT "$com -m a\n";
		print ARRAY_SHAPEIT "$com -hold_jid $shapeit1[0]\n";
		print ARRAY_SHAPEIT "$com -V\n";
		print ARRAY_SHAPEIT "$com -e $IMP2_OUT_DIR\n";
		print ARRAY_SHAPEIT "$com -o $IMP2_OUT_DIR\n";
	}
	$sys="$PERL $dir/Phase_Impute_by_parallel_proc.pl  -run_config $IMP2_OUT_DIR/Impute_run.cfg -tool_config $IMP2_OUT_DIR/Impute_tool.cfg";
	print ARRAY_SHAPEIT "$sys\n";
	close(ARRAY_SHAPEIT);
	if($MODULES_NEEDED =~ m/REF_FILTER/ && $envr =~ m/SGE_MAYO/i)
	{	
		$jobid=`$QSUB $IMP2_OUT_DIR/Impute_Submit.csh`;
		chomp($jobid);
		#readin job id from submit_shapeit
		@shapeit =split(" ",$jobid);
		@shapeit1 =split(/\./,$shapeit[2]);
		print "JOB ID extracted: $shapeit1[0]\n";
	}
	else
	{	
		$sys="sh $IMP2_OUT_DIR/Impute_Submit.csh";
		$exitcode=system("sh $IMP2_OUT_DIR/Impute_Submit.csh");
		if($exitcode != 0)
		{
			die "command $sys failed\nexitcode $exitcode\n";
		}
	}	
}
