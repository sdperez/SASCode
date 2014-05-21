********************************************************************************
MACRO:
Runs proc genmod with a base model and one additional variable. Adds the
AIC of the model to a running AIC file
*******************************************************************************;
%macro GenModAIC(data=colon, basemodel=rvu_total asav2 ,testvar=logcreat);

proc genmod data=&data;
  where group='Training Set';
  ods output Modelfit=Model	;
  model logcost =&basemodel &testvar;
RUN; 

data AIC; set Model;
  format Basemodel $CHAR21.;
  format VariableTested $CHAR21.;
  if Criterion='AIC (smaller is better)';
  Basemodel="&basemodel";
  VariableTested="&testvar";
*keep  VariableTested Criterion  Value;
run;

proc append base=AICs data=AIC;	run;
%mend GenModAIC;
*****************************END MACRO*****************************************;
