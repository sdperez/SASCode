data BDDtable;
input bdd count;
datalines;
1 32
0 156
;
run;
proc freq data=bddtable;
weight count;
table bdd/ chisq fisher testp=(98 2);
run;
