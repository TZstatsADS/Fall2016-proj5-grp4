library("glmnet")
#lasso
lasso.mod=glmnet(x=as.matrix(new_data_train_3[,-1]),y=as.factor(new_data_train_3[,1]),family="binomial",alpha=1)
cv.out=cv.glmnet(x=as.matrix(new_data_train_3[,-1]),y=as.factor(new_data_train_3[,1]),family="binomial",alpha=1)
bestlam=cv.out$lambda.min
lasso.pred=predict(lasso.mod,s=bestlam ,newx=as.matrix(new_data_test_3[,-1]),type = "response")

#cross validation
lasso.mod1=glmnet(x=as.matrix(new_data_train_3[1:1500,-1]),y=as.factor(new_data_train_3[1:1500,1]),family="binomial",alpha=1)
cv.out1=cv.glmnet(x=as.matrix(new_data_train_3[1:1500,-1]),y=as.factor(new_data_train_3[1:1500,1]),family="binomial",alpha=1)
bestlam1=cv.out1$lambda.min
lasso.pred1=predict(lasso.mod1,s=bestlam ,newx=as.matrix(new_data_train_3[1501:1863,-1]),type = "class")

cv1_number=sample(1:1860,size=372)
cv1<-new_data_train_3[cv1_number,]
cv2_s<-new_data_train_3[1:1860,][-cv1_number,]
cv2_number<-sample(1:nrow(cv2_s),size=372)
cv2<-cv2_s[cv2_number,]
cv3_s<-cv2_s[-cv2_number,]
cv3_number<-sample(1:nrow(cv3_s),size=372)
cv3<-cv3_s[cv3_number,]
cv4_s<-cv3_s[-cv3_number,]
cv4_number<-sample(1:nrow(cv4_s),size=372)
cv4<-cv4_s[cv4_number,]
cv5<-cv4_s[cv4_number,]

lasso.modcv1=glmnet(x=as.matrix(rbind(cv1[,-1],cv2[,-1],cv3[,-1],cv4[,-1])),y=as.factor(rbind(cv1[,1],cv2[,1],cv3[,1],cv4[,1])),family="binomial",alpha=1)
cv.outcv1=cv.glmnet(x=as.matrix(rbind(cv1[,-1],cv2[,-1],cv3[,-1],cv4[,-1])),y=as.factor(rbind(cv1[,1],cv2[,1],cv3[,1],cv4[,1])),family="binomial",alpha=1)
bestlamcv1=cv.outcv1$lambda.min
lasso.predcv1=predict(lasso.modcv1,s=bestlam ,newx=as.matrix(cv5[,-1]),type = "class")

lasso.modcv2=glmnet(x=as.matrix(rbind(cv1[,-1],cv2[,-1],cv3[,-1],cv5[,-1])),y=as.factor(rbind(cv1[,1],cv2[,1],cv3[,1],cv5[,1])),family="binomial",alpha=1)
cv.outcv2=cv.glmnet(x=as.matrix(rbind(cv1[,-1],cv2[,-1],cv3[,-1],cv5[,-1])),y=as.factor(rbind(cv1[,1],cv2[,1],cv3[,1],cv5[,1])),family="binomial",alpha=1)
bestlamcv2=cv.outcv2$lambda.min
lasso.predcv2=predict(lasso.modcv2,s=bestlam ,newx=as.matrix(cv4[,-1]),type = "class")

lasso.modcv3=glmnet(x=as.matrix(rbind(cv1[,-1],cv2[,-1],cv4[,-1],cv5[,-1])),y=as.factor(rbind(cv1[,1],cv2[,1],cv4[,1],cv5[,1])),family="binomial",alpha=1)
cv.outcv3=cv.glmnet(x=as.matrix(rbind(cv1[,-1],cv2[,-1],cv4[,-1],cv5[,-1])),y=as.factor(rbind(cv1[,1],cv2[,1],cv4[,1],cv5[,1])),family="binomial",alpha=1)
bestlamcv3=cv.outcv3$lambda.min
lasso.predcv3=predict(lasso.modcv3,s=bestlam ,newx=as.matrix(cv3[,-1]),type = "class")

lasso.modcv4=glmnet(x=as.matrix(rbind(cv1[,-1],cv5[,-1],cv3[,-1],cv4[,-1])),y=as.factor(rbind(cv1[,1],cv5[,1],cv3[,1],cv4[,1])),family="binomial",alpha=1)
cv.outcv4=cv.glmnet(x=as.matrix(rbind(cv1[,-1],cv5[,-1],cv3[,-1],cv4[,-1])),y=as.factor(rbind(cv1[,1],cv5[,1],cv3[,1],cv4[,1])),family="binomial",alpha=1)
bestlamcv4=cv.outcv4$lambda.min
lasso.predcv4=predict(lasso.modcv4,s=bestlam ,newx=as.matrix(cv2[,-1]),type = "class")

lasso.modcv5=glmnet(x=as.matrix(rbind(cv5[,-1],cv2[,-1],cv3[,-1],cv4[,-1])),y=as.factor(rbind(cv5[,1],cv2[,1],cv3[,1],cv4[,1])),family="binomial",alpha=1)
cv.outcv5=cv.glmnet(x=as.matrix(rbind(cv5[,-1],cv2[,-1],cv3[,-1],cv4[,-1])),y=as.factor(rbind(cv5[,1],cv2[,1],cv3[,1],cv4[,1])),family="binomial",alpha=1)
bestlamcv5=cv.outcv5$lambda.min
lasso.predcv5=predict(lasso.modcv5,s=bestlam ,newx=as.matrix(cv1[,-1]),type = "class")

sum(mean(lasso.predcv1==cv5[,1]),mean(lasso.predcv2==cv4[,1]),mean(lasso.predcv3==cv3[,1]),mean(lasso.predcv4==cv2[,1]),mean(lasso.predcv5==cv1[,1]))/5
