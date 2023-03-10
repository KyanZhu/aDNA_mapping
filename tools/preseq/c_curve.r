# Date: 2023.3.6
# Author: KyanZhu
# Version: v1.2
library(reshape2)
library(ggplot2)
library(dplyr)
library(magrittr)

df1 <- read.table("c_curve.result",header=TRUE)
df1 <- df1[1:300,]
df1 <- melt(df1,id="TOTAL_READS")
df1 <- na.omit(df1)
epsilon <- 1000

ggplot(data=df1,aes(x=TOTAL_READS/epsilon,y=value/epsilon,color=variable))+
  geom_line(linetype = 1) + 
  xlab("Read depth (K)") +
  ylab("Unique fragments (K)") +
  theme(legend.title = element_blank()) +

# 添加样本标签
  geom_text(data=df1 %>% group_by(variable) %>% summarize(TOTAL_READS=max(TOTAL_READS/epsilon), value=max(value/epsilon)),
          aes(x=TOTAL_READS, y=value, label=variable),
          nudge_x = 0.5, hjust = 0, vjust = -0.5, size=3.5, show.legend = FALSE)

ggsave("c_curve.pdf",width=12,height=10)
