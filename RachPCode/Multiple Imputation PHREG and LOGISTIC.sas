/**********************************************************************************
Program:    Multiple Imputation Example
Project:	Electrocardiographic predictors of mortality

Date:       5/8/2013
 
Author:     REP

Purpose:    The purpose of this program is to provide an example of multiple imputation
			using both proc phreg and proc logistic, using an example cohort of Emory
			Transplant Center patients who were evaluated for kidney transplantation.

***************************************************************************************/;

 
***For PROC PHREG;

***First step is to use proc mi with your existing dataset (work.three), name a new dataset that the 
	output/imputed dataset will be stored in, and give this any number as a seed. There are other options
	for proc mi (e.g. default will give you five imputed values for each variable listed in the var 
	statement, but you can change this.  See SAS documentation for more details;
proc mi data=work.three out=outecgmi seed=12345 ;
	var potassium alb calcium_cat lvef_cat ventricular_rate esrd_cat_new bp_sys;  *These are all of my continuous variables that have missing data;
									 *I think you can also do this for missing categorical data but I believe
											they need to be coded numerically.;
run;

*Next you just run your normal proc phreg model on the output dataset, with a few key additions:;
proc phreg data=work.outecgmi covout outest=outecgmi2;  *You have to have covout in this line for it to work;
	class ecg_abnorm2 (ref='0') /param=ref;
	class age_cat (ref='1')/param=ref;
	class race_cat (ref='1')/param=ref;	
	*class bmi_cat (ref='2')/param=ref;
	class dialysis_cat (ref='0')/param=ref;
	class sex (ref='2')/param=ref;
	class esrd_cat_new (ref='7')/param=ref;
	class calcium_cat (ref='2')/param=ref;
	class lvef_cat (ref='3')/param=ref;
	model fu_timetxcens*death(0) = ecg_abnorm2 age_cat sex race_cat diabetes_etc potassium 
		dialysis_cat alb calcium_cat cvd lvef_cat ventricular_rate bp_sys esrd_cat_new / rl covb;
		by _imputation_;  *MUST do this by _imputation_, which is a variable that was stored in the output dataset of proc mi;
run;

*You have to specify a new variable for each class level effect (get the names from the step above);
proc mianalyze data=work.outecgmi2;
	modeleffects ecg_abnorm21 ecg_abnorm22 age_cat2 age_cat3 age_cat4 age_cat5
		race_cat2 sex1 race_cat3 diabetes_etc potassium dialysis_cat1 
		dialysis_cat2 dialysis_cat3 alb calcium_cat1 calcium_cat3 
		cvd lvef_cat1 lvef_cat2 ventricular_rate bp_sys 
		esrd_cat_new1 esrd_cat_new2 esrd_cat_new3 esrd_cat_new4 esrd_cat_new5 esrd_cat_new6  ;
run;





*** Proc Logistic Multiple Imputation ***;

*For variables that I have a missing category created, need to first set these to . (missing) so that they are imputed;
proc mi data=work.three out=outecgmi seed=12345 ;
	var potassium alb calcium_cat lvef_cat ventricular_rate esrd_cat_new bp_sys;  *These are all of my continuous variables that have missing data;
									 *I think you can also do this for missing categorical data but I believe
											they need to be coded numerically.;
run;


proc logistic data=work.outecgmi descending covout outest=outecglogcmi;
	class ecg_abnorm2 (ref='0') /param=ref;
	class age_cat (ref='1')/param=ref;
	class race_cat (ref='1')/param=ref;	
	class bmi_cat (ref='2')/param=ref;
	class dialysis_cat (ref='0')/param=ref;
	class esrd_cat (ref='1')/param=ref;
	class ckd_stage_new (ref='1')/param=ref;
	class sex (ref='2')/param=ref;
	class esrd_cat (ref='1')/param=ref;
	*class diabetes_etc (ref='0')/param=ref;
	model death = ecg_abnorm2 sex age_cat race_cat dialysis_cat alb potassium diabetes_etc cvd calcium lvef bp_sys esrd_cat;
		by _imputation_;
run; 

proc mianalyze data=work.outecglogcmi;
	modeleffects ecg_abnorm21 ecg_abnorm22 sex1 sexunknown age_cat2 age_cat3 age_cat4 age_cat5
		race_cat2 race_cat3 dialysis_cat2 dialysis_cat3 diabetes_etc alb potassium cvd calcium lvef bp_sys 
		esrd_cat2 esrd_cat3 esrd_cat4 esrd_cat5 esrd_cat6 esrd_cat7 esrd_cat8;
run;
