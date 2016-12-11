# ADS Final Project: Stock Market Prediction Using Daily News

Term: Fall 2016

+ Team Name: Group 4
+ Projec title: Stock Market Prediction Using Daily News 
+ Team members
	+ team member 1 Jing Mu (jm4269)
	+ team member 2 Kaisheng Wang (kw2628)
	+ team member 3 Yifei Hu (yh2781)
	+ team member 4 Yu Qin (yq2186)
	+ team member 5 Chi Zhang (cz2388)
+ Project summary: In this project, we try to predict the ups and downs of DJIA (Dow Jones Industrial Average) using 25 everyday headlines from Reddit. We compared 1-gram, 2-gram and 3-gram and we finally picked 3-gram words count as our features. We tried 5 types response variables such as type (1)  0/1 (0=decrease, 1=increase or the same) for from today's to tomorrow's opening index price, type (2) 0/1 for from yesterday's to today's adjusted closing index price and so on. We compared neural networks, random forest, etc. and finally chose lasso with prediction accuracy as 55.2% for type (1) response variable and vector AR(2) model with prediction accuracy as 57.6 % for type (2) response variable as our final models. At last, our trading strategy is that if we use the lasso model, we should trade the portfolio at opening time of every day and if we use the Var model, we should trade the portfolio towards the end of every day.
	
**Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/ computation codes
├── data/ the orginal data and data processed
├── doc/ just the contibution statement
├── figs/ figure files produced during the project and running of the codes
└── output/ nothing here since our outputs are in the presentation file
```

Please see each subfolder for a README file.

Final report can be accessed [here](https://github.com/TZstatsADS/Fall2016-proj5-proj5-grp4/blob/master/presentation.md)
