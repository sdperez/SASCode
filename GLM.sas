*Using GLM for an ananlysis of covairace. Continuous and categoical variables.;
proc glm data=mri;
 class race2 sex;
 model creatdiff=age race2 sex /solution;*solution asks for parameter estimates and t-tests;
 run;
ods graphics on;
proc glm data=mri plots=diagnostics; *diagnostic plots in panel form (try UNPACK if you want separate
plots;
model gfrchange72= Gadolinium_Dose________ /solution  ;
run;
*ANOVA analysis;
proc glm data=mri plots=diagnostics; *use (label) to see obs numbers on plots (or id number if 
id statement used) ;
class  Gadolinium_Dose________;
model gfrchange72= Gadolinium_Dose________   ;
means Gadolinium_Dose________ / hovtest welch;*means gets you means by groups and 
hovtests checks equality of variances which is a must for ANOVA	(class statement is needed)"welch" asks for 
a modified ANOVA test that accounts for heteroscedasticity;
output out=predict p=pred r=resid;*output file with predicted and residual values;
run;
