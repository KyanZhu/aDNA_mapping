#!/bin/sh
# @Time : 2023/03/05 15:59
# @Author : KyanZhu
# @Version： V 1.5
# @File : mapping.parl.sh


parallel_thread=6
mapping_thread=20
output_dir=/home/KongyangZhu/data/12.shallow/2023.02.16
cut_bp=4  # trimBam settings: trim N BP from both ends of reads
text_message="20230216 aDNA mapping Done !"
mkdir -p ${output_dir}

# Source PATH
source $(pwd)/softsource.txt

# Parallel SETTINGS
input_dir=/home/KongyangZhu/data/12.shallow/2023.02.16/Rawdata
f_adaptor=AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNNATCTCGTATGCCGTCTTCTGCTTG
r_adaptor=GGAAGAGCGTCGTGTAGGGAAAGAGTGTNNNNNNNGTGTAGATCTCGGTGGTCGCCGTATCATT
samples=$(ls ${input_dir})
for sample in ${samples};do
    echo "sh mapping.sh ${output_dir} ${sample} \
    ${input_dir}/${sample}/${sample}_R1.fq.gz \
    ${input_dir}/${sample}/${sample}_R2.fq.gz \
    ${f_adaptor} ${r_adaptor} ${mapping_thread}"
done > mapping.parl


# Mapping
cat mapping.parl | parallel -j ${parallel_thread}

# Post-Processing
sh stats.sh
sh mapDamage.sh ${ref}
sh trimBam.sh ${cut_bp} ${parallel_thread}  # default: $1=4, $2=5
sh pileupCaller.sh ${ref}
cd ${output_dir}/pmdtools ; pdfunite *.pdf pmdtools.pdf ; zip pmdtools.zip *.pdf
mkdir -p ${output_dir}/Summary ; cd ${output_dir}/Summary ; cp ../pmdtools/*.zip ./ ; cp ../mapDamage/*.zip ./ ; cp ../pileupCaller/*.coverage ./ ; cp ../stats/*.xls ./
name=$(basename $(dirname $(pwd))).zip ; zip ${name} *
mv ${name} ../ ; rm * ; cd ../ ; rmdir Summary
notify ${text_message}
sh contaminate.parl.sh && notify "contaminate estimation Done !"
# sh preseq.sh  # preseq if need