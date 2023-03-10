#!/bin/sh
# @Time : 2022/10/28 15:59
# @Author : cewinhot
# @Version：V 0.3
# @File : MappedReads.sh


bam=$1
thread=5 ; if [ -n "$2" ]; then  thread=$2 ; fi
sample=$(basename ${bam} .bam)
merge=""
samtools view -@ ${thread} -F0x4 -b ${bam} > ${sample}.map.bam
samtools index -@ ${thread} ${sample}.map.bam
for i in {1..22} X Y MT ;do
    samtools view -@ ${thread} -b ${sample}.map.bam ${i} > ${sample}.${i}.bam
    merge=${merge}" ${sample}.${i}.bam"
done
samtools merge -p -c -@ ${thread} ${sample}.mapped.bam ${merge}
samtools index       -@ ${thread} ${sample}.mapped.bam
samtools idxstats    -@ ${thread} ${sample}.mapped.bam > ${sample}.mapped.idxstats
samtools stats       -@ ${thread} ${sample}.mapped.bam > ${sample}.mapped.stats
samtools flagstat    -@ ${thread} ${sample}.mapped.bam > ${sample}.mapped.flagstats
rm ${sample}.map.bam ${sample}.map.bam.bai
rm ${merge}
