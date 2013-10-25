
*Test linearity assumption of year variable;

/*TEST 1 of the LINEARITY ASSUMPTION
/*TEST of linearity assumption for continuous predictors in Regression
STEPS:
1. Divide your continuous predictor into some number of even bins (quartiles, quintiles, deciles, etc.). 
2. Record the mean value of your continuous predictor in each bin (this will be used later in graphing). 
3. Treat this bin variable as a categorical predictor in Cox regression (use a dummy code for each bin). 
4. Save the beta for each bin (from the fitted model) into a new SAS dataset.
5. Plot these fitted betas against the mean value of your continuous predictor in each bin.
6. This should be roughly a straight line.
*/


*Example - year as a continuous variable in model;
data work.linearity;
	set work.preemptive_rates;
		year2 = year + 0; *make continuous;
run;

proc univariate data=work.linearity;
	var year2;
run;

/*DIVIDE your continuous predictor variable (here: depression score) up into some number of bins; here=10*/;
proc rank data=work.linearity groups=10 out=work.ranks;
   var year2;
   ranks groups;
run;

/*Record the mean value of year in each bin*/
proc means data=ranks mean;
 	class groups;	
    var year;
run;

/*Dummy code your bin variable for use in procedure*/
options nofmterr;
data ranks;                                                          
   set ranks;                                                        
   bin1=(groups=0);                                                  
   bin2=(groups=1);                                                  
   bin3=(groups=2);                                                  
   bin4=(groups=3); 
   bin5=(groups=4); 
   bin6=(groups=5); 
   bin7=(groups=6); 
   bin8=(groups=7);
   bin9=(groups=8);
   bin10=(groups=9);
run;    
/*Run your Cox regression model with your dummy coded bin variable to obtain betas for 
each bin*/ ;
proc genmod data=ranks;                                               
   model pretx_ld = race_ethn bin1 bin2 bin3 bin4 bin5 bin6 bin7 bin8 bin9 ; 
   ods output parameterestimates=betas;                              
run;  

/*Create one variable "binmean" that stores the mean value of depression score for each bin*/;
data betas;                               
   set betas;                             
   if parameter = 'bin1' then binmean = 2000;  
   if parameter = 'bin2' then binmean = 2001;  
   if parameter = 'bin3' then binmean = 2002; 
   if parameter = 'bin4' then binmean = 2003; 
   if parameter = 'bin5' then binmean = 2004;
   if parameter = 'bin6' then binmean = 2005;
   if parameter = 'bin7' then binmean = 2006;
   if parameter = 'bin8' then binmean = 2007;
   if parameter = 'bin9' then binmean = 2008;
   if parameter = 'bin10' then binmean = 2009;
run;    

 /*PLOT the betas against the bin means and assess linearity*/
 proc gplot data=betas;                                      
   plot estimate*binmean ;                                        
   symbol v=dot i=sm80s;                                   
   label binmeanl='Mean Level';                                
   title 'Assess the Linearity Assumption of Year'; 
run;                                                        
quit;          
*looks linear; 

