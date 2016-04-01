#!/bin/sh
#Set your ezimputer program directory
#set -x

if [ "$#" -ne 3 ]
then
	SCRIPT=$(readlink -f "$0")
	echo "usage:$SCRIPT <path_to_ezimputer_install> <path_to_example_process_dir to run the examples>  <path to the tool info file>"
	exit 1
else
	export EZIMPUTER=$1
	export EXAMPLES=$2
	export TOOLINFO=$3
	mkdir -p $EXAMPLES
fi
EZIMPUTER=`echo $EZIMPUTER|sed 's/\/$//g'`
EXAMPLES=`echo $EXAMPLES|sed 's/\/$//g'`

if [ -f $TOOLINFO ]
then
	echo "$TOOLINFO file exists."
else
	echo "TOOLINFO file $TOOLINFO not found."
fi
file=$EZIMPUTER/Phase_Impute_by_parallel_proc.pl
if [ -f $file ]
then
	echo "directory $EZIMPUTER  exists."
else
	echo "directory not exists or EZIMPUTER scripts not found in the directory $EZIMPUTER"
fi


#export EZIMPUTER=/data5/bsi/RandD/Workflow/temp/hugues_test_shapeit/ezimputer/new_ref_ezimputer
#replace the path for example with your working directory
#export EXAMPLES=/data5/bsi/RandD/Workflow/temp/hugues_test_shapeit/ezimputer/new_ref_ezimputer/test1
#get the hapmap data
# Here you would replace this script with command to get your own data.
cd $EXAMPLES

PERL=`grep 'PERL=' $TOOLINFO | cut -d '=' -f2`

echo $PERL
#convert the plink file format to transpose
PLINK=`grep 'PLINK='  $TOOLINFO | cut -d '=' -f2 `

wget --quiet http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/hapmap3_r3/plink_format/hapmap3_r3_b36_fwd.consensus.qc.poly.map.gz
if [ $? -ne 0 ]
then
	echo "Download failed http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/hapmap3_r3/plink_format/hapmap3_r3_b36_fwd.consensus.qc.poly.map.gz"
	echo "check the log file $EXAMPLES/hapmap3_r3_b36_fwd.consensus.qc.poly.map.log"
	exit
fi
wget --quiet  http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/hapmap3_r3/plink_format/hapmap3_r3_b36_fwd.consensus.qc.poly.ped.gz
if [ $? -ne 0 ]
then
	echo "Download failed http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/hapmap3_r3/plink_format/hapmap3_r3_b36_fwd.consensus.qc.poly.ped.gz"
	echo "check the log file $EXAMPLES/hapmap3_r3_b36_fwd.consensus.qc.poly.ped.log"
	exit
fi
#Uncompress(gunzip) them and convert the plink files to plink transpose files (this may take ~1 hour)
gunzip hapmap3_*.gz
if [ $? -ne 0 ]
then
	echo "Download files  decompression http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/hapmap3_r3/plink_format/hapmap3_r3_b36_fwd.consensus.qc.poly.ped.gz & http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/hapmap3_r3/plink_format/hapmap3_r3_b36_fwd.consensus.qc.poly.map.gz failed"
	exit
fi

SH=`which sh`
if [ -x $SH ]
then
	echo "sh exists $SH"
else
   echo "SHELL SCRIPT SH either not exists or don't have the executable permissions"
   exit 1
fi




#download & prepare external tools
# Skip this if you have already installed the tools.. and set TOOLINFO to the path/name of your tool_info.config file
###$EZIMPUTER/install_tools.sh $EZIMPUTER
###make tool_info.config file
#$SH $EZIMPUTER/make_tool_info.sh $EZIMPUTER > $EXAMPLES/tool_info.config
#if [ $? -ne 0 ]
#then
#	echo "Some thing wrong with the script $EZIMPUTER/make_tool_info.sh. check for $EXAMPLES/tool_info.config!"
#	exit 1
#fi
#export TOOLINFO=$EXAMPLES/tool_info.config



#Extract the top 50 samples 
cut -f1-6 -d ' ' $EXAMPLES/hapmap3_r3_b36_fwd.consensus.qc.poly.ped|head -50   > $EXAMPLES/hapmap3_r3_b36_fwd.consensus.qc.poly_50.keep 
$PLINK --file $EXAMPLES/hapmap3_r3_b36_fwd.consensus.qc.poly  --keep $EXAMPLES/hapmap3_r3_b36_fwd.consensus.qc.poly_50.keep --chr 22 --make-bed --out $EXAMPLES/hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly

#get imputataion reference
mkdir $EXAMPLES/impute_ref

$PERL  $EZIMPUTER/Get_impute_reference.pl  -OUT_REF_DIR  $EXAMPLES/impute_ref  -DOWNLOAD_LINK   http://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz 
if [ $? -ne 0 ]
then
	echo "Some thing wrong with the script $EZIMPUTER/Get_impute_reference.pl. Impute2 reference files not generated!"
	exit
fi
mkdir $EXAMPLES/DBDIR
cd $EXAMPLES/DBDIR
#wget --quiet   ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b141_GRCh37p13/database/organism_data/b141_SNPChrPosOnRef_GRCh37p13.bcp.gz
wget --quiet   ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b144_GRCh37p13/database/organism_data/b144_SNPChrPosOnRef_105.bcp.gz
if [ $? -ne 0 ]
then
	echo "Some thing wrong with the wget command ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b141_GRCh37p13/database/organism_data/b141_SNPChrPosOnRef_GRCh37p13.bcp.gz!"
	echo "check the log file $EXAMPLES/wget_dbsnp.log"
	exit
fi
#preparing run config file for the Wrapper script
echo "INPUT_PLINK=$EXAMPLES/hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly"  > $EXAMPLES/Wrapper_run_info.config
echo "IMP2_OUT_DIR=$EXAMPLES/WHOLECHR"  >> $EXAMPLES/Wrapper_run_info.config
echo "MODULES_NEEDED=UPGRADE_BUILD,IMPUTE"  >> $EXAMPLES/Wrapper_run_info.config
#echo "DBSNP_DOWNLOADLINK=ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b141_GRCh37p13/database/organism_data/b141_SNPChrPosOnRef_GRCh37p13.bcp.gz"  >> $EXAMPLES/Wrapper_run_info.config
echo "DBSNP_DOWNLOADLINK=ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b144_GRCh37p13/database/organism_data/b144_SNPChrPosOnRef_105.bcp.gz"  >> $EXAMPLES/Wrapper_run_info.config
echo "DBSNP_DIR=$EXAMPLES/DBDIR"  >> $EXAMPLES/Wrapper_run_info.config
echo "IMPUTE_REF=$EXAMPLES/impute_ref/ALL_1000G_phase1integrated_v3_impute"  >> $EXAMPLES/Wrapper_run_info.config
echo "IMPUTEREF_VERSION=ALL_1000G_phase1integrated_v3_impute"  >> $EXAMPLES/Wrapper_run_info.config
echo "BEAGLE_REF_DB=$EXAMPLES/DBDIR/BEAGLE/"  >> $EXAMPLES/Wrapper_run_info.config
echo "EMAIL=email"  >> $EXAMPLES/Wrapper_run_info.config
echo "USERNAME=username"  >> $EXAMPLES/Wrapper_run_info.config
echo "DEAL_AMBIGUOUS=YES"  >> $EXAMPLES/Wrapper_run_info.config
echo "ENVR=MANUAL"  >> $EXAMPLES/Wrapper_run_info.config
perl  $EZIMPUTER/Wrapper.pl  -wrapper_config $EXAMPLES/Wrapper_run_info.config -tool_config $TOOLINFO
