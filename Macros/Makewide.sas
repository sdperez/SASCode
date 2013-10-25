/***********************************************************************************************************************
Part I - Definition of Macros

	MAKEWIDE_BASIS
	MAKEWIDE


FOR MORE RESSOURCES ON DATA PREPARATION FOR ANALYTICS CHECK OUT:
http://www.sascommunity.org/wiki/Data_Preparation_for_Analytics

Dr. Gerhard Svolba
May 2008

************************************************************************************************************************/



%MACRO MAKEWIDE (DATA=,OUT=out,COPY=,ID=,
                 VAR=, TIME=time);

*** Macro that transposes from a LONG to a WIDE structure;

/*** PARAMETERS *******************************************************
DATA and OUT		        The names of the input and output data sets, respectively.
ID				The name of the ID variable that identifies the subject.
COPY				A list of variables that occur repeatedly with each observation for a subject and will be copied to the resulting data 
                                set. Note that the COPY variable(s) must not be used in the COPY statement of PROC TRANSPOSE for our purposes, but 
                                are listed in the BY statement after the ID variable. We assume here that COPY variables have the same values within 
                                one ID.
VAR				The variables that holds the values to be transposed.
TIME				The variable that numerates the repeated measurements.
**********************************************************************/

%MACRO MAKEWIDE_BASIS (DATA=,OUT=out,COPY=,ID=,
                 VAR=, TIME=time);
*** Macro that transposes one variable per by-group;
*** Dr. Gerhard Svolba, May 2nd 2008 - Rel 2.1; 
PROC TRANSPOSE DATA   = &data
               PREFIX = &var
               OUT    = &out(DROP = _name_);
 BY  &id &copy;
 VAR &var;
 ID  &time;
RUN;
%MEND;

*** Calculate number of variables;
%LET c=1; 
%DO %WHILE(%SCAN(&var,&c) NE); 
    %LET c=%EVAL(&c+1);
%END;
%LET nvars=%EVAL(&c-1);

%IF &nvars=1 %then %do; %*** macro is  called with only one variable;  
   %MAKEWIDE_BASIS(data=&data, out = &out, copy=&copy, id=&id, var=&var,time=&time);
%END; %** end: only 1 variable;

%ELSE %DO; ** more then 2 vars;

 %DO i = 1 %TO &nvars;
    %MAKEWIDE_BASIS(data=&data, out = _mw_tmp_&i., copy=&copy, id=&id, var=%scan(&var,&i),time=&time);
 %END; *** end do loop;

 data &out;
  merge %do i = 1 %to &nvars; _mw_tmp_&i. %end; ;
  by &id;
 run;


%END;


%MEND;



/***********************************************************************************************************************
Part II - CREATE DEMO DATASETS
************************************************************************************************************************/

/*
data dogs_long; 
      input ID  Drug $14. Depleted $ Measurement Histamine Heamoglobin; 
      datalines; 
1   Morphine       N    0    0.04      14.7
1   Morphine       N    1    0.2       14
1   Morphine       N    3    0.1       14.2
1   Morphine       N    5    0.08      14.1
2   Morphine       N    0    0.02      14.4
2   Morphine       N    1    0.06      14.5
2   Morphine       N    3    0.02      14.2
2   Morphine       N    5    0.02      14.2
3   Morphine       N    0    0.07      14.4
3   Morphine       N    1    1.4       14.2
3   Morphine       N    3    0.48      14.9
3   Morphine       N    5    0.24      14.2
4   Morphine       N    0    0.17      15
4   Morphine       N    1    0.57      14.9
4   Morphine       N    3    0.35      14.3
4   Morphine       N    5    0.24      14.3
5   Morphine       Y    0    0.1       14.5
5   Morphine       Y    1    0.09      14.7
5   Morphine       Y    3    0.13      14
5   Morphine       Y    5    0.14      14.2
6   Morphine       Y    0    0.12      14.4
6   Morphine       Y    1    0.11      14.5
6   Morphine       Y    3    0.1       14.9
6   Morphine       Y    5    .         15
7   Morphine       Y    0    0.07      14.3
7   Morphine       Y    1    0.07      14.5
7   Morphine       Y    3    0.06      14
7   Morphine       Y    5    0.07      14.1
8   Morphine       Y    0    0.05      14.3
8   Morphine       Y    1    0.07      14.1
8   Morphine       Y    3    0.06      14.7
8   Morphine       Y    5    0.07      14.2
9   Trimethaphan   N    0    0.03      14.1
9   Trimethaphan   N    1    0.62      14
9   Trimethaphan   N    3    0.31      14.1
9   Trimethaphan   N    5    0.22      14.4
10  Trimethaphan   N    0    0.03      14.1
10  Trimethaphan   N    1    1.05      14.7
10  Trimethaphan   N    3    0.73      14.5
10  Trimethaphan   N    5    0.6       14.3
11  Trimethaphan   N    0    0.07      14.6
11  Trimethaphan   N    1    0.83      15
11  Trimethaphan   N    3    1.07      14.2
11  Trimethaphan   N    5    0.8       14
12  Trimethaphan   N    0    0.09      14.5
12  Trimethaphan   N    1    3.13      14.4
12  Trimethaphan   N    3    2.06      14.3
12  Trimethaphan   N    5    1.23      14.1
13  Trimethaphan   Y    0    0.1       14.7
13  Trimethaphan   Y    1    0.09      14.3
13  Trimethaphan   Y    3    0.09      14.2
13  Trimethaphan   Y    5    0.08      14.6
14  Trimethaphan   Y    0    0.08      14.9
14  Trimethaphan   Y    1    0.09      14.2
14  Trimethaphan   Y    3    0.09      14.4
14  Trimethaphan   Y    5    0.1       14.1
15  Trimethaphan   Y    0    0.13      14.7
15  Trimethaphan   Y    1    0.1       14.7
15  Trimethaphan   Y    3    0.12      15
15  Trimethaphan   Y    5    0.12      14.5
16  Trimethaphan   Y    0    0.06      14.8
16  Trimethaphan   Y    1    0.05      14.9
16  Trimethaphan   Y    3    0.05      14.7
16  Trimethaphan   Y    5    0.05      14.5
   ; 
run;

/***********************************************************************************************************************
Part III - Example, Use Macro MAKEWIDE, to create a one-row-per-subject dataset
************************************************************************************************************************/

/*
%MAKEWIDE(data        = dogs_long, 
          out         = dogs_wide_out,
		  id          = id,
          copy        = drug depleted,
		  var         = histamine heamoglobin,
		  time        = measurement)


proc print data = dogs_wide_out;
run;

*/
