*SAS usually performs Fisher's tests automatically when sample size is small but
   this uses a case when Fisher's is not appropriate;
data Graft;
      input Group $ Pair $ Response $ ;
      datalines;
GTKO 1 Y
GTKO 2 Y
GTKO 3 	Y
GTKO 4	Y
GTKO 5	N
WT 1 N
WT 2 N
WT 3 Y
WT 4 N
WT 5 N
   ;

proc freq data=graft;
tables pair*group*response;
exact  comor zelen ; 
run; *This performs a stratified analysis (by pair number) of the response by treatment group.
Since sample size is so small, exact tests were performed: zelen performs a test on whether the odds
ratios are equal across strata (interaction?) and comor tests whther the common odds ratio is 
equal to 1 (no effect);
