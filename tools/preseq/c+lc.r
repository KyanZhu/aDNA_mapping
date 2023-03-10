library(reshape2)
library(ggplot2)

df1 <- read.table("c_curve.result", header=TRUE)  # 300 lines
df1 <- melt(df1, id="TOTAL_READS")

df2 <- read.table("lc_extrap.result", header=TRUE)
df2 <- df2[1:200,]
df2 <- melt(df2, id="TOTAL_READS")
epsilon <- 1000
ggplot() +
  
  geom_line(aes(x=df2$TOTAL_READS/epsilon,y=df2$value/epsilon,color=df2$variable), linetype=2, show.legend = TRUE) +
  geom_line(aes(x=df1$TOTAL_READS/epsilon,y=df1$value/epsilon,color=df1$variable), linetype=1, show.legend = TRUE) + 
  
  xlim(0,2000) + 
  ylim(0,1920) +
  xlab("Read depth (K)") +
  ylab("Unique fragments (K)") +
  theme(legend.title = element_blank())

ggsave("summary.pdf",width=11,height=10)
