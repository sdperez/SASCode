*************************************
Examples of proc tabulate;

*Here (from NSQIP) we create a table with many variables divided into two columns.
First we look at a set of variables (rows) and then choose to split by 
whether they did or didn return to the OR;

proc tabulate data=return3;
class smoke etoh  hxcopd
cpneumon ascites esovar hxchf hxmi prvpci
prvpcs hxangina hypermed renafail dialysis impsens
hemi bleeddis returnor;	*Since these variables are categorical we include them in 'class' list;
table smoke etoh  hxcopd
cpneumon ascites esovar hxchf hxmi prvpci
prvpcs hxangina hypermed renafail dialysis impsens
hemi bleeddis, returnor*(n='n'*f=8.0 colpctn="%")
 ; 	*in the table statement we list the rows first (separated by spaces) then the columns (separated by a coma).
 After each variable you can define how you wan that displayed/formatted with an '*'.Here we requested counts (n)
 and named that column 'n' then gave a format of 8.0. We also request another column for percent.;
run; 


*Another example. In this example we converted categorical variables into 1s and 0s so we can do sums (instead of counts)
and do some other operations.
Every line in the data set has a 1 for 'sugeries' so that when we sum by surgeon it gives us their total surgeries.
The column ssi would have a 1 if infection 0 otherwise.
;

proc tabulate data=colect noseps;
class code;	*code is surgeon code and is categorical;
var surgeries ssi asa; *1s and 0s can be used as continuous variables;
keylabel n=' ' sum=' ' mean=' ' pctn=' ' pctsum=' '; *this blanks out a subtitle line for the columns;
table code="Surgeon", 
Surgeries='Total Colectomies'*f=2.0 
ssi='SSI   Number'*f=2.0 
ssi='SSI   Rate'*(pctsum<surgeries>)*f=9.1	
asa='%ASA Class 3, 4 or 5'*(pctsum<surgeries>)*f=9.1;
; *rows=suregon codes. next we count the number of surgeries and ssis (automatically uses sums).
We calculate ssi as a percentage of surgeries by using pctsum of 'surgeries'. Same for ASA.;
run;
