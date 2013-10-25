
******************************************************************;
/*  CINDEX  macro                                                */
/*  Author: Mithat Gonen                                         */
/*                                                               */
/*                                                               */
/*  Computes the concirdance index for a marker and a censored   */
/*  outcome                                                      */
/*                                                               */
/*  INPUTS                                                       */
/*                                                               */
/*  dsn:    data set name                                        */
/*  marker: name of the marker or predictor variable for which   */
/*          a time-dependent ROC curve is desired.               */  
/*          must be numerical                                    */
/*  surv:   survival time (or time to the event of interest      */
/*  cens:   censoring status. (1:censored, 0:event)              */
/*                                                               */
******************************************************************;

options nofmterr;

%macro cindex(dsn,marker,surv,cens);

data _base_;
  set &dsn;
  i+1;
run;

data _firstbase_;
  set _base_;
run;

proc sql noprint;
  select n(&marker) into:_n_ from _base_;
quit;

%macro mergepairs;
%do i=1 %to &_n_;
data _base_i;
  set _firstbase_;
  i=&i;
  rename &surv=_surv2 &cens=_cens2 &marker=_pred2;
run;

data _base_;
  merge _base_ _base_i;
  by i;
run;
%end;
%mend;
%mergepairs;

data _final_;
  set _base_(where=((&cens=0 and _cens2=0 and &surv>_surv2) or 
        (&cens=1 and _cens2=0 and &surv>_surv2) or 
        (&cens=0 and _cens2=0 and &surv<_surv2) or 
        (&cens=0 and _cens2=1 and &surv<_surv2)));
  if (&marker-_pred2)*(&surv-_surv2)>0 then aij=1;
  else aij=0;
run;

proc sql;
  select max(sum(aij)/n(aij),1-(sum(aij)/n(aij))) as cindex
  from _final_;
quit;

%mend;


%cindex(dsn=work.survival_etc,marker=s,surv=referral_to_list,cens=waitlist);


*%cindex(dsn=example,marker=marker,surv=surv,cens=status);
