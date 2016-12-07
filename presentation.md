#Stock Market Prediction Using Daily News
+ Group #4
+ Team Members:
  + Jing Mu (jm4269)
  + Kaisheng Wang (kw2628)
  + Yifei Hu (yh2781)
  + Yu Qin (yq2186)
  + Chi Zhang (cz2388)
  
+ Project summary: In this project, we try to predict DJIA (Dow Jones Industrial Average) using 25 everyday headlines from Reddit.

##1 Dataset Description
We used two datasets from Kaggle in this project. One is called 'DJIA_table' which includes DJIA index from 08/08/2008 to 07/01/2016. Another is called 'Combined_News_DJIA' which includes top 25 news headlines from Reddit during the same time period, and a binary label indicating whether the index was increasing or decreasing. Both datasets can be downloaded [here](https://www.kaggle.com/aaron7sun/stocknews/downloads/stocknews.zip).
The datasets look like this:
###DJIA_table:
![stockhead](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/stockhead.png)
###Combined_News_DJIA:
![headlines](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/headlines.png)

##2 Data Manipulation

##3 Exploratory Data Analysis
First, we plot the overall trend for DJIA for the 9 years.
![ts](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/ts1.png)
DJIA was increasing overall during the time period.

Second, we compute the increase rate of everay day using the adjusted closing index and plot a histogram.
![hist](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/hist1.png)
The rate is approximately normal distributed, hence most of the rate are with the range [-2.5%, 2.5%].

Third, we want to see which words (or phrases) occur most frequently in the headlines. So we use word clouds.
![unigram](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/wc1.png)
![bigram](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/wc2.png)
![trigram](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/wc3.png)

##4 Model Fitting
###Response Variable:
We have tried three types of response variables: 0/1(0=decrease, 1=increase or the same), adjusted close index, and increasing rate.  
+ Tobefinished

###Independent Variables:
Among the three n-gram models, unigram does not work well because one single word does not make sense most of the time. 
Trigram generally works better than bigram.

The table below shows the accuracy of different models on different word datasets.


ngram/model | naive bayes |  svm  | lasso | adaboost |  gbm  | xgboost | random forest |  var  
------------|-------------|-------|-------|----------|-------|---------|---------------|------ 
bigram      |             |       |       |          |       |         |               |  48%
trigram     |             |       |       |          |       |         |               | **57.6%**

Here is a time series plot of var model.  
![var](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/VAR.png)

##5 Conclusion and Future Improvements
Overall, none of the models reach an accuracy of 60%, which means it is hard to predict stock index just using news headlines. 
