libname r "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Studies\TransplantOutcomes";
libname library "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Studies\TransplantOutcomes";
data test; set r.transplant_outcomes_sebastian;
run; *this data set has 13 fields per patient with admission dates (and 13 for discharges) to identify
their readmissions. I want to be able to go through all their readmissions and get information on them;
data test2; set test;
array AdmStart (13) 
r1_admit_dt r2_admit_dt r3_admit_dt r4_admit_dt r5_admit_dt r6_admit_dt r7_admit_dt r8_admit_dt r9_admit_dt
r10_admit_dt r11_admit_dt r12_admit_dt r13_admit_dt; *this creates an array and places several variables in it that I
want to repeat a procedure on;
array AdmEnd (13) 
r1_disch_dt r2_disch_dt r3_disch_dt r4_disch_dt r5_disch_dt r6_disch_dt r7_disch_dt r8_disch_dt r9_disch_dt
r10_disch_dt r11_disch_dt r12_disch_dt r13_disch_dt; *another set of variables I want to act on;

array MonthN(36); *new set of variables. Notice I don't assign any current cvariables to each array item;
array Time(36);

*this checks whether a patient was admitted during a specifc month. The first do loop cycles through the 
months and the second cycles through each of the readmissions;
do j=1 to 36;
MonthN(j)=0;
Time(j)=j;
	do i=1 to 13;
	if 	(j-1)*30<(admstart(i)-date_transp)<=j*30 then MonthN(j)=1; 
	end;
end;
output;

run;

