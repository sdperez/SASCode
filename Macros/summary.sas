  /*------------------------------------------------------------------*
   | MACRO NAME  : summary
   | SHORT DESC  : Summarize specific variables and output results
   |               to an RTF file
   *------------------------------------------------------------------*
   | CREATED BY  : Lennon, Ryan                  (04/13/2004 10:30)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This program computes summaries and test statistics for
   | differences between two (or more) independent samples.
   | A nice feature is that it can output well-formatted tables
   | into a Rich Text File, which can be read directly into
   | MS Word.
   | See notes and sample code below. This program is dependent
   | on variable names of the output datasets created by SAS PROCS
   | with ODS as well as the output dataset for the %SURV macro.
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (06/22/2004 11:19)
   |
   | - Potential error for survival statistics if the CLASS variable is a
   |   character variable and one level's name is identical to the first
   |   N characters of another level name
   | - The upper and lower CI limits for K-M estimates were reversed when
   |   SURVOP=2
   | - Add parameters CWIDTH1, CWIDTH2, CWIDTH3 to allow user to designate
   |   column widths in the RTF output
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (09/14/2005  8:33)
   |
   | Made corrections for SAS9 version of ODS output from PROC FREQ
   |  Revised DATE/TIME footnote to appear under previously defined
   |   footnotes, rather than replace/delete them.
   |  Get log-rank test from PROC LIFETEST instead of %survlrk through %surv
   |  No variables over 26 characters in name
   |  Some other small programming changes
   |
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (06/30/2006  9:30)
   |
   | Fix a bug for CAT1 variables when one of the variables does not have
   |  any observations equal to 1. The problem was caused by not resetting
   |  variables in a retain statement. This was not a problem in the SAS8
   |  version of %SUMMARY.
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (01/11/2007  9:03)
   |
   | Correct LABLEN error in RTFOUT data set
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (10/22/2009 14:43)
   |
   | Added the SUR4, SDOPT, NEVENTS and DATA parameters. Gave additional
   | values to the SURVOP parameter so that K-M estimates may be reported
   | as percentages. Other minor changes to bring macro up to standards.
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (09/02/2011 13:37)
   |
   | Added SUR5 parameter to report median (Q1, Q3) of right-censored
   | data points.
   | Changed LABLEN parameter default to $60
   | Changed SDOPT default to 2
   | Changed frequency labels to "n (%)" instead of "No. (%)"
   | Changed capitalization of some statistic labels
   | Changed "P-value" to "P value" with italics
   | Altered display summary in log to only report positive counts
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %summary (
   |            data= ,
   |            con1= ,
   |            con2= ,
   |            con3= ,
   |            cat1= ,
   |            cat2= ,
   |            ord1= ,
   |            sur1= ,
   |            sur2= ,
   |            sur3= ,
   |            sur4= ,
   |            sur5= ,
   |            class= ,
   |            sdopt=2,
   |            points='182, 365',
   |            cen_vl=0,
   |            survop=1,
   |            sunits=days,
   |            cl=3,
   |            nevents=1,
   |            out=_out_,
   |            rtfout=_rtf_,
   |            rtffile= ,
   |            sortby= ,
   |            list= ,
   |            style= ,
   |            tbltitle= ,
   |            f1=6.1,
   |            f2=6.1,
   |            f3=6.1,
   |            f4=6.1,
   |            f5=6.1,
   |            f6=5.0,
   |            f7=3.0,
   |            f8=5.2,
   |            lablen=$60,
   |            pfmt=pvalue6.4,
   |            perfmt=5.1,
   |            printp=0,
   |            prints=1,
   |            cwidth1= ,
   |            cwidth2= ,
   |            cwidth3=400,
   |            ds=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : Input data set to be used. Replaces DS parameter.
   |
   | Name      : con1
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report mean +- S.D., one-way ANOVA
   |
   | Name      : con2
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report median (min, max), K-W rank sum test
   |
   | Name      : con3
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report median (Q1, Q3), K-W rank sum test
   |
   | Name      : cat1
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Give N (%) for variable=1, Pearson's Chi-square
   |
   | Name      : cat2
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Give N (%) for all levels, Pearson's Chi-square
   |
   | Name      : ord1
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Give N (%) for all levels, K-W rank sum test
   |
   | Name      : sur1
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report estimate (%), 95% CI, log-rank test
   |
   | Name      : sur2
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report estimate (%), # cum. events, log-rank test
   |
   | Name      : sur3
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report estimate (%), log-rank test
   |
   | Name      : sur4
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report # cum. events, estimate (%), log-rank test
   |
   | Name      : sur5
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Report median (Q1, Q3) of right-censored data
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : class
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : The variable which defines the groups, may be character
   |             or numeric
   |
   | Name      : sdopt
   | Default   : 2
   | Type      : Number (Single)
   | Purpose   : Choose how the standard deviation should be displayed
   |             1 = with +/- sign
   |             2 = in parentheses
   |
   | Name      : points
   | Default   : '182, 365'
   | Type      : Text
   | Purpose   : Designate the time points at which survival estimates
   |             should be reported, similar to POINTS parameter in %SURV
   |
   | Name      : cen_vl
   | Default   : 0
   | Type      : Number (Single)
   | Purpose   : Value to represent censored observations in survival,
   |             with the same comments as in %SURV
   |
   | Name      : survop
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Specify which estimate to report (default=1)
   |             1=The survival rate estimate (P(t))
   |             2=The event rate estimate (1-P(t))
   |             3=The survival rate estimate as a percentage
   |             4=The event rate estimate as a percentage
   |
   | Name      : sunits
   | Default   : days
   | Type      : Text
   | Purpose   : Specify the unit of the time to event variables for
   |             labelling (default=days)
   |
   | Name      : cl
   | Default   : 3
   | Type      : Number (Single)
   | Purpose   : Type of confidence limits for K-M estimates, see %SURV
   |             (default=3 (log-e transformation (log)))
   |
   | Name      : nevents
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Print the total number of events observed in follow-up for variables
   |             listed in the SUR1-SUR4 parameters.
   |             1 = Do not print
   |             2 = Print on the first line of the survival summary
   |             3 = Print on the last line of the survival summary
   |
   | Name      : out
   | Default   : _out_
   | Type      : Dataset Name
   | Purpose   : The data set in which the results are stored
   |
   | Name      : rtfout
   | Default   : _rtf_
   | Type      : Dataset Name
   | Purpose   : The data set in which results for RTF printing are
   |             stored
   |
   | Name      : rtffile
   | Default   :
   | Type      : Text
   | Purpose   : Rich text file name in which to store results, it should
   |             be surrounded in quotes, e.g. '~userid/consult/out.rtf'
   |
   | Name      : sortby
   | Default   :
   | Type      : Text
   | Purpose   : Sort the information before printing by these
   |             variables.  The options are:
   |             _list: Sort by the list given (see LIST)
   |             _pval: Sort by the p-value
   |             __var: Sort by variable names.
   |
   | Name      : list
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : List the variables in the order they should be reported,
   |             it does not have to include all variables
   |
   | Name      : style
   | Default   :
   | Type      : Text
   | Purpose   : Define a style for RTF output
   |
   | Name      : tbltitle
   | Default   :
   | Type      : Text
   | Purpose   : Give a name to the table
   |
   | Name      : f1
   | Default   : 6.1
   | Type      : Text
   | Purpose   : (RTF only) Mean format
   |
   | Name      : f2
   | Default   : 6.1
   | Type      : Text
   | Purpose   : (RTF only) Standard deviation format
   |
   | Name      : f3
   | Default   : 6.1
   | Type      : Text
   | Purpose   : (RTF only) Median format
   |
   | Name      : f4
   | Default   : 6.1
   | Type      : Text
   | Purpose   : (RTF only) Min,Max format
   |
   | Name      : f5
   | Default   : 6.1
   | Type      : Text
   | Purpose   : (RTF only) Q1,Q3 format
   |
   | Name      : f6
   | Default   : 5.0
   | Type      : Text
   | Purpose   : (RTF only) Count format
   |
   | Name      : f7
   | Default   : 3.0
   | Type      : Text
   | Purpose   : (RTF only) Percent format
   |
   | Name      : f8
   | Default   : 5.2
   | Type      : Text
   | Purpose   : (RTF only) K-M estimate format
   |
   | Name      : lablen
   | Default   : $60
   | Type      : Text
   | Purpose   : Maximum Label Length captured
   |
   | Name      : pfmt
   | Default   : pvalue6.4
   | Type      : Text
   | Purpose   : (SAS output) Format for the p-value
   |
   | Name      : perfmt
   | Default   : 5.1
   | Type      : Text
   | Purpose   : (SAS output) Format for the group statistics
   |
   | Name      : printp
   | Default   : 0
   | Type      : Number (Single)
   | Purpose   : Print FREQ, MEANS and NPAR1WAY results (1=Yes).
   |
   | Name      : prints
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Print the summary results in SAS output (1=Yes).
   |
   | Name      : cwidth1
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Column width in RTF file for the mean/median/frequency columns.
   |             Default is 120 if SUR1, CON2 or CON3 are used, 85 otherwise.
   |
   | Name      : cwidth2
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Column width in RTF file for S.D./Range/percentage columns.
   |             Default is 150 when SUR1 is used, 140 when CON2 or CON3 are used,
   |             100 otherwise.
   |
   | Name      : cwidth3
   | Default   : 400
   | Type      : Number (Single)
   | Purpose   : Column width in RTF file for variable labels.
   |
   | Name      : ds
   | Default   :
   | Type      : Dataset Name
   | Purpose   : The data set to be used
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | SAS output listing and data sets of summary statistics,
   | as well as RTF file if specified.
   |
   |
   |
   |
   |
   |
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | 1. This macro uses the %SURV macro for Kaplan-Meier estimates.
   | 2. It is a good idea to have all variables formatted, especially the
   |    CLASS variable
   | 3. For survival analysis, list time and event variables together in
   |    that order. For example,
   |    "SUR1 = time1 event1 time2 event2 time3 event3,".
   |    The pairs are listed together, with the time to event variable first.
   |    The label of the EVENT variable will be used in the RTF output.
   |    Use the EVENT variable to refer to the variable pair in the LIST
   |    parameter.
   | 4. POINTS values must NOT have more than 5 decimal points, i.e. all
   |    zeros after the fifth decimal spot. For example, '100.231442' is
   |    unacceptable. Furthermore, survival estimates at TIME=0 are not
   |    available for the summary table.
   | 5. You can sort the results by any combination of variables found in
   |    the &OUT dataset and use the DESCENDING option as well.
   | 6. The macro will set 'options validvarname=v7;' so that variable
   |    names longer than 8 characters will be allowed within the macro only.
   |    At the end of the macro, the validvarname option will be set back to
   |    its value prior to macro invocation. However, variable names longer
   |    than 26 characters will not be allowed.
   | 7. CAT2 may contain SAS numeric or character variables, all other
   |    variable lists should contain SAS numeric variables.
   | 8. The RTFOUT dataset is still created even if RTFFILE is blank.
   | 9. A variable should occur in only ONE display parameter list,
   |    i.e. don't put 'age' in both CON1 and CON2. You must create an
   |    identical variable with a different name to show different
   |    statistics.
   | 10. Variables which have all missing values will not be analyzed.
   |    Notification of this occurrence is sent to the SAS log.
   | 11.If the number of variables analyzed is large, you may get warning
   |    messages about unbalanced quotation marks. These may be ignored.
   | 12.Data sets (potentially) created:
   |      ____cout ____s1 _misout_ _Tmiss_ _tmpchk_ _tmpout_ _f _tempd_
   |      __groups _Chisq_ _CTF_ _Freq1-_Freq(#catvars) _freq _freqs _summ1_
   |      _means_ _anova_ _kwt_ _labs _tmeans_ _summ2_ _summ3_ _surv_ _ssum_
   |      _lr_ _totn_ _tmp_ _counts_ _print_ _tmp1_ _surv1-_surv(#Pairs)
   |      _summ4_ _fsumm_ _list &OUT &RTFOUT
   | 13. Created data sets that are NOT deleted:  &OUT &RTFOUT
   |
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | title1 'Sample execution of %SUMMARY';
   | footnote "Randomly generated data";
   |
   | proc format;
   |   value groupf  1="Group A" 2="Group B";
   |   value x5f     0="Failure" 1="Success";
   |  run;
   |
   | data a;
   |   do Group=1 to 2;
   |     do i=1 to 100;
   |        X1 = rannor(0);
   |        X2 = 100*ranexp(0);
   |        X3 = exp(rannor(0));
   |        X4 = ranbin(0, 1, 0.5);
   |        X5 = ranbin(0, 1, 0.7);
   |        X6 = ranbin(0, 4, 0.8);
   |        X7a = 100*ranexp(0);
   |        X7b = (X7a<X2);
   |        output;
   |      end;
   |   end;
   |   label X1="Normal variate"
   |         X2="Exponential variate"
   |         X3="Log-normal variate"
   |         X4="Bernoulli variate"
   |         X5="Formatted Bernoulli"
   |         X6="Ordinal variate"
   |         X7a="Time to event/censor"
   |         X7b="Event";
   |    format group groupf. X5 x5f.;
   |  run;
   |
   | options nomprint nosymbolgen;
   | %summary(ds=a,
   |          class=group,
   |          rtffile="summary.rtf",
   |          con1=x1,
   |          con2=x2,
   |          con3=x3,
   |          cat1=x4,
   |          cat2=x5,
   |          ord1=x6,
   |          sur1=x7a x7b,
   |          points='50 to 300 by 50',
   |          sunits=days ,
   |          survop=4,
   |          nevents=2,
   |          sortby=_list,
   |          list=x2 x7b x1 x6,
   |          tbltitle=Data summaries);
   |
   |
   *------------------------------------------------------------------*
   | Copyright 2011 Mayo Clinic College of Medicine.
   |
   | This program is free software; you can redistribute it and/or
   | modify it under the terms of the GNU General Public License as
   | published by the Free Software Foundation; either version 2 of
   | the License, or (at your option) any later version.
   |
   | This program is distributed in the hope that it will be useful,
   | but WITHOUT ANY WARRANTY; without even the implied warranty of
   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   | General Public License for more details.
   *------------------------------------------------------------------*/
 
 
 
%MACRO SUMMARY(data=,
               class=,
               out=_out_,
               rtfout=_rtf_,
               rtffile= ,
               con1=,
               con2=,
               con3=,
               cat1=,
               cat2=,
               ord1=,
               sur1=,
               sur2=,
               sur3=,
               sur4=,
               sur5=,
               sdopt=2,
               points='182, 365',
               survop=1,
               sunits=days,
               cen_vl=0,
               nevents=1,
               cl=3,
               sortby=,
               list=,
               style=,
               tbltitle=  ,
               f1= 6.1,
               f2= 6.1,
               f3= 6.1,
               f4= 6.1,
               f5= 6.1,
               f6= 5.0,
               f7= 3.0,
               f8= 5.2,
               lablen = $60,
               pfmt=pvalue6.4,
               perfmt=5.1,
               cwidth1=,
               cwidth2=,
               cwidth3=400,
               printp=0,
               prints=1,
               ds=);
 
%LOCAL VALID DATEON ERRORFLG LEVELS LOOP CLASSTYP
       NMCON1 NMCON2 NMCON3 NMCAT1 NMCAT2 NMORD1
       NMSUR1 NMSUR2 NMSUR3 NMSUR4 NMLIST NOMORE COUNT
       ICON1 ICON2 ICON3 ICAT1 ICAT2 IORD1 ISUR1 ISUR2 ISUR3 ISUR4 ILIST
       CON1V CON2V CON3V CAT1V CAT2V ORD1V SUR1V SUR2V SUR3V SUR4V SUR5V
       LISTV TOTNM TOTVARN
       A1 A2 A3 A4 A5 B1 B2 B3 B4 B5 EVEN1 EVEN2 EVEN3 EVEN4 EVEN5
       FN FLOOP
       ICAT RMSTRING CATVARN ICON NOWCON AOVL KWTL CONVARN
       IORD NOWORD ORDVARN ISUR SUR SUBTRACT PERCMULT
       VFCLASS SLOOP TMVAR EVVAR
       VARPAIR LEV DATENOW TIMENOW CW1 CW2 FPLUS1;
 
%let valid=%sysfunc(getoption(validvarname));
%let dateon=%sysfunc(getoption(nodate));
 
options validvarname=v7 nodate;
 
 
 
*********************************************************************
*********************************************************************
                       CHECK ERRORS IN CALL
*********************************************************************
*********************************************************************;
 
%LET ERRORFLG=0;
 
%IF (&DATA= ) & (&DS= ) %THEN %DO;
    %PUT "ERROR: No input data set identified in DATA parameter.
          Macro will stop executing.";
    %LET ERRORFLG=1;
  %END;
%ELSE %IF (&DATA^= ) & (&DS^= ) &
         (%UPCASE(&DATA)^=%UPCASE(&DS)) %THEN %PUT
 "WARNING: Different input data sets were identified by the DATA and DS
  input parameters. &DATA (DATA) will be used.";
 
%IF (&DATA= ) %THEN %LET DATA=&DS;
 
 
 
******************** NO VARIABLES OVER 26 CHARACTERS LONG ***********;
 data _null_;
  retain _vlist1_ "&CON1 &CON2 &CON3 ";
  retain _vlist2_ "&CAT1 &CAT2 ";
  retain _vlist3_ "&ORD1 ";
  retain _vlist4_ "&SUR1 &SUR2 &SUR3 &SUR4 &SUR5 ";
  i=0; stop=0;
  do until (stop=1);
     i=i+1;
     conv = scan(_vlist1_, i);
     catv = scan(_vlist2_, i);
     ordv = scan(_vlist3_, i);
     surv = scan(_vlist4_, i);
     if missing(conv)=1 and missing(catv)=1 and missing(ordv)=1
        and missing(surv)=1 then stop=1;
     if length(trim(conv))>26 then BadCon=1;
     if length(trim(catv))>26 then BadCat=1;
     if length(trim(ordv))>26 then BadOrd=1;
     if length(trim(surv))>26 then BadSur=1;
    end;
  if badcon | badcat | badord | badsur then do;
    put "ERROR - A variable name is longer than 26 characters";
    badvar=1; call symput('ERRORFLG', left(put(badvar, 2.0)));
   end;
 run;
 
 
 
*********** ELIMINATE VARIABLES WITH COMPLETE MISSINGNESS ***********;
 
%MACRO NEWLIST(DSET, list);
  %LOCAL LIST LIST2 COND NEWCAT2 ICT2 CTVAR NEXVAR OKCAT2 CAT2;
 
  %LET LIST=%UPCASE(&LIST);
  %LET LIST2=%str(&)&list;
 
 
  %IF (&CLASS= ) %THEN %LET COND= ;
   %ELSE %LET COND=%str( where missing(&CLASS)=0;);
 
 
  %IF &LIST=CAT2 %THEN %DO;
 
     %LET NEWCAT2= ;
     %LET ICT2=1;
     %LET CTVAR=%SCAN(&CAT2,&ICT2);
     %LET NEXVAR=&CTVAR;
     %DO %WHILE(&NEXVAR NE );
 
       %LET CTVAR=&NEXVAR;
       %LET ICT2=%EVAL(&ICT2+1);
       %LET NEXVAR=%SCAN(&CAT2,&ICT2);
 
       %LET OKCAT2= ;
       proc freq data=&DSET noprint;
         &COND;
         table &CTVAR/ out=____cout;
       run;
       proc means noprint data=____cout sum;
         var percent; output out=____s1 sum=_s;
       run;
       data _null_;
         set ____s1;
         if _s=. then ok=0; else ok=1;
         call symput('OKCAT2',put(ok,1.0));
         if ok=0 then do;
            put
       "WARNING: Variable &CTVAR in list CAT2 is completely missing.";
            put "WARNING: &CTVAR will not be analyzed.";
          end;
        run;
       %IF &OKCAT2=1 %THEN %LET NEWCAT2=&NEWCAT2 &CTVAR;
       proc datasets nolist; delete ____cout ____s1; run; quit;
      %END;
 
     %LET CAT2=&NEWCAT2;
   %END;
  %ELSE %DO;
 
     proc means noprint data=&DSET n;
       &COND;
       var &LIST2;
       output out=_misout_  n=&LIST2;
     proc transpose data=_misout_ out=_Tmiss_; run;
     data _tmiss_;
       set _tmiss_;
       if _NAME_ ne '_TYPE_'; if _NAME_ ne '_FREQ_';
      run;
 
      %IF (&LIST=CON1) or (&LIST=CON2) or (&LIST=CON3)
       or (&LIST=CAT1) or (&LIST=ORD1) %THEN %DO;
        data _null_;
           ** Get enough variable length for _vlist_ **;
          retain _vlist_ "&CON1 &CON2 &CON3 &CAT1 &ORD1  ";
          if _N_=1 then _vlist_=" ";
          retain change 0;
          set _Tmiss_ end=eof;
          if col1 ne 0 then _vlist_=trim(left(_vlist_))||" "||_NAME_;
          if col1=0 then do;
             change=1;
             put
     "WARNING: Variable " _NAME_ "in list &LIST is completely missing.";
             put "WARNING: " _NAME_ "will not be analyzed.";
            end;
          if eof=1 then do;
            if change=1 then call symput("&LIST", trim(_vlist_));
           end;
         run;
       %END;
 
      %IF (&LIST=SUR1) or (&LIST=SUR2) or (&LIST=SUR3) or (&LIST=SUR4)
      %THEN %DO;
        data _null_;
          retain _vlist_ " &SUR1 &SUR2 &SUR3 &SUR4 &SUR5";
          retain _v2_ " &SUR1 &SUR2 &SUR3  &SUR4 &SUR5";
          retain __lname " &SUR1 &SUR2 &SUR3 &SUR4 &SUR5";
          if _N_=1 then do; _vlist_=" "; _v2_=" "; __lname=" "; end;
          retain change 0;
          set _Tmiss_ end=eof;
          odd= mod(_N_, 2);
          if odd=1 then do;
            if col1 ne 0 then _v2_=_NAME_;
            else do;
               _v2_=" ";
               put
    "WARNING: Variable " _NAME_ " in list &LIST is completely missing.";
             end;
           end;
          if odd=0 then do;
            if ((col1 ne 0) and (_v2_ ne ' ')) then
              _vlist_=trim(left(_vlist_))||" "
                      ||compress(_v2_)||" "||compress(_NAME_);
             else do;
               change=1;
               if col1=0 then
                 put
    "WARNING: Variable " _NAME_ " in list &LIST is completely missing.";
               put
    "WARNING: " __lname "/" _NAME_ " will not be analyzed.";
              end;
           end;
          __lname=_NAME_;
          if eof=1 then do;
            if change=1 then call symput("&LIST", trim(_vlist_));
           end;
         run;
       %END;
     proc datasets nolist; delete _misout_ _Tmiss_; run; quit;
   %END;
 
%MEND NEWLIST;
 
 
%IF (&CON1 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=CON1); %END;
%IF (&CON2 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=CON2); %END;
%IF (&CON3 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=CON3); %END;
%IF (&CAT1 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=CAT1); %END;
%IF (&CAT2 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=CAT2); %END;
%IF (&ORD1 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=ORD1); %END;
%IF (&SUR1 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=SUR1); %END;
%IF (&SUR2 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=SUR2); %END;
%IF (&SUR3 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=SUR3); %END;
%IF (&SUR4 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=SUR4); %END;
%IF (&SUR5 NE ) %THEN %DO; %NEWLIST(dset=&DATA, list=SUR5); %END;
 
 
 
******************** COUNT NUMBER OF VARIABLES **********************;
 
%LET NMCON1=0; %LET NMCON2=0; %LET NMCON3=0;
%LET NMCAT1=0; %LET NMCAT2=0;
%LET NMORD1=0;
%LET NMSUR1=0; %LET NMSUR2=0; %LET NMSUR3=0; %LET NMSUR4=0;
 %LET NMSUR5=0;
%LET NMLIST=0;
%LET NOMORE=0; %LET COUNT=0;
 
%DO %UNTIL (&NOMORE=1);
  %IF &NMCON1=0 %THEN %LET ICON1=&COUNT;
  %IF &NMCON2=0 %THEN %LET ICON2=&COUNT;
  %IF &NMCON3=0 %THEN %LET ICON3=&COUNT;
  %IF &NMCAT1=0 %THEN %LET ICAT1=&COUNT;
  %IF &NMCAT2=0 %THEN %LET ICAT2=&COUNT;
  %IF &NMORD1=0 %THEN %LET IORD1=&COUNT;
  %IF &NMSUR1=0 %THEN %LET ISUR1=&COUNT;
  %IF &NMSUR2=0 %THEN %LET ISUR2=&COUNT;
  %IF &NMSUR3=0 %THEN %LET ISUR3=&COUNT;
  %IF &NMSUR4=0 %THEN %LET ISUR4=&COUNT;
  %IF &NMSUR5=0 %THEN %LET ISUR5=&COUNT;
  %IF &NMLIST=0 %THEN %LET ILIST=&COUNT;
 
  %LET COUNT=%EVAL(&COUNT + 1);
  %LET CON1V=%SCAN(&CON1, &COUNT);
  %LET CON2V=%SCAN(&CON2, &COUNT);
  %LET CON3V=%SCAN(&CON3, &COUNT);
  %LET CAT1V=%SCAN(&CAT1, &COUNT);
  %LET CAT2V=%SCAN(&CAT2, &COUNT);
  %LET ORD1V=%SCAN(&ORD1, &COUNT);
  %LET SUR1V=%SCAN(&SUR1, &COUNT);
  %LET SUR2V=%SCAN(&SUR2, &COUNT);
  %LET SUR3V=%SCAN(&SUR3, &COUNT);
  %LET SUR4V=%SCAN(&SUR4, &COUNT);
  %LET SUR5V=%SCAN(&SUR5, &COUNT);
  %LET LISTV=%SCAN(&LIST, &COUNT);
 
  %IF (&CON1V= ) %THEN %LET NMCON1=1;
  %IF (&CON2V= ) %THEN %LET NMCON2=1;
  %IF (&CON3V= ) %THEN %LET NMCON3=1;
  %IF (&CAT1V= ) %THEN %LET NMCAT1=1;
  %IF (&CAT2V= ) %THEN %LET NMCAT2=1;
  %IF (&ORD1V= ) %THEN %LET NMORD1=1;
  %IF (&SUR1V= ) %THEN %LET NMSUR1=1;
  %IF (&SUR2V= ) %THEN %LET NMSUR2=1;
  %IF (&SUR3V= ) %THEN %LET NMSUR3=1;
  %IF (&SUR4V= ) %THEN %LET NMSUR4=1;
  %IF (&SUR5V= ) %THEN %LET NMSUR5=1;
  %IF (&LISTV= ) %THEN %LET NMLIST=1;
  %LET TOTNM = %EVAL(&NMCON1 + &NMCON2 + &NMCON3 + &NMCAT1 + &NMCAT2
                   + &NMORD1 + &NMSUR1 + &NMSUR2 + &NMSUR3 + &NMSUR4
                   + &NMSUR5 + &NMLIST);
  %IF (&TOTNM=12) %THEN %LET NOMORE=1;
 %END;
 
 
*__________________________________________________________________;
 
 
 
 
*** Check at least one variable was specified ***;
%LET TOTVARN =
  %EVAL(&ICON1+&ICON2+&ICON3+&ICAT1+&ICAT2+&IORD1
       +&ISUR1+&ISUR2+&ISUR3+&ISUR4+&ISUR5);
%IF &TOTVARN=0 %THEN %DO;
  %PUT ERROR - No variables were specified for summarization.;
  %LET ERRORFLG=1;
 %END;
 
 
 
*** Check all continuous variables are SAS numeric ***;
%IF &ERRORFLG^=1 %THEN %DO;
data _null_;
  set &DATA;
  if _N_=1;
  badvar=0;
  %DO LOOP=1 %TO &ICON1;
    if vtype(%scan(&CON1, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&CON1, &LOOP) is not numeric, but was listed in CON1";
     end;
   %END;
  %DO LOOP=1 %TO &ICON2;
    if vtype(%scan(&CON2, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&CON2, &LOOP) is not numeric, but was listed in CON2";
     end;
   %END;
  %DO LOOP=1 %TO &ICON3;
    if vtype(%scan(&CON3, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&CON3, &LOOP) is not numeric, but was listed in CON3";
     end;
   %END;
  %DO LOOP=1 %TO &ICAT1;
    if vtype(%scan(&CAT1, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&CAT1, &LOOP) is not numeric, but was listed in CAT1";
     end;
   %END;
  %DO LOOP=1 %TO &IORD1;
    if vtype(%scan(&ORD1, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&ORD1, &LOOP) is not numeric, but was listed in ORD1";
     end;
   %END;
  %DO LOOP=1 %TO &ISUR1;
    %LET SVAR = %scan(&SUR1, &LOOP);
    if vtype(&SVAR)='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&SUR1, &LOOP) is not numeric, but was listed in SUR1";
     end;
   %END;
  %DO LOOP=1 %TO &ISUR2;
    if vtype(%scan(&SUR2, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&SUR2, &LOOP) is not numeric, but was listed in SUR2";
     end;
   %END;
  %DO LOOP=1 %TO &ISUR3;
    if vtype(%scan(&SUR3, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&SUR3, &LOOP) is not numeric, but was listed in SUR3";
     end;
   %END;
  %DO LOOP=1 %TO &ISUR4;
    if vtype(%scan(&SUR4, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&SUR4, &LOOP) is not numeric, but was listed in SUR4";
     end;
   %END;
  %DO LOOP=1 %TO &ISUR5;
    if vtype(%scan(&SUR5, &LOOP))='C' then do;
      badvar=1;
      put
 "ERROR - %scan(&SUR5, &LOOP) is not numeric, but was listed in SUR5";
     end;
   %END;
  if badvar=1 then call symput('ERRORFLG', left(put(badvar, 2.0)));
 run;
 
 
*** MAKE SURE VARIABLES WERE NOT LISTED TWICE ***;
data _tmpchk_;
  attrib _var length=$32;
  %DO LOOP=1 %TO &ICON1; _var="%upcase(%scan(&con1, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ICON2; _var="%upcase(%scan(&con2, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ICON3; _var="%upcase(%scan(&con3, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ICAT1; _var="%upcase(%scan(&cat1, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ICAT2; _var="%upcase(%scan(&cat2, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &IORD1; _var="%upcase(%scan(&ord1, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ISUR1; _var="%upcase(%scan(&sur1, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ISUR2; _var="%upcase(%scan(&sur2, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ISUR3; _var="%upcase(%scan(&sur3, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ISUR4; _var="%upcase(%scan(&sur4, &LOOP))"; output;
   %END;
  %DO LOOP=1 %TO &ISUR5; _var="%upcase(%scan(&sur5, &LOOP))"; output;
   %END;
 proc freq noprint;
   table _var / out=_tmpout_;
 data _null_;
   set _tmpout_;
   if count>1 then do;
     put 'ERROR - A variable was listed more than once. ' _var= count= ;
     dummy=1;
     call symput('ERRORFLG', left(put(dummy, 2.0)));
    end;
  run;
 
proc datasets nolist; delete _tmpchk_ _tmpout_; run; quit;
%END;
 
%IF (&SDOPT^=1) AND (&SDOPT^=2) %THEN %DO;
  %PUT ERROR - SDOPT parameter must be 1 or 2.;
  %LET ERRORFLG=1;
 %END;
 
%IF (&NEVENTS^=1) AND (&NEVENTS^=2) AND (&NEVENTS^=3) %THEN %DO;
  %PUT ERROR - NEVENTS parameter must be 1, 2 or 3.;
  %LET ERRORFLG=1;
 %END;
 
%IF (&LIST^= ) AND (&SORTBY= ) %THEN %DO;
  %PUT WARNING - Variables were listed in the LIST parameter,
 but the SORTBY parameter is unspecified.;
  %PUT;
 %END;
 
 
 
**** MAKE SURE SURVIVAL PARAMETERS HAVE EVEN COUNTS ****;
 %LET A1=%EVAL(&ISUR1/2); %LET B1=%EVAL((&ISUR1+1)/2);
 %LET A2=%EVAL(&ISUR2/2); %LET B2=%EVAL((&ISUR2+1)/2);
 %LET A3=%EVAL(&ISUR3/2); %LET B3=%EVAL((&ISUR3+1)/2);
 %LET A4=%EVAL(&ISUR4/2); %LET B4=%EVAL((&ISUR4+1)/2);
 %LET A5=%EVAL(&ISUR5/2); %LET B5=%EVAL((&ISUR5+1)/2);
 %LET EVEN1=0;
 %LET EVEN2=0;
 %LET EVEN3=0;
 %LET EVEN4=0;
 %LET EVEN5=0;
 %IF (&A1=&B1) %THEN %LET EVEN1=1;
 %IF (&A2=&B2) %THEN %LET EVEN2=1;
 %IF (&A3=&B3) %THEN %LET EVEN3=1;
 %IF (&A4=&B4) %THEN %LET EVEN4=1;
 %IF (&A5=&B5) %THEN %LET EVEN5=1;
 
 %IF (&EVEN1=0) %THEN %DO;
    %PUT ERROR - An odd number (&ISUR1) of variables were listed in the
 SUR1 parameter.;
    %PUT; %LET ERRORFLG=1;
   %END;
 %IF (&EVEN2=0) %THEN %DO;
    %PUT ERROR - An odd number (&ISUR2) of variables were listed in the
 SUR2 parameter.;
    %PUT; %LET ERRORFLG=1;
   %END;
 %IF (&EVEN3=0) %THEN %DO;
    %PUT ERROR - An odd number (&ISUR3) of variables were listed in the
 SUR3 parameter.;
    %PUT; %LET ERRORFLG=1;
   %END;
 %IF (&EVEN4=0) %THEN %DO;
    %PUT ERROR - An odd number (&ISUR4) of variables were listed in the
 SUR4 parameter.;
    %PUT; %LET ERRORFLG=1;
   %END;
 %IF (&EVEN5=0) %THEN %DO;
    %PUT ERROR - An odd number (&ISUR5) of variables were listed in the
 SUR5 parameter.;
    %PUT; %LET ERRORFLG=1;
   %END;
 
**** Other parameter checks ****;
%IF &CEN_VL ^= 0 and &CEN_VL ^= 1 %THEN %DO;
   %PUT  ERROR - Parameter <CEN_VL> not defined as 0 or 1;
   %LET  ERRORFLG = 1;
   %END;
%IF &CL<1 or &CL>8  %THEN %DO;
   %PUT ERROR - Parameter <CL> is not 1-8;
   %LET ERRORFLG = 1;
   %END;
 
 
 
%IF &ERRORFLG=0 %THEN %DO;
*____________________________________________________________________;
*____________________________________________________________________;
*____________________________________________________________________;
 
 
 
 
*********************************************************************
                          STORE FOOTNOTES
*********************************************************************;
 proc sql ;
    create table work._f as select *
      from dictionary.titles where type='F';
    reset noprint; quit;
 
 proc sql;
   reset noprint;
   select nobs into :FN from dictionary.tables
   where libname="WORK" & memname="_F";
 quit;
  %IF (&FN>=1) %THEN %DO FLOOP=1 %TO &FN;
      %LOCAL FOOT&FLOOP;
      %END;
 
*** Store footnotes in macro variables ***;
%LET FOOT1= ;** Initialize at least one title **;
data _null_;
  set _f;
  %IF (&FN>=1) %THEN %DO FLOOP=1 %TO &FN;
     if number=&FLOOP then call symput("FOOT&FLOOP", trim(left(text)));
     %END;
 run;
 
*____________________________________________________________________;
*____________________________________________________________________;
 
 
 
 
 
*********************************************************************
                 GET NUMBER OF CLASSIFICATION LEVELS
*********************************************************************;
data _tempd_;
    set &DATA;
    *** We dont want the name of the class variable to cause problems
        in  ODS data sets. ;
    %IF (&CLASS= ) %THEN %DO;
      ___class="Overall";
     %END;
    %ELSE %DO;
      rename &CLASS = ___class;
     %END;
 run;
 
ods listing close;
 
ods output OneWayFreqs=__groups;
 
proc freq data=_tempd_;
  table ___class / nocol norow nopercent;
 run;
 
ods listing;
 
 
data _null_; set __groups nobs=_lev_ end=_eof;
  call symput('LEVELS', left(put(_lev_,2.)));
  if _eof then do;
      ctype=vtype(___class);
      call symput ('CLASSTYP',trim(left(ctype)));
    end;
 run;
 
%DO LOOP=1 %TO &LEVELS;
    %LOCAL TVAL&LOOP TLAB&LOOP TNUM&LOOP;
    %END;
 
data _null_; set __groups;
  retain  _tmlab1-_tmlab&LEVELS _tmn1-_tmn&LEVELS _tmv1-_tmv&LEVELS;
  length  _tmlab1-_tmlab&LEVELS $24;
  %DO LOOP=1 %TO &LEVELS;
    if _N_=&LOOP then do;
      %IF &CLASSTYP=C %THEN %DO;
        _tmv&LOOP='"'||trim(left(___class))||'"';
       %END;
      %IF &CLASSTYP=N %THEN %DO; _tmv&LOOP=trim(put(___class, 10.4));
       %END;
      _tmlab&LOOP = trim(left(F____class));
      _tmn&LOOP = trim(put(Frequency, 9.0));
     end;
        *** Assign levels and freqs to MACRO variables ***;
    call symput("TVAL&LOOP", trim(left(_tmv&LOOP)));
    call symput("TLAB&LOOP", left(_tmlab&LOOP));
    call symput("TNUM&LOOP", trim(left(_tmn&LOOP)));
   %END;
 run;
 
proc datasets nolist;
  delete __groups; run; quit;
 
%PUT The CLASS variable (&CLASS) has &LEVELS levels.;
%PUT;
 
 
%PUT ****** DISPLAY SUMMARY ******;
%IF (&ICON1>0) %THEN %PUT CON1: &ICON1 VARIABLES;
%IF (&ICON2>0) %THEN %PUT CON2: &ICON2 VARIABLES;
%IF (&ICON3>0) %THEN %PUT CON3: &ICON3 VARIABLES;
%IF (&ICAT1>0) %THEN %PUT CAT1: &ICAT1 VARIABLES;
%IF (&ICAT2>0) %THEN %PUT CAT2: &ICAT2 VARIABLES;
%IF (&IORD1>0) %THEN %PUT ORD1: &IORD1 VARIABLES;
%IF (&ISUR1>0) %THEN %PUT SUR1: &ISUR1 VARIABLES;
%IF (&ISUR2>0) %THEN %PUT SUR2: &ISUR2 VARIABLES;
%IF (&ISUR3>0) %THEN %PUT SUR3: &ISUR3 VARIABLES;
%IF (&ISUR4>0) %THEN %PUT SUR4: &ISUR4 VARIABLES;
%IF (&ISUR5>0) %THEN %PUT SUR5: &ISUR5 VARIABLES;
%PUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
 
*____________________________________________________________________;
 
 
 
*********************************************************************;
********************** CATEGORICAL SUMMARY **************************;
 
*********************************************************************;
%LET ICAT=%EVAL(&ICAT1 + &ICAT2);
 
%IF (&ICAT>0) %THEN %DO;
 
 
 %IF  (&PRINTP ne 1)  %THEN %DO; ods listing close; %END;
 
 ***** Assign output to datasets ******;
 %IF &LEVELS NE 1 %THEN %DO;
   ods output Chisq=_Chisq_;
  %END;
 
 %IF "&SYSVER">="9" %THEN %DO;
   ods output CrossTabFreqs=_CTF_;
  %END;
 %ELSE %DO;
 
   ********* VERSION 8 only ************;
   %DO LOOP=1 %TO &ICAT;
     %IF &LOOP=1 %THEN %DO;
       ods output CrossTabFreqs=_Freq1;
      %END;
     %ELSE %DO;
       ods output CrossTabFreqs&LOOP=_Freq&LOOP;
      %END;
    %END;
 
  %END;
 
 
 ***** Get stats from PROC FREQ *****;
 proc freq data=_tempd_   ;
   table
   ___class*(&cat1 &cat2)
   / sparse
   %IF &LEVELS NE 1 %THEN %DO;  chisq  %END;
    ;
  run;
 
 %IF  (&PRINTP ne 1)  %THEN %DO; ods listing; %END;
 
   ********* VERSION 8 only ************;
     **** Put all CrossFreqs together ****;
 
%IF "&SYSVER"<"9" %THEN %DO;
    %DO LOOP=1 %TO &ICAT;
      data _ctf_;
        set
        %IF &LOOP>1 %THEN %DO; _ctf_ %END;
        _FREQ&LOOP;
       run;
 
    %END;
   %END;
 
 
 ***** Get Chi-sq p-values for each variable *****;
 %IF &LEVELS NE 1 %THEN %DO;
   %IF "&SYSVER"<"9" %THEN %LET RMSTRING=___class_by_;
    %ELSE %LET RMSTRING=Table ___class * ;
   data _Chisq_;
     attrib __var length=$32;
     set _Chisq_;
     keep _pval __var;
 
     if Statistic='Chi-Square' then do;
       __var = upcase(left(tranwrd(Table,"&RMSTRING"," ")));
       _pval = Prob;
       output;
      end;
    run;
   %END;
 
 
 
 
  **** New data step needed for SAS9 ****;
  data _ctf_; set _ctf_;
    retain _i 0;
    if table ne lag(table) then _i=_i+1;
   run;
  proc sort data=_ctf_; by _i &CAT1 &CAT2 ___class;
 
 
     %DO LOOP=1 %TO &ICAT; %LOCAL VF&LOOP; %END;
     data _null_; *** Get var. format ***;
       attrib _vf length=$16;
        set _ctf_;
        %DO LOOP=1 %TO &ICAT;
        %LET CATVARN=%SCAN(&CAT1 &CAT2, &LOOP);
         _vf = vformat(&catvarn);
         call symput("VF&LOOP", _vf);
         %END;
      run;
 
  data _FREQ;
    set _ctf_; by _i &CAT1 &CAT2 ___class;
    keep _m1-_m&LEVELS _s1-_s&LEVELS __n _i _i2 _lab __var;
 
    length __var $32 _lab &LABLEN _vf $16;
    retain i 1  _m1-_m&LEVELS _s1-_s&LEVELS __n validobs _i2;
    array m(&LEVELS)  _m1-_m&LEVELS;
    array s(&LEVELS)  _s1-_s&LEVELS;
 
    if first._i then i=1;
 
    %DO LOOP=1 %TO &ICAT; *** Get variable name ***;
      %LET CATVARN=%SCAN(&CAT1 &CAT2, &LOOP);
      if _i=&LOOP then do;
        __var="%UPCASE(&CATVARN)";
        _vf=vformat(&CATVARN);
        ***** CAT2 SUMMARY *****;
        if _i>&ICAT1 then do;
          if  first.&CATVARN then do;
            do j=1 to &LEVELS; m(j)=.; s(j)=.; end;
            i=1;
           end;
          if missing(___class)=1 and _type_='00' & Percent=100 then do;
            __n=Frequency;
            _i2=_i;
            call label(%SCAN(&CAT1 &CAT2, &LOOP), _lab);
            output;
           end;
          if missing(___class)=0 and _type_='11' then do;
            m(i)=Frequency;
            s(i)=RowPercent;
            i=i+1;
            if last.&CATVARN then do;
              _i2=_i2+0.01;
              _lab=".     "||left(put(&CATVARN, &&VF&LOOP));
              output;
             end;
           end;
 
         end;
 
          ***** CAT1 SUMMARY *****;
        else if _i<=&ICAT1 then do;
          if first._i then do;
            do j=1 to &LEVELS; m(j)=.; s(j)=.; end;
           end;
          if first.&CATVARN then i=1;
          if missing(___class)=0 then validobs=1;
          if missing(___class)=0 and &CATVARN=1 then do;
            m(i) = Frequency; s(i) = RowPercent;
            i=i+1;
            end;
          if missing(___class)=1 and &CATVARN=. & _TYPE_='00'
            then __N=Frequency;
          if last._i;
          call label(&CATVARN, _lab);
          _i2=_i;
          if validobs=1 and nmiss(of _m1-_m&LEVELS)=&LEVELS then do;
            do j=1 to &LEVELS; m(j)=0; s(j)=0; end;
            output;
           end;
          else output;
          validobs=.;
         end;
       end; *** END to if _I=LOOP then do; ***;
     %END; *** END to DO LOOP=1 to ICAT ***;
 run;
 
 
 
 %IF &LEVELS NE 1 %THEN %DO;
   proc sort data=_Chisq_; by __var;
  %END;
proc sort data=_freq; by __var;
 
 
 
data _summ1_;
  attrib __var length=$32  _type length=$8;
  merge
 %IF &LEVELS NE 1 %THEN %DO;
   %IF %sysfunc(exist(_Chisq_)) %THEN %DO;
        _Chisq_(in=in1)
    %END;
  %END;
        _freq(in=in2);
  by __var;
 %IF &LEVELS NE 1 %THEN %DO;
  if in1=0 then put 'No Chi-sq available for ' __var;
  %END;
  if in2=0 then put 'No Frequencies for ' __var;
  if in2;
  if _i<=&ICAT1 then _type='CAT1';
  if _i>&ICAT1 then _type='CAT2';
  _i2 = _i2 + &ICON1 + &ICON2 + &ICON3;
  keep __var _lab _m1-_m&LEVELS _s1-_s&LEVELS __n _type _i _i2
      %IF &LEVELS NE 1 %THEN %DO;
       _pval
       %END;
      ;
 run;
 
proc sort data=_summ1_
          out=_summ1_(drop=_i); by _i _i2;
run;
 
proc datasets nolist;
  delete
    _ctf_ _freq
   %IF &LEVELS NE 1 %THEN %DO; _chisq_ %END;
   %IF "&SYSVER"<"9" %THEN %DO LOOP=1 %TO &ICAT; _freq&LOOP  %END;
   ;
 run; quit;
 
%END;
 
 
 
*********************************************************************;
*********************** CONTINUOUS ANALYSIS *************************;
*********************************************************************;
 
%LET ICON=%EVAL(&ICON1 + &ICON2 + &ICON3);
 
%IF (&ICON>0) %THEN %DO;
 
 %IF (&PRINTP ne 1) %THEN %DO; ods listing close; %END;
 
 ods output Summary=_means_;
 
 proc means data=_tempd_ n mean std median min max q1 q3 ;
    class ___class;
    var &con1 &con2 &con3;
  run;
 
 %IF &LEVELS NE 1 %THEN %DO;
 
   %IF &ICON1>0 %THEN %DO;
     %DO AOVL=1 %TO &ICON1;
       %LET NOWCON=%SCAN(&CON1,&AOVL);
       ods output ANOVA=_anova__;
       proc npar1way data=_tempd_ anova;
         class ___class;
         var &nowcon;
        run;
 
       %IF %sysfunc(exist(_anova__)) %THEN %DO;
         data _anova__; set _anova__;
           attrib __var2 length=$32;
           keep _i __var2 _pval;
           if source='Among';
           _pval=ProbF;
           __var2="&NOWCON"; _var2=upcase(__var2);
           _i=&AOVL;
          run;
         proc append base=_anova_ data=_anova__; run; quit;
         proc datasets nolist; delete _anova__; run; quit;
        %END;
      %END;
     %IF %sysfunc(exist(_anova_)) %THEN %DO;
       proc sort data=_anova_; by _i; run;
      %END;
    %END;
 
   %IF &ICON2>0 %THEN %DO;
     %DO KWTL=1 %TO &ICON2;
       %LET NOWCON=%SCAN(&CON2, &KWTL);
 
       ods output KruskalWallisTest=_kwt__;
       proc npar1way data=_tempd_ wilcoxon ;
         class ___class;
         var &nowcon;
        run;
 
       %IF %sysfunc(exist(_kwt__)) %THEN %DO;
         data _kwt__; set _kwt__;
           attrib __var2 length=$32;
           keep _i __var2 _pval;
           if Label1='Pr > Chi-Square';
           _pval=nValue1;
           __var2="&NOWCON"; _var2=upcase(__var2);
           _i=&ICON1 + &KWTL;
          run;
         proc append base=_kwt_ data=_kwt__; run; quit;
         proc datasets nolist; delete _kwt__; run; quit;
        %END;
      %END;
    %END;
 
   %IF &ICON3>0 %THEN %DO;
     %DO KWTL=1 %TO &ICON3;
       %LET NOWCON=%SCAN(&CON3, &KWTL);
 
       ods output KruskalWallisTest=_kwt__;
       proc npar1way data=_tempd_ wilcoxon ;
         class ___class;
         var &nowcon;
        run;
 
       %IF %sysfunc(exist(_kwt__)) %THEN %DO;
         data _kwt__; set _kwt__;
           attrib __var2 length=$32;
           keep _i __var2 _pval;
           if Label1='Pr > Chi-Square';
           _pval=nValue1;
           __var2="&NOWCON"; _var2=upcase(__var2);
           _i= &ICON1 + &ICON2 + &KWTL;
          run;
         proc append base=_kwt_ data=_kwt__; run; quit;
         proc datasets nolist; delete _kwt__; run; quit;
        %END;
      %END;
    %END;
 
   %IF %sysfunc(exist(_kwt_)) %THEN %DO;
     proc sort data=_kwt_; by _i; run;
    %END;
 
 
  %END;
 
 %IF (&PRINTP ne 1) %THEN %DO; ods listing; %END;
 
 
 data _labs;
   attrib __var1 length=$32 _lab length=&LABLEN;
   set _means_;
   if _N_=1;
   %DO LOOP=1 %TO &ICON;
    %LET CONVARN=%SCAN(&con1 &con2 &con3, &LOOP);
     __var1="&CONVARN";
     _lab=Label_&CONVARN;
     if Label_&CONVARN=' ' then do;
        set _tempd_(obs=1); _lab=vlabel(&CONVARN);
       end;
     _i=&LOOP;
     output;
   %END;
   _var1=upcase(__var1);
   keep __var1 _lab _i;
  run;
 
 proc transpose data=_means_ out=_tmeans_;
  run;
 
 
 data _tmeans_; set _tmeans_;
  if _LABEL_ in('N', 'Mean', 'Std Dev', 'Median', 'Minimum', 'Maximum'
           'Lower Quartile', 'Upper Quartile');
  retain _i 0  %DO LOOP=1 %TO &LEVELS; _m&LOOP _s&LOOP _t&LOOP %END;
         __n ;
  array m(&LEVELS) _m1-_m&LEVELS;  *** Mean or median ***;
  array s(&LEVELS) _s1-_s&LEVELS;  *** S.D. or min or Q1 ***;
  array t(&LEVELS) _t1-_t&LEVELS;  *** Max or Q3 ***;
  array c(&LEVELS) col1-col&LEVELS;
  if _LABEL_='N' then do;  *** Get N ***;
     _i=_i+1;  *** Placement among continuous variables ***;
     __n=sum(of col1-col&LEVELS);
     do i=1 to &LEVELS;
       m(i)=.; s(i)=.; t(i)=.;
       end;
   end;
  if _i<=&ICON1 then do;
    if _LABEL_='Mean' then do;  *** Get Mean ***;
      do i=1 to &LEVELS; m(i)=c(i); end;
     end;
    if _LABEL_='Std Dev' then do;   *** Get S.D. ***;
      do i=1 to &LEVELS; s(i)=c(i); end;
      output;
     end;
   end;
  else do;
    if _LABEL_='Median' then do;  *** Get Median ***;
      do i=1 to &LEVELS; m(i)=c(i); end;
     end;
    if _i<=(&ICON1 + &ICON2) then do;
      if _LABEL_='Minimum' then do; *** Get Minimum ***;
        do i=1 to &LEVELS; s(i)=c(i); end;
       end;
      if _LABEL_='Maximum' then do; *** Get Maximum ***;
        do i=1 to &LEVELS; t(i)=c(i); end;
        output;
       end;
     end;
    else do;
      if _LABEL_='Lower Quartile' then do; *** Get Q1 ***;
        do i=1 to &LEVELS; s(i)=c(i); end;
       end;
      if _LABEL_='Upper Quartile' then do; *** Get Q3 ***;
        do i=1 to &LEVELS; t(i)=c(i); end;
        output;
       end;
     end;
   end;
  keep _name_ _m1-_m&LEVELS _s1-_s&LEVELS _t1-_t&LEVELS __n _i;
 run;
 
 proc sort data=_labs; by _i;
 proc sort data=_tmeans_; by _i;
 run;
 
 data _summ2_;
   attrib __var length=$32 _type length=$8;
   merge _labs(in=in1)
         _tmeans_(in=in2)
         %IF &LEVELS NE 1 %THEN %DO;
          %IF %sysfunc(exist(_anova_)) %THEN %DO; _anova_(in=in3) %END;
          %IF %sysfunc(exist(_kwt_)) %THEN %DO; _kwt_(in=in4)  %END;
          %END;
        ;
   by _i;
  %IF &LEVELS NE 1 %THEN %DO;
    if not(in1=in2) then
     put 'WARNING! Mismatched merge in _summ2_ '
         in1= in2= __var1 _name_;
    if max(in3,in4)=1 then do;
     if in1=0 or in2=0 then
      put 'WARNING! Mismatched merge in _summ2_ '
          in1= in2= in3= in4= __var2;
     __var1=compress(upcase(__var1)); __var2=compress(upcase(__var2));
     if in1=1 and ( __var1 ne __var2 ) then
      put 'WARNING! Mismatched merge in _summ2_ '
           __var1= __var2= _name_= ;
     end;
   %END;
  %ELSE %DO;
    if in1 ne in2 then
        put 'WARNING! Mismatched merge in _summ2_'
             in1= in2= __var1 _name_ ;
   %END;
  if in1 or in2
    %IF &LEVELS NE 1 %THEN %DO; or in3 or in4
     %END;
    ;
  __var=upcase(__var1);
  if _i<=&ICON1 then _type='CON1';
   else if _i<=(&ICON1 + &ICON2) then _type='CON2';
    else _type='CON3';
  %IF &LEVELS NE 1 %THEN %DO;
    if _type='CON1' and in3=0 then
     put 'No ANOVA F-test available for ' __var;
    %IF &LEVELS=2 %THEN %DO;
      if _type in('CON2' 'CON3') and in4=0 then
       put 'No Mann-Whitney-Wilcoxon test available for ' __var;
     %END;
    %ELSE %DO;
      if _type in('CON2' 'CON3') and in4=0 then
       put 'No Kruskal-Wallis test available for ' __var;
     %END;
   %END;
  _i2=_i;  *** Placement among ALL variables ***;
  keep __var _lab _m1-_m&LEVELS _s1-_s&LEVELS _t1-_t&LEVELS
       __n _type _i2
       %IF &LEVELS NE 1 %THEN %DO;
         _pval
        %END;
      ;
 run;
 
 proc datasets nolist;
   delete _labs _tmeans_ _means_
        %IF &LEVELS NE 1 %THEN %DO;
          %IF %sysfunc(exist(_anova_)) %THEN %DO; _anova_ %END;
          %IF %sysfunc(exist(_kwt_)) %THEN %DO; _kwt_ %END;
         %END;
         ;
  run; quit;
 
%END;
 
 
 
 
*********************************************************************;
************************ ORDINAL ANALYSIS ***************************;
*********************************************************************;
 
%IF &IORD1>0 %THEN %DO;
 
 %IF (&PRINTP ne 1) %THEN %DO; ods listing close; %END;
 
  %IF "&SYSVER">="9" %THEN %DO;
   ods output CrossTabFreqs=_CTF_;
  %END;
 %ELSE %DO;
 
   ********* VERSION 8 only ************;
   %DO LOOP=1 %TO &IORD1;
     %IF &LOOP=1 %THEN %DO;
       ods output CrossTabFreqs=_Freq1;
      %END;
     %ELSE %DO;
       ods output CrossTabFreqs&LOOP=_Freq&LOOP;
      %END;
    %END;
 
  %END;
 
 
 ***** Get stats from PROC FREQ *****;
 proc freq data=_tempd_   ;
   table
   ___class*(&ORD1)
   / sparse;
   run;
 
 %IF  (&PRINTP ne 1)  %THEN %DO; ods listing close; %END;
 
   ********* VERSION 8 only ************;
     **** Put all CrossFreqs together ****;
  %IF "&SYSVER"<"9" %THEN %DO;
    %DO LOOP=1 %TO &IORD1;
      data _ctf_;
        set
        %IF &LOOP>1 %THEN %DO; _ctf_ %END;
        _FREQ&LOOP;
      run;
 
     %END;
   %END;
 
 
 %IF &LEVELS NE 1 %THEN %DO;
   %DO KWTL=1 %TO &IORD1;
     %LET NOWORD=%SCAN(&ORD1, &KWTL);
 
     ods output KruskalWallisTest=_kwt__;
     proc npar1way data=_tempd_ wilcoxon ;
       class ___class;
       var &noword;
      run;
 
     %IF %sysfunc(exist(_kwt__)) %THEN %DO;
       data _kwt__; set _kwt__;
         attrib __var length=$32;
         keep __var _pval;
         if Label1='Pr > Chi-Square';
         _pval=nValue1;
         __var="&NOWORD"; __var=upcase(__var);
        run;
       proc append base=_kwt_ data=_kwt__; run; quit;
       proc datasets nolist; delete _kwt__; run; quit;
      %END;
    %END;
  %END;
 
 
 %IF (&PRINTP ne 1) %THEN %DO; ods listing; %END;
 
 
 
 
  **** New data step for SAS9 ****;
  data _ctf_; set _ctf_;
    retain _i 0;
    if table ne lag(table) then _i=_i+1;
   run;
  proc sort data=_ctf_; by _i &ORD1 ___class;
 
 
     %DO LOOP=1 %TO &IORD1; %LOCAL VF&LOOP; %END;
     data _null_; *** Get var. format ***;
       attrib _vf length=$16;
        set _ctf_;
        %DO LOOP=1 %TO &IORD1;
        %LET ORDVARN=%SCAN(&ORD1, &LOOP);
         _vf = vformat(&ordvarn);
         call symput("VF&LOOP", _vf);
         %END;
      run;
 
  data _FREQS;
    set _ctf_; by _i &ORD1 ___class;
    keep _m1-_m&LEVELS _s1-_s&LEVELS __n _i _i2 _lab __var;
 
    length __var $32 _lab &LABLEN _vf $16;
    retain i 1  _m1-_m&LEVELS _s1-_s&LEVELS __n  _i2;
    array m(&LEVELS)  _m1-_m&LEVELS;
    array s(&LEVELS)  _s1-_s&LEVELS;
 
    if first._i then i=1;
 
    %DO LOOP=1 %TO &IORD1; *** Get variable name ***;
      %LET ORDVARN=%SCAN(&ORD1, &LOOP);
      if _i=&LOOP then do;
        __var="%UPCASE(&ORDVARN)";
        _vf=vformat(&ORDVARN);
        if  first.&ORDVARN then do;
          do j=1 to &LEVELS; m(j)=.; s(j)=.; end;
          i=1;
         end;
 
        if missing(___class)=1 and _type_='00' & Percent=100 then do;
          __n=Frequency;
          _i2=_i;
          call label(&ORDVARN, _lab);
          output;
         end;
        if missing(___class)=0 and _type_='11' then do;
          m(i)=Frequency;
          s(i)=RowPercent;
          i=i+1;
          if last.&ORDVARN then do;
            _i2=_i2+0.01;
            _lab=".     "||left(put(&ORDVARN, &&VF&LOOP));
            output;
           end;
         end;
        end; *** END to if _I=LOOP then do; ***;
     %END; *** END to DO LOOP=1 to IORD1 ***;
 run;
 
 
 %IF &LEVELS NE 1 %THEN %DO;
   proc sort data=_kwt_; by __var;
  %END;
 proc sort data=_freqs; by __var;
 
 data _summ3_;
   attrib __var length=$32  _type length=$8;
   merge _freqs(in=in1)
       %IF &LEVELS NE 1 %THEN %DO;
         %IF %sysfunc(exist(_kwt_)) %THEN %DO; _kwt_(in=in2) %END;
        %END;
       ;
   by __var;
   if in1=0 then put 'No Frequencies available for ' __var ;
   %IF &LEVELS NE 1 %THEN %DO;
     %IF &LEVELS=2 %THEN %DO;
       if in2=0 then
         put 'No Mann-Whitney-Wilcoxon test available for ' __var ;
      %END;
     %ELSE %DO;
       if in2=0 then put 'No Kruskal-Wallis test available for ' __var;
      %END;
    %END;
   if in1;
   _type='ORD1';
 
   _i2 = _i2 + &ICON1 + &ICON2 + &ICON3 + &ICAT1 + &ICAT2;
   keep __var _lab _m1-_m&LEVELS _s1-_s&LEVELS __n _type _i _i2
        %IF &LEVELS NE 1 %THEN %DO;  _pval %END;
      ;
  run;
 
 proc sort data=_summ3_
           out=_summ3_(drop=_i); by _i _i2;
  run;
 
 
proc datasets nolist;
  delete
    _ctf_ _freqs
   %IF &LEVELS NE 1 %THEN %DO; _kwt_ %END;
   %IF "&SYSVER"<"9" %THEN %DO LOOP=1 %TO &IORD1; _freq&LOOP  %END;
   ;
 run; quit;
 
 
%END;
 
 
*********************************************************************;
*****************       SURVIVAL ANALYSIS      **********************;
*********************************************************************;
 
%LET ISUR=%EVAL(&ISUR1 + &ISUR2 + &ISUR3 + &ISUR4 + &ISUR5);
%LET ISURF4=%EVAL(&ISUR1 + &ISUR2 + &ISUR3 + &ISUR4);
%LET SUR= &SUR1  &SUR2  &SUR3  &SUR4  &SUR5;
 
%IF (&ISUR>0) %THEN %DO;
 
    *** Display settings ***;
  %IF (&PRINTP ne 1) %THEN %LET PRINTOP=0;
    %ELSE %LET PRINTOP=4;
 
 
  %IF (&SURVOP NE 2) AND (&SURVOP NE 4) %THEN %LET SUBTRACT= 0+ ;
   %ELSE %LET SUBTRACT= 1- ;
  %IF (&SURVOP NE 1) AND (&SURVOP NE 2) %THEN %LET PERCMULT=100;
   %ELSE %LET PERCMULT= 1 ;
 
 
  %IF &CLASSTYP=C %THEN %DO; ** Cant have character class variable ***;
    data _tempd_;
      set _tempd_;
      %DO LOOP=1 %TO &LEVELS;
        if ___class=&&TVAL&LOOP then __classn=&LOOP;
       %END;
      run;
    data _null_;
      attrib _vf length=$16;
      set _tempd_;
      _vf = vformat(___class);
      call symput('VFCLASS', _vf);
     run;
   %END;
 
 
 
 
    *** Loop through SUR summary ***;
  %DO SLOOP=1 %TO &ISUR;
    %LET TMVAR = %SCAN(&SUR, &SLOOP);
    %LET SLOOP = %EVAL(&SLOOP + 1);
    %LET EVVAR = %SCAN(&SUR, &SLOOP);
    %LET VARPAIR=%EVAL(&SLOOP/2);
 
 
    /*
    USE %SURV TO GET THE K-M ESTIMATES BECAUSE OF OPTIONS TO CHOOSE
    CHOICE OF STANDARD ERROR FORMULA. HOWEVER, USE PROC LIFETEST TO
    GET THE LOG-RANK TEST - FASTER THAN IML CODE USED BY %SURVLRK.
 
    ONLY NEED TO RUN SURV FOR SUR1-SUR4 PARAMETERS. FOR SUR5, GET
    ALL INFO FROM LIFETEST
    */ ;
 
 
   %IF (&SLOOP<=&ISURF4) %THEN %DO;
 
     %let notes=%sysfunc(getoption(notes));
 
     %IF &CLASSTYP=C %THEN %DO;
      %surv(time=&TMVAR, event=&EVVAR, cen_vl=&CEN_VL, class=__classn,
            out=_surv_, outsum=_ssum_, data=_tempd_, printop=&PRINTOP,
            points=&POINTS, cl=&CL, logrank=1, plottype=1);
      %END;
     %ELSE %DO;
       %surv(time=&TMVAR, event=&EVVAR, cen_vl=&CEN_VL, class=___class,
            out=_surv_, outsum=_ssum_, data=_tempd_, printop=&PRINTOP,
            points=&POINTS, cl=&CL, logrank=1, plottype=1);
      %END;
 
      *** Add footnotes back - %SURV makes its own footnotes ***;
     %IF (&FN>=1) %THEN %DO FLOOP=1 %TO &FN;
       footnote&FLOOP "&&FOOT&FLOOP";
      %END;
     options &NOTES;
 
     *** Get total N used ***;
 
proc means data=_ssum_ sum noprint;
       var total; output out=_totn_ sum=__n;
      run;
 
     %IF &LEVELS NE 1 %THEN %DO;
       %IF (&PRINTP ne 1) %THEN %DO; ods listing close; %END;
       proc lifetest data=_tempd_  method=KM ;
           time &TMVAR*&EVVAR(&CEN_VL);
           ods output HomTests=_lr_; strata ___class;
         run;
         ods listing;
      %END;
 
     data _surv_;
       set _surv_;
       retain _pval;
       if _N_=1 then do;
         set _totn_(keep=__n);
         %IF &LEVELS NE 1 %THEN %DO;
           set _lr_(obs=1 keep=ProbChiSq); _pval=ProbChiSq;
          %END;
          ;
        end;
       if pointflg;
      run;
 
     proc sort data=_surv_; by &TMVAR
       %IF &CLASSTYP=C %THEN %DO; __classn %END;
       %ELSE %DO;  ___class %END;
         ;
 
 
     data _surv&VARPAIR;
       attrib __var length=$32 _lab length=&LABLEN _type length=$8;
       set _surv_;
       retain i 0 _m1-_m&LEVELS _s1-_s&LEVELS _t1-_t&LEVELS __n _i2;
       array m(&LEVELS) _m1-_m&LEVELS;
       array s(&LEVELS) _s1-_s&LEVELS;
       array t(&LEVELS) _t1-_t&LEVELS;
       by &TMVAR
 
     %IF &CLASSTYP=C %THEN %DO; __classn %END;
     %ELSE %DO;  ___class %END;
           ;
       if first.&TMVAR then do; *** Reset Stats ***;
         do j=1 to &LEVELS;
           m(j)=.; s(j)=.; t(j)=.;
          end;
         i=i+0.001;
        end;
       __var= upcase("&EVVAR");
       _i=&VARPAIR; *** Placement among SURV analyses ***;
          *** _i2 represents overall placement ***;
       _i2 = _i + &ICON1 + &ICON2 + &ICON3 + &ICAT1 + &ICAT2 + &IORD1;
 
      %IF &CLASSTYP=C %THEN %DO;
        if last.__classn then do;
       %END;
      %ELSE %DO;
        if last.___class then do;
        %DO LEV=1 %TO &LEVELS;
           if ___class=&&TVAL&LEV then __classn=&LEV;
         %END;
       %END;
 
        if 2*_i<=&ISUR1 then do;
           _type='SUR1';
           m(__classn)=&PERCMULT * ( &SUBTRACT pt );
            %IF &SURVOP NE 2 %THEN %DO;
              s(__classn)=&PERCMULT *(lower_cl);
              t(__classn)=&PERCMULT *(upper_cl);
             %END;
            %ELSE %DO;
              s(__classn)=&PERCMULT *( 1 - upper_cl);
              t(__classn)=&PERCMULT *( 1 - lower_cl);
             %END;
         end;
        else if 2*_i<=(&ISUR1 + &ISUR2) then do;
          _type='SUR2';
          m(__classn)=&PERCMULT *( &SUBTRACT pt );
          s(__classn)=cum_ev;
          t(__classn)=.;
         end;
        else if 2*_i<=(&ISUR1 + &ISUR2 + &ISUR3) then do;
          _type='SUR3';
          m(__classn)=&PERCMULT *( &SUBTRACT pt );
          s(__classn)=.;
          t(__classn)=.;
         end;
        else do;
          _type='SUR4';
          m(__classn)=cum_ev;
          s(__classn)=&PERCMULT *(&SUBTRACT pt);
          t(__classn)=.;
         end;
          end;
 
        if last.&TMVAR then do;
          _lab=".     "||trim(put(&TMVAR, best5.))||" &SUNITS";
          _i2=_i2+i;
          output;
         end;
        keep __var _lab _m1-_m&LEVELS _s1-_s&LEVELS _t1-_t&LEVELS __n
             _type _i2 _i
        %IF &LEVELS NE 1 %THEN %DO;
             _pval
         %END;
            ;
       run;
 
         **** NEXT DATASET CREATES TITLE LINE FOR SURVIVAL VARIABLE ****;
       data _surv&VARPAIR;
         set _surv&VARPAIR;
         array m(&LEVELS) _m1-_m&LEVELS;
         array s(&LEVELS) _s1-_s&LEVELS;
         array t(&LEVELS) _t1-_t&LEVELS;
         drop &EVVAR j;
         if _N_=1 then do;
           output;
           set _tempd_(obs=1 keep=&EVVAR);
           _lab=vlabel(&EVVAR);
           _i=&VARPAIR;
           _i2=_i + &ICON1 + &ICON2 + &ICON3 + &ICAT1 + &ICAT2 + &IORD1;
           do j=1 to &LEVELS; m(j)=.; s(j)=.; t(j)=.; end;
           output;
          end;
         else output;
        run;
 
        **** Get total events if requested ****;
       %IF (&NEVENTS=2 | &NEVENTS=3) %THEN %DO;
          proc sort data=_ssum_;
              by %IF &CLASSTYP=C %THEN %DO; __classn %END;
                 %ELSE %DO;  ___class %END;   ;
          data _ssum_;
              set _ssum_ end=_eof;
              if _N_=1 then set _surv&VARPAIR(keep=__n _type
                   %IF &LEVELS NE 1 %THEN %DO; _pval %END;);
              keep _m1-_m&LEVELS __var _lab _i _i2 __n _type
                  %IF &LEVELS NE 1 %THEN %DO; _pval %END; ;
              array m(&LEVELS) _m1-_m&LEVELS;
              retain _m1-_m&LEVELS;
              %IF &CLASSTYP^=C %THEN %DO LEV=1 %TO &LEVELS;
                  if ___class=&&TVAL&LEV then __classn=&LEV;
                  %END;
              m(__classn) = cum_ev;
              if _eof;
              __var= upcase("&EVVAR");
              _lab=".     Total # events";
              _i = &VARPAIR;
              _i2 = _i + &ICON1 + &ICON2 + &ICON3
                   + &ICAT1 + &ICAT2 + &IORD1;
              %IF &NEVENTS=2 %THEN %DO;
               _i2=_i2 + 0.0001;
               %END;
              %ELSE %DO;
               _i2=_i2 + 0.9999;
               %END;
            run;
          data _surv&VARPAIR;
             set _surv&VARPAIR _ssum_;
          run;
         %END;
 
       proc sort; by _i2; run;
 
       proc datasets nolist;
         delete _surv_ _ssum_ _lr_ _totn_  _tmp_
                _counts_  _print_ _tmp1_ ;
        run; quit;
 
    %END;
 
   %ELSE %DO;  *** IF SLOOP>ISURF4 (SUR5 variables) ***;
 
       %IF (&PRINTP ne 1) %THEN %DO; ods listing close; %END;
       proc lifetest data=_tempd_  method=KM ;
          ods output Quartiles = _surv_
                     CensoredSummary=_totn_
          %IF &LEVELS NE 1 %THEN %DO;  HomTests=_lr_ %END; ;
          time &TMVAR*&EVVAR(&CEN_VL);
          %IF &LEVELS NE 1 %THEN %DO; strata ___class; %END;
        run;
       ods listing;
 
       data _totn_;
         set _totn_;
         if stratum=.T;
         __n=Total;
         keep __n;
        run;
 
       data _surv_;
         set _surv_;
         retain _pval;
         if _N_=1 then do;
            set _totn_;
           %IF &LEVELS NE 1 %THEN %DO;
 
             set _lr_(obs=1 keep=ProbChiSq); _pval=ProbChiSq;
            %END;
           ;
          end;
        run;
 
       data _surv&VARPAIR;
         attrib __var length=$32 _lab length=&LABLEN _type length=$8;
         set _surv_ end=eof;
         retain i 0 _m1-_m&LEVELS _s1-_s&LEVELS _t1-_t&LEVELS __n _i2;
         array mst(3, &LEVELS) _s1-_s&LEVELS   /* Q1 */
                               _m1-_m&LEVELS   /* median */
                               _t1-_t&LEVELS ; /* Q3 */
         _index_ = percent/25;
         mst(_index_, stratum) = estimate;
         if eof;
         set _tempd_(obs=1 keep=&EVVAR);
         _lab=vlabel(&EVVAR);
         _type='SUR5';
         __var= upcase("&EVVAR");
         _i=&VARPAIR; *** Placement among SURV analyses ***;
            *** _i2 represents overall placement ***;
         _i2 = _i + &ICON1 + &ICON2 + &ICON3 + &ICAT1 + &ICAT2 + &IORD1;
         keep __var _lab _m1-_m&LEVELS _s1-_s&LEVELS _t1-_t&LEVELS __n
              _type _i2 _i
          %IF &LEVELS NE 1 %THEN %DO;
            _pval
           %END;
            ;
        run;
 
       proc datasets nolist;
          delete _surv_ _totn_ _lr_;
         run; quit;
 
     %END; *** END FOR "SLOOP>ISURF4(SUR5 variables)" ***;
 
   %END; *** End looping through survival variables ***;
 
   data _summ4_;
      set
      %DO LOOP=1 %TO %EVAL(&ISUR/2);
      _surv&LOOP %END;
      ;
     run;
 
 
   proc datasets nolist;
      delete %DO LOOP=1 %TO %EVAL(&ISUR/2); _surv&LOOP %END;
 
;
     run; quit;
 
 %END; *** END SURVIVAL ANALYSIS ***;
 
 
*********************************************************************;
***************** PREPARE RESULTS FOR PRINTING **********************;
*********************************************************************;
 
 
 data _fsumm_;
   %IF &LEVELS=1 %THEN %DO; _pval=.; %END;
   set
      %IF &ICON>0 %THEN %DO; _summ2_ %END;
      %IF &ICAT>0 %THEN %DO; _summ1_ %END;
      %IF &IORD1>0 %THEN %DO; _summ3_ %END;
      %IF &ISUR>0 %THEN %DO; _summ4_ %END;
      ;
   label __var='Variable Name'
         __n='N'
         _type='Summary Type'
         _pval='P Value'
         _lab='Variable'
 
         %DO LOOP=1 %TO &LEVELS;
           _m&LOOP="&&TLAB&LOOP Statistic 1"
           _s&LOOP="&&TLAB&LOOP Statistic 2"
 
           %IF (&ICON>&ICON1 OR &ISUR1>0) %THEN %DO;
             _t&LOOP="&&TLAB&LOOP Statistic 3"
            %END;
          %END;
   ;run;
 
 
 ***** ORDER VARIABLES HERE *****;
 %IF (&LIST^= ) %THEN %DO;
   data _list;
     attrib __var length=$32  _list length=8;
     keep __var _list;
     %DO LOOP=1 %TO &ILIST;
       __var=upcase("%SCAN(&LIST, &LOOP)");
       _list=&LOOP;
       output;
      %END;
    run;
   proc sort data=_list; by __var;
   proc sort data=_fsumm_; by __var;
   data &OUT;
     merge _fsumm_(in=inf)
           _list(in=inl);
     by __var;
     if inl>inf then put
   'WARNING! ' __var 'is in the LIST parameter, but was not analyzed.';
     if inf;
     if inl=0 then _list=&ILIST+1;
    run;
   proc sort data=&OUT; by _i2;
   run;
   proc datasets nolist; delete _list; run;
  %END;
  %ELSE %DO;
    data &OUT; set _fsumm_; _list=1; run;
   %END;
 
  %IF (&SORTBY^= ) %THEN %DO;
    proc sort data=&OUT; by &SORTBY _i2; run;
   %END;
 
 
 %IF &PRINTS=1 %THEN %DO;
 proc print data=&out l;
   id __var;
   var  _lab _type __n
        %DO LOOP=1 %TO &LEVELS;
          _m&LOOP _s&LOOP
          %IF (&ICON>&ICON1 OR &ISUR1>0 OR &ISUR5>0) %THEN %DO;
            _t&LOOP
           %END;
        %END;
        %IF &LEVELS>1 %THEN %DO; _pval %END;  ;
   format _pval &pfmt
          _m1-_m&levels _s1-_s&levels
          %IF (&ICON>&ICON1 OR &ISUR1>0 OR &ISUR5>0) %THEN %DO;
              _t1-_t&levels
           %END;
           &perfmt;
 run;
 %END;
 
 proc datasets nolist;
   delete _summ1_ _summ2_ _summ3_ _summ4_ _fsumm_ _tempd_;
  run; quit;
 
 
 ********* ODS STUFF HERE **************;
  *** If K-M estimates are being reported as percentages, then use the
      percentage format (F7) ***;
  %IF &PERCMULT=100 %THEN %LET F8 = &F7;
 
 data &RTFOUT;
   attrib _cellA1-_cellA&LEVELS _cellB1-_cellB&LEVELS length=$24
          _varlab length=&LABLEN    _p length=$6
          _lab1-_lab&LEVELS length=$24;
   set &out;
   keep _varlab _cellA1-_cellA&LEVELS _cellB1-_cellB&LEVELS _p
        _type _nlev_ _lab1-_lab&LEVELS _N1-_N&LEVELS;
     *** Data to store for %OUTSUMM USE ***;
   if _N_=1 then do;
     _nlev_ = &LEVELS;
     %DO LLOOP=1 %TO &LEVELS;
        _lab&LLOOP = "&&TLAB&LLOOP";
        _N&LLOOP = &&TNUM&LLOOP;
      %END;
     end;
    *** Values that will be output to RTF ***;
   if _i2 ne floor(_i2) then _p=" ";
    else if .<_pval<0.05 then _p=left(put(_pval, pvalue6.3));
     else _p=left(put(_pval, pvalue4.2));
   if _type='CON1' then do;
     _varlab=_lab;
     %DO LOOP=1 %TO &LEVELS;
       _cellA&LOOP = trim(put(_m&LOOP, &F1));
       %IF &SDOPT=1 %THEN %DO;
    _cellB&LOOP = trim("{\'b1 }{"||left(trim(put(_s&LOOP, &F2)))||"}");
        %END;
       %ELSE %DO;
    _cellB&LOOP = trim("("||trim(left(put(_s&LOOP, &F2)))||")");
        %END;
      %END;
    end;
   if _type='CON2' then do;
     _varlab=trim(_lab)||", median (min, max)";
     %DO LOOP=1 %TO &LEVELS;
       _cellA&LOOP = trim(put(_m&LOOP, &F3));
       _cellB&LOOP = "("||trim(left(put(_s&LOOP, &F4)))||", "
                     ||trim(left(put(_t&LOOP, &F4)))||")";
      %END;
    end;
   if _type='CON3' then do;
     _varlab=trim(_lab)||", median (Q1, Q3)";
     %DO LOOP=1 %TO &LEVELS;
       _cellA&LOOP = trim(put(_m&LOOP, &F3));
       _cellB&LOOP = "("||trim(left(put(_s&LOOP, &F5)))||", "
                     ||trim(left(put(_t&LOOP, &F5)))||")";
      %END;
    end;
   if _type='CAT1' then do;
     _varlab=trim(_lab)||", n (%)";
     %DO LOOP=1 %TO &LEVELS;
       _cellA&LOOP = trim(put(_m&LOOP, &F6));
       _cellB&LOOP = "("||trim(left(put(_s&LOOP, &F7)))||"%)";
      %END;
    end;
   if _type='CAT2' or _type='ORD1' then do;
     if _i2=floor(_i2) then do;
       _varlab=trim(_lab)||", n (%)";
       %DO LOOP=1 %TO &LEVELS;
         _cellA&LOOP = trim(" ");
         _cellB&LOOP = trim(" ");
        %END;
      end;
     else do;
       _varlab=_lab;
       %DO LOOP=1 %TO &LEVELS;
         _cellA&LOOP = trim(put(_m&LOOP, &F6));
         _cellB&LOOP = "("||trim(left(put(_s&LOOP, &F7)))||"%)";
        %END;
      end;
    end;
   if _type='SUR1' then do;
     if _i2=floor(_i2) then do;
        _varlab=trim(_lab)||", K-M (95% CI)";
       %DO LOOP=1 %TO &LEVELS;
         _cellA&LOOP = trim(" ");
         _cellB&LOOP = trim(" ");
        %END;
      end;
      else do;
        _varlab=_lab;
        if _lab=".     Total # events" then do;
        %DO LOOP=1 %TO &LEVELS;
            _cellA&LOOP = trim(put(_m&LOOP, &F6));
            _cellB&LOOP = trim(" ");
           %END;
         end;
        else do;
        %DO LOOP=1 %TO &LEVELS;
            _cellA&LOOP = trim(put(_m&LOOP, &F8))
                      %IF &PERCMULT=100 %THEN %DO; ||"%" %END; ;
            _cellB&LOOP = "("||trim(left(put(_s&LOOP, &F8)))||", "||
                         trim(left(put(_t&LOOP, &F8)))||")";
            %END;
          end;
        end;
    end;
   if _type='SUR2' then do;
     if _i2=floor(_i2) then do;
       _varlab=trim(_lab)||", K-M (# events)";
       %DO LOOP=1 %TO &LEVELS;
          _cellA&LOOP= trim(" ");
          _cellB&LOOP= trim(" ");
         %END;
      end;
      else do;
        _varlab=_lab;
        if _lab=".     Total # events" then do;
        %DO LOOP=1 %TO &LEVELS;
            _cellA&LOOP = trim(put(_m&LOOP, &F6));
            _cellB&LOOP = trim(" ");
           %END;
         end;
        else do;
        %DO LOOP=1 %TO &LEVELS;
          _cellA&LOOP= trim(put(_m&LOOP, &F8))
                      %IF &PERCMULT=100 %THEN %DO; ||"%" %END; ;
          _cellB&LOOP= "("||trim(left(put(_s&LOOP, &F6)))||")";
         %END;
         end;
       end;
     end;
    if _type='SUR3' then do;
      if _i2=floor(_i2) then do;
       _varlab=trim(_lab)||", K-M";
       %DO LOOP=1 %TO &LEVELS;
          _cellA&LOOP= trim(" ");
          _cellB&LOOP= trim(" ");
         %END;
       end;
       else do;
        _varlab=_lab;
        if _lab=".     Total # events" then do;
        %DO LOOP=1 %TO &LEVELS;
            _cellA&LOOP = trim(put(_m&LOOP, &F6));
            _cellB&LOOP = trim(" ");
           %END;
         end;
        else do;
         %DO LOOP=1 %TO &LEVELS;
           _cellA&LOOP = trim(put(_m&LOOP, &F8))
                %IF &PERCMULT=100 %THEN %DO; ||"%" %END; ;
           _cellB&LOOP = trim(" ");
          %END;
         end;
        end;
     end;
    if _type='SUR4' then do;
      if _i2=floor(_i2) then do;
       _varlab=trim(_lab)||", # events (K-M)";
       %DO LOOP=1 %TO &LEVELS;
          _cellA&LOOP= trim(" ");
          _cellB&LOOP= trim(" ");
         %END;
       end;
       else do;
        _varlab=_lab;
        if _lab=".     Total # events" then do;
        %DO LOOP=1 %TO &LEVELS;
            _cellA&LOOP = trim(put(_m&LOOP, &F6));
            _cellB&LOOP = trim(" ");
           %END;
         end;
        else do;
         %DO LOOP=1 %TO &LEVELS;
          _cellA&LOOP= trim(left(put(_m&LOOP, &F6)));
          _cellB&LOOP="("|| trim(left(put(_s&LOOP, &F8)))
                      %IF &PERCMULT=100 %THEN %DO; ||"%" %END; ||")" ;
          %END;
         end;
        end;
     end;
     if _type='SUR5' then do;
       _varlab=trim(_lab)||", median (Q1, Q3)";
       %DO LOOP=1 %TO &LEVELS;
         _cellA&LOOP = trim(put(_m&LOOP, &F3));
         _cellB&LOOP = "("||trim(left(put(_s&LOOP, &F5)))||", "
                       ||trim(left(put(_t&LOOP, &F5)))||")";
        %END;
      end;
 
 
   label _varlab='Variable' _p='P Value'
         %DO LOOP=1 %TO &LEVELS;
           _cellA&LOOP="&&TLAB&LOOP Stat1"
           _cellB&LOOP="&&TLAB&LOOP Stat2"
          %END;
        ;
  run;
 
 %IF (&RTFFILE^= ) %THEN %DO;
 
   %IF (&STYLE= ) %THEN %DO;
     %LET STYLE=_WordTab;
     proc template;
       define style _WordTab;
        parent=styles.minimal;
        style Table       /  cellpadding=4 cellspacing=5
                             borderwidth=2  rules=groups  ;
        style data        /  font_face="Times New Roman"
                             font_size=12pt               ;
        style SystemTitle /  font_face="Times New Roman"
                             font_size=16pt               ;
        style SystemFooter/  font_face="Times New Roman"
                             font_size=10pt               ;
        style Header      /  font_face="Times New Roman"
                             font_weight=bold
                             font_size=14pt               ;
        style BodyDate    /  font_face="Times New Roman"
                             font_size=8pt                ;
       end;
      run;
    %END;
 
   data _null_;
     datenow = today(); timenow=datetime();
     call symput('datenow', trim(left(put(datenow, weekdate.))));
     call symput('timenow', trim(right(put(timenow, tod5.2))));
    run;
 
   ods rtf file=&RTFFILE  style=&style;
   ods listing close;
 
   %IF &ISUR1>0 | &ISUR5>0 %THEN %DO;
     %LET CW1=120; %LET CW2=150;
    %END;
   %ELSE %IF &ICON>&ICON1 %THEN %DO;
     %LET CW1=120; %LET CW2=140;
    %END;
   %ELSE %DO;
     %LET CW1=85; %LET CW2=100;
    %END;
   %IF (&CWIDTH1=) %THEN %LET CWIDTH1=&CW1;
   %IF (&CWIDTH2=) %THEN %LET CWIDTH2=&CW2;
 
   *** Add footnotes ***;
  %IF (&FN>=1) %THEN %DO FLOOP=1 %TO &FN;
    footnote&FLOOP "&&FOOT&FLOOP";
   %END;
   %LET FPLUS1 = %EVAL(&FN + 1);
   footnote&FPLUS1 h=10pt j=r "&timenow  &datenow";
 
   ods escapechar="^";
   proc report data=&RTFOUT nowd headline;
     column ("&TBLTITLE"
             ("Variable" _varlab)
             %DO LOOP=1 %TO &LEVELS;
               ("&&TLAB&LOOP./(N=&&TNUM&LOOP.)" _cellA&LOOP _cellB&LOOP)
              %END;
             %IF &LEVELS>1 %THEN %DO;
               ('^\i P^\i0  Value' _p)
              %END;
            );
     define _varlab /display width=60 left ''
                     style(column)={cellwidth=&CWIDTH3 cellpadding=12};
     %DO LOOP=1 %TO &LEVELS;
      define _cellA&LOOP /display width=10 right ''
                          style={cellwidth=&CWIDTH1};
      define _cellB&LOOP /display width=20 left ''
                          style={cellwidth=&CWIDTH2};
     %END;
     %IF &LEVELS>1 %THEN %DO;
       define _p / display width=8 right '';
      %END;
 
    run; quit;
   footnote&FPLUS1;
 
 
   ods rtf close;
   ods listing;
  %END;
  %IF (&FN>=1) %THEN %DO FLOOP=1 %TO &FN;
    footnote&FLOOP "&&FOOT&FLOOP";
   %END;
   %LET FPLUS1 = %EVAL(&FN + 1);
  proc datasets nolist lib=work; delete _f; run; quit;
 
 
%END;  **** Error Flag Loop ****;
 
%IF &ERRORFLG^=0 %THEN %DO;
  %PUT Errors exist in the macro call, no output will be produced.;
 %END;
 
options validvarname=&VALID &dateon;
 
%MEND SUMMARY;
 
 
 
