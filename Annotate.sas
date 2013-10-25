PROC IMPORT OUT= WORK.Baseline 
            DATAFILE= "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents
\Studies\SplenectomyNeha\SplenectNeha.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
PROC IMPORT OUT= WORK.postop 
            DATAFILE= "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents
\Studies\SplenectomyNeha\Labs.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="postop$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data WBCpost; set postop; if procedure_lab_cd='WBC'; 
dayspost=order_dt-op_dt;
currWBC= result_lab_tval;
wholeDay=int(dayspost);
keep mrn dayspost wholeday currWBC;
run;
data baseline2; set baseline; 
mrn=patient_mrn/1;
baseWBC= Pre_op_WBC__x1000_ml_;
Infection=Infectious_Compl_;
do i=1 to 7;
wholeDay=i;
output;
end;
keep mrn anycomp comptype Infection wholeday gender race age baseWBC;
run;
proc sort data=WBCpost; by mrn wholeday;
proc sort data=baseline2; by mrn wholeday;
data Allwbc; merge baseline2 (in=n) WBCpost; by mrn wholeday; if n; 
run;
proc format;
value yesno  0="No" 1="Yes";
run;
data riskarea; 
input wholeDay WBCLevel upper;
datalines;
1 19 42
2 19 42
3 18 42
4 15 42
5 14 42
6 12 42
7 10 42
;
run;
proc sort data=allwbc; by wholeday;
proc sort data=riskarea; by wholeday;
data All; merge allwbc riskarea; by wholeday;run;
*Add Annotations;
data plotannotate;
input x y text$;
function='label'; xsys='2';ysys='2'; hsys='3';
datalines;
1 1 Sens
1.5 1 92%
2.5 1 60%
3.5 1 65%
4.5 1 70%
5.5 1 80%
6.5 1 91%
7.5 1 82%
;
run;
goptions reset=all;
symbol1 interpol=none value=dot;
*symbol2 i=none value=dot;
symbol2 interpol=join ;
proc gplot data=All;
where wholeday<=7;
*band x=dayspost upper=upper lower=WBCLevel;
plot currWBC*dayspost WBClevel*dayspost/ annotate=plotannotate overlay;
label infection="Infection";
run;

******************************************
Get diagnostic measures;
Data Diagnose; set All;
if currWBC>WBCLevel
then Alarm='Yes';
else Alarm='No';
run;
proc sort data=diagnose; by mrn alarm;run;
data diagnose2; set diagnose;by mrn alarm; if last.mrn;run;
proc freq data=diagnose2;
table Alarm*infection;
run;
