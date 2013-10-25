/**********************************************************************************
Program:    Proportional Hazards Assumption for PHREG
Project:	Example is from a Pediatric dataset from the United States Renal Data System
Date:       5/8/2013
 
Author:     REP

Purpose:    The purpose of this program is to provide an example of how to assess the 
			proportional hazards assumption in proc phreg using three different techniques,
			including ln-ln survival curves, goodness of fitness testing, and time-dependent
			Cox modeling. 

Notes:      Note the assessment of the PH Assumption is somewhat subjective, and only major
			violations are probably important to consider (e.g. if the effect of covariate
			is HR< 1 in one time period but crosses over the null to HR > 1 in another time point.
			Best approach if PH assumption has failed - try to recategorize the variable first.
			If this doesn't work, you can use stratified or extended Cox models to address
			the violation.	

***************************************************************************************/;


***Assess PH Assumption (do this prior to model building);
**********************************************************************************************************
Evaluate PH Assumption: Method 1 (log-log survival curves);
**********************************************************************************************************;

proc lifetest data=etc.coded_study2pop method=km plots=(s,lls) outsurv=survival;
	time dialysis_to_transplant*dd_tx(0);
		strata race_new; *exposure variable;
run;
*ok;

data work.survival1;
	set work.survival;
	lls = log (-log(survival));
run;


symbol color = blue;
symbol2 color=red;
symbol3 color = green;

proc gplot data=work.survival1;
	plot lls*dialysis_to_transplant = race_new;
run;



********************************************************************************
EVALUATE PH ASSUMPTION:(Step 2 of 3) GOODNESS OF FIT TESTING;
********************************************************************************;

***CHECKING THE EXPOSURE VARIABLE (Post-allocation COHORT)****;
proc phreg data=etc.coded_study2pop;
    model dialysis_to_transplant*dd_tx(0)=race_new/ rl;
	  output out=resid ressch=rtrq;
run;
data events;
	set resid;
		if dd_tx=1;
run;
proc rank data=events out=ranked ties=mean;
	var dialysis_to_transplant;
		ranks timerank;
run;
proc corr data=ranked nosimple;
	with timerank;
		var rtrq;
run;
*;



******************************************************************************************
(Method 3 of 3): Checking PH assumption with time dependent variables.
******************************************************************************************;

****Extented Cox Method of PH analysis with time dependent variable*each covariate;

*Look at statistical significance of the p-value for the time-covariate variable;
proc phreg data=etc.coded_study2pop;
	class race_new (ref = '1') / param = ref; 
   model timewt*waitlist(0)= cohort race_new povertycat insurance sex agecat region esrdcause ruca TIMERACE/ rl;
   	TIMERACE=race_new*timewt;
run; 





**************************************************************************
  Proportional Hazard Assumption Summary Table for Waitlisting Outcome:

VARIABLE		Log-Log                 GOF           EXTENDED(time-dep)          
_____________________________________________________________________
race_ethn		  yes					yes				yes				
agecat			  no 					no				no        
sex	 		  	  yes 					yes				yes
insurance		  yes 					yes				yes
povertycat		  yes 					yes				yes
region         	  yes					yes				yes
esrdcause	 	  no					yes				yes
ruca			  no					yes				yes
blood_cat		  yes					yes				yes
**************************************************************************;
