#!/bin/sh
# 2022.10.29
# Version : v3
# Author : KyanZhu
# File : sexRxy

# use sh sexRxy.sh /PATH/TO/SAMPLE.BAM SUFFIX THREAD

bamfile=$1
suffix=$2
thread=$3
rxy_dir=$4
# rxy_dir=/home/KongyangZhu/sh/sex_determination/

output=$(basename ${bamfile} ${suffix})
samtools view -@ ${thread} -q 30 -b ${bamfile} > ${output}_q30.bam
samtools index -@ ${thread} ${output}_q30.bam
samtools idxstats ${output}_q30.bam > ${output}_q30.idxstats
Rscript ${rxy_dir}/Rx_compute.r ${output}_q30 > ${output}_Rx.sex
grep Male ${output}_Rx.sex
grep Female ${output}_Rx.sex
samtools view -@ ${thread} ${output}_q30.bam | python3 ${rxy_dir}/ry_compute.py3 > ${output}_Ry.sex
echo ==========  Rx  ========= > ${output}.sex
cat ${output}_Rx.sex >> ${output}.sex
echo ==========  Ry  ========== >> ${output}.sex
cat ${output}_Ry.sex >> ${output}.sex
grep XY ${output}_Ry.sex
grep XX ${output}_Ry.sex
rm ${output}_Rx.sex
rm ${output}_Ry.sex
rm ${output}_q30.bam
rm ${output}_q30.idxstats
rm ${output}_q30.bam.bai

