#! /bin/bash
#$ -q lg-mem
#$ -l h_vmem=15G
#$ -M prodduturi.naresh@mayo.edu
#$ -m abe
#$ -V
#$ -cwd
#$ -e XXX/sgelog
#$ -o XXX/sgelog
/usr/bin/perl /data5/bsi/bioinf_int/s106381.borawork/naresh_scripts/PAPER/ezimputer2/Phase_Impute_by_parallel_proc.pl  -run_config XXX -tool_config /data5/sicotte/naresh/ezimputer_5_1_2014/tool_info.config
