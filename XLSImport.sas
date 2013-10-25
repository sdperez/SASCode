PROC IMPORT OUT= WORK.BCT 
            DATAFILE= "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents
\Studies\XimenaMatch\BCT vs OP data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Styblo BCTs$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
