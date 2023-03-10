pdf("mapDamage.pdf",width=20,height=20,useDingbats=FALSE)
layout(matrix(c(1,2,3,3),2,2,byrow=TRUE)) 
par(mar=c(3,3,3,3),pin=c(7,4))
data<-read.table("5p.txt",header= TRUE)
read_position <-data$position
library("ggsci")
plot(main="5pC->T",cex.main=1.5,read_position,read_position,xlab="Distance from 5' end of sequence read",ylab="Mismatch frequency",cex.axis=1,cex.lab=1.5,cex=3,type="n",ylim=c(0,0.50),xlim=c(0,max(read_position)))
sample_num <- ncol(data)-1
cols=pal_ucscgb(palette = c("default"), alpha =0.7)(ncol(data)) # 颜色不够
library(dplyr)
for(j in 2:(sample_num+1)){
lines(read_position,data%>%dplyr::pull(j),col=cols[j-1],lwd=2)} #col=cols[j-1]

data<-read.table("3p.txt",header= TRUE)
read_position <-data$position
plot(main="3pG->A",cex.main=1.5,read_position,read_position,xlab="Distance from 3' end of sequence read",ylab="",cex.axis=1,cex.lab=1.5,cex=3,yaxt="n",type="n",ylim=c(0,0.50),xlim=c(max(read_position),0))
axis(side=4)
mtext(4,text="Mismatch frequency",line = 2)
for(j in 2:(sample_num+1)){
lines(read_position,data%>%dplyr::pull(j),col=cols[j-1],lwd=2)} #col=cols[j-1]

sample_names <- colnames(data)
plot.new()
par(mar=c(1,1,1,1),pin=c(20,4))
legend("top",sample_names[-1],lty=1,lwd=2,col=cols,bty="b",cex=1.5,bg="white",ncol=6)

dev.off()
