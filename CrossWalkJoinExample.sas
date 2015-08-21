**********************************
Example for doing a many-to-many join in SAS
by using a crosswalk dataset
***********************************;
data one; 
input group day;
datalines;
1 1
1 2
1 3
1 4
2 1
2 2
3 3
4 4
;
run;
data two;
input group result;
datalines;
1 1
1 2
1 3
1 4
1 5
1 6
2 1
2 2
2 3
2 4
3 1
3 2
3 3
4 1
4 2
4 3
;
run;
proc sort data=one; by group;
proc sort data=two; by group;
data twoxwalk; set two; by group;
if last.group;
run;

data firstmerge; merge one twoxwalk; by group;
do i=1 to result;
 result2=i;
 output;
end;
run;


data merged; merge  one two; by group;
run;
data merged2; merge  one two; by group day;
run;
