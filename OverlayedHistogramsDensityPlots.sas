***********************************
Overlaying histograms and density plots;



*example #1 using panel plots;
libname r 'C:\Documents and Settings\N375726\My Documents\Studies\ROwensOpTime';
data AAA; set r.AAAfinal;
mprob=morbprob*100;
if sex='male' then moptime=optime;
if sex='female' then foptime=optime;
run;
proc sort data=aaa;by SEX;run;
proc sgpanel data=AAA;
  panelby inout;
  colaxis label = "Time";
  density  moptime / legendlabel = "Male";
   density foptime / legendlabel = "Female";
run;

*example #2 using proc univariate and graph replay;

data test;
        drop i;
        do group='A','B';
          do i=1 to 100;
             x=20+ 8*rannor(12345);
            output;
          end;
        end;
      run;
title 'Overlay on one set of axes';
goptions nodisplay;
      proc univariate data=test gout=work.gseg noprint;
        where group='A';
        var x;
        histogram x / normal(noprint color=red)
                      nobars
                      name='A'
                      midpoints=-5 to 40 by 5
                      vaxis=0 to 30 by 5;
        inset normal(mu sigma) / pos=nw header='Group A';
      run;
      quit;

      proc univariate data=test gout=work.gseg noprint;
        where group='B';
        var x;
        histogram x / normal(noprint color=blue l=20)
                      nobars
                      name='B'
                      midpoints=-5 to 40 by 5
                      vaxis=0 to 30 by 5;
        inset normal(mu sigma) / pos=ne header='Group B';
      run;
      quit;

/* Replay the graphs into the same template */
goptions display;
proc greplay igout=work.gseg nofs tc=sashelp.templt template=whole;
treplay 1:A2 1:B2;
run;
quit;
