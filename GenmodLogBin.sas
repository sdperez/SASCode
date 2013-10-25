*Where the parameter of interest is risk or prevalence ratios you can estimate
directly by using log binomial regression instead of using logistic reg to estimate
RRs from ORs. Especially useful when the rare disease assumption is violated and ORs<>RRs;
data greenland;
input death receptor $ stage2 stage3 number;
cards;
1 low 0 0 2
1 hi  0 0 5
0 low 0 0 10
0 hi  0 0 50
1 low 1 0 9
1 hi  1 0 17
0 low 1 0 13
0 hi  1 0 57
1 low 0 1 12
1 hi  0 1 9
0 low 0 1 2
0 hi  0 1 6

;
run;
*check table;
proc freq data=greenland;
table death*receptor;
weight number;
run;
*Log Binomial Regression;
proc genmod descending;	*1 is the event instead of 0;
class receptor;
weight number; *data is sumarized;
model death=receptor stage2 stage3/dist=bin link=log; *default is dist=normal link=identity (no transform);
*The parameter estimates that are in the output can be exponentiated to give ris ratios;
*To let sas do it you can can use ESTIMATE statements with the EXP option.
Notice that when you use a class statement it creates two variables aout of the binary predictors
and that's why two numbers follow the variable name;
estimate "RR receptor low vs. hi" receptor -1 1;
estimate "RR receptor hi vs. lo" receptor 1 -1;
estimate "RR stage2 vs stage1" stage2 1 -1;
estimate "RR stage2 vs stage3" stage2 1 
								stage3 -1 ;
run;





*When log binomial regression fails to converge try poisson regression with
a "robust variance" adjustment. Poisson regression by itself works, but because 
we have a dichotomous outcomes the variance that is traditionally calculated will be too
wide (ie. confidence intervals will be too conservative but estimates will be
correct). Using the repeated measures line adjusts for this;
data greenland2; set greenland;	*first let's change our data from a summarized table to 
individual lines per subject;
do i=1 to number;
id+1; output;
end;
drop number;
run;

proc genmod data=greenland2 descending;
class id receptor;
model death=receptor stage2 stage3/dist=poisson link=log;
repeated subject=id/type=ind;
estimate "RR receptor low vs. hi" receptor -1 1;
run;
