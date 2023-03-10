#bin/bash


# coding:utf-8
# @Time : 2022/09/26 15:49
# @Version: v8
# @File : contaminate.sh
# @Author : zky

if [[ "$1" == "" ]]; then
	echo 'contaminate.sh $bamfile $sample $outputdir XY/XX'
else
	bamfile=$1
	sample=$2
	outputdir=$3
	bamdir=$(dirname ${bamfile})
	prefix=$(basename ${bamfile} .bam)
	mt_bam=${bamdir}/${prefix}'_MT.bam'
	md_bam=${bamdir}/${prefix}'_MT.MD.bam'
	an=/home/administrator/miniconda3/bin/angsd
	sch=/home/administrator/bin/schmutzi
	ref=/home/KongyangZhu/ref/hs37d5/hs37d5_MT.fa
	HapMap=/home/administrator/data/angsd/RES/HapMapChrX.gz
	mtref=eurasian  # mtref=197
	logfile=${outputdir}/${sample}/${sample}.log
	mkdir -p ${outputdir}/${sample}
	thread=5

	# create index if no exist
	if [ ! -f ${bamfile}'.bai' ];then
		echo creating index | tee ${logfile}
		samtools index -@ ${thread} ${bamfile}
		echo create index done | tee ${logfile}
	fi
	# create MT.bam
	cd ${bamdir}
	echo
	echo Creating _MT.bam
	TEMP=${prefix}.tmp.sam
	HEADER=${prefix}.head
	samtools view -H ${bamfile} > ${HEADER}
	cat ${HEADER} | grep '@HD' > ${TEMP}
	cat ${HEADER} | grep 'SN:MT' >> ${TEMP}
	cat ${HEADER} | grep '@PG' >> ${TEMP}
	samtools view -@ ${thread} ${bamfile} MT >> ${TEMP}
	samtools view -@ ${thread} -bS ${TEMP} > ${mt_bam}
	samtools index -@ ${thread} ${mt_bam}
	rm ${HEADER}
	rm ${TEMP}
	echo create ${mt_bam} DONE... | tee ${logfile}

	# calmd MD.tag
	samtools calmd -@ ${thread} -b ${mt_bam} ${ref} > ${md_bam} 2>/dev/null
	samtools index -@ ${thread} ${md_bam}
	echo create ${md_bam} DONE... | tee -a ${logfile}
	echo | tee -a ${logfile}

	# schmutzi_contDeam
	echo schmutzi_contDeam | tee -a ${logfile}
	cd ${outputdir}/${sample}
	nohup ${sch}/src/contDeam.pl --library double --out ${outputdir}/${sample}/${sample} ${md_bam} > ${outputdir}/${sample}/contDeam.log
	echo contDeam DONE...
	echo 'logfile --> '"${outputdir}/${sample}: contDeam.log" | tee -a ${logfile}
	echo 'result --> '"${outputdir}/${sample}: ${sample}.cont"'*' | tee -a ${logfile}
	echo | tee -a ${logfile}

	# schmutzi_schmutzi
	echo schmutzi_schmutzi | tee -a ${logfile}
	nohup ${sch}/src/schmutzi.pl --t ${thread} --uselength --ref ${ref} ${outputdir}/${sample}/${sample} ${sch}/share/schmutzi/alleleFreqMT/${mtref}/freqs/ ${md_bam} > schmutzi.log
	echo schumutzi DONE...
	echo 'logfile --> '"${outputdir}/${sample}: schmutzi.log" | tee -a ${logfile}
	echo 'result --> '"${outputdir}/${sample}: ${sample}_final.cont"'*' | tee -a ${logfile}
	echo | tee -a ${logfile}

	# angsd_angsd
	if [[ "$4" == "XX" ]];then
		echo skip angsd analysis
	else
		echo angsd_angsd | tee -a ${logfile}
		cd ${outputdir}/${sample}; mkdir -p angsd; cd angsd
		nohup angsd -i ${bamfile} -r X:5000000-154900000 -doCounts 1 -iCounts 1 -minMapQ 30 -minQ 30 -out ${sample} > angsd.log
		echo angsd_angsd DONE... | tee -a ${logfile}
		echo 'logfile --> '"${outputdir}/${sample}/angsd: angsd.log" | tee -a ${logfile}
		echo | tee -a ${logfile}

		# angsd_contamination
		echo angsd_contamination | tee -a ${logfile}
		nohup contamination -a ${outputdir}/${sample}/angsd/${sample}.icnts.gz -h ${HapMap} 2> ${sample}.angsd.contamination.out
		echo angsd_contamination DONE... | tee -a ${logfile}
		echo 'result --> '"${outputdir}/${sample}/angsd: angsd.contamination.out" | tee -a ${logfile}
		echo | tee -a ${logfile}
	fi
fi

