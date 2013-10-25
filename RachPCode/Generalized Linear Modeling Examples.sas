/***************************************************************************************************
Program:    Generalized Linear Modeling Examples
Date:       5/15/2013                                                       
Author:     REP
Purpose:    To provide an example of use of generalized linear modeling for count or binary data

			Examples include log-binomial regression for binary data in proc genmod, modified 
				Poisson regression for count data in proc genmod, and generalized linear modeling 
				for a continuous outcome using proc mixed and proc glimmix. 
				


***************************************************************************************************/;



*Proc Genmod Examples for Generalized Linear Models;


*Log-binomial Regression to get estimates of Risk Ratios;

*Crude Risk Ratios;
*Example where we have potential clustering of patient level data within OPO region;
*Uses robust standard errors by using the repeated statement;
*This approach uses Binomial Regression where the outcome is 0/1, but we don't want to 
	use logistic because we want Risk Ratios instead of Odds Ratios;

proc genmod data=work.preemptive_rates descending ;
	class opo_region;
	model pretx_dd = race_ethn  / dist=bin link=log ;  
	repeated subject=opo_region/type=exch; *gives robust standard errors;
run;
*Note this model didn't run - one suggestion is to change the intercept to another 
	number to change the scale. This won't change the model at all, but may allow
	the model to run;


proc genmod data=work.preemptive_rates descending ;
	class opo_region;
	model pretx_dd = race_ethn  / dist=bin link=log intercept = -4;  
	repeated subject=opo_region/type=exch; *gives robust standard errors;
run;
*This model runs and is a good fit for data.
*Note that the type=exchangeable option allows you to choose the type of correlation
	that you think you have. See SAS notes on this - there are a number of potential
	reasons that you may choose one correlation structure over another but
	the most common is exchangeable or compound symmetric. Usually you don't know
	how the data are correlated.  The repeated statement gives you robust standard 
	errors, so in general it probably doesn't matter the type of structure you pick;


***Modified Poisson Regression for Risk Ratios;
**Outcome = Count variable;


proc genmod data=work.preemptive_rates descending ;
	class opo_region;
	model pretx_dd = race_ethn  / dist=poisson link=log ;  ;
	repeated subject=opo_region/type=exch; *gives robust standard errors;
run;
*Note the scaled deviance in the output of this model (Value/DF) should be close to 1 if possible.
	If it's not, this indicates over or underdispersion, and a Poisson model may not be appropriate.


**Example Model if Poisson model is not appropriate is Negative Binomial Distribution;
**Used for count variable (e.g. number of readmissions);

proc genmod data=work.preemptive_rates descending ;
	class opo_region;
	model pretx_dd = race_ethn  / dist=nb link=log ; 
	repeated subject=opo_region/type=exch; *gives robust standard errors;
run;



***For a continuous outcome, there are several generalized linear modeling approaches that can be used;
***This in part depends on whether you want to account for potential correlation (multilevel models) or 
	you have repeated measures over time, and/or if you want to account for random effects in the model;

*The simplest approach - SAS Proc Mixed;

**Example using a ratio outcome called 'strz_f' which is the the standardized transplant ratio;
**We have data on dialysis treatment facilities, which may be correlated within regions (networks);

*Look at effect of variation only;
proc mixed data=work.dfr1 covtest;
	class network;
	model strz_f = / solution;
	random intercept / sub=network;
run;
*residual estimate = 0.3882;


*Look at effect of variation only using a log-transformed model;
proc mixed data=work.dfr1 covtest;
	class network;
	model logstr = / solution;
	random intercept / sub=network;
run;
*Intercept p=0.0035 - suggests networks differ in their STR estimates (we know this);
*Covariance parameter estimates tell us about the random effects.
*Old model (ln (STR)) - Both Intercept and Residual are significant:
Intercept estimate = 0.1720 (p=0.0035)
Residual EStimate = 3.3073 (p<0.0001)
Suggests that the variation WITHIN Networks is 19 times greater 
	than the variation BETWEEN Networks;
*Model AIC = 16582;
*Intraclass correlation = intercept estimate / intercept + residual estimate;
*Updatded now with new logSTR+1 - ICC here this is 0.15, which indicates clustering;



*Look at level-1 effects;
proc mixed data=work.dfr1 covtest;
	class network;
	model logstr = black smr profit staff no_nephcare
		diabetes hosp_days network_n / solution;
	random intercept / sub=network;
run;
*Consider additional factors like comorbidities in this model;

*Random slope AND random intercept model - compare AIC;
*considering all random slopes - model did not converge;
proc mixed data=work.dfr1 covtest;
	class network;
	model logstr = black ethmy1_f profit 
		diabetes hosp_days network_n insurance_emp 
		employed avf esa smoker ht / solution;
	random intercept / sub=network;
run;



****PROC GLIMMIX;
***If we want to include random effects for a continuous outcome, we should consider proc glimmix
	as a modeling approach;

*Just look at means (i.e. no predictors);
proc glimmix data=work.count;
	model strz_f = /  solution;
run;
*Check Pearson chi-square/DF for fit of model - should be close to 1;
*Pearson chi-square/DF implies this is somewhat underdispersed (0.45);

*Try a Poisson distribution for this continuous outcome;
proc glimmix data=work.dfr1;
	model strz_f = black staff no_nephcare
		diabetes hosp_days insurance_emp 
		employed esa hd vintage
		tx_ctr_rate_n / dist=poi link=log solution ;
run;


*Add random effect;
proc glimmix data=work.dfr1;
	model strz_f = / dist=poi link=log solution;
		random intercept / subject=network_n; 
run;
*This model did not converge with the random effect;
*Sometimes this happens - you can try different distributions like Negative Binomial,
		but sometimes the data may be too sparse for this model to run or there 
		may be other issues with model fit, etc.;

*Try negative binomial model;
proc glimmix data=work.dfr1;
	model strz_f = / dist=nb link=log solution;
		random intercept / subject=network_n; 
run;
*Model did not converge;

***Try modeling as count variable;

data work.count;
	set work.dfr1;
	logcnt = log(extxz_f); 
run;

*Neither Poisson nor Negative Binomial models converged;
proc glimmix data=work.count;
	model obtrz_f  = / dist=nb link=log offset=logcnt solution;
		random intercept / subject=network_n; 
run;
*Model did not run;

***Because these models did not run, I have to avoid glimmix and 
	go back to proc genmod. Disadvantage is that I can't look at
	random effects now;

**Try modeling just the counts of the STR
- Use observed count as output and expected count as offset.
- Because Poisson model looks like it is overdispersed - use Negative Binomial instead;

*Observed transplants = obtrz_f;
*Expected transplants = extrz_f;
proc genmod data=work.count;
	model obtrz_f =  / dist=nb offset=logn diagnostics covb;
run;
*Pearson/DF = 1.02, indicates oversdispersion problem is taken
	care of with a Negative Binomial Model;



*Full model;
*Full model- include basically all covariates that were univariately 
	associated with outcome (this is all but SMR in our data), outside of
	those that were correlated with one another - e.g. white and black are
	highly correlated so I just picked black;
*Next, include main variables we KNOW are associated with transplant - like 
	age, comorbidities, and race, plus variables that are p<= 0.1 in full model
	and through backwards elimination;

proc genmod data=work.count;
	class network_n (ref="1");
	model obtrz_f = black asian nat_am age staff pt_notinformed
		 no_nephcare employed avf pd vintage smoker comorbid diabetes
		esa shred profit employed insurance_none facility_n
		tx_ctr_rate_n /dist=nb link=log offset=logcnt;
	repeated subject=network_n/ ; *subject=network_n will give robust standard errors;
run;
*Assess GOF of model using AIC (smaller is better);
