load(file.choose())
s<-colSums(words_count1)
quantile(s,c(0.05,0.95))
word1<-words_count1[,c(1289:33751)]
s1<-colSums(word1)


library(vars)

stopwords<-read.table(file.choose())
word_name<-colnames(word1)
c<-vector()
for(i in 1:length(word_name))
{ if(sum(stopwords==word_name[i])!=0)
  { c<-c(c,i)}}

word2<-word1[,-c]
combine_dija<-read.csv(file.choose(),header=T)
label_dija<-combine_dija$Label[1:1863]
data_dija<-cbind(as.factor(label_dija),word2)
colnames(data_dija)<-c("label_dija1",colnames(word2))

#lasso#
library(glmnet)
index_train<-sample(1863,0.8*1863)
index_test<-c(1:1863)[-index_train]
cv_glm<-cv.glmnet(word2[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=0)
fit_glm<-glmnet(word2[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=0,lambda=cv_glm$lambda.min)
yhat_lasso<-predict(fit_glm,word2[index_test,],type="response")
yhat<-ifelse(yhat_lasso>=0.5,1,0)
sum(yhat!=label_dija[index_test])/length(yhat)
write.csv(word2,"C:/Users/Owner/Desktop/ADS/Project5/word_simplify.csv")


#RM#
library(randomForest)
fit.rm<-randomForest(x=word2[index_train,],y=as.factor(label_dija[index_train]),mtry=179,ntree=100,importance=TRUE)
yhat.rm<-predict(fit.rm,newdata=word2[index_test,],type="response")
sum(yhat.rm!=label_dija[index_test])/length(yhat.rm)




#1+2-gram#
load("C:/Users/Owner/Desktop/ADS/Project5/no_number_no_stopwords_words_1_2_gram/no_number_no_stopwords_words_1_2_gram.RData")
data_1_2_gram<-words_1_2_no_stopwords_1
index_train<-sample(1863,0.8*1863)
index_test<-c(1:1863)[-index_train]
#RM#
library(randomForest)
fit.rm1<-randomForest(x=data_1_2_gram[index_train,],y=as.factor(label_dija[index_train]),mtry=137,ntree=100,importance=TRUE)
yhat.rm1<-predict(fit.rm1,newdata=data_1_2_gram[index_test,],type="response")
sum(yhat.rm1!=label_dija[index_test])/length(yhat.rm1)
#Ridge#
library(glmnet)
cv_glm1<-cv.glmnet(data_1_2_gram[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=0)
fit_glm1<-glmnet(data_1_2_gram[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=0,lambda=cv_glm1$lambda.min)
yhat_ridge1<-predict(fit_glm1,data_1_2_gram[index_test,],type="response")
yhat1<-ifelse(yhat_ridge1>=0.5,1,0)
sum(yhat1!=label_dija[index_test])/length(yhat1)


#Time series#
library(vars)
#top 100#
#colna_1_2<-colnames(data_1_2_gram)
label_djia_num<-read.csv("C:/Users/Owner/Desktop/ADS/Project5/data/DJIA_table.csv")
label_num<-label_djia_num$Adj.Close
data_top10<-data_1_2_gram[,order(colSums(data_1_2_gram),decreasing=T)[1:50]]
data_top10<-cbind(data_top10,label_num[1:1863])
var_top10<-VAR(data_top10,p=3,type="both")
yhat_top10<-predict(var_top10,n.ahead=10,ci=0.99)
yhat_top10_x<-yhat_top10$fcst$X[,1]
label_test<-label_num[1864:1873]
sqrt(sum((yhat_top10_x-label_test)^2))

#test loop#
test_top10<-vector(length=100)
for(i in 1:100)
{var_top10<-VAR(data_top10[c(1:(1863-i)),],p=3,type="both")
 yhat_top10<-predict(var_top10,n.ahead=1)
 yhat_top10_x<-yhat_top10$fcst$X[,1]
 label_test<-label_num[1864-i]
 test_top10[i]<-yhat_top10_x-label_test
}
mean(abs(test_top10))

test_top10<-read.csv(file.choose())
test_top10<-test_top10$x
order_top10<-1864-c(1:100)
di_1<-vector(length=100)
di_2<-vector(length=100)
for(i in 1:100)
{ temp<-label_num[order_top10[i]]-label_num[order_top10[i]-1]
  if(temp>=0)
  {di_1[i]<-1}
  else{di_1[i]<-0}
  temp2<-test_top10[i]-label_num[order_top10[i]-1]+label_num[order_top10[i]]
  if(temp2>=0)
  {di_2[i]<-1}
  else{di_2[i]<-0}
}
sum(di_1==di_2)/length(di_1)


#1-gram#
word_simpify<-read.csv("C:/Users/Owner/Desktop/ADS/Project5/word_simplify.csv")
word_simpify<-word_simpify[,-1]

#TF#
tf_sum<-rowSums(word_simpify)
tf_sum_mat<-diag(1/tf_sum)
tf<-tf_sum_mat%*%as.matrix(word_simpify)
write.csv(tf,"tf.csv")

#IDF#
idf<-vector(length=dim(word_simpify)[1])
sum_ind<-vector(length=dim(word_simpify)[1])
for(i in 1:length(sum_ind))
{sum_ind[i]<-sum(word_simpify[i,]!=0)+1}
for(i in 1:length(idf))
{idf[i]<-log(length(idf)/sum_ind[i])}
write.csv(idf,"idf.csv")

idf_mat<-diag(idf)
feature_new<-idf_mat%*%tf
feature_new<-feature_new[,-1]
write.csv(feature_new,"feature_tfidf.csv")

label<-label_num[1:1863]
index_train<-sample(1863,0.8*1863)
index_test<-c(1:1863)[-index_train]

#RM#
library(randomForest)
fit.rm1<-randomForest(x=data_2[index_train,],y=as.factor(label_dija[index_train]),mtry=53,ntree=100,importance=TRUE)
yhat.rm1<-predict(fit.rm1,newdata=data_2[index_test,],type="response")
sum(yhat.rm1!=label_dija[index_test])/length(yhat.rm1)

#Ridge#
library(glmnet)
cv_glm1<-cv.glmnet(data_2[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1)
fit_glm1<-glmnet(data_2[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1,lambda=cv_glm1$lambda.min)
yhat_ridge1<-predict(fit_glm1,data_2[index_test,],type="response")
yhat1<-ifelse(yhat_ridge1>=0.5,1,0)
sum(yhat1!=label_dija[index_test])/length(yhat1)


#LASSO#
cv_glm2<-cv.glmnet(feature_new[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1)
fit_glm2<-glmnet(feature_new[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1,lambda=cv_glm2$lambda.min)
yhat_lasso1<-predict(fit_glm2,feature_new[index_test,],type="response")
yhat2<-ifelse(yhat_lasso1>=0.5,1,0)
sum(yhat2!=label_dija[index_test])/length(yhat2)



#VAR#
library(vars)
var_t<-vector(length=dim(feature_new)[2])
for(i in 1:length(var_t))
{var_t[i]<-var(feature_new[,i])}
data_top<-feature_new[,order(var_t,decreasing=T)[1:50]]
data_top<-cbind(data_top,label)
var_top<-VAR(data_top,p=3,type="both")
yhat_top<-predict(var_top,n.ahead=1)
yhat_top_x<-yhat_top$fcst$label[,1]



#test loop#
test_top<-vector(length=100)
for(i in 1:100)
{var_top<-VAR(data_top[c(1:(1863-i)),],p=3,type="both")
yhat_top<-predict(var_top,n.ahead=1)
yhat_top_x<-yhat_top$fcst$label[,1]
label_test<-label_num[1864-i]
test_top[i]<-yhat_top_x-label_test
}
mean(abs(test_top))


order_top<-1864-c(1:100)
di_1<-vector(length=100)
di_2<-vector(length=100)
for(i in 1:100)
{ temp<-label_num[order_top[i]]-label_num[order_top[i]-1]
if(temp>=0)
{di_1[i]<-1}
else{di_1[i]<-0}
temp2<-test_top[i]-label_num[order_top[i]-1]+label_num[order_top[i]]
if(temp2>=0)
{di_2[i]<-1}
else{di_2[i]<-0}
}
sum(di_1==di_2)/length(di_1)



#random pick#
ind_top<-sample(c(1000:1863),100)
test_top<-vector(length=100)
for(i in 1:100)
{ var_temp<-vector(length=dim(feature_new)[2])
  for(j in 1:length(var_temp))
  { var_temp[j]<-var(feature_new[,j])}
 data_temp<-feature_new[,order(var_temp,decreasing=T)[1:20]]
 data_temp<-cbind(data_temp,label)
 var_top<-VAR(data_temp[c(1:ind_top[i]),],p=3,type="both")
 yhat_top<-predict(var_top,n.ahead=1)
 test_top[i]<-yhat_top$fcst$label[,1]
}
mean(abs(test_top-label_num[ind_top]))
d1<-vector(length=100)
d2<-vector(length=100)
for(i in 1:100)
{d1[i]<-ifelse(label_num[ind_top[i]]>=label_num[ind_top[i]-1],1,0)
 d2[i]<-ifelse(test_top[i]>=label_num[ind_top[i]-1],1,0)}
sum(d1==d2)/length(d1)
write.csv(cbind(test_top,d1,d2),"test_top20.csv")


#stemming#
load("C:/Users/Owner/Desktop/words_stem_1_no_stopwords.RData")
index_train<-sample(1863,0.8*1863)
index_test<-c(1:1863)[-index_train]
#RM#
library(randomForest)
fit.rm1<-randomForest(x=data_3[index_train,],y=label_dija[index_train],mtry=40,ntree=100,importance=TRUE)
yhat.rm1<-predict(fit.rm1,newdata=data_3[index_test,],type="response")
#d_rm<-vector(length=length(yhat.rm1))
#for(i in 1:length(d_rm))
#{d_rm[i]<-ifelse(yhat.rm1[i]>label_num[index_train[i]],1,0)}
yhat_rm<-ifelse(yhat.rm1>=0.5,1,0)
sum(yhat_rm==label_dija[index_test])/length(d_rm)
#Ridge#
library(glmnet)
cv_glm1<-cv.glmnet(data[index_train,],label_num[index_train],family="gaussian",alpha=0)
fit_glm1<-glmnet(data[index_train,],label_num[index_train],family="gaussian",alpha=0,lambda=cv_glm1$lambda.min)
yhat_ridge1<-predict(fit_glm1,data[index_test,],type="response")
d_ridge<-vector(length=length(yhat_ridge1))
for(i in 1:length(d_ridge))
{d_ridge[i]<-ifelse(yhat_ridge1[i]>label_num[index_train[i]],1,0)}
sum(d_ridge==label_dija[index_test])/length(d_ridge)
#LASSO#
cv_glm2<-cv.glmnet(data[index_train,],label_num[index_train],family="gaussian",alpha=1)
fit_glm2<-glmnet(data[index_train,],label_num[index_train],family="gaussian",alpha=1,lambda=cv_glm1$lambda.min)
yhat_lasso<-predict(fit_glm2,data[index_test,],type="response")
d_lasso<-vector(length=length(yhat_lasso))
for(i in 1:length(d_lasso))
{d_lasso[i]<-ifelse(yhat_lasso[i]>label_num[index_train[i]],1,0)}
sum(d_lasso==label_dija[index_test])/length(d_lasso)
#GBM#
library(gbm)
label<-label_num[1:1863][index_train]
data_train<-data.frame(data[index_train,],label)
data_test<-data.frame(data[index_test,])
fit_gbm<-gbm.fit(y=label,x=data[index_train,],distribution="gaussian",n.trees=100,interaction.depth=2)
yhat_gbm<-predict(fit_gbm,newdata=data[index_test,],n.trees=100)





##LASSO#
m<-vector(length=10)
for(i in 1:10)
{
index_train<-sample(1863,0.8*1863)
index_test<-c(1:1863)[-index_train]
cv_glm2<-cv.glmnet(data_2[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1)
fit_glm2<-glmnet(data_2[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1,lambda=cv_glm2$lambda.min)
yhat_lasso1<-predict(fit_glm2,data_2[index_test,],type="response")
yhat2<-ifelse(yhat_lasso1>=0.5,1,0)
m[i]<-sum(yhat2==label_dija[index_test])/length(yhat2)}


#GBM#
library(gbm)
n<-vector(length=10)
#for(i in 1:10)
#{
index_train<-sample(1863,0.8*1863)
index_test<-c(1:1863)[-index_train]
label_temp<-label_dija[index_train]
data_temp<-cbind(data_2[index_train,],label_temp)
fit_gbm<-gbm(label_temp~.,data=as.data.frame(data_temp),distribution="bernoulli",n.trees=100)
yhat_gbm<-predict(fit_gbm,newdata=as.data.frame(data_2[index_test,]),n.trees=100,type="response")
