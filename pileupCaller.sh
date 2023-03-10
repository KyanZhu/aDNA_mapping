#!/bin/sh
# @Time : 2023/03/06 12:13
# @Author : KyanZhu
# @Version : V 0.2
# @File : pileupCaller


alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'

ref=$1
samples_dir=$(dirname $(pwd))/trimbam
output_dir=$(dirname $(pwd))/pileupCaller
mkdir -p ${output_dir} ; cd ${output_dir}
bamfile=$(ls ${samples_dir}/*.trim.bam)
samples=""
bamfilein=""
panels="1240k 2.2M"
for i in ${bamfile};do
        bamfilein="${bamfilein} ${i}"
        samples=${samples},$(basename ${i} .trim.bam)
done
samples=${samples:1}
echo -e "samples:\n  $(echo ${samples} | sed 's/,/\n  /g')"
echo -e "bam input:\n  $(echo ${bamfilein} | sed 's/ /\n  /g')"

for pops in ${panels};do
    echo -n "Processing ${pops}: "
    ref_snp=/home/KongyangZhu/ref/map/${pops}.XY.snp
    ref_pos=/home/KongyangZhu/ref/map/${pops}.XY.pos
    samtools mpileup -R -B -q30 -Q30 -l ${ref_pos} \
        -f ${ref} \
        ${bamfilein} | \

    pileupCaller --randomHaploid --sampleNames ${samples} \
        -f ${ref_snp} \
        -e ${pops} > ${pops}.log 2>&1
    cat ${pops}.log | grep -v "#" | rmsp | cut -f 1,3 > ${pops}.coverage
done