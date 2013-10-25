libname Epi "h:\EpiII";
***Create Temp data sets;
data myeloma;
set epi.myeloma_problem;
run;
data standard;
set epi.standard_2000;
run;
***********************
Part A


***Add up cases and population by race to get crude rates for black males
and white males;

proc summary data=myeloma nway missing;
where male=1;
class black;
var cases pop;
output out=raceincidence sum=sumcases sumpop ;
run;quit;
**Calculate incidence rate;
 
data raceincidence;
set raceincidence;
incidenceR= sumcases/sumpop*100000;
run;
proc print data=raceincidence;run;
**Get Rate Ratio;

data work.RateRatioA;
array IR(2) IR1 IR2 ; ;
do i=1 to 2;
***Begins loop that counts over i and will increment at the end of code;
 set work.raceincidence;
 by black;
 IR(i) = incidenceR;
 end;
rateratio= IR2 / IR1;
keep Ir1 Ir2 rateratio;

run;

proc print data=rateratioA; run;


***********
Part B

First let's put an age variable in the standard file;

data standard;
set standard;
i+1;
age=i-1;
run;
**
First lets get the total for the standard population;

***It's 1,000,000 py;


proc summary data=standard nway missing;
var standard;
output out=standardTot sum=Total ;
run;quit;
proc print data=standardtot; run;
proc sort data=myeloma;
by age;
run;

**Join data sets so you have the standard population for each group;
**Then calculate the standardized incidence for each group;

data Standardized;
merge myeloma standard;
by age;
StdIncid = (cases/pop)* standard /10; * reporting everything per 100,000 people years;
drop i;
run;
** add up by race to get the total incidence rate;
proc summary data=standardized nway missing;
where male=1;
class black;
var stdIncid;
output out=stdraceincidence sum= StdIncid ;
run;quit;

proc print data=stdraceincidence;run;


data work.RateRatioB;
array IR(2) IR1 IR2 ; ;
do i=1 to 2;
***Begins loop that counts over i and will increment at the end of code;
 set work.stdraceincidence;
 by black;
 IR(i) = stdincid;
 end;
rateratio= IR2 / IR1;
keep Ir1 Ir2 rateratio;

run;


**********
Part C


Let's do the same thing we did earlier but for all people by 
which registry they were in;


proc summary data=myeloma nway missing;
class registry;
var cases pop;
output out=regincidence sum=sumcases sumpop ;
run;quit;

**Calculate incidence rate;
 
data regincidence;
set regincidence;
incidenceR= sumcases/sumpop*100000;
run;
proc print data=regincidence;run;
**Get Rate Ratio;

data work.RateRatioC;
array IR(2) IR1 IR2 ; ;
do i=1 to 2;
***Begins loop that counts over i and will increment at the end of code;
 set work.regincidence;
 by registry;
 IR(i) = incidenceR;
 end;
rateratio= IR1 / IR2;
keep Ir1 Ir2 rateratio;

run;

proc print data=rateratioC; run;


********
Part D


Let's create the standard first ( remember we should have 38 categories);


proc summary data=myeloma nway missing;
class black age;
var pop;
output out=CombinedStandard sum= stdpop ;
run;quit;
proc summary data=combinedstandard nway missing;
var stdpop;
output out=Total sum=;
run; quit;
proc sort data=myeloma;
by black age;
run;
data Standardized2;
merge myeloma combinedstandard;
by  black age;
StdIncid = (cases/pop)* stdpop /312.48447; * reporting everything per 100,000 people years;

run;
** add up by race to get the total incidence rate;
proc summary data=standardized2 nway missing;

class registry;
var stdIncid;
output out=stdregincidence sum= StdIncid ;
run;quit;

data work.RateRatioD;
array IR(2) IR1 IR2 ; ;
do i=1 to 2;
***Begins loop that counts over i and will increment at the end of code;
 set work.stdregincidence;
 by registry;
 IR(i) = stdincid;
 end;
rateratio= IR1 / IR2;
keep Ir1 Ir2 rateratio;

run;
********
Part E
I already have a data set with standardized incidence rates for people 
so I'll jsut create a subset for women 30 and over.
;
data women30;
set standardized;
where male=0 and age > 7;
run;
*Let's add both registries;

proc summary data=women30 nway missing;

class black age;
var stdIncid;
output out=plotdata sum= StdIncid ;
run;quit;
*now let's plot;
goptions reset = all gunit=pct rotate = landscape colors=(black blue green red)interpol= none
rotate = landscape htitle= 3;
symbol1 interpol=join value=diamond;
symbol2 interpol=join value=dot;
proc gplot data=plotdata; 

plot stdincid*age=black;   *y-axis variable first, x-axis variable second;
run; quit;



proc print data=plotdata noobs;
var Black age stdIncid;run;

proc summary data=women30 nway missing;

class black ;
var stdIncid;
output out=women sum= StdIncid ;
run;quit;


