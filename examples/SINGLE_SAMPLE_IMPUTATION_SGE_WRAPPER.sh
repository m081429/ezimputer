#!/bin/sh
# This assumes you already created a tool_info.config file in the main directory where you installed the tools.
#set -x
#export EZIMPUTER=/data5/bsi/RandD/Workflow/temp/hugues_test_shapeit/ezimputer/new_ref_ezimputer
#replace the path for example with your working directory
#export EXAMPLES=/data5/bsi/RandD/Workflow/temp/hugues_test_shapeit/ezimputer/new_ref_ezimputer/test
if [ "$#" -ne 3 ]
then
	SCRIPT=$(readlink -f "$0")
	echo "usage: $SCRIPT <path_to_ezimputer_install> <path_to_example_process_dir> <path to the tool info file>"
	exit 1
else
	export EZIMPUTER=$1
	export EXAMPLES=$2
	export TOOLINFO=$3
	#mkdir -p $EXAMPLES
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

FILE=$EXAMPLES/WHOLECHR/hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly.newbuild.tped
if [ -f $FILE ];
then
   echo "File $FILE exists"
else
   echo "File $FILE does not exists"
   echo "Run WHOLE_GENOME_CHROMOSOME_IMPUTATION_SGE_WRAPPER.sh befoe running this script"
   exit
fi

#TOOLINFO=$EXAMPLES/tool_info.config
#if [ -f $TOOLINFO ];
#then
#   echo "File $TOOLINFO exists"
#else
#   echo "ToolInfoFile $TOOLINFO does not exists"
#   echo "Run WHOLE_GENOME_CHROMOSOME_IMPUTATION_SGE_WRAPPER.sh befoe running this script"
#   exit 1
#fi

cd $EXAMPLES/WHOLECHR/
cp hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly.tfam  hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly.newbuild.tfam
head -1 hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly.newbuild.tfam  > single_samp.txt
#extracting smalle region from whole genome
# Before running this script, you must run the whole genome workflow example up to the QC Step to generate the fwdStrandResults_input file
#convert the plink file format to transpose
PLINK=`grep 'PLINK='  $TOOLINFO | cut -d '=' -f2 `

$PLINK --tfile hapmap3_r3_b36_fwd.consensus_subset50_chr22.qc.poly.newbuild --keep $EXAMPLES/WHOLECHR/single_samp.txt --make-bed --out single_sample_fwdStrandResults_input
if [ $? -ne 0 ]
then
	echo "Some thing wrong with plink command.Plink Output fileset $EXAMPLES/WHOLECHR/single_sample_fwdStrandResults_input not generated!"
	exit
else
#compress the tped file
	echo "File exists $EXAMPLES/WHOLECHR/single_sample_fwdStrandResults_input" 
fi

#preparing run config file
echo "INPUT_PLINK=$EXAMPLES/WHOLECHR/single_sample_fwdStrandResults_input"  > $EXAMPLES/single_sample_Wrapper_run_info.config
echo "IMP2_OUT_DIR=$EXAMPLES/SINGLE_SAMPLE"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "MODULES_NEEDED=IMPUTE"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "IMPUTE_REF=$EXAMPLES/impute_ref/ALL_1000G_phase1integrated_v3_impute"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "IMPUTEREF_VERSION=ALL_1000G_phase1integrated_v3_impute"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "EMAIL=email"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "USERNAME=username"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "DEAL_AMBIGUOUS=YES"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo "ENVR=MANUAL"  >> $EXAMPLES/single_sample_Wrapper_run_info.config
echo 'LESS_NUM_SAMP="YES"'  >> $EXAMPLES/single_sample_Wrapper_run_info.config
perl  $EZIMPUTER/Wrapper.pl  -wrapper_config  $EXAMPLES/single_sample_Wrapper_run_info.config -tool_config $TOOLINFO




