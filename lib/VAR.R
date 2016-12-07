#retrain#
#TF_IDF#
tf_sum<-rowSums(data)
tf_sum_mat<-diag(1/tf_sum)
tf<-tf_sum_mat%*%as.matrix(data)
#write.csv(tf,"tf.csv")

#IDF#
idf<-vector(length=dim(data)[1])
sum_ind<-vector(length=dim(data)[1])
for(i in 1:length(sum_ind))
{sum_ind[i]<-sum(data[i,]!=0)+1}
for(i in 1:length(idf))
{idf[i]<-log(length(idf)/sum_ind[i])}
#write.csv(idf,"idf.csv")

idf_mat<-diag(idf)
feature_new<-idf_mat%*%tf
#feature_new<-feature_new[,-1]
#write.csv(feature_new,"feature_tfidf.csv")
library(vars)
#feature_new<-read.csv(file.choose())#feature_tfidf#
#feature_new<-feature_new[,-c(1,2)]
#label_djia_num<-read.csv(file.choose())#DJIA_table#
#label_num<-label_djia_num$Adj.Close
data_ad<-data_3_new
label<-label_num[1:1863]
m1<-vector(length=10)
n1<-vector(length=10)
for(k in 1:10)
{ind_top<-sample(c(500:1863),100)
 test_top<-vector(length=100)
 for(i in 1:100)
 { var_temp<-vector(length=dim(data_ad)[2])
   for(j in 1:length(var_temp))
   { var_temp[j]<-var(data_ad[c(1:ind_top[i]),j])}
   data_temp<-data_ad[,order(var_temp,decreasing=T)[1:20]]
   data_temp<-cbind(data_temp,label)
   var_top<-VAR(data_temp[c(1:ind_top[i]),],p=3,type="both")
   yhat_top<-predict(var_top,n.ahead=1)
   test_top[i]<-yhat_top$fcst$label[,1]
 }
 m1[k]<-mean(abs(test_top-label_num[ind_top]))
 d1<-vector(length=100)
 d2<-vector(length=100)
 for(i in 1:100)
 {d1[i]<-ifelse(label_num[ind_top[i]+1]>label_num[ind_top[i]],1,0)
 d2[i]<-ifelse(test_top[i]>label_num[ind_top[i]],1,0)}
 n1[k]<-sum(d1==d2)/length(d1)}


#predict all at once#
var_all<-vector(length=dim(data)[2])
for(i in 1:length(var_all))
{ var_all[i]<-var(data[,i])}
data_all<-data[,order(var_all,decreasing=T)[1:100]]
data_all<-cbind(data_all,label)
var_all<-VAR(data_all,p=3,type="both")
yhat_all<-predict(var_all,n.ahead=100)
yhat_all_once<-yhat_all$fcst$label[,1]
d1_all<-vector(length=100)
d2_all<-vector(length=100)
for(i in 1:100)
{d1_all[i]<-ifelse(label_num[1863+i]>label_num[1862+i],1,0)
d2_all[i]<-ifelse(yhat_all_once[i]>label_num[1862+i],1,0)}
sum(d1==d2)/length(d1)



#VAR plot#

data_temp<-rbind(data_3_new,M_3)
data_temp_all<-cbind(data_temp,label_num)
upper<-vector(length=126)
lower<-vector(length=126)
y.predict<-vector(length=126)
for(i in 1:126)
{  
#var_temp<-vector(length=dim(data_temp)[2])
#for(j in 1:length(var_temp))
#{ var_temp[j]<-var(data_temp[c(1:1862+i),j])}
#var_top<-VAR(data_temp[c(1:1862+i),order(var_temp,decreasing=T)[1:10]],p=2,type="both")
data_pca<-prcomp(t(data_temp[c(1:(1862+i)),]))$rotation[,c(1:10)]
data_use<-cbind(data_pca,label_num[1:(1862+i)])
var_top<-VAR(data_use,p=2,type="both")
yhat_top<-predict(var_top,n.ahead=1,ci=0.95)
upper[i]<-yhat_top$fcst$X[1,3]
lower[i]<-yhat_top$fcst$X[1,2]
y.predict[i]<-yhat_top$fcst$X[1,1]
}
date<-rownames(M_3)
value_true<-label_num[1864:1989]
y.pred<-data.frame(date,value_true,upper,lower,y.predict)
y.pred$date<-as.Date(y.pred$date,format="%Y-%m-%d")
library(ggplot2)
ggplot(y.pred, aes(date)) + 
  geom_line(aes(y = value_true, colour = "True value")) + 
  #geom_line(aes(y = upper, colour = "var1"))+
  #geom_line(aes(y = lower, colour = "var1"))+
  geom_line(aes(y = y.predict, colour = "Predict value"))+
  ylab("Daily Adj Close Index")+ggtitle("VAR model(3 grams) Prediction of Adj Close Index")

#distance#
value_true_dis<-vector(length=125)
for(i in 1:125)
{value_true_dis[i]<-value_true[i+1]-value_true[i]}
pred.dis<-vector(length=125)
for(i in 1:125)
{pred.dis[i]<-y.predict[i+1]-value_true[i]}
v<-ifelse(value_true_dis>=0,1,0)
p<-ifelse(pred.dis>=0,1,0)


ggplot(df,aes(FPR,TPR,color=GeneSet))+geom_line(size = 2, alpha = 0.7)+
  labs(title= "ROC curve", 
       x = "False Positive Rate (1-Specificity)", 
       y = "True Positive Rate (Sensitivity)")