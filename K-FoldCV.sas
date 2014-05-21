%macro linKfoldCV (K=5, data=training,y=logcost, basemodel=rvu_total asav2 ,testvar=logcreat);

data dat2;set &data;
*randomly assign observation to one of K groups;
 rand=ranuni(0);
   do fold=1 to &K;
	 if rand>=(1/&K)*(fold-1) AND rand< (1/&K)*fold then output;
   end;

run;

proc surveyselect data=dat2 out=cv seed=231258
samprate=1 outall reps=&K; *replicate the data K times and record the replicate number;
run;

data cv;  set cv;
   if fold ne Replicate then new_y=&y;	*only use the outcome for the observations not in the validation set;
drop selected j;
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

 /*Append summary statistics to a running file to compare models*/
proc append base=RMSEs data=out3;	run;
%mend linKfoldCV;

%linKfoldCV;

