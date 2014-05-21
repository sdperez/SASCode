**********************************************************************
Random K-fold Crossvalidation

**********************************************************************;


  %let K=5;
  %let rate=%sysevalf((&K-1)/&K);

  *Build model with all data;

  proc reg data=xv.sample1;
  model y=x1 x2 x3 x4 x5 x6 x7;
  run;

  *Generate the cross validation sample;
  proc surveyselect data=xv.sample1 out=cv seed=231258
  samprate=&rate outall reps=5;
  run;

  /* the variable selected is an automatic variable generatic by surveyselect.If selected is true then then new_y will get the value of y otherwise is missing */

  data cv;
  set cv;
   if selected then new_y=y;
  run;

/* get predicted values for the missing new_y in each replicate */

 ods output ParameterEstimates=ParamEst;
  proc reg data=cv;
    model new_y=x1 x2 x3 x4 x5 x6 x7;
   by replicate;
   output out=out1(where=(new_y=.)) predicted=y_hat;
  run;

 /* summarise the results of the cross-validations */ 
  data out2;
  set out1;
   d=y-y_hat;
   absd=abs(d);
  run;

  proc summary data=out2;
  var d absd;
  output out=out3 std(d)=rmse mean(absd)=mae;
  run;

 /* Calculate the R2 */ 
 proc corr data=out2 pearson out=corr(where=( type ='CORR'));
  var y ;
  with y hat;
 run;

 data corr;
  set corr;
  Rsqrd=y**2;
 run;
