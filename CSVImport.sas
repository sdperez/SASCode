
PROC IMPORT OUT= WORK.caseinf 
      DATAFILE= "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Studies\OutpatientAdmissions\Data\RawData\Case_Form.csv" 
      DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
