********************************************************
Proc mixed can be used for a variety of models. Here it is used for a repeated
measures model on a conitnuous and (normal?) outcome.
;
proc mixed data=cd4naive empirical;*the empirical option ignores the correlation structure given and uses what 
it thinks is best;
class treatment;
model cd4Naive= time | treatment /solution ddfm=residual;*ddfm changes the degrees of freedom for the model.
Residual is more appropriate than the default;
repeated /subject=idno type=un; *repeated statement teels it what variable it uses to identify 
related observations. Type sets the correlation structure to test;
run;
****
Here we test unstructured, AR(1) and Toep(3) correlation structures;
proc mixed data=cd4naive ;
where time>=0;
class treatment;
model cd4Naive= t1 t2 treatment t1*treatment t2*treatment/solution ddfm=residual;
repeated /subject=idno type=un;
run;
proc mixed data=cd4naive ;
where time>=0;
class treatment;
model cd4Naive= t1 t2 treatment t1*treatment t2*treatment/solution ddfm=residual;
repeated /subject=idno type=AR(1);
run;
proc mixed data=cd4naive ;
where time>=0;
class treatment;
model cd4Naive= t1 t2 treatment t1*treatment t2*treatment/solution ddfm=residual;
repeated /subject=idno type=toep(3);
run;

*****
Here we output a file with predictions. We also do some specific tests:
Is t1+(t1*treatmnet)=0
Id t1-t2=0?
;
proc mixed data=cd4naive ;
where time>=0;
class treatment;
model cd4Naive= t1 t2 treatment t1*treatment /solution ddfm=residual  outpm=cd4Pred;;
repeated /subject=idno type=toep(3);
estimate "Treatment 1.0mg zero slope" 
          	t1 1
			t1*treatment 1;
estimate "T1 equals T2 slope" 
			t1 1
			t2 -1;
run;
