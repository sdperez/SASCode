*************************************************************************
Two sample t-test by variable in class statement;

PROC TTEST DATA=BIOS501L.wdocs;
  CLASS exerreco;
  VAR DBP;
TITLE  Does average DBP Differ Among Women Docs Who Meet CDC Recommended  Guidelines ?;
RUN;

** A paired ttest listing the pre and post values of a measurement for each patient;

proc ttest data=mri;
 paired pre_creat*post_creat;
 title Was there a sigbificant change in creatinine level after the MRI?;
 run;
