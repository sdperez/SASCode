*************************************************************
Getting adjusted survival curves from PHREG:
the plot=survival will give you a survival plot for your whole population. In it
phreg uses the reference values for categorical and the mean values for continuous
variables for the graph. In order to choose a set of values to use for the graph
you must use the BASELINE command along with a covariate file. In this case we use
two set of covariates to create two survival lines; 

libname c "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Studies\JSharma1";
data surv; set c.ValveFinal;
run;
ods graphics on;
data Inrisks; *Sets covariate values you want to graph/predict;
      length Id $20;
      input pthcategory  age race angina mi bmi 
			Antihypertensives ca phos hemoglobin ID $;;
      datalines;
 1 54.99 1.710 1.645 1.73 27.62 1.374 8.91 5.51 10.82 PTH<400
 2 54.99 1.710 1.645 1.73 27.62 1.374 8.91 5.51 10.82 PTH>400
   ;
proc phreg data=surv plots(overlay)=survival;*the overlay option puts all survival lines on the same graph;
	title Survival Curves and Estimates by PTH Group;
     model survivaldays*mortStatus(2)=pthcategory age race angina mi bmi 
									Antihypertensives ca phos hemoglobin/RL;
      baseline covariates=Inrisks out=Pred1 survival=_all_ / rowid=Id; *Tells it specifically what covariate values to
	  use in the graphs;
   run;
proc phreg data=surv plots(overlay)=survival;*the overlay option puts all survival lines on the same graph;
	title Survival Curves and Estimates by PTH Group;
     model survivaldays*mortStatus(2)=pthcategory age race angina mi bmi 
									Antihypertensives ca phos hemoglobin/RL;
      baseline  out=Pred1 survival=_all_ ; *Tells it specifically what covariate values to
	  use in the graphs;
   run;
