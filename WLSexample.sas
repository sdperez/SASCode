title 'Weighted least squares example (NWK Table 10.1)';
* NWK4 Table 10.1, p.407;
data bloodpr;
   input age bloodpr @@;
	label age= 'Age'
	      bloodpr='Diastolic Blood Pressure';
	   lines;
27 73  21 66  22 63  26 79  25 68  28 67  24 75  25 71  23 70  20 65
29 79  24 72  20 70  38 91  32 76  33 69  31 66  34 73  37 78  38 87
33 76  35 79  30 73  37 68  31 80  39 75  46 89  49 101 40 70  42 72  
43 80  46 83  43 75  49 80  40 90  48 70  42 85  44 71  46 80  47 96
45 92  55 76  54 71  57 99  52 86  53 79  56 92  52 85  57 109 50 71
59 90  50 91  52 100 58 80
;
proc print;

*-- Fit ols regression;
proc reg data=bloodpr;
   model bloodpr = age;
   plot r. * age;
	output out=ols r=resid p=predict;
	
*-- Examine residual variance in relation to age;
proc sort;
   by age;

*-- Break up into 4 age groups;
proc rank data=bloodpr groups=4 out=bloodpr;
   var age;
   ranks agegp;

*-- Boxplots of bloodpr, and residuals;
%splot(data=bloodpr, var=bloodpr resid, class=agegp);

proc univariate noprint data=bloodpr;
   by agegp;
   var resid;
   output out=sumry n=n mean=mean std=std var=var qrange=iqr;

data sumry;
   set sumry;
	logmean = log10(mean);
	logstd  = log10(std);
	
proc print;	   
proc plot;
   plot logstd * logmean = agegp;

*-- Fit wls regression;
data newbp;
   set bloodpr;
   wt = 1 / age**2;

proc reg data=newbp;
   weight wt;
   model bloodpr = age;
   output out=conf p=predict u95m=u95m l95m=l95m;

*-- Plot OLS and WLS fits;
%include goptions;
goptions vsize=6in hsize=7in htext=1.7 htitle=2;
title 'NWK Blood Pressure Data: OLS and WLS fits';

data anno;
   retain xsys ysys '2';
	x = 22;  
	y=105; color = 'BLUE';  text='WLS'; function='LABEL'; output;
	x = 25; function='MOVE'; output; line=1;
	x = 29; function='DRAW'; output;
	x = 22;  
	y=102; color = 'RED ';  text='OLS'; function='LABEL'; output;
	x = 25; function='MOVE'; output; line=3;
	x = 29; function='DRAW'; output;

proc gplot data=conf;
   plot bloodpr * age = 1
        predict * age = 2
        u95m    * age = 3
        l95m    * age = 4 
            / overlay frame vaxis=axis1 anno=anno;
   axis1 label=(a=90 r=0);
   symbol1  v=dot  h=1.5 i=rlclm95 color=black ci=red l=3;
   symbol2  v=none i=join   c=blue ;
   symbol3  v=none i=spline c=blue ;
   symbol4  v=none i=spline c=blue ; run;

%gfinish;

