data chitest;
input Group$ Outcome$ Count;
datalines;
Low 1Low 25
Low 2Med 40
Low 3Hi 57
Med 1Low 18
Med 2Med 33
Med 3Hi 55
Hi 1Low 9
Hi 2Med 18
Hi 3Hi 44
;
run;
proc freq data=chitest order=data;
weight count;
tables group*outcome/ cmh;
run;
proc freq data=chitest ;
weight count;
tables group*outcome/ cmh;
run;
