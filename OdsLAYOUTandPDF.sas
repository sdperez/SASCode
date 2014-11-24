
**************************************************
Example of using ODS LAYOUT and ODS PDF to create a 
report in SAS
*************************************************;
data class; set sashelp.class;
run;

*- Set options and nullify titles and footnotes -; 
options nodate nonumber center; 


*- ODS "escape" character to tell it that what follows is not text -; 
ods escapechar="^";
ods listing close; 


ods pdf file="\\nasn1ac.cc.emory.edu\surgery\SQOR\SurgeonValueComparisons\Colectomy\Reports\test.pdf" 
style=BarrettsBlue startpage=no; 
ODS Layout start width=8 in height=10 in;

*- produce the title -; 
title1 ; 
footnote1; 

ODS REGION x=0 in y=0 in width=7 in height=3 in;
ods pdf text="^S={preimage='C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Others\EmoryLogos\Emorysurgery.png'}";
ODS REGION x=0 in y=3 in width=7 in height=1 in;
ods pdf text="^S={just=c font_size=14pt font_face=Arial} ^n^nInclude a title^n some more";  

ODS REGION x=0 in y=4 in width=7 in height=10 in;
ods proclabel "School membership"; 
proc report missing nowd data=work.class contents="Class Members"; 
run;
ODS REGION x=2 in y=7 in width=7 in height=10 in;
ods pdf text="Second text field^n^n^n^n^n^nNext Page"; 
ods pdf close; 


ods listing; 
