li=$(ls Rawdata)
for i in ${li};do
    mkdir -p Cut1/${i}
    echo "trimmomatic SE -threads 10 -phred33 -trimlog /dev/null  Rawdata/${i}/${i}_R1.fq.gz    Cut1/${i}/${i}_R1.fq.gz  HEADCROP:1"
    echo "trimmomatic SE -threads 10 -phred33 -trimlog /dev/null  Rawdata/${i}/${i}_R2.fq.gz    Cut1/${i}/${i}_R2.fq.gz  HEADCROP:1"
done | parallel
