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
We used two datasets from Kaggle in this project. One includes DJIA index from 08/08/2008 to 07/01/2016. Another includes top 25 news headlines from Reddit during the same time period. Both datasets can be downloaded [here](https://www.kaggle.com/aaron7sun/stocknews/downloads/stocknews.zip).

##2 Data Manipulation

##3 Exploratory Data Analysis
First, we plot the overall trend for DJIA for the 9 years.
![ts](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/ts1.png)
DJIA was increasing overall during the time period.

Second, we compute the increase rate of everay day using the adjusted closing index and plot a histogram.
![hist](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/figs/hist1.png)
The rate is approximately normal distributed, hence most of the rate are with the range [-2.5%, 2.5%].

Third, we compute two word clouds using 1-gram which refer to the highest and lowest increasing rate respectively.

##4 Model Fitting
The table below shows the accuracy of different models on different word datasets.

##5 Conclusion and Future Improvements
