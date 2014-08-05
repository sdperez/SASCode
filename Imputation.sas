*************************************************************************
IMPUTATION TECHNIQUES

Try various imputation techniques for missing data in the NSQIP
PUF file

Sebastian Perez
7/8/2014
*************************************************************************;

libname r 'C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\CurrentStudies\ShipraReadmit\Data';
data Vasc; set r.Vascular; run; *This is all of 2012 vascular surgery data

*************************************
Select a smaller dataset to work with
*************************************;
proc surveyselect  data=Vasc
method=srs n=200 out=Sample;
run;

data sample2; set sample;
array labs(13) PRSODM--PRPT;
do i = 1 to 13;
 if labs(i)=-99 then labs(i)=.;
end;
output;
run;
*************************************
Multiple imputations of continuous
variables with missing data.
by default, creates 5 imputations.
*************************************;
proc mi data=sample2 out=imputedLabs seed=12345 ;
	var PRSODM--PRPT;  *These are all of my continuous variables that have missing data;
run; 

*now run a regression 'by imputation number' and use proc mianalyze
to summarize results;
proc freq;
table READMISSION1 ;
run;
proc logistic data=imputedlabs covout outest=outlogistic; *covout needed;
model Readmission1(event='Yes')=PRSODM--PRPT;
 by _imputation_;
 run;
proc mianalyze data=outlogistic;
modeleffects  PRSODM PRBUN PRCREAT PRALBUM PRBILI PRSGOT PRALKPH PRWBC PRHCT PRPLATE PRPTT PRINR PRPT;
run;

*****************************************
NIMPUTE changes the number of imputations
in this case to 1
*****************************************;
proc mi data=sample2 out=imputedLabs1 seed=12345 nimpute=1;
	var PRSODM--PRPT;  *These are all of my continuous variables that have missing data;
run; 


**********************************************************
Multiple Imputation on categorical variables
**********************************************************;
data sample3; set sample2;
if ETHNICITY_HISPANIC='NULL' then ETHNICITY_HISPANIC=' ';
run;
proc mi data=sample3 out=imputedLabsEthn seed=12345 ;

    class  ETHNICITY_HISPANIC ;
	var PRSODM-- PRPT ETHNICITY_HISPANIC ; 
	monotone  logistic(ETHNICITY_HISPANIC= PRSODM-- PRPT);
	 
run;  *not monotone pattern;

*****************************
Create an indicator variable 
for missings
****************************;
data sample4; set sample3;
ethMISS=missing(ETHNICITY_HISPANIC);
run;
**
Macro to create missing indices for a list of variables;
%macro missind(indata, outdata, varlist, suffix, indlist=);
  %let k=1;
  %let myvar = %scan(&varlist, &k);
  %* creating the list for indicator variables;
  %let mvarlist = ;
  %do %while("&myvar" NE "");
    %let mvarlist = &mvarlist &myvar._miss;
    %let k = %eval(&k + 1);
    %let myvar = %scan(&varlist, &k);
  %end;
  %* generating the indicator variables;
  data &outdata;
    set &indata;
	  array _a1_(*) &varlist;
	  array _a2_(*) &mvarlist;
	  do i = 1 to dim(_a1_);
	     _a2_(i) = missing(_a1_(i));
	  end;
  run;   
  %let &indlist = &mvarlist;
%mend;
%let myvars = PRSODM PRINR PRPT ;
%global myindvars ;
%missind(sample3, sample4, &myvars, _miss, indlist= myindvars) ;
proc freq data = sample4;
  tables &myindvars;
run;





