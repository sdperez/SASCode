 /* This handout gives a MACRO written by Prof. Frank Harrell to do "restricted
cubic splines" in SAS.  It can be used within a data step to define splines.
If you specify k knots than the macro will generate k-2 new variables by
adding numbers to the end of the "x" variable.  Prof Harrell has rules for
selecting the knots, for example for 3 knots one should select the 10%, 50%
and 90% of the x-distribution. */

%MACRO
  RCSPLINE(x,knot1,knot2,knot3,knot4,knot5,knot6,knot7,knot8,knot9,knot10,
  norm=2);
  %LOCAL j v7 k tk tk1 t k1 k2;
  %LET v7=&x; %IF %LENGTH(&v7)=8 %THEN %LET v7=%SUBSTR(&v7,1,7);
      %*Get no. knots, last knot, next to last knot;
        %DO k=1 %TO 10;
        %IF %QUOTE(&&knot&k)=  %THEN %GOTO nomorek;
        %END;
  %LET k=11;
  %nomorek: %LET k=%EVAL(&k-1); %LET k1=%EVAL(&k-1); %LET k2=%EVAL(&k-2);
  %IF &k<3 %THEN %PUT ERROR: <3 KNOTS GIVEN.  NO SPLINE VARIABLES CREATED.;
          %ELSE %DO;
          %LET tk=&&knot&k;
          %LET tk1=&&knot&k1;
          DROP _kd_; _kd_=
          %IF &norm=0 %THEN 1;
          %ELSE %IF &norm=1 %THEN &tk - &tk1;
          %ELSE (&tk - &knot1)**.666666666666; ;
                  %DO j=1 %TO &k2;
                   %LET t=&&knot&j;

  &v7&j=max((&x-&t)/_kd_,0)**3+((&tk1-&t)*max((&x-&tk)/_kd_,0)**3
                     -(&tk-&t)*max((&x-&tk1)/_kd_,0)**3)/(&tk-&tk1)%STR(;);
                  %END;
     %END;
  %MEND;

DATA SIMULATE;
 DO X=-20 TO 120;
  IF X<0 THEN Y=.;
  IF 0<=X<25 THEN Y=0+RANNOR(0);
  IF 25<=X<75 THEN Y=X-26+RANNOR(0);
  IF X>=75 THEN Y=50+RANNOR(0);
  IF X>100 THEN Y=.;
 X2=X*X; X3=X2*X;
  *this will generate data following a very non-linear pattern;
 OUTPUT; END;
PROC REG DATA=SIMULATE;  *this does cubic regression;
 MODEL Y=X X2 X3;
 OUTPUT OUT=PP1 P=P;
PROC GPLOT DATA=PP1;
 TITLE 'CUBIC REGRESSION';
 PLOT (Y P)*X/OVERLAY  ;
 SYMBOL1 V=DOT C=BLACK;
 SYMBOL2 V=NONE I=JOIN C=RED;
RUN;
DATA TWO; SET SIMULATE; XX=X;
 %RCSPLINE(XX,5,35,65,95);
PROC REG DATA=TWO;  *this uses the RCS;;
 MODEL Y=XX XX1 XX2;
 OUTPUT OUT=PP2 P=P;
PROC GPLOT DATA=PP2;
 TITLE 'RESTRICTED CUBIC SPLINE';
 PLOT (Y P)*X/OVERLAY  ;
 SYMBOL1 V=DOT C=BLACK;
 SYMBOL2 V=NONE I=JOIN C=RED;
RUN;
 * Create in y a discontinuous function of x.;
   
   data a;
      x = -0.000001;
      do i = 0 to 199;
         if mod(i, 50) = 0 then do;
            c = ((x / 2) - 5)**2;
            if i = 150 then c = c + 5;
            y = c;
         end;
         x = x + 0.1;
         y = y - sin(x - c);
         output;
      end;
   run;
data a2;set a;
XX=X;
 %RCSPLINE(XX,1,5,10,15,19);
 run;
 PROC REG DATA=a2;  *this uses the RCS;;
 MODEL Y=XX XX1 XX2 XX3;
 OUTPUT OUT=PP2 P=P;
PROC GPLOT DATA=PP2;
 TITLE 'RESTRICTED CUBIC SPLINE w/5 knots';
 PLOT (Y P)*X/OVERLAY  ;
 SYMBOL1 V=DOT C=BLACK;
 SYMBOL2 V=NONE I=JOIN C=RED;
RUN;
data a2;set a;
XX=X;
 %RCSPLINE(XX,5,10,15);
 run;
 PROC REG DATA=a2;  *this uses the RCS;;
 MODEL Y=XX XX1;
 OUTPUT OUT=PP2 P=P;
PROC GPLOT DATA=PP2;
 TITLE 'RESTRICTED CUBIC SPLINE w/3 knots';
 PLOT (Y P)*X/OVERLAY  ;
 SYMBOL1 V=DOT C=BLACK;
 SYMBOL2 V=NONE I=JOIN C=RED;
RUN;
****************************************************
A note about using splines and the number of knots, taken from 
Desquilbett and Mariotti:
"The choice of the adequate number of knots depends on
the objective. For statistically testing the assumption of linearity of a dose-response association, 
a 3-knot RCS function, which is much smoother than a 5-knot RCS function, would be more powerful to 
detect departure from linearity (Wald 2 test with 1 DF compared with 3 DF for a 5-knot RCS function). 
For adjustment for a continuous confounder by using an RCS function, a 3-knot RCS function would also 
be preferable to a 5-knot RCS function since it is more parsimonious and would remove most of the
residual confounding. A 5-knot RCS function would be desirable for explanatory analyses, when 
one wants to characterize the dose-response association more precisely (i.e. closer to the data), on 
the a priori assumption that the association might be more complex than that accounted by a 3-knot RCS 
function."
