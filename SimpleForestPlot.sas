********************************************************
Resident Participation Study Forest Plot
;

data Forest;
input Procedure $1-5 Outcome $7-15 Type  OddsRatio LowerCL UpperCL;
*234567890123456789;
datalines;
Appy  Morbidity 1 1.298 1.148 1.467
Chole Morbidity 1 1.233 1.082 1.405
Colon Morbidity 1 1.298 1.081 1.559
Fundo Morbidity 1 1.219 0.806 1.844
IH    Morbidity 1 1.107 0.631 1.942
RYGB  Morbidity 1 1.332 1.124 1.578
Appy  Morbidity 0 1.308 1.154 1.482
Chole Morbidity 0 1.166 1.019 1.333
Colon Morbidity 0 1.349 1.119 1.626
Fundo Morbidity 0 1.170 0.762 1.797
IH    Morbidity 0 1.140 0.644 2.018
RYGB  Morbidity 0 1.334 1.125 1.581
Appy  Mortality 1 0.649 0.275 1.528
Chole Mortality 1 0.883 0.564 1.381
Colon Mortality 1 0.683 0.377 1.238
Fundo Mortality 1 1.240 0.129 11.928
IH    Mortality 1 0.434 0.039 4.792
RYGB  Mortality 1 1.247 0.516 3.010
Appy  Mortality 0 0.711 0.289 1.752
Chole Mortality 0 0.849 0.521 1.385
Colon Mortality 0 0.788 0.416 1.491
Fundo Mortality 0 1.041 0.098 11.050
IH    Mortality 0 0.506 0.043 5.948
RYGB  Mortality 0 1.217 0.502 2.953
;
run;

proc format;
value type 
1='Crude'
0='Adjusted';
value $proc
'Appy'='Lap Appy'
'Chole'='Lap Chole'
'Colon'='Lap Colon'
'Fundo'='Lap Fundo'
'IH'='Lap IH'
'RYGB'='Lap RYGB'
;
run;
ods graphics on;

proc sgpanel data=forest;
title Crude and Adjusted Odds Ratios for Morbidity;
where outcome="Morbidity";
panelby  Procedure/ columns=1 onepanel;
scatter x=oddsratio y=type/ xerrorlower=lowercl xerrorupper=uppercl
								markerattrs= (symbol=diamondfilled size=8);
								refline 1/ axis=x;
								colaxis  label='OR and 95%CI' min=0;
								rowaxis type=discrete DISCRETEORDER=unformatted
								offsetmax=.2 offsetmin=.2;
								format Type Type. procedure $proc.;
								run;quit;

proc sgpanel data=forest;
title Crude and Adjusted Odds Ratios for Mortality;
where outcome="Mortality";
panelby  Procedure/ columns=1 onepanel;
scatter x=oddsratio y=type/ xerrorlower=lowercl xerrorupper=uppercl
								markerattrs= (symbol=diamondfilled size=8);
								refline 1/ axis=x;
								colaxis type=log label='OR and 95%CI' min=0;
								rowaxis type=discrete DISCRETEORDER=unformatted
								offsetmax=.2 offsetmin=.2;
								format Type Type. procedure $proc.;
								run;quit;
