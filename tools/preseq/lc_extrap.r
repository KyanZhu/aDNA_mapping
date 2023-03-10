library(reshape2)
library(ggplot2)



df2 <- read.table("lc_extrap.result", header=TRUE)
df2 <- df2[1:400,]
df2 <- melt(df2, id="TOTAL_READS")
epsilon <- 1000
ggplot() +
  
  geom_line(aes(x=df2$TOTAL_READS/epsilon,y=df2$value/epsilon,color=df2$variable), linetype=2, show.legend = TRUE) +
  
  xlab("Read depth (K)") +
  ylab("Unique fragments (K)") +
  theme(legend.title = element_blank())

ggsave("lc_extrap.pdf",width=11,height=10)
