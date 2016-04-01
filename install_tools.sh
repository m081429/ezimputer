#!/bin/sh
#
# This script will install all anciliary tools for ezimputer
# usage: install_tools.sh path_to_install_directory
#
#DETAILED DESCRIPTION TO DOWNLOAD THE TOOLS

if [ "$#" -eq 2 ]
then


export EZIMPUTER=$1
TOOLINFOFILE=$2

$toodir=`dirname $TOOLINFOFILE`;

if [ ! -d "$toodir" ]
then
	mkdir -p $toodir
fi
EZIMPUTER=`echo $EZIMPUTER|sed 's/\/$//g'`
echo "INSTALL DIRECTORY SPECIFIED: $EZIMPUTER"

#Create main tools directory
if [ ! -d $EZIMPUTER ]
then
mkdir -p $EZIMPUTER
fi
mkdir $EZIMPUTER/LOG

#Change directory
cd $EZIMPUTER

tools_installed=""
tools_installed_ind=1

#CHECK_STRAND
echo "Downloading the Program CHECK_STRAND"
#Create main CHECK_STRAND directory
mkdir $EZIMPUTER/CHECK_STRAND
#Change to CHECK_STRAND directory
cd $EZIMPUTER/CHECK_STRAND
#Download CHECK_STRAND package
wget http://faculty.washington.edu/sguy/beagle/strand_switching/check_strands_16May11.tar.gz
#uncompress the package
tar -zxvf check_strands_16May11.tar.gz
#change directory
cd check_strands_16May11
chmod +xr $EZIMPUTER/CHECK_STRAND/check_strands_16May11/check_strands.py
python $EZIMPUTER/CHECK_STRAND/check_strands_16May11/check_strands.py > $EZIMPUTER/LOG/CHECK_STRAND.log 2>&1 
python $EZIMPUTER/CHECK_STRAND/check_strands_16May11/check_strands.py
if [ $? -ne 0 ]
    then
    echo "Unable to download beagle utils or python is not set to the path"
    tools_installed_ind=0
	tools_installed=$tools_installed" CHECK_STRAND_BEAGLE_UTILS"
fi
CHECK_STRAND="${EZIMPUTER}/CHECK_STRAND/check_strands_16May11/check_strands.py"
echo " "
echo " "
echo " "
echo " "

#PLINK 
echo "Checking for the Program plink v1.07exists in your PATH variable.If this version of program doesn't exist then it will be downloaded"
PLINK=`which plink`
checkcount=`$PLINK 2>&1|grep v1.07 |wc -l|cut -f1 -d ' '`
if [ $checkcount -lt 1 ]; then
	echo "Plink version v1.07 does not exist.So downloading the plink v1.07"
	#Create main plink directory
	mkdir $EZIMPUTER/PLINK
	#Change to plink main directory
	cd $EZIMPUTER/PLINK
	#Download the plink package
	wget http://pngu.mgh.harvard.edu/~purcell/plink/dist/plink-1.07-x86_64.zip
	#Uncompresszip files
	unzip plink-1.07-x86_64.zip
	#The plink binary is now in $EZIMPUTER/PLINK/plink-1.07-x86_64/plink
	# when you enter the path in the too info file, you must replace the value of
	# $EZIMPUTER with the actual path, e.g.
	chmod +xr $EZIMPUTER/PLINK/plink-1.07-x86_64/plink
	$EZIMPUTER/PLINK/plink-1.07-x86_64/plink > $EZIMPUTER/LOG/PLINK.log 2>&1 
	testp=`$EZIMPUTER/PLINK/plink-1.07-x86_64/plink | grep -c 'Purcell'`
	if [ $testp -eq 0 ]
		then
		echo "Error during plink installation"
		tools_installed_ind=0
		tools_installed=$tools_installed" PLINK"
	fi
	PLINK="${EZIMPUTER}/PLINK/plink-1.07-x86_64/plink"	
fi	
echo " "
echo " "
echo " "
echo " "

#STRUCTURE
echo "Checking for the Program STRUCTURE v2.3.4 exists in your PATH variable.If this version of program doesn't exist then it will be downloaded"
STRUCTURE=`which structure`
STRUCTURE_PARAM=`echo $STRUCTURE|sed 's/structure/extraparams/g'`
checkcount=`$STRUCTURE 2>&1|grep v2.3.4 |wc -l|cut -f1 -d ' '`
if [ $checkcount -lt 1 ]  || [ ! -f $STRUCTURE_PARAM ]
then
	echo "STRUCTURE version v2.3.4 does not exist or extra param file no in the path.So downloading the tool"
	#Create main STRUCTURE directory
	mkdir $EZIMPUTER/STRUCTURE
	#Change to STRUCTURE directory
	cd $EZIMPUTER/STRUCTURE
	#Download the STRUCTURE tool
	wget http://pritchardlab.stanford.edu/structure_software/release_versions/v2.3.4/release/structure_linux_console.tar.gz

	#uncompress the  package
	tar -zxvf structure_linux_console.tar.gz
	cd console/
	chmod +xr $EZIMPUTER/STRUCTURE/console/structure
	#Test the new executable
	echo "$EZIMPUTER/STRUCTURE/console/structure"
	$EZIMPUTER/STRUCTURE/console/structure > $EZIMPUTER/LOG/STRUCTURE.log 2>&1 
	testnew=`$EZIMPUTER/STRUCTURE/console/structure | grep -c 'STRUCTURE'`
	if [ $testnew -eq 0 ] 
	then
		echo "installation of STRUCTURE failed after compilation\n";
		tools_installed_ind=0
		tools_installed=$tools_installed" STRUCTURE"
	fi
	STRUCTURE="${EZIMPUTER}/STRUCTURE/console/structure"
	STRUCTURE_PARAM="${EZIMPUTER}/STRUCTURE/console/extraparams"
fi
echo " "
echo " "
echo " "
echo " "

#IMPUTE
echo "Checking for the Program IMPUTE2 v2.3.0 exists in your PATH variable.If this version of program doesn't exist then it will be downloaded"
IMPUTE=`which impute2`
checkcount=`$IMPUTE 2>&1|grep v2.3.1 |wc -l|cut -f1 -d ' '`
if [ $checkcount -lt 1 ]; then
	echo "IMPUTE2 version v2.3.1 does not exist.So downloading the tool"
	#Create main IMPUTE directory
	mkdir $EZIMPUTER/IMPUTE
	#Change to IMPUTE directory
	cd $EZIMPUTER/IMPUTE
	#Download IMPUTE tool package
	wget https://mathgen.stats.ox.ac.uk/impute/impute_v2.3.1_x86_64_static.tgz
	#Untar the downloaded package
	tar -zxvf impute_v2.3.1_x86_64_static.tgz
	#change directory 
	cd impute_v2.3.1_x86_64_static
	chmod +xr impute2
	./impute2 > $EZIMPUTER/LOG/IMPUTE.log 2>&1 
	#Try Impute
	itest=`./impute2 | grep -c 'IMPUTE'`
	#You should be able to see
	#======================
	# IMPUTE version 2.2.2
	#======================
	#
	#Copyright 2008 Bryan Howie, Peter Donnelly, and Jonathan Marchini
	#Please see the LICENCE file included with this program for conditions of use.
	#
	#The seed for the random number generator is 1997316289.
	#
	#Command-line input: impute2
	#
	#ERROR: You must specify a valid interval for imputation using the -int argument.

	if [ $itest -eq 0 ]
		then
		echo "Error during the impute installation"
		tools_installed_ind=0
		tools_installed=$tools_installed" IMPUTE"
	fi
	IMPUTE="${EZIMPUTER}/IMPUTE/impute_v2.3.1_x86_64_static/impute2"
fi


echo " "
echo " "
echo " "
echo " "


#(1)GPROBS
#Create main GPROBS directory
mkdir $EZIMPUTER/GPROBS
#Change to GPROBS directory
cd $EZIMPUTER/GPROBS
#Download GPROBS package
wget http://faculty.washington.edu/browning/beagle_utilities/gprobsmetrics.jar
chmod +xr $EZIMPUTER/GPROBS/gprobsmetrics.jar
java -jar $EZIMPUTER/GPROBS/gprobsmetrics.jar  -h >$EZIMPUTER/LOG/GPROBS.log 2>&1 
java -jar $EZIMPUTER/GPROBS/gprobsmetrics.jar  -h
if [ $? -ne 0 ]
    then
    echo "Unable to download gprobs or java is not set to the path"
    tools_installed_ind=0
	tools_installed=$tools_installed" GPROBS"
fi

GPROBS="${EZIMPUTER}/GPROBS/gprobsmetrics.jar"
echo " "
echo " "
echo " "
echo " "


#SHAPEIT
echo "Checking for the Program SHAPEIT v2.r790 exists in your PATH variable.If this version of program doesn't exist then it will be downloaded"
SHAPEIT=`which shapeit`
checkcount=`$SHAPEIT --v 2>&1|grep v2.3.4 |wc -l|cut -f1 -d ' '`
if [ $checkcount -lt 1 ]; then
	echo "SHAPEIT2 version v2.r778 does not exist.So downloading the tool"
	#Create main SHAPEIT directory
	mkdir $EZIMPUTER/SHAPEIT
	#Change to SHAPEIT directory
	cd $EZIMPUTER/SHAPEIT
	#Download SHAPEIT tool package
	 wget  https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.v2.r790.RHELS_5.4.static.tar.gz
	#timeout 20
	#if [ $? -eq 124 ]
	#	then
	#	echo "timeout occured while downloading shapeit tool, so copying the tool from local source"
	#	cp /data5/bsi/bioinf_int/s106381.borawork/naresh_scripts/PAPER/EasyImputer_v2/bin/TOOLS/SHAPEIT2/shapeit.v2.r727.linux.x64.tar.gz .
		
	#fi


	#Untar the downloaded package
	 tar -zxvf shapeit.*.tar.gz
	#Try SHAPEIT
	chmod +xr $EZIMPUTER/SHAPEIT/shapeit
	 $EZIMPUTER/SHAPEIT/shapeit >$EZIMPUTER/LOG/SHAPEIT.log 2>&1 
	$EZIMPUTER/SHAPEIT/shapeit

	if [ $? -eq 0 ]
		then
		echo "Unable to install shapeit"
		tools_installed_ind=0
		tools_installed=$tools_installed" SHAPEIT"
	fi
	SHAPEIT="${EZIMPUTER}/SHAPEIT/shapeit"
fi	
	
	
	
echo " "
echo " "
echo " "
echo " "

PERL=`which perl`
PYTHON=`which python`
JAVA=`which java`
QSUB=`which qsub`
SH=`which bash`
	
if [ $tools_installed_ind -eq 0 ]
then
	echo "Following tools not installed properly.Check the LOG directory in the install directory for more information"
	echo $tools_installed
fi

#CHECK_STRAND
if [ !  -f $CHECK_STRAND ]
    then
    echo "no CHECK_STRAND Program not found $CHECK_STRAND in the ${EZIMPUTER}/"
    exit 1	
fi

#plink
if [ !  -f $PLINK ]
    then
    echo "no plink found $PLINK"
    exit 1	
fi
if [ !  -x $PLINK ]
    then
    echo "plink found but it is not executable $PLINK.Pleasec give execute permissions"
    exit 1
fi

#structure
if [ !  -f $STRUCTURE ]
    then
    echo "no structure found $STRUCTURE"
    exit 1	
fi
if [ !  -x $STRUCTURE ]
    then
    echo "structure found but it is not executable $STRUCTURE"
    exit 1
fi
#structure param
if [ !  -f $STRUCTURE_PARAM ]
    then
    echo "no structure extraparam file found. $STRUCTURE_PARAM"
    exit 1	
fi

#impute
if [ !  -f $IMPUTE ]
    then
    echo "no impute found $IMPUTE"
    exit 1	
fi
if [ !  -x $IMPUTE ]
    then
    echo "impute found but it is not executable $IMPUTE"
    exit 1
fi


#GPROBS
if [ !  -f $GPROBS ]
    then
    echo "no GPROBS found $GPROBS"
    exit 1	
fi

#shapeit
if [ !  -f $SHAPEIT ]
    then
    echo "no shapeit found $SHAPEIT"
    exit 1	
fi
if [ !  -x $SHAPEIT ]
    then
    echo "shapeit found but it is not executable $SHAPEIT"
    exit 1
fi

#PERL
if [ !  -f $PERL ]
    then
    echo "no PERL found $PERL"
    exit 1	
fi
if [ !  -x $PERL ]
    then
    echo "PERL found but it is not executable $PERL"
    exit 1
fi
#PYTHON
if [ !  -f $PYTHON ]
    then
    echo "no PYTHON found $PYTHON"
    exit 1	
fi

#JAVA
if [ !  -f $JAVA ]
    then
    echo "no JAVA found $JAVA"
    exit 1	
fi
if [ !  -x $JAVA ]
    then
    echo "JAVA found but it is not executable $JAVA"
    exit 1
fi
#SH
if [ !  -f $SH ]
    then
    echo "no SH found $SH"
    exit 1	
fi
if [ !  -x $SH ]
    then
    echo "SH found but it is not executable $SH"
    exit 1
fi
echo "PLINK=${PLINK}" > $TOOLINFOFILE
echo "STRUCTURE=${STRUCTURE}" >> $TOOLINFOFILE
echo "STRUCTURE_PARAM=${STRUCTURE_PARAM}" >> $TOOLINFOFILE
echo "SHAPEIT=${SHAPEIT}" >> $TOOLINFOFILE
echo "IMPUTE=${IMPUTE}" >> $TOOLINFOFILE
echo "CHECK_STRAND=${CHECK_STRAND}" >> $TOOLINFOFILE
echo "GPROBS=${GPROBS}" >> $TOOLINFOFILE
echo "PERL=${PERL}" >> $TOOLINFOFILE
echo "PYTHON=${PYTHON}" >> $TOOLINFOFILE
echo "JAVA=${JAVA}" >> $TOOLINFOFILE
echo "QSUB=${QSUB}" >> $TOOLINFOFILE
echo "SH=${SH}" >> $TOOLINFOFILE

chmod -R 755 $EZIMPUTER/
else

echo "usage: install_tools.sh <Full path_to_install_directory> <PATH & NAME TO CREATE TOOL INFO FILE>"
fi

#Once you are done with downloading next step is to create the tool info config file (here). 
