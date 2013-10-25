PROC EXPORT DATA= WORK.CASES 
            OUTFILE= "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\
Studies\OutpatientAdmissions\Data\ForJeffLookup.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="nsqip"; 
RUN;
