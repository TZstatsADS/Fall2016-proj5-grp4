library(spam)
library(dplyr)
library('tm')
#install.packages("spam")
setwd("/Users/yifeihu/Documents/semester_3/applied_data_science/project_5/stock_news")

#train data set time
date<-read.csv("time.csv")

#2_gram word count (dictionary)
words_stem_2_count <-read.MM("stem_2gram.mtx")
words_stem_2_count<-as.matrix(words_stem_2_count)
stem_2_words<-read.csv("stem_2_gram_words.csv")
colnames(words_stem_2_count)<-as.character(t(stem_2_words))
rownames(words_stem_2_count)<-as.character(t(date))
number_2<-apply(words_stem_2_count,2, function(x) sum(x>=1))
data_2_new<-words_stem_2_count[,which(number_2>=10)]
save(data_2_new,file="data_2_new.RData")

#3_gram word count (dictionary)
words_stem_3_count <-read.MM("stem_3gram.mtx")
words_stem_3_count<-as.matrix(words_stem_3_count)
stem_3_words<-read.csv("stem_3_gram_words.csv")
colnames(words_stem_3_count)<-as.character(t(stem_3_words))
rownames(words_stem_3_count)<-as.character(t(date))
number_3<-apply(words_stem_3_count,2, function(x) sum(x>=1))
data_3<-words_stem_3_count[,which(number_3>=10)]
data_3_new<-data_3
save(data_3_new,file="data3_new.RData")

#test time
date_test<-read.csv("time_test_3.csv")


#2 gram test data set
test_2_count <-read.MM("test_2gram.mtx")
test_2_count<-as.matrix(test_2_count)
test_2_words<-read.csv("test_2_gram_words.csv")
colnames(test_2_count)<-as.character(t(test_2_words))
rownames(test_2_count)<-as.character(t(date_test))


#assign column for 2-gram
M_2<-matrix(0,nrow=nrow(test_2_count),ncol=ncol(data_2_new))
colnames(M_2)<-colnames(data_2_new)
rownames(M_2)<-rownames(test_2_count)

for(i in 1:ncol(M_2)){
  if (sum(colnames(M_2)[i]==colnames(test_2_count))==1){
    M_2[,i]<-test_2_count[,which(colnames(M_2)[i]==colnames(test_2_count))]   
  }
}

save(M_2,file="M_2.RData")


#3 gram test data set
test_3_count <-read.MM("test_3gram.mtx")
test_3_count<-as.matrix(test_3_count)
test_3_words<-read.csv("test_3_gram_words.csv")
colnames(test_3_count)<-as.character(t(test_3_words))
rownames(test_3_count)<-as.character(t(date_test))

#assign column for 3-gram
M_3<-matrix(0,nrow=nrow(test_3_count),ncol=ncol(data_3_new))
colnames(M_3)<-colnames(data_3_new)
rownames(M_3)<-rownames(test_3_count)
for(i in 1:ncol(M_3)){
  if (sum(colnames(M_3)[i]==colnames(test_3_count))==1){
    M_3[,i]<-test_3_count[,which(colnames(M_3)[i]==colnames(test_3_count))]   
  }
}

save(M_3,file="M_3.RData")

#for open_open data
da_new<-read.csv("DJIA_table.csv")
label<-vector()
for (i in 1:nrow(da_new)-1){
  label[i]<-da_new$Open[i]-da_new$Open[i+1]
}
label_rev<-label[c(length(label):1)]
label_train<-label_rev[1:1863]
label_test<-label_rev[1864:1988]
new_data_train<-cbind(label_train,data_3_new)
new_data_test<-cbind(label_test,M_3[-nrow(M_3),])

new_data_train_3<-as.data.frame(new_data_train)
new_data_test_3<-as.data.frame(new_data_test)
#train
for(i in 1:nrow(new_data_train_3)){
  if(new_data_train_3$label_train[i]>=0){
    new_data_train_3$label_train[i]=1
  }
  else{
    new_data_train_3$label_train[i]=0
  }
}
#test
for(i in 1:nrow(new_data_test_3)){
  if(new_data_test_3$label_test[i]>=0){
    new_data_test_3$label_test[i]=1
  }
  else{
    new_data_test_3$label_test[i]=0
  }
}
save(new_data_train_3,file="open_open_train.RData")
save(new_data_test_3,file="open_open_test.RData")


