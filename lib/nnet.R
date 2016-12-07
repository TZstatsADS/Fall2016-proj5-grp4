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
