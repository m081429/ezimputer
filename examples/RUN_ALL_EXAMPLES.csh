#!/bin/sh
#sh should be in the path to execute this script
#This script will install all anciliary tools for ezimputer and run all the example scripts for you
#set -x
if [ "$#" -ne 3 ]
then
	echo "usage:sh  RUN_ALL_EXAMPLES.csh <path_to_ezimputer_install> <path_to_ezimputer_directory_example_scripts> <path to the tool info file>"
	SCRIPT=$(readlink -f "$0")
	EZIMPUTER=`dirname $SCRIPT`
	EZIMPUTER=`echo $EZIMPUTER|rev|tr '/' " "|cut -f2- -d ' '|rev|tr " " '/'`
	echo "If you just downloaded the tool and did not move any directory then just execute"
	echo "sh $SCRIPT  $EZIMPUTER <PATH TO DIR TO RUN THE EXAMPLES> <PATH TO TOOL INFO FILE>"
	exit 1
else
	export EZIMPUTER=$1
	export EXAMPLES_DIR=$2
	export TOOLINFO=$3
fi

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


SH=`which sh`
if [ -x $SH ]
then
	echo "sh exists $SH"
else
   echo "SHELL SCRIPT SH either not exists or don't have the executable permissions"
   exit 1
fi
echo " "
echo " "
echo " "
echo " "

##installing the tools
#if [ -x "$EZIMPUTER/install_tools.sh" ]
#then
#	echo "tools will be executed in the dir $EZIMPUTER"
#	$SH $EZIMPUTER/install_tools.sh $EZIMPUTER
#else
#   echo "script $EZIMPUTER/install_tools.sh either not exists or don't have the executable permissions"
#   exit 1
#fi

echo " "
echo " "
echo " "
echo " "

sucess=1

#running the WHOLECHROMSOME EXAMPLE
echo "running the whole chromosome example in the directory  $EXAMPLES_DIR "
echo "executing $SH $EZIMPUTER/examples/WHOLE_GENOME_CHROMOSOME_IMPUTATION_SGE_WRAPPER.sh  $EZIMPUTER $EXAMPLES_DIR $TOOLINFO"
$SH $EZIMPUTER/examples/WHOLE_GENOME_CHROMOSOME_IMPUTATION_SGE_WRAPPER.sh  $EZIMPUTER $EXAMPLES_DIR $TOOLINFO
if [ $? -ne 0 ]
then
	echo "Example script $EZIMPUTER/examples/WHOLE_GENOME_CHROMOSOME_IMPUTATION_SGE_WRAPPER.sh failed!"
	sucess=0
	exit
fi 
echo " "
echo " "
echo " "
echo " "

#running the SMALL REGION IMPUTATION EXAMPLE
echo "running the small region example in the directory  $EXAMPLES_DIR "
echo "executing $SH $EZIMPUTER/examples/SMALL_REGION_IMPUTATION_SGE_WRAPPER.sh   $EZIMPUTER $EXAMPLES_DIR $TOOLINFO"
$SH $EZIMPUTER/examples/SMALL_REGION_IMPUTATION_SGE_WRAPPER.sh   $EZIMPUTER $EXAMPLES_DIR $TOOLINFO
if [ $? -ne 0 ]
then
	echo "Example script $EZIMPUTER/examples/SMALL_REGION_IMPUTATION_SGE_WRAPPER.sh failed!"
	sucess=0
	exit
fi 
echo " "
echo " "
echo " "
echo " "

#running the SINGLE SAMPLE EXAMPLE
echo "running the single sample example in the directory  $EXAMPLES_DIR "
echo "executing $SH $EZIMPUTER/examples/SINGLE_SAMPLE_IMPUTATION_SGE_WRAPPER.sh   $EZIMPUTER $EXAMPLES_DIR $TOOLINFO"
$SH $EZIMPUTER/examples/SINGLE_SAMPLE_IMPUTATION_SGE_WRAPPER.sh   $EZIMPUTER $EXAMPLES_DIR $TOOLINFO
if [ $? -ne 0 ]
then
	echo "Example script $EZIMPUTER/examples/SINGLE_SAMPLE_IMPUTATION_SGE_WRAPPER.sh failed!"
	sucess=0
	exit
fi 

if [ $sucess -ne 0 ]
then
	echo "Here are the results for:"
	echo "WHOLECHR: $EXAMPLES_DIR/WHOLECHR/Impute_tmp/impute"
	echo "SMALL_REGION: $EXAMPLES_DIR/SMALL_REGION/Impute_tmp/impute"
	echo "SINGLE_SAMPLE: $EXAMPLES_DIR/SINGLE_SAMPLE/Impute_tmp/impute"
	echo "Result Description file: $EXAMPLES_DIR/WHOLECHR/Impute_tmp/impute/READ_ME_result"
else
	echo "The run was not sucessful! Please see above errors!"
fi	