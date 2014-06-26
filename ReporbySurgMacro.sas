****************************************************************************
/*
How to print a PDF report by surgeon including custom text by surgeon 
depending if they are above or below the expected (with symput..)
*/
****************************************************************************


data colon7; merge colon6 OERatios;by surgeon_id; run;
proc format; value yesnof 0='High Quality' 1='Low Quality'; RUN;
%MACRO Report (id=15905);
title "Value Report for Surgeon &id";
ods pdf file="\\nasn1ac.cc.emory.edu\surgery\SQOR\SurgeonValueComparisons\Colectomy\Reports\Reportfor&id..pdf" ;
ods noproctitle;
options nodate;
ods pdf text="This report shows how your costs per patient and complication rates compare to what is expected 
(based on your patient accuity) and the overall average of all surgeons doing Colectomies.
The plot shows reference lines for the overall average rate of complications and costs for surgeons who did at 
least three colectomies. The light blue diamonds represent, for each of the patients you operated on, the predicted 
probability of a complication and predicted cost of their encounter. The blue X represents expected average cost
and complication rate for your patients. The red X shows your actual average cost and complication rate.";
data _null_;
   set OEratios;
   if surgeon_id=&id;
   if avg_act_cost< avg_pred_cost then costtext="less";
   else costtext='more';
   if avg_act_comp< avg_pred_comps then comptext="less";
   else comptext='more';
   call symput('var',costtext);
   call symput('var2',comptext); 
   
proc sgplot data=colon7 ;
where surgeon_id = &id;
scatter y=predcost x=PredCompProb /markerattrs=(color=lightblue symbol=diamond)legendlabel='Patient Cost and Complication Status Predicted by Pre-Op Risk Factors';
scatter y=avTC x=avCyn  /markerattrs=(color=red size=12 symbol=x) markercharattrs=(weight=BOLD) legendlabel="Surgeon's Real Average";
scatter y=avg_pred_cost x=avg_pred_comps  /markerattrs=(color=blue size=12 symbol=x) markercharattrs=(weight=BOLD) legendlabel="Surgeon's Expected Average";
refline &AvgCost /axis=y  lineattrs=(color=green) label='All-Surgeon Avg Cost' labelloc=inside labelpos=max;
refline &CompRate /axis=x  lineattrs=(color=red) label='All-Surgeon Complication Rate' labelloc=inside labelpos=min;
xaxis label='Complication Rate';
yaxis label='Encounter Cost';
RUN;

ODS PDF Text="In your case, your actual cost is &var than is predicted for your patients";
ODS PDF Text="Your actual complication rate is &var2 than is predicted for your patients";
ods pdf close;


%mend;

%Report(id=15928);
