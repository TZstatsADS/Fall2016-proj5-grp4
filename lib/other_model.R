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

#TPR & FPR#
library(randomForest)
library(glmnet)
library(gbm)
library(ggplot2)
library(vars)
load("data_3_new.Rdata")
load("M_3")
combine_dija<-read.csv("combine_dija")
label_dija<-combine_dija$Label
data_all_in<-rbind(data_3_new,M_3)

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

library(h2o)
#cross_validation#
index_t<-vector("list",length=5)
index_t[[1]]<-sample(1863,0.2*1863)
index_t[[2]]<-sample(c(1:1863)[-index_t[[1]]],0.2*1863)
index_t[[3]]<-sample(c(1:1863)[-c(index_t[[1]],index_t[[2]])],0.2*1863)
index_t[[4]]<-sample(c(1:1863)[-c(index_t[[1]],index_t[[2]],index_t[[3]])],0.2*1863)
index_t[[5]]<-c(1:1863)[-c(index_t[[1]],index_t[[2]],index_t[[3]],index_t[[4]])]
                     

#index_train<-sample(1863,0.8*1863)
#index_test<-c(1:1863)[-index_train]
err_rate<-vector(length=5)
localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE)
for(i in 1:5)
{
data_train<-cbind(data_3_new+0.01,label_dija[1:1863])[-index_t[[i]],]
data_test<-data_3_new[index_t[[i]],]+0.01
dat_h2o <- as.h2o(data.frame(data_train))
model <- 
  h2o.deeplearning(x = 1:1610,  # column numbers for predictors
                   y = 1611,   # column number for label
                   dat_h2o, # data in H2O format
                   activation = "TanhWithDropout", # or 'Tanh'
                   input_dropout_ratio = 0.2, # % of inputs dropout
                   hidden_dropout_ratios = c(0.5,0.5,0.5,0.5,0.5), # % for nodes dropout
                   balance_classes = FALSE, 
                   hidden = c(50,50,50,50,50), # five layers of 50 nodes
                   epochs = 100)
                   #nfolds=5,  #cross-valid part
                   #fold_assignment =c("Random"),
                   #keep_cross_validation_predictions = TRUE,
                   #keep_cross_validation_fold_assignment = TRUE
#test_h2o<-as.h2o(data.frame(Sift_test[,-5034]))
#h2o_yhat_test <- h2o.predict(model, test_h2o)
#y_hat_dl <- as.data.frame(h2o_yhat_test)
#y_hat_dl<-y_hat_dl[,1]
#for(i in 1:length(y_hat_dl))
#{if(y_hat_dl[i]>=0.5)
#{y_hat_dl[i]=1}
#  else{y_hat_dl[i]=0}}
#sum(y_hat_dl==Sift_test[,5034])/length(y_hat_dl)
test_h2o<-as.h2o(data.frame(data_test))
h2o_yhat_test<-h2o.predict(model,test_h2o)
test_error_dl<-as.data.frame(h2o_yhat_test)
test_error_dl<-test_error_dl[,1]
for(j in 1:length(test_error_dl))
  {if(test_error_dl[j]>=0.5)
  {test_error_dl[j]=1}
  else{test_error_dl[j]=0}}
err_rate[i]<-sum(test_error_dl!=label_dija[index_t[[i]]])/length(test_error_dl)
}


#Ada_boost
setwd("/Users/kaishengwang/Desktop/Applied Data Science Proj 5") 
install.packages("gbm")
library(gbm)
load("data3_new.RData")
data_all <- read.csv('/Users/kaishengwang/Desktop/Applied Data Science Proj 5/Combined_News_DJIA.csv', stringsAsFactors = FALSE)
#View(data_3_new)
dim(data_3_new)
data_label <- data_all$Label
data_label <- data_label[1:1863]
input_data <- data_3_new
input_data_yesterday <- input_data[-1863,]
data_label_today <- data_label[-1]
dim(input_data_yesterday)
length(data_label_today)
X <- input_data_yesterday
Y <- data_label_today

length_data <- dim(input_data_yesterday)[1]
index_all <- c(1:length_data)
index_test <- vector("list", length = 5)
index_tuned <- vector()
index_rest <- index_all
j <- 1
for (i in 5:1){
  index_test[[j]] <- sample(index_rest, trunc(length(index_rest)/i))
  index_tuned <- c(index_tuned, index_test[[j]])
  index_rest <- index_all[-index_tuned]
  length(index_rest)
  j <- j+1
}

#index_1 <- sample(index_all, trunc(length_data/5))
#index_rest <- index_all[-index_1]
#length(index_rest)
#index_2 <- sample(index_rest, trunc(length(index_rest)/4))
#index_rest <- index_all[-c(index_1,index_2)]
#length(index_rest)
#index_3 <- sample(index_rest, trunc(length(index_rest)/3))
#index_rest <- index_all[-c(index_1,index_2,index_3)]
#length(index_rest)
#index_4 <- sample(index_rest, trunc(length(index_rest)/2))
#index_rest <- index_all[-c(index_1,index_2,index_3,index_4)]
#length(index_rest)
#index_5 <- index_rest

#index_test
success <- vector()
for (i in 1:5){
  data_train <- X[-index_test[[i]],]
  label_train <- Y[-index_test[[i]]]
  data_test <- X[index_test[[i]],]
  label_test <- Y[index_test[[i]]]
  
  train_dataset <- data.frame(label_train, data_train)
  test_dataset <- data.frame(label_test, data_test)
  gbm_algorithm <- gbm(label_train ~ ., data = train_dataset, distribution = "adaboost", n.trees = 5000)
  gbm_predicted <- predict(gbm_algorithm, test_dataset, n.trees = 5000)
  gbm_predicted<-plogis(2*gbm_predicted)
  #gbm_predicted
  gbm_predicted_0_1 <- gbm_predicted > 0.5
  gbm_predicted_0_1 <- as.numeric(gbm_predicted_0_1)
  #gbm_predicted_0_1
  
  err <- mean(gbm_predicted_0_1 != label_test)
  #print(paste("test-error=", err))
  success[i] <- 1 - err
  
}
mean(success)
#52.25504%
#View(train_dataset)

