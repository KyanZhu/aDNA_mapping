#!/bin/sh
# 2022.10.31
# Version : v1
# Author : KyanZhu
# Files : gender.sh


samples_dir=$(dirname $(pwd))/Bamfiles
output_dir=$(dirname $(pwd))/gender
samples=$(ls -l ${samples_dir} | grep drwx | awk '{print $9}')

mkdir -p ${output_dir} ; cd ${output_dir}
echo -e "Samples\tRx\tRy" > samples.sex
for i in ${samples};do
    # sample
    echo -n -e "${i}\t"
    # Rx
    Rx=$(cat ${samples_dir}/${i}/${i}.sex | grep "== Ry ==" -B 100)
    echo ${Rx} | grep -q -E 'should be assigned as Female|consistent with XX' ; if [ $? -eq 0 ];then echo -n -e "F\t" ; fi
    echo ${Rx} | grep -q -E 'should be assigned as Male|consistent with XY' ; if [ $? -eq 0 ];then echo -n -e "M\t" ; fi
    echo ${Rx} | grep -q -E 'could not be assigned' ; if [ $? -eq 0 ];then echo -n -e "NA\t" ; fi
    Ry=$(cat ${samples_dir}/${i}/${i}.sex | grep "== Ry ==" -A 100 | sed "s/but not XY//g" | sed "s/but not XX//g")
    echo ${Ry} | grep -q -E 'XX' ; if [ $? -eq 0 ];then echo -n -e "F\t" ; fi
    echo ${Ry} | grep -q -E 'XY' ; if [ $? -eq 0 ];then echo -n -e "M\t" ; fi
    echo ${Ry} | grep -q -E 'Not Assigned' ; if [ $? -eq 0 ];then echo -n -e "NA\t" ; fi
    echo ""
done >> samples.sex