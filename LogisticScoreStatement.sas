/*
Getting predictions on new data sets using the score statement in PROC LOGISTIC
*/

*Sample data;
data Crops;
      length Crop $ 10;
      infile datalines truncover;
      input Crop $ @@;
      do i=1 to 3;
        input x1-x4 @@;
        if (x1 ^= .) then output;
      end;
      input;
      datalines;
   Corn       16 27 31 33  15 23 30 30  16 27 27 26  
   Corn       18 20 25 23  15 15 31 32  15 32 32 15  
   Corn       12 15 16 73  
   Other      20 23 23 25  24 24 25 32  21 25 23 24  
   Other      27 45 24 12  12 13 15 42  22 32 31 43  
   Other      31 32 33 34  29 24 26 28  34 32 28 45  
   Other      26 25 23 24  53 48 75 26  34 35 25 78  
   Other      22 23 25 42  25 25 24 26  34 25 16 52  
   Other      54 23 21 54  25 43 32 15  26 54  2 54  
   Other      12 45 32 54  24 58 25 34  87 54 61 21  
   Other      51 31 31 16  96 48 54 62  31 31 11 11  
   Other      56 13 13 71  32 13 27 32  36 26 54 32  
   Other      53 08 06 54  32 32 62 16  
   ;

*Run logistic regression on the 'training' data
to set the prediciton model;
   proc logistic data=Crops outmodel=model1; *the outmodel statement outputs hte estimates to be used in fututre scoring;
      model Crop=x1-x4 / 
      outroc=roc_cross_valid ctable  roceps=0 pprob=0.01 to 0.99 by 0.01; *ROC curve data;
 	  output out=cross_validation predprobs=x p=phat; *outputs cross validation numbers;
      score out=Score1;
   run;

*New data to validate on;
data New;
      length Crop $ 10;
      infile datalines truncover;
      input Crop $ @@;
      do i=1 to 3;
        input x1-x4 @@;
        if (x1 ^= .) then output;
      end;
      input;
      datalines;
   Corn       16 23 31 33  15 28 30 31  16 27 27 25 
   Corn       18 45 25 23  15 16 31 31  15 32 32 20 
   Corn       12 32 16 73  
   Other      20 27 23 25  24 25 25 31  21 25 23 24 
   Other      27 20 24 12  12 14 15 41  22 32 31 43 
   Other      31 17 33 34  29 28 26 30  34 32 28 45
**External Validation**;
***Importing model1 from Training set and obtaining pprobs for pLOS for the Validation set***;
Proc logistic inmodel=model1  ; 
score data=New out=scores_ROCs outroc=roc_ROCs; 
run;

*Now these ROC curves can be plotted together if you need.
