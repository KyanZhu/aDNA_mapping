#!/bin/sh
# @Time : 2023/03/06 12:13
# @Author : KyanZhu
# @Version : V 0.2
# @File : trimBam


cut_bp=4 ; if [ -n "$1" ]; then  cut_bp=$1 ; fi  # $1 set #BP trimmed from both ends, default=4bp
thread_parl=5 ; if [ -n "$2" ]; then  thread_parl=$2 ; fi  # $2 set multi-processing cores, default=5
thread=5
samples_dir=$(dirname $(pwd))/Bamfiles
output_dir=$(dirname $(pwd))/trimbam
samples=$(ls -l ${samples_dir} | grep drwx | awk '{print $9}')
mkdir -p ${output_dir} ; cd ${output_dir}
files=$(ls ${samples_dir}/*/*.mapped.bam)
parallel -j ${thread_parl} bam trimBam ${samples_dir}/{1}/{1}.mapped.bam {1}.trim.bam ${cut_bp} ";" \
                           samtools index -@ ${thread} {1}.trim.bam ::: ${samples}