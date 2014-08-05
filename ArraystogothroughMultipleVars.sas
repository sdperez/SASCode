*******************************************************
ARRAYS:
Ways to go through multple variables per observation and
take the same action
********************************************************;

******************************
EXAMPLE 1:
stores 13 possible readmit dates and 13 discharge
dates in the arrays. Then uses a loop to go through 
the list and determine whether the patient was in or
out of the hospital in a given month (36 months checked)
*****************************;

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

******************************
EXAMPLE 2:
If the variables are in sequence then you can
use this shortcut to put them into the array
**********************************;
libname r 'C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\CurrentStudies\ShipraReadmit\Data';

*Select a subset of PUF file to work with;
proc surveyselect  data=r.Vascular
method=srs n=200 out=Sample;
run;

data sample2; set sample;
array labs(13) PRSODM--PRPT; *notice 13 variables are put into the array;
do i = 1 to 13;
 if labs(i)=-99 then labs(i)=.;
end;
output;
run;

*******************************
EXAMPLE 3:
You don't need to specify the dimension
of the array. Here, all numeric variables
are put into array a and all character into
array b.
****************************** ;
data sample3 ;
  set sample; 
    array _a_(*) _numeric_;
   array _b_(*) _character_;
   var1=dim(_a_);
   var2=dim(_b_);
   output;
run;
********************************
In the following case we put every variable name
into a dataset(as observations);

data new(keep=name type);
   set sample;
      /* all character variables in old */ 
   array abc{*} _character_;   
      /* all numeric variables in old */ 
   array def{*} _numeric_;     
      /* name is not in either array */
   length name $32;             
   do i=1 to dim(abc);
         /* get name of character variable */
      call vname(abc{i},name); 
	  type='number';
         /* write name and type to an observation */
      output;                  
   end;
   do j=1 to dim(def);
         /* get name of numeric variable */
      call vname(def{j},name); 	*also can do name=vname(def(i));
	   type='char';
         /* write name  and type to an observation */
      output;                  
   end;
   stop;
run;
*see also varnum function varlabel and vartype;

