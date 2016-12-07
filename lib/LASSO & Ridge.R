#LASSO & Ridge#
library(glmnet)

index_t<-vector("list",length=5)
index_t[[1]]<-sample(1863,0.2*1863)
index_t[[2]]<-sample(c(1:1863)[-index_t[[1]]],0.2*1863)
index_t[[3]]<-sample(c(1:1863)[-c(index_t[[1]],index_t[[2]])],0.2*1863)
index_t[[4]]<-sample(c(1:1863)[-c(index_t[[1]],index_t[[2]],index_t[[3]])],0.2*1863)
index_t[[5]]<-c(1:1863)[-c(index_t[[1]],index_t[[2]],index_t[[3]],index_t[[4]])]

m1<-vector(length=5)
m2<-vector(length=5)
#Ridge#
for(i in 1:5)
{
data_train<-data_3_new[-index_t[[i]],]
data_test<-data_3_new[index_t[[i]],]                   
cv_glm1<-cv.glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=0)
fit_glm1<-glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=0,lambda=cv_glm1$lambda.min)
yhat_ridge1<-predict(fit_glm1,data_test,type="response")
yhat1<-ifelse(yhat_ridge1>=0.5,1,0)
m1[i]<-sum(yhat1==label_dija[index_t[[i]]])/length(yhat1)
#LASSO#
cv_glm2<-cv.glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=1)
fit_glm2<-glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=1,lambda=cv_glm2$lambda.min)
yhat_lasso<-predict(fit_glm2,data_test,type="response")
yhat2<-ifelse(yhat_lasso>=0.5,1,0)
m2[i]<-sum(yhat2==label_dija[index_t[[i]]])/length(yhat2)
}