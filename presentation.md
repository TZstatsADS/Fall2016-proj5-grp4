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
We used two datasets from Kaggle in this project. One is called 'DJIA_table' which includes DJIA index from 08/08/2008 to 07/01/2016. Another is called 'Combined_News_DJIA' which includes top 25 news headlines from [Reddit](https://www.reddit.com/r/worldnews/) during the same time period, and a binary label indicating whether the index was increasing or decreasing. Both datasets can be downloaded [here](https://www.kaggle.com/aaron7sun/stocknews/downloads/stocknews.zip).

The datasets look like this:
###DJIA_table:
![stockhead](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/stockhead.png)
###Combined_News_DJIA:
![headlines](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/headlines.png)

##2 Data Manipulation
+ We use the data before year 2016 as our training set and the rest as testing set.  
+ We convert all the headline to lowercase letters, split the sentence into a list of words, remove punctuation, stem the words (for instance, change “playing”, “played” to “play”) and transform them to a table of words counts.  
+ We tried n-gram where n = 1,2 and 3. We also deleted the words that appear in less than ten days otherwise it will lead to overfitting.  
+ Unigram is not quite useful since we cannot get a good idea of how a single word will change the stock price. For example, we do not know whether the oil price goes up or down just from the word “oil”. Bigram and trigram make better sense.  
+ Stopwords such as "only", "more", "against", "shouldn't" can affect the meaning of a sentence in the headlines so we include them.  
+ For test data set, if the "words" appear in the training data set dictionary, we count the number, if not we ignore them. And for the "words" that in the dictionary and not in the test set, we assign count 0.

##3 Exploratory Data Analysis
First, we plot the overall trend for DJIA for the 9 years.
![ts](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/ts1.png)
DJIA was increasing overall during the time period.

Second, we compute the increase rate of everay day using the adjusted closing index and plot a histogram.
![hist](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/hist1.png)
The rate is approximately normal distributed, hence most of the rate are with the range [-2.5%, 2.5%].

Third, we want to see which phrases occur most frequently in the headlines. So we use word clouds.
![bigram](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/wc2.png)
![trigram](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/wc3.png)

##4 Model Fitting
###Response Variable:
We have tried several types of response variables: 
+ (1) 0/1 for from today's to tomorrow's opening index price
+ (2) 0/1 (0=decrease, 1=increase or the same) for from yesterday's to today's adjusted closing index price
+ (3) 0/1 for from today's adjusted close index price to tomorrow's opening index price
+ (4) adjusted close index price
+ (5) increasing rate.  

###Independent Variables:
In general, trigram works better than bigram.

##5 Model Evaluation

The table below shows the accuracy of different models with different response variables using trigram:  

response/model |  svm  | lasso | random forest |  var  
---------------|-------|-------|---------------|------ 
1              | 53.2% | **55.2%** |    51.2%      |  48%
2              | 50.3% | 52.2% |    50.8%      | **57.6%**

Here is a time series plot of var model.  
![var](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/VAR_3_gram.png)

Here is the ROC curve of random forest model.
![RMROC](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/ROC RM.png)

+ If we consider each day as independent, we use response variable as (2) 0/1 for from today's to tomorrow's opening index price which means to use today's news to predict whether tomorrow's opening will increase comparing to today's opening. This requires the assumption that the stock market takes one day to absorb the news information. In this case, LASSO works best because the number of observations and predictors are almost equal, the word count is a sparse matrix and the cross validation accuracy rate is the highest.

+ But if we consider each day is related, Vector AR(2) model is the best choice. We predict each day adjust close value in 2016 until July 1st based on every day data before this day. For example, if we want to predict the adjust close index for 1/20/2016, we should use every data before 1/20/2016 in VAR model. In order to aviod overfitting and time wasting, we only use 10 phrases with highest variances. 

##6 Conclusion and Future Improvements
Overall, none of the models reaches an accuracy of 60%, which means it is hard to predict stock index using only news headlines. 
