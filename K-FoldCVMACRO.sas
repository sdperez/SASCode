*****************************************************************************************
Macro performs K-fold cross-validation on linear regression models. It returns
the root means squared error and mean absolute error;

%macro linKfoldCV (K=5, data=training,y=logcost, basemodel=rvu_total asav2 ,testvar=logcreat);

 data dat2;set &data;
  *randomly assign observation to one of K groups;
  rand=ranuni(1012);
   do fold=1 to &K;
	 if rand>=(1/&K)*(fold-1) AND rand< (1/&K)*fold then output;
   end;

 run;

 proc surveyselect data=dat2 out=cv seed=231258
 samprate=1 outall reps=&K; *replicate the data K times and record the replicate number;
 run;

 data cv;  set cv;
   if fold ne Replicate then new_y=&y;	*only use the outcome for the observations not in the validation set;
 drop selected ;
 run;

 proc genmod data=cv;
  model new_y =&basemodel &testvar;	*Run model;
  by replicate;
  output out=out1(where=(new_y=.)) predicted=y_hat;	*output predictions only for observations in the validation set;
 run; 


 /* summarise the results of the cross-validations */ 
 data out2;
 set out1;
  d=&y-y_hat;
  absd=abs(d);
 run;

 proc summary data=out2;
 var d absd;
 output out=out3 std(d)=rmse mean(absd)=mae;
 run;

 data out3; set out3; format VariableTested $CHAR21.; variableTested="&testvar";
 proc print data=out3; var rmse;run;
 /*Append summary statistics to a running file to compare models*/
 proc append base=RMSEs data=out3;	run;
%mend linKfoldCV;

*****************************************************************************************
Macro performs K-fold cross-validation on logistic regression models. Returns
the c-statistic/ROCAUC and misclassification error (using a probability of .5 as a cutoff);

%macro logitKfoldCV (K=5, data=training,y=comps_yn, basemodel=rvu_total asav2 ,testvar=logcreat);
/*%let K=5;
%let data=training;
%let y=comps_yn;
%let basemodel=rvu_total asav2 ;
%let testvar=logcreat; For testing*/

 data dat2;set &data;
  *randomly assign observation to one of K groups;
  rand=ranuni(1123);
   do fold=1 to &K;
	 if rand>=(1/&K)*(fold-1) AND rand< (1/&K)*fold then output;
   end;

 run;

 proc surveyselect data=dat2 out=cv seed=231300
 samprate=1 outall reps=&K; *replicate the data K times and record the replicate number;
 run;

 data cv;  set cv;
   if fold ne Replicate then new_y=&y;	*only use the outcome for the observations not in the validation set;
 drop selected ;
 run;
 proc logistic data=cv;* outmodel=logprms;
  by replicate;
  model new_y(event='1') =&basemodel &testvar;
  output out=out1(where=(new_y=.)) predicted=y_hat;
 run;

/*Calculate Misclassification error by fold*/
data out2; set out1;
if y_hat>=.5 then yguess=1;
else yguess=0;

if yguess ne comps_yn then err=1; 
else err=0;
run;

/*Calculate c-statistic(Area under the ROC cy=urve) per replicate*/
 proc logistic data=out1;
  ods output ROCAssociation=ROCs;
  by replicate;
  model &y(event='1') =y_hat;
  ROC;
 run;
 data ROC2;set ROCs; if ROCModel='Model';run;


 /* summarise the results of the cross-validations */ 
 
 proc summary data=roc2 ;
 var Area;
 output out=roc3 mean(Area)=cstatistic;
 run;

 proc summary data=out2 ;
 var err;
 output out=out3 mean(err)=Error;
 run;

 /*Merge statistics into one file*/
 data out3; merge out3 roc3; format VariableTested $CHAR21.; variableTested="&testvar";
 proc print data=out3;title misclassification error and C-statistic; var Error Cstatistic;run;	title;
 /*Append summary statistics to a running file to compare models*/
 proc append base=Errors data=out3;	run;
%mend logitKfoldCV;

