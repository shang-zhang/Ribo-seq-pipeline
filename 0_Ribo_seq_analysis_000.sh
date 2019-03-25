#!/usr/bin
##-*-coding:utf-8-*-

##-*-filename:0_Ribo_seq_analysis_000.sh
##-*-author:zhangshang-*-
##-*-version:1.0-*-
##-*-date:20190319-*-
##function:
##		pipeline for Ribo-seq data analysis


###################################head information############################
EXPECTED_ARGS=3
##srrFile必须以.sra作为后缀


if [ $# -ne $EXPECTED_ARGS ] ; then
	echo "Errors! Usage: $0 srrFile(endWith .sra) reference(mm10) analysisDir(notEndWith'/')"
	exit
fi

##frequently change paramaters
srrFile=$1
reference=$2
analysisDir=$3

##other prarmaters
##TODO adt=`cat $path1/adaptor/$sig`       ##需要修改路径

################################Local variable###################################
STARindex=

#################################SRA data download and convert to fastq#############################
echo "--------BEGIN: downloading $srrFile and convert_to_fastq-------------"
mkdir $analysisDir/SRR_Raw_file $analysisDir/fastq_Raw
prefetch -c $srrFile -O $analysisDir/SRR_Raw_file;fastq-dump $analysisDir/SRR_Raw_file/$srrFile -O $analysisDir/fastq_Raw
echo "--------FINISH: download and convert $srrFile, please check------"


seqFilePrefix=${srrFile%.sra}
##########################QC-cutadapter-QC############################
echo "--------BEGIN: QC-cutadapter-QC---------------"
## 使用fastQC对raw data做质控
mkdir $analysisDir/rawQC $analysisDir/fastq_clean $analysisDir/cleanQC
##fastqc -o $analysisDir/rawQC -t 8 -f fastq $analysisDir/fastq_Raw/${srrFile}_R1.f*q* $seqDir/${seqName}_R2.f*q*    ##针对双端测序
fastqc -o $analysisDir/rawQC -t 8 -f fastq $analysisDir/fastq_Raw/${srrFilePrefix}.f*q*      ##针对单端测序
fastx_clipper -Q33 -a $adt -l 25 -c -n -v -i $analysisDir/fastq_Raw/${srrFilePrefix}.f*q* > $analysisDir/fastq_clean/${srrFilePrefix}.1.fastq;
fastqc -o $analysisDir/cleanQC -t 8 -f fastq $analysisDir/fastq_clean/${srrFilePrefix}.1.fastq      ##针对单端测序
fastx_trimmer -Q33 -f 2 -l 36 -i $analysisDir/fastq_clean/${srrFilePrefix}.1.fastq > $analysisDir/fastq_clean/${srrFilePrefix}.fastq
fastqc -o $analysisDir/cleanQC -t 8 -f fastq $analysisDir/fastq_clean/${srrFilePrefix}.fastq
echo "--------FINISH: QC-cutadapt-QC finish, please check--------"


##########################STAR mapping#############################
##1. mapping to rRNA
echo "--------BEGIN: mapping to rRNA---------"
STAR --genomeDir
##2. mapping to genome
