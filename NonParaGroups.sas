****************************************************
Ways to do non-parametric tests
;
*Using NPAR1Way to do tests you can do a wilcoxon test (equivalent to two sample t-tests) if data is symmetrical
or krustal Wallis tests if you have more than two groups;
PROC NPAR1WAY data=meld1b wilcoxon plots=wilcoxonboxplot ; *asking for box plots of the ranked scores;
class complication; var lgmeld; run; *If class has two values then it wilcoxon if more than two the krustal wallis;

PROC NPAR1WAY data=meld1b wilcoxon plots=wilcoxonboxplot ;
class complication; var lgmeld; 
exact wilcoxon; *requests the exact p-value for the wilcoxon test, which might be more appropriate for 
small sample sizes;
run;

*Will rank tests then use an analysis of variance on the ranks (a Krustal-Wallis procedure);
proc rank data=adult2 out=adults3;
var average_OPG average_CXCL10 average_CXCL9;
ranks rankOPG rankCXCL10 rankCXCL9;
run; 
*Essentially ANOVA tests, I am also doing follow-up tests with the estimate statements;
proc glm data=adults3;
title OPG between groups;
class group1;
model rankopg= group1 ;
MEANS group1 ; 
ESTIMATE 'ACR & BK Inf vs. Others' group1 .5 -.25 -.25 -.25 .5 -.25;
ESTIMATE 'ACR vs Others' group1 -.2 -.2 -.2 -.2 1 -.2;
ESTIMATE 'ACR vs BK Inf' group1 -1 0 0 0 1 0;
run; *These tests results will not be adjusted for multiple testing but in this case i was using a
bonferroni adjustment;
