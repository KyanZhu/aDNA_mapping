#!/bin/sh
# 2022.10.31
# Version : v3
# Author : KyanZhu


ref=$1
output_dir=$(dirname $(pwd))/mapDamage
samples_dir=$(dirname $(pwd))/Bamfiles
samples=$(ls -l ${samples_dir} | grep drwx | awk '{print $9}')
# mapDamage_plot=/home/KongyangZhu/sh/mapDamage/mapDamage_plot.R

mkdir -p ${output_dir} ; cd ${output_dir}
# for i in ${samples};do
#     mapDamage -i ${samples_dir}/${i}/${i}.mapped.bam -r ${ref} -n 200000 -t ${i} -d ${i}
# done > mapDamage.log 2>&1


# mapDamage post-processing
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
cp ${mapDamage_plot} ./
rm -f 3p.txt 5p.txt ; touch position.dtmp 
echo position >> position.dtmp
for i in {1..25};do echo ${i} >> position.dtmp ; done

for i in ${samples};do
    # 3pGtoA_freq.txt
    touch 3p_${i}.dtmp
    echo ${i} >> 3p_${i}.dtmp
    cat ${i}/3pGtoA_freq.txt | rmsp | cut -f 2 | tail -n+2 >> 3p_${i}.dtmp
    
    # 5pCtoT_freq.txt
    touch 5p_${i}.dtmp
    echo ${i} >> 5p_${i}.dtmp
    cat ${i}/5pCtoT_freq.txt | rmsp | cut -f 2 | tail -n+2 >> 5p_${i}.dtmp
done

paste position.dtmp 3p_*.dtmp > 3p.txt
paste position.dtmp 5p_*.dtmp > 5p.txt
rm *.dtmp
Rscript mapDamage_plot.R

for i in ${samples};do cp ${i}/Length_plot.pdf ./${i}.Length.pdf ; done
for i in ${samples};do cp ${i}/Fragmisincorporation_plot.pdf ./${i}.Damage.pdf ; done
pdfunite *.Damage.pdf Damage.pdf
pdfunite *.Length.pdf Length.pdf
zip mapDamage.zip *.pdf *.R *.sh *.txt


