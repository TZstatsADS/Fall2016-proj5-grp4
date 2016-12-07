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

