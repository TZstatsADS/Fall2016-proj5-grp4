#retrain#
library(vars)
feature_new<-read.csv(file.choose())#feature_tfidf#
feature_new<-feature_new[,-c(1,2)]
label_djia_num<-read.csv(file.choose())#DJIA_table#
label_num<-label_djia_num$Adj.Close
label<-label_num[1:1863]
m1<-vector(length=10)
n1<-vector(length=10)
for(k in 1:10)
{ind_top<-sample(c(1000:1863),100)
 test_top<-vector(length=100)
 for(i in 1:100)
 { var_temp<-vector(length=dim(feature_new)[2])
   for(j in 1:length(var_temp))
   { var_temp[j]<-var(feature_new[c(1:ind_top[i]),j])}
   data_temp<-feature_new[,order(var_temp,decreasing=T)[1:20]]
   data_temp<-cbind(data_temp,label)
   var_top<-VAR(data_temp[c((ind_top[i]-100):ind_top[i]),],p=3,type="both")
   yhat_top<-predict(var_top,n.ahead=1)
   test_top[i]<-yhat_top$fcst$label[,1]
 }
 m1[k]<-mean(abs(test_top-label_num[ind_top]))
 d1<-vector(length=100)
 d2<-vector(length=100)
 for(i in 1:100)
 {d1[i]<-ifelse(label_num[ind_top[i]+1]>=label_num[ind_top[i]],1,0)
 d2[i]<-ifelse(test_top[i]>=label_num[ind_top[i]],1,0)}
 n1[k]<-sum(d1==d2)/length(d1)
}
