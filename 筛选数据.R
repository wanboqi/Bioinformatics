rm(list=ls())
setwd("C:/Users/12149/Desktop")

raw_data = 'C:/Users/12149/Desktop/big.csv'
select_data = 'C:/Users/12149/Desktop/small.csv'
raw_data <- read.csv(raw_data,header = T)
select_data <- read.csv(select_data,header = F)
colnames(raw_data)[1] = c("index")
colnames(select_data)[1] = c("index")
filter_data = merge(raw_data,select_data,by="index") # merge()相当于excel的VLoolup
rownames(filter_data) <- make.names(filter_data[,1])
filter_data <- filter_data[,-1]
write.csv(filter_data,"filter_data.csv")
