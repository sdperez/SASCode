

proc corr data=dat1 plots(only)=scatter;
var fev1;
with  donage recage;
run;

proc corr data=dat1 plots(only)=scatter pearson spearman;
*default is pearson but if you want both you can use these statements;
var fev1;
with  donage recage;
run;
