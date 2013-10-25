***************************************************************
Linear regression for continuous covariates and a continuous and NORMALLY
distributed outcome variable

***************************************************************;
PROC CORR DATA=BIOS501L.wdocs PEARSON SPEARMAN PLOTS=SCATTER;
   VAR exercise;
   WITH dbp;
TITLE Is there a linear relationship between diastolic blood pressure and total exercise?;
RUN;
******************
Simple Linear Regresion (1 variable);
ODS GRAPHICS ON;
PROC REG DATA=infection PLOTS(ONLY)=FIT;	
  	ID facility;	/* puts the facility (independent variable) in the output table*/
  	MODEL prob_inf = facility / CLM CLI;	
/* The MODEL statement is required. The syntax is dependentvar= independentvar list.
Place options after the forward slash.   The CLM option requests confidence intervals 
for the mean response for each observation. The CLI option requests prediction intervals. */
RUN; QUIT;
*The Plots(only) option tells it to only print fit plots (no diagnostic plots);

***********************************
Multiple Linear Regression:PARTIAL correlations
Below we ask for partial plots of each variable (plots=partial)
and partial correlations (/Partial and Pcorr2);
;
PROC REG DATA=senic PLOTS(ONLY)=PARTIAL;
      MODEL prob_inf = rate_cul stay facility nurses  / PARTIAL PCORR2; 
RUN; QUIT;

**********************************
Multiple Lin Regression: CHUNK tests
Uses the test statement to do a partial F tests on multiple variables;
PROC REG DATA=senic2;
    MODEL prob_inf = rate_cul stay facility nurses nurse_sq;
    Num_nurses: TEST  nurses , nurse_sq;
TITLE Multiple Partial F-test (CHUNK test) for nurses and squared nurses;
RUN; QUIT;
* Tests that nurses=0 AND nurse_sq=0 (you can list many variables);

************************************
MLR: Model Selection
Running all possible regressions with R**2 CP AIC BIC criteria.
Best for predictive models. Look for high R**2 low AIC low BIC and Cp close to p+1
;
TITLE All Possible Regressions;
PROC REG DATA=bios501.senic;
  MODEL prob_inf = rate_cul -- nurses / SELECTION = RSQUARE ADJRSQ CP AIC BIC;
RUN;
***********;
TITLE Stepwise Regression;
PROC REG DATA=bios501.senic;
MODEL prob_inf = rate_cul--nurses/ SELECTION = STEPWISE	
        						SLENTRY = .1
        						SLSTAY = .1
        						DETAILS; 
* DETAILS gives you details about each step in the selection process SELECTION can also be 
BACWARDS/ FORWARDS;
RUN;

***********
Chunkwise Selection
;
PROC REG DATA=fev;
TITLE Chunkwise method;
  MODEL fev=height {sex sexh} {smoking smkh} / GROUPNAMES= 'height'  'sex sexh'  'smk smkh'
        										INCLUDE=1 
												SELECTION=STEPWISE  
												SLENTRY=.1 SLSTAY=.1 
												DETAILS;
RUN; QUIT; *The{} creates groups that are entered or subtracted from the model together, GROUPNAMES simply
labels these groups. INCLUDE=1 forces first variable into all models;




