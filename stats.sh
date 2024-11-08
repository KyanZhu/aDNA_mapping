#!/bin/sh
# coding:utf-8
# @Time : 2022/12/09 01:29
# @Author : KyanZhu
# @Version: 1.1
# @File : stats.sh


alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
samples_dir=$(dirname $(pwd))/Bamfiles
output_dir=$(dirname $(pwd))/stats
bc=$1
samples=$(ls -l ${samples_dir} | grep drwx | awk '{print $9}')
mkdir -p ${output_dir} ; cd ${output_dir}


# 1. aln.endogenous rate : endogenous rate before Dedup from Samtools flagstats
for i in ${samples};do
    echo -n -e "${i}\t"
    cat ${samples_dir}/${i}/${i}.aln.flagstats | grep mapped | grep % | head -n 1
done | sed 's/(//g' | awk '{print $1,$6}' | rmsp > aln.endogenous_rate.result

# 2. endogenous : endogenous rate after Dedup from Samtools flagstats
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.flagstats | grep mapped | grep % | head -n 1
done | sed 's/(//g' | awk '{print $5}' > endogenous_rate.result

# 3. duplication : duplication rate from Dedup log
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.duplication.txt | grep "Duplication Rate:" | awk '{print $3}'
done > duplication.result

# 4. library.length : average length of whole library (including unmapping reads) from Samtools stats
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.stats | grep "average length:" | awk '{print $4}'
done > library.length

# 5. mapped.length : average length of mapped reads only from Samtools stats
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.mapped.stats | grep "average length:" | awk '{print $4}'
done > mapped.length

# 6. mapped reads : mapped reads from Samtools stats
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.mapped.stats | grep "reads mapped:" | awk '{print $4}'
done > mapped.reads

# 7. mapped bases : mapped bases (cigar) from Samtools stats
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.mapped.stats | grep "bases mapped (cigar):" | awk '{print $5}'
done > mapped.bases

# 8. mapped MT reads : mapped reads from Samtools idxstats
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.mapped.idxstats | grep "MT" | awk '{print $3}'
done > mapped.MTreads

# 9. average quality : average quality of mapped bases
for i in ${samples};do
    cat ${samples_dir}/${i}/${i}.mapped.stats | grep "average quality:" | awk '{print $4}'
done > average.quality

# 10. Coverage : mapped bases/3095693981*100%
cov=$(cat mapped.bases)
for i in ${cov};do
    python ${bc} ${i}/3095693981*100
    echo "%"
done > mapped.coverage

# 11. #SNPs 1240k
rm -rf HO.snps 1240k.snps 2200.snps ; touch HO.snps 1240k.snps 2200.snps
for i in ${samples};do
    cat $(dirname $(pwd))/pileupCaller/HO.coverage    | grep -w ${i} | awk '{print $2}' >> HO.snps
    cat $(dirname $(pwd))/pileupCaller/1240k.coverage | grep -w ${i} | awk '{print $2}' >> 1240k.snps
    cat $(dirname $(pwd))/pileupCaller/2.2M.coverage  | grep -w ${i} | awk '{print $2}' >> 2200.snps
done

# 12. #gender
rm -rf Rx Ry; touch Rx Ry
for i in ${samples};do
    cat $(dirname $(pwd))/gender/samples.sex | grep -w ${i} | awk '{print $2}' >> Rx
    cat $(dirname $(pwd))/gender/samples.sex | grep -w ${i} | awk '{print $3}' >> Ry
done

# Summary
# Header
echo -e "Samples\t\
aln.endogenous\t\
endogenous\t\
duplication rate\t\
library.length\t\
mapped.length\t\
mapped reads\t\
mapped bases\t\
MT reads\t\
average quality\t\
coverage\t\
#SNPs HO\t\
#SNPs 1240k\t\
#SNPs 2.2M\t\
Rx\t\
Ry" > header.tmp

# Body
body="aln.endogenous_rate.result \
endogenous_rate.result \
duplication.result \
library.length \
mapped.length \
mapped.reads \
mapped.bases \
mapped.MTreads \
average.quality \
mapped.coverage \
HO.snps \
1240k.snps \
2200.snps \
Rx \
Ry"
paste ${body} > body.tmp

# Annotation
for i in "Annotation";do
    echo ""
    echo "# aln.endogenous : endogenous rate from Samtools flagstats (before Dedup)"
    echo "# endogenous : endogenous rate from Samtools flagstats (after Dedup)"
    echo "# duplication : duplication rate from Dedup log"
    echo "# library.length : average length of whole library (including unmapping reads) from Samtools stats"
    echo "# mapped.length : average length of reads mapped to human only from Samtools stats"
    echo "# mapped reads : mapped reads from Samtools stats"
    echo "# mapped bases : mapped bases (cigar) from Samtools stats"
    echo "# mapped MT reads : mapped reads from Samtools idxstats"
    echo "# average quality : average base quality of mapped bases"
    echo "# coverage : mapped bases/3095693981*100%"
    echo "# #SNPs HO : #SNPs coverage on HO"
    echo "# #SNPs 1240k : #SNPs coverage on 1240k"
    echo "# #SNPs 2.2M : #SNPs coverage on 2.2M"
    echo '# Rx : Sex assignment by Rx'
    echo '# Ry : Sex assignment by Ry'
done > annotation.tmp
cat header.tmp body.tmp annotation.tmp > Summary.xls ; rm *.tmp ${body}
