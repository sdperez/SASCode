/***************************************************************************************************
Program:    Checking Linearity Assumption for Linear Models
Date:       5/15/2013                                                       
Author:     REP
Purpose:    To provide an example of proc lifetest for a time to event outcome
			
			Also use of style and other options in ods graphics	

***************************************************************************************************/;

ods graphics on; *	In new SAS 9.3, ods graphics is always on so you shouldn't have to turn it on;
*/ width=2.5 in height=1.5 in;
ods html image_dpi=300;  *often for journals we need the resolution to be high;
ods html style = Journal;  *this will make the curves black and white - usually good for journals
		when you don't want to pay for color printing fees!;


*Crude data;
proc lifetest data=work.two method=km plots=(s,lls) atrisk 
		timelist=(0, 30.4, 182.4, 365, 730, 1095, 1826)  
		conftype=asinsqrt outsurv = survest ; *I can use the timelist option if I want to get an estimate of the N at risk
													by group for each time point;
	time timetxfail*graft_fail(0);
		strata pretx;  *Stratify by my exposure of interest;
		Title 'Time to Graft Failure Among Preemptive vs. Non-Preemptive Transplant Recipients';
		where donor_type = 1; *0 is DD, 1 is LD;  *I can limit analyses to one particular group if I want;
run;
	
*?p-values for strata difference at 3 years;
proc lifetest data=work.two method=km plots=(s,lls) atrisk 
		conftype=asinsqrt ;
	time timetxfail*graft_fail(0);
		strata pretx;
		Title 'Time to Graft Failure Among Preemptive vs. Non-Preemptive Transplant Recipients';
		where donor_type = 0 and timetxfail <1095; *0 is DD, 1 is LD;
run;
