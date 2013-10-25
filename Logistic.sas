ods graphics on;
proc logistic data=dat plots(only)=effect;
model complication (event='Yes')=pralbum;
run;
*effect plot gives an indication of resulting probability as predictor
changes;
proc logistic data=dat3 ; title Logistic model try;
class  Diabetes--prsepis;
model complication (event='Yes')=Diabetes--prsepis / selection=forward details; 
run;* details tells it to give details on each step of the selection process. Model has every variable 
between diabetes and sepsis;

proc logistic data=dat3 ; title Logistic Model with Continuous Lab Values;
class  wndclas (ref="1-Clean") asaclas (ref="1-No Disturb")fnstatus2 (ref="Independent")
		bleeddis (ref="No");
*setting the variables levels that should be used as reference levels;
model complication (event='Yes')=wndclas asaclas fnstatus2 pralbum bleeddis 

/aggregate  scale=none;  * aggregate and scale tell it to output a deviance test. Because no vars
were put after the aggregate statement it uses all variables to create subgroups. You should aggregate 
on all variables of the 'full' model so you can compare any smaller models to it;
run;

proc logistic data=dat3 ; title Logistic Model with Continuous Lab Values;
class  wndclas (ref="1-Clean") asaclas (ref="1-No Disturb")fnstatus2 (ref="Independent")
		bleeddis (ref="No");
*setting the variables levels that should be used as reference levels;
model complication (event='Yes')=wndclas |asaclas| fnstatus2| pralbum| bleeddis;
run;*Runs model with ALL possible intereactions (not just 2way);
