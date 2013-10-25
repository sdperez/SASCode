proc quantreg data=mri ci=resampling; *resampling is one of the methods of calculating confidence intervals
You need to put this (or sparsity) to calculate p-values (resampling is better for large data sets);
class gender; *class statements may be used;
model gfrchange72= Gadolinium_Dose________ race2 gender age_ / q=.5;
run; quit;
proc quantreg data=mri ci=sparsity;
class gender;
model gfrchange48= Gadolinium_Dose________ race2 gender age_/ q=.5;
test Gadolinium_Dose________/ lr wald; *you can request wald or likelihood ratio tests;
run; quit;
