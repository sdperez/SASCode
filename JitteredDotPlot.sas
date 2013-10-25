****************************************************************************
To create dot plots instead of Boxplots of the data suing a SAS jittering Macro
;

PROC IMPORT OUT= WORK.jackson 
            DATAFILE= "C:\Documents and Settings\N375726\My Documents\Studies\JJacksKim\Plexmark1.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
ods graphics on;
Data Jacks2; set Jackson;
If ACR_group=1 OR ab_Rej_Group=1 then group1="3.Reject  ";
 else if BK_Neph_group=1 OR bk_stable_group=1 then group1="4.BK Inf";
 else if acute_CNI_Tox_group=1 OR biopsy_CNI_toxicity_group=1 then group1="5.CNI Tox";
 else if  IFTA_group=2 OR IFTA_group=3 then group1="6.IFTA";
 else if stable_group=1 then group1="2.Stable";
 else if healthy_control_group=1 then group1="1.Healthy";
logOPG= Log( average_OPG);
logCxcl10= Log (average_CXCL10);
logcxcl9= Log (average_CXCL9);
 drop F109--F140;
 label group1="Group";
 run;

proc rank data=Jacks2 out=Jacks3;
var average_OPG average_CXCL10 average_CXCL9 change_in_creat_from_baseline;
ranks rankOPG rankCXCL10 rankCXCL9 Creatinine_Change;
run; 
data Jacks3;set Jacks3;
label   rankOPG="Rank of OPG level"
		rankCXCL10="Rank of CXCL10 level"
		rankCXCL9="Rank of CXCL9 level"
		Creatinine_Change="Rank of Creatinine Change";
		mean1=1;
if group1="1.Healthy" then xval=1;
if group1="2.Stable" then xval=2;
if group1="3.Reject  " then xval=3;
if group1="4.BK Inf" then xval=4;
if group1="5.CNI Tox" then xval=5;
if group1="6.IFTA" then xval=6;

run;

********************************************************;
data jacks4;set jacks3;
new_x=ROUND(rand('NORMAL',xval,.07),.01);
run;
proc means data=jacks3 mean;
var rankcxcl9 rankcxcl10 creatinine_change; class group1;
run;

data temp;
group1="1.Healthy"; new_x=1;mean1=2; rankcxcl9=56.27; rankcxcl10=52.24; output;
group1="2.Stable"; new_x=2; mean1=2; rankcxcl9=63.29; rankcxcl10=63.92; creatinine_change=37.71; output;
group1="3.Reject  " ; new_x=3;mean1=2; rankcxcl9=124.52; rankcxcl10=117.04; creatinine_change=99.10; output;
group1="4.BK Inf"; new_x=4;mean1=2; rankcxcl9=119.75; rankcxcl10=111.5; creatinine_change=56.54; output;
group1="5.CNI Tox";new_x=5; mean1=2; rankcxcl9=50.59; rankcxcl10=74.12; creatinine_change=37.71; output;
group1="6.IFTA"; new_x=6;mean1=2; rankcxcl9=54.44; rankcxcl10=63.17; creatinine_change=97.72; output;
run;
data jacks4; set jacks4 temp;
run;

symbol1 value=circle;
symbol2 value=dot width=10;
proc gplot data=jacks4;
plot1 rankcxcl9*new_x=mean1/overlay;

run;quit;
