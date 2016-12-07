#TPR & FPR#
library(randomForest)
library(glmnet)
library(gbm)
library(ggplot2)
data_all_in<-rbind(data_3_new,M_3)
label_dija<-combine_dija$Label
#label<-label_num
TPR_RM<-vector(length=50)
FPR_RM<-vector(length=50)
TPR_LASSO<-vector(length=50)
FPR_LASSO<-vector(length=50)
TPR_GBM<-vector(length=50)
FPR_GBM<-vector(length=50)

for(i in 1:50)
{
#RM# 
index_train<-sample(1989,1989*0.8)
index_test<-c(1:1989)[-index_train]
var_temp<-vector(length=dim(data_all_in)[2])
for(j in 1:length(var_temp))
{ var_temp[j]<-var(data_all_in[index_train,j])}
data_all<-data_all_in[,order(var_temp,decreasing=T)[1:10]]
fit.rm<-randomForest(x=data_all[index_train,],y=as.factor(label_dija[index_train]),mtry=3,ntree=100,importance=TRUE)
yhat.rm<-predict(fit.rm,newdata=data_all[index_test,],type="response")
TPR_RM[i]<-sum(yhat.rm==1&label_dija[index_test]==1)/sum(yhat.rm==label_dija[index_test])
FPR_RM[i]<-sum(yhat.rm==1&label_dija[index_test]==0)/sum(yhat.rm!=label_dija[index_test])
#LASSO#
cv_lasso<-cv.glmnet(data_all[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1)
fit_lasso<-glmnet(data_all[index_train,],as.factor(label_dija[index_train]),family="binomial",alpha=1,lambda=cv_lasso$lambda.min)
yhat_lasso<-predict(fit_lasso,data_all[index_test,],type="response")
yhat.lasso<-ifelse(yhat_lasso>=0.5,1,0)
TPR_LASSO[i]<-sum(yhat.lasso==1&label_dija[index_test]==1)/sum(yhat.lasso==label_dija[index_test])
FPR_LASSO[i]<-sum(yhat.lasso==1&label_dija[index_test]==0)/sum(yhat.lasso!=label_dija[index_test])
#GBM#
label<-label_dija[index_train]
data_train<-cbind(data_all[index_train,],label)
fit_gbm<-gbm(label~.,data=data.frame(data_train),distribution="bernoulli",n.trees=100)
yhat_gbm<-predict(fit_gbm,newdata=data.frame(data_all[index_test,]),n.trees=100,type="response")
yhat.gbm<-ifelse(yhat_gbm>=0.5,1,0)
TPR_GBM[i]<-sum(yhat.gbm==1&label_dija[index_test]==1)/sum(yhat.gbm==label_dija[index_test])
FPR_GBM[i]<-sum(yhat.gbm==1&label_dija[index_test]==0)/sum(yhat.gbm!=label_dija[index_test])
}

#TPR<-c(sort(TPR_RM),sort(TPR_LASSO),sort(TPR_GBM))
#FPR<-c(FPR_RM[order(TPR_RM)],FPR_LASSO[order(TPR_LASSO)],FPR_GBM[order(TPR_GBM)])
#col<-c(rep(1,50),rep(2,50),rep(3,50))
#df<-data.frame(TPR,FPR,col)
#ggplot(df,aes(FPR,TPR,color=col))+geom_line(size = 2, alpha = 0.7)+
#  labs(title= "ROC curve", 
#       x = "False Positive Rate (1-Specificity)", 
#       y = "True Positive Rate (Sensitivity)")


#ROC #
df_RM<-data.frame(TPR_RM,FPR_RM)
ggplot(df_RM,aes(FPR_RM,TPR_RM))+geom_smooth(size = 2, alpha = 0.7)+
   labs(title= "ROC RM curve", 
         x = "False Positive Rate (1-Specificity)", 
         y = "True Positive Rate (Sensitivity)")


df_LASSO<-data.frame(TPR_LASSO,FPR_LASSO)
ggplot(df_LASSO,aes(FPR_LASSO,TPR_LASSO))+geom_smooth(size = 2, alpha = 0.7)+
  labs(title= "ROC LASSO curve", 
       x = "False Positive Rate (1-Specificity)", 
       y = "True Positive Rate (Sensitivity)")

df_GBM<-data.frame(TPR_GBM,FPR_GBM)
ggplot(df_GBM,aes(FPR_GBM,TPR_GBM))+geom_smooth(size = 2, alpha = 0.7)+
  labs(title= "ROC GBM curve", 
       x = "False Positive Rate (1-Specificity)", 
       y = "True Positive Rate (Sensitivity)")


#Another ROC#
TPR_VAR<-vector(length=50)
FPR_VAR<-vector(length=50)
#VAR#
data_ad<-data_all_in
for(k in 1:50)
{ind_top<-sample(c(500:1989),100)
 test_top<-vector(length=100)
for(i in 1:100)
{ var_temp<-vector(length=dim(data_ad)[2])
 for(j in 1:length(var_temp))
  { var_temp[j]<-var(data_ad[c(1:ind_top[i]),j])}
 data_temp<-data_ad[,order(var_temp,decreasing=T)[1:10]]
 data_temp<-cbind(data_temp,label_dija)
 var_top<-VAR(data_temp[c(1:ind_top[i]),],p=2,type="both")
 yhat_top<-predict(var_top,n.ahead=1)
 test_top[i]<-yhat_top$fcst$label[,1]
 }
 VAR_test<-ifelse(test_top>=0.5,1,0)
 TPR_VAR[k]<-sum(VAR_test==1&label_dija[ind_top]==1)/sum(VAR_test==label_dija[ind_top])
 FPR_VAR[k]<-sum(VAR_test==1&label_dija[ind_top]==0)/sum(VAR_test!=label_dija[ind_top])
}
df_VAR<-data.frame(TPR_VAR,FPR_VAR)
ggplot(df_VAR,aes(FPR_VAR,TPR_VAR))+geom_smooth(size = 2, alpha = 0.7)+
  labs(title= "ROC VAR curve", 
       x = "False Positive Rate (1-Specificity)", 
       y = "True Positive Rate (Sensitivity)")
