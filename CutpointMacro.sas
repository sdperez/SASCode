********************************
Simple macro to test various cutpoint of a continuous variable
and get the c-statistic from proc logistic for each
cutpoint. Choosing the cutpoint with the highest c-statistic is one possible
way of choosing the best threshold for a diagnostic test;


%macro ChooseCut (testVar=Day2 dataset=WBCtimpute2);
data result;run;

%do tau=1 %to 25 %by 1;
data test; set &dataset;
if &testVar>&tau then group=1; else group=0;
run;

ods output association=out;
proc logistic data=test ;
model anycomp=group;
run;
ods output close;
data out2;set out;
if label2='c';
tau=&tau;
keep  tau label2 nvalue2;
run;

data result;
set result out2;
run;
%end;
%mend;


