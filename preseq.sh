#!/bin/sh


samples_dir=$(dirname $(pwd))/Bamfiles
output_dir=$(dirname $(pwd))/preseq
# preseq_sh=/home/KongyangZhu/sh/preseq
samples=$(ls -l ${samples_dir} | grep drwx | awk '{print $9}')

mkdir -p ${output_dir} ; cd ${output_dir}
for i in ${samples};do
    preseq c_curve   -B              -s 100000 ${samples_dir}/${i}/${i}.sort.bam -o ${output_dir}/${i}.c.txt  # -s step size, -B bam, -e maximum extrapolation
    preseq lc_extrap -B -e 100000000 -s 100000 ${samples_dir}/${i}/${i}.sort.bam -o ${output_dir}/${i}.lc.txt
done > preseq.log 2>&1

# c_curve post-processing
maxline=$(wc -l *txt  | sort -r | head -n 2 | tail -n 1 | awk '{print $1}')
maxfile=$(wc -l *txt  | sort -r | head -n 2 | tail -n 1 | awk '{print $2}')
for i in *.c.txt;do
    name=$(basename ${i} .c.txt)
    sed -i "s/distinct_reads/${name}/g" ${i}
    for j in $(seq 1 ${maxline});do echo "NA NA" >> ${i} ; done  # padding NA
done
cat ${maxfile} | awk '{print $1}' | sed "s/total_reads/TOTAL_READS/g" > tmp1
for i in *.c.txt;do
    cat ${i} | awk '{print $2}' > ${i}.tmp2
done
paste tmp1 *tmp2 > tmp3
head -n ${maxline} tmp3 > c_curve.result
rm tmp1 *tmp2 tmp3

# lc_extrap post-processing
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
li=$(ls *.lc.txt)
cat $(echo ${li} | rmsp | cut -f 1) | rmsp | cut -f 1 > tmp1
for i in ${li};do
    name=$(basename ${i} .lc.txt)
    cat ${i} | rmsp | cut -f 2 | sed "s/EXPECTED_DISTINCT/${name}/g" > ${name}.tmp2
done
paste tmp1 *tmp2 | rmsp > lc_extrap.result
rm tmp1 *tmp2
cp ${preseq_sh}/*.r ./
Rscript c_curve.r
notify preseq done