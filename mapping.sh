#!/bin/sh
# @Time : 2023/03/05 15:59
# @Author : KyanZhu
# @Version：V 1.5
# @File : mapping.sh


# sh mapping.sh /PATH/TO/OUTPUT_DIR SAMPLE_NAME /PATH/TO/SAMPLE_R1.fq.gz /PATH/TO/SAMPLE_R2.fq.gz F_ADAPTOR R_ADAPTOR MAPPING_THREAD
# $1,2,3,4,5,6,7 = sample, output_dir, r1, r2, f_adaptor, r_adaptor, mapping_thread
output_dir=$1
sample=$2
fastq1=$3
fastq2=$4
RGID=${sample}
RGLB=LB
RGSM=${sample}
RGPL=Illumina
adapter_f=$5
adapter_r=$6
thread=$7

# Source PATH
source $(pwd)/softsource.txt

mkdir -p ${output_dir}/Bamfiles/${sample} ; cd ${output_dir}/Bamfiles/${sample}
echo =============$(basename ${fastq1})=============

# Cut Adaptor
${AdapterRemoval} \
--adapter1 ${adapter_f} \
--adapter2 ${adapter_r} \
--file1 ${fastq1} \
--file2 ${fastq2} \
--minlength 30 \
--trim3p 0 \
--preserve5p \
--trimns --trimqualities \
--collapse --threads ${thread} --gzip --basename ${sample}
rm -v *.truncated.gz *discarded.gz

# Fastqc
mkdir -p ${output_dir}/fastqc
${fastqc} -q -t ${thread} -o ${output_dir}/fastqc ${sample}.collapsed.gz

# bwa aln & samse
bwa aln -l 1024 -n 0.01 -t ${thread} ${reference} ${sample}.collapsed.gz > ${sample}.sai
bwa samse -r "@RG\tID:${RGID}\tLB:${RGLB}\tSM:${RGSM}\tPL:${RGPL}" ${reference} ${sample}.sai ${sample}.collapsed.gz | samtools view -Shb -o ${sample}.aln.bam -

# aln.flagstat
${samtools} flagstat -@ ${thread} ${sample}.aln.bam > ${sample}.aln.flagstats

# sort
${samtools} sort -@ ${thread} ${sample}.aln.bam  -o ${sample}.sort.bam  # ${sample}.sort.bam used for preseq
${samtools} index -@ ${thread} ${sample}.sort.bam
rm -v ${sample}.aln.bam

# mark duplication
${Dedup} -m -i ${sample}.sort.bam -o ./ > ${sample}.duplication.txt
${samtools} sort -@ ${thread} ${sample}.sort_rmdup.bam -o ${sample}.bam
rm -v ${sample}.sort_rmdup.bam

${samtools} index -@ ${thread} ${sample}.bam
${samtools} stats -@ ${thread} ${sample}.bam > ${sample}.stats
${samtools} flagstat -@ ${thread} ${sample}.bam > ${sample}.flagstats
${samtools} idxstats ${sample}.bam > ${sample}.idxstats
rm -v ${sample}.{sai,settings,sort.hist,sort.log}

# Extract mapped reads
sh mappedreads.sh ${sample}.bam ${thread}

# Sex Determination
sh ${rxy_dir}/sexRxy.sh ${sample}.mapped.bam .mapped.bam ${thread}

# MapDamage
mkdir -p ${output_dir}/mapDamage
mapDamage -i ${sample}.mapped.bam -r ${reference} -n 200000 -t ${sample} -d ${output_dir}/mapDamage/${sample}

# PMDtools
total=$(cat ${sample}.mapped.stats | grep "reads mapped:" | awk '{print $4}')
sub=$(python ${subbc} 500000/${total})  # subsample
mkdir -p ${output_dir}/pmdtools
samtools view -@ ${thread} ${sub} ${sample}.mapped.bam | python3 ${pmdtools}/pmdtools.0.60.py3 --platypus --requirebaseq 30 > ${sample}.pmd
Rscript ${pmdtools}/plotPMD.v2.edit.R ${sample}
mv ${sample}.{pmd,pdf} ${output_dir}/pmdtools