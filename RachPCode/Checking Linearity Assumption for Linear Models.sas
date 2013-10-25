/***************************************************************************************************
Program:    Checking Linearity Assumption for Linear Models
Date:       5/15/2013                                                       
Author:     REP
Purpose:    To provide an example of modeling a continuous outcome, including how to asses 
			linearity assumptions necessary for a valid model.


		Linearity Modeling Assumptions includes:
1. iid - examine model residuals (independence/no serial correlation) 
	     plot residuals vs. predicted values, Use Durbin-Watson statistic to 
		test for resudal autocorrelation
2. normality of the error distribution - Check kurtosis or use Shapiro-Wilk or other normality test
3. homoscedasticity (constant variance) of errors (vs. time and vs. predictors) - look at 
		plot of residuals over time and/or by predictors. 
***************************************************************************************************/;

*Always a good idea to look at all of the important variables by plotting the data first - 
	outcome, exposure, covariates, etc;
*Plot data;
proc sgscatter data=work.dfr1;
	plot strz_f*tx_ctr_rate_n/pbspline;
run;
*look at various predictors for trends;
*age has very skewed distribution - may want to consider use of a spline in model;

proc sgscatter data=work.dfr1;
	plot logstr*age/pbspline;
run;

proc univariate data=work.dfr1;
	var strz_f;
	histogram/normal kernal;
	probplot/normal (mu=est signma=est);
run;

proc univariate data=work.dfr1;
	var logstr;
	histogram/normal kernal;
	probplot/normal (mu=est signma=est);
run;

proc plot data=work.dfr1;
	plot strz_f*(black profit staff no_nephcare network_n);
run;

proc corr data=work.dfr1 spearman;
	var  black asianmy1_f nativmy1_f ethmy1_f agemy1_f femmy1_f smr profit staff no_nephcare
		diabetes hosp_days shr_f network_n insurance_emp insurance_mdcr insurance_mdcd
		employed hd pd fistula graft catheter avf cva hemoglobin albumin
		creatinine esa ht smoker cancer alcohol drugs ambulatory comorbid
		tx_ctr_rate_n;
run;

***First evaluate whether observations are i.i.d.;

proc reg data=work.dfr1;
 	model strz_f = black ethmy1_f agemy1_f profit staff
		diabetes hosp_days insurance_emp insurance_mdcd
		employed avf albumin esa comorbid / dw spec;  *Request Durban-Watson test statistic and the specificity test;
	output out=resids r=res ;
run;
*Spec test p-value > 0.05 indicates that the error terms are independent and identically distributed;
*Generally a durban-watson statistic of ~2.0 indicates data are independent.  They are independent in this case (DW=1.8);


**Are the error terms normal?;
proc univariate data=resids normal plot ;
	var res;
	 qqplot res / normal(mu=est sigma=est);
	 histogram;
run;
*Check shapiro wilks statistic for normality of error, a p<0.05 indicates data are non-normal;
*This is somewhat difficult to assess if large dataset because p-value may indicate non-normality just
	because you have a lot of power. In general central limit theorem holds if the sample size is
	"large enough". No clear definition for what is "large enough", but if you have more than a few hundred 	
	observations it is probably okay;
*looks like data are non-normal;


*If data are non-normal;
*Try looking at the log of the outcome - sometimes transforming a continuous variable
	helps meet normality modeling assumption;
proc reg data=work.dfr1;
 	model logstr = black ethmy1_f agemy1_f profit staff
		diabetes hosp_days insurance_emp insurance_mdcd
		employed avf albumin esa comorbid / dw ;
	output out=resids r=res;
run;
*Spec test p-value > 0.05 indicates that the error terms are independent and identically distributed;
*Generally durban-watson statistic of ~2.0 indicates data are independent.  They are independent in this case (DW=1.8);

**Are the error terms normal?;
proc univariate data=resids normal plot;
	var res;
	qqplot res / normal(mu=est sigma=est);
	histogram;
run;
*Check Kolmogorov-Smirnov statistic for normality of error, p>0.05 so data are normal;
