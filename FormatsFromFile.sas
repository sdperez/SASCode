**************************************************************************
Creating Formats from a Spreadsheet of Values
Instead of manually entering a list of values to use in a format you can import a spreadsheet
into a sas data file, then tell proc format to get the formats from the list of values there.

The file must include the variables, start, lable and FMTNAME. It can also optionally include an end variable.
This is so you can format a range of values (start=1, end=10, label='First Group') in a single label.
****************************************************************************;

*Import Formats/Dictionary for procedures;
PROC IMPORT OUT= WORK.ProcNames 
            DATAFILE= "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\CurrentStudies\ShipraReadmit\Data\CPTlookuptable.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="GroupDictonary$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data procnames; set procnames; FMTNAME='proc';run;
proc format cntlin=procnames;run; 
