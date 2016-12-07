#Ridge & Random Forest#
library(glmnet)
library(randomForest)
load("data_3_new.Rdata")
load("M_3")
data_all_in<-rbind(data_3_new,M_3)
combine_dija<-read.csv("combine_dija")
label_dija<-combine_dija$Label
index_t<-vector("list",length=5)
index_t[[1]]<-sample(1989,0.2*1863)
index_t[[2]]<-sample(c(1:1989)[-index_t[[1]]],0.2*1989)
index_t[[3]]<-sample(c(1:1989)[-c(index_t[[1]],index_t[[2]])],0.2*1989)
index_t[[4]]<-sample(c(1:1989)[-c(index_t[[1]],index_t[[2]],index_t[[3]])],0.2*1989)
index_t[[5]]<-c(1:1989)[-c(index_t[[1]],index_t[[2]],index_t[[3]],index_t[[4]])]

m_ridge<-vector(length=5)
m_rm<-vector(length=5)

#Ridge#
for(i in 1:5)
{
data_train<-data_all_in[-index_t[[i]],]
data_test<-data_all_in[index_t[[i]],]                   
cv_glm1<-cv.glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=0)
fit_glm1<-glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=0,lambda=cv_glm1$lambda.min)
yhat_ridge1<-predict(fit_glm1,data_test,type="response")
yhat1<-ifelse(yhat_ridge1>=0.5,1,0)
m_ridge[i]<-sum(yhat1==label_dija[index_t[[i]]])/length(yhat1)
#LASSO#
#cv_glm2<-cv.glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=1)
#fit_glm2<-glmnet(data_train,as.factor(label_dija[-index_t[[i]]]),family="binomial",alpha=1,lambda=cv_glm2$lambda.min)
#yhat_lasso<-predict(fit_glm2,data_test,type="response")
#yhat2<-ifelse(yhat_lasso>=0.5,1,0)
#m2[i]<-sum(yhat2==label_dija[index_t[[i]]])/length(yhat2)
#RM#
fit.rm<-randomForest(x=data_train,y=as.factor(label_dija[-index_t[[i]]]),mtry=44,ntree=100,importance=TRUE)
yhat.rm<-predict(fit.rm,newdata=data_test,type="response",n.trees=100)
m_rm[i]<-sum(yhat.rm!=label_dija[index_t[[i]]])/length(yhat.rm)

}
mean(m_ridge)
mean(m_rm)