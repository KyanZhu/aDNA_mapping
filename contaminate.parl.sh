#!/bin/sh


thread=5
contam=$1
samples_dir=$(dirname $(pwd))/Bamfiles
output_dir=$(dirname $(pwd))/contamination
samples=$(ls -l ${samples_dir} | grep drwx | awk '{print $9}')
mkdir -p ${output_dir} ; cd ${output_dir} ; cp ${contam} ./
for i in ${samples};do
    echo "sh contaminate.sh ${samples_dir}/${i}/${i}.bam ${i} ${output_dir} XY"
done > contaminate.parl
cat contaminate.parl | parallel -j ${thread}
