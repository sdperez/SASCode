*Macro for matching a case with controls;
* ClassVar: define the case and control group. 
    format: valueList1|valueList2: 
      valueList1 for case group, valueList2 for control group;
* MatchVars: specify match variables. 
   If variables with :range, the match is within the range, 
   otherwise, it is a exact match;
* ratio: ratio for case:control=1:ratio;
* Reference: 
  Using SAS to match cases for case control studies, paper 173-29, SUGI29
from website http://qiaohaozhu.wordpress.com/2011/11/04/sas-macro-for-matching-cases-and-controls/;
**************************************************************************************************;
%macro match(data=_last_, ID=ID_Number, nCases=10, ratio=1,
             classVar=%str(cVar:1,2|3,4),
             matchVars=Var1:1|Var2|Var3:0.1, 
             out=matchData);
  data _match_temp_;
    set &data.;
  run;
  %let cVar=%scan(&classVar.,1,:);
  %let cVals=%scan(&classVar.,2,:);
  %let controlVals=%scan(%quote(&cVals.),2,|);
  %let caseVals=%scan(%quote(&cVals.),1,|);

  *select the Cases;
  ods exclude all;
  proc surveyselect data=_match_temp_(where=(&cVar. in (&caseVals.)))
    sampsize=&nCases.
    out=_Cases;
  run;
  ods select all;

  data _Controls;
    set _match_temp_;
	where &cVar. in (&controlVals.);
  run;

  *get the control variables and the matching condition;
  %let i=1;
  %let mv1=%scan(&matchVars.,&i.,|);
  %do %while (&mv1.~=);
    %let var=%scan(&mv1.,1,:);
	%let range=%scan(&mv1.,2,:);
	%if (&range.~=) %then %do;
	  data _Controls;
	    set _Controls;
		&var._Low=&var.-&range.;
		&var._Up=&var.+&range.;
	  run;
	  %let cond1=(case.&var. between control.&var._Low and control.&var._Up);
	%end;
	%else %do;
	  %let cond1=(case.&var.=control.&var.);
	%end;

	%let newVar=%str(case.&var. as case&Var., control.&var. as control&Var.);

	%if (&i.=1) %then %do;
	  %let condition=&cond1.;
	  %let newVars=%str(&newVar.);
	%end;
	%else %do;
	  %let condition=&condition. and &cond1.;
	  %let newVars=&newVars.,&newVar.;
	%end;

    %let i=%eval(&i.+1);
	%let mv1=%scan(&matchVars.,&i.,|);
  %end;

  *do the matching;
  proc sql;
    create table _matches_ as
	  select case.&ID. as caseID, 
                 control.&ID as controlID, 
                 case.&cVar. as case&cVar., 
                 control.&cVar as control&cVar., 
                 &newVars.
	  from _Cases case, _Controls control
	  where (&condition.)
	  order by caseID;
  quit;
  data _matches_;
    set _matches_;
    rnd=ranuni(1); *generate a random number;
  run;
  proc sql;
    create table _matches_ as
	  select _matches_.*, n(caseID) as count from _matches_ group by caseID;
  quit;
  proc sort data=_matches_;
    by controlID count rnd;
  run;
  data _matches_;
    set _matches_;
	by controlID;
	if first. controlID then output; *Only pick the first controlID;
  run;
  proc sort data=_matches_;
    by caseID rnd;
  run;
  data _matches_(drop=k count rnd);
    set _matches_;
	by caseID;
	retain k;
	if first.caseID then k=0;
	k+1;
	if k<=&ratio. then output;
  run;
  data &out.;
    set _matches_;
  run;

%mend match;
