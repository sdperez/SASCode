/***************************************************************************************************
Program:    Proc PHREG Robust Sandwich Variance Estimates and Adjusted Survival Curves
Date:       5/15/2013                                                       
Author:     REP
Purpose:    To provide an example of how to model time to event data in PHREG 
				when you have correlated data, e.g. multi-level (such as many patients in
				one zip code). Also to provide example of how to plot adjusted survival 
				curves (like K-M curves, but adjusted for variables in the model).

			Also, example of use of the hazardratio statement when you have interaction in a model
				and want effect estimates at these strata

***************************************************************************************************/;






proc phreg data=sharenew.cohortsFeb2012 covsandwich(aggregate) covm plots=(survival cumhaz);  
					*the covsandwich aggregate option will give robust sandwich variance estimates - note both
						regular and robust standard errors will be produced in output, use CI's produced by
						the robust estimates;	
					*the plots statement will give me adjusted survival or cumulative hazard curves, adjusted
						for variables in the model below;
	class race_ethn (ref='0') / param = ref;
	class agecat (ref = '4') / param = ref;
	class esrdcause (ref = '6') / param = ref;
	class sex ; *** Male is reference grp;
	class bmi_85 (ref='0')/param=ref;
	class epo_cat (ref='0')/param=ref;
	class album_cat (ref='0')/param=ref;
	class hemo_cat (ref='0')/param=ref;
	class opo_region (ref = '5') / param = ref; 
	class insurance (ref='1')/param=ref;
	class povertycat (ref='1') / param = ref;
	class ruca (ref='1')/param=ref;
	class blood_cat (ref='4')/param=ref;  ;
	class ppra_cat (ref='0')/param=ref;
	class cohort (ref='0')/param=ref;
	model timetx1*tx2(0)= race_ethn cohort agecat sex esrdcause opo_region insurance blood_cat race_ethn*cohort/ rl;
 
	hazardratio race_ethn /diff=all at (cohort = '0');  *The hazardratio statement will give effect estimates for the 
			exposure variable at different levels. For example, if there is interaction between race (3 levels) and
			cohort (2 levels), the output will give me the stratified estimates of the effect of race/ethn (vs. reference
			race/ethnicity) on the outcome of transplantation at both levels;
	hazardratio race_ethn /diff=all at (cohort = '1');
	
run;
