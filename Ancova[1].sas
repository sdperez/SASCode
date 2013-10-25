*******************************************************************
*Analysis of covariance (ANCOVA):
*-- Combineds ANOVA and Regression
*-- augment ANOVA model containing factor effects with one of more 
*   additional quantitative variances that are related to the response.
*-- This augmenttation is intended to reduce the variance of the error
*   terms and make the analysis more precise.
*-- An ANCOVA could be viewed as a regression on the residuals of a
*   one-way ANOVA, or, alternatively, as a one-way ANOVA on the
*   residuals of a regression.
*
*
* As an example, suppose that each of three groups of lambs is given a
*   different brand of lamb chow. We test the three lamb chows by
*   weighing the lambs when they are one year old.
* We are told that the lambs were randomly assigned to the three
*   treatment groups, but are not genetically uniform. In
*   particular, there might be genetic reasons why some lambs are
*   heavier when they are one year old. If the treatment effect (lamb
*   chow) turns out to be significant, it might be because of
*   accidental correlations between these genetic effects and the
*   assignment to treatment groups.
*
* Alternatively, we can attempt to correct for this genetic effect by
*   using the maternal weight at birth of the ewes that gave birth to
*   the lambs. This would give two factors in the model, the lamb-chow
*   treatment group and maternal weight, leading to an ANCOVA model
*   of the type above.
*
*******************************************************************
;

TITLE 'LAMB WEIGHT FOR 3 LAMB CHOWS';
OPTIONS LS=75 PS=60 PAGENO=1 NODATE;
* Use `proc format' to create a user-defined format to expand 
*   codes 1,2,3 to brand names;
PROC FORMAT;
	VALUE feed 1='AZenith'  2='BXQ11'  3='Clover7';
RUN;


* Values are read in pairs from the datalines block, since the
*   main data values are pairs (Y,X) for lamb yearling and
*   maternal ewe weights. ;

DATA lambs;
     RETAIN chow feednum;
     INPUT t1$ t2 @@;
     IF  t1= 'Feed' THEN DO; 
		chow=t2; 
		feednum=t2;  end;
     ELSE DO;  
		lambwt=input(t1,12.0);  
		matwt=t2;
		OUTPUT;
		END;
	FORMAT chow feed.;
	DROP t1 t2;
DATALINES;
 Feed 1   45   98     47   93     46   89     45  101     56  127  
          56   99     43   82     38   81     44   91     46   95  
          47  103     46   87     48   84     50  106     48   89  
 Feed 2   52   92     48   99     54  111     45  102     50   91  
          46  105     47   82     56  103     44   81     46   96  
          53  109     49  103     54  120     53  120     53   95  
 Feed 3   45  116     55   99     56  111     58   85     49  110  
          55   94     50  105     54  110     51  104     51   99  
          55   91     43  105     45   99     50  104     55  122  
       ;

* You may print the data to check how SAS sees it;

** One-Way ANOVA Model ***;
PROC GLM;
   TITLE2 'ONE-WAY ANOVA FOR WEIGHT ON FEED BRAND';
   TITLE3 'THIS IS (BORDERLINE) SIGNIFICANT, BUT IS IT THE ENTIRE STORY?';
   TITLE4 'NOTE THAT THE MODEL RSQUARE IS ONLY 0.166';
   CLASS chow;
   MODEL lambwt=chow;
RUN;

PROC MEANS N MEAN STD  DATA=lambs; 
	TITLE2 "WILL MEANS AND STANDARD DEVIATIONS GIVE ANY CLUES?";
	TITLE3 "NOTE THAT THE CLASS MEANS OF LAMB AND MATERNAL WEIGHTS";
	TITLE4 "  SEEM TO BE CORRELATED ACROSS FEED TYPE.";
   	CLASS chow;
   	VAR lambwt matwt;
	OUTPUT OUT=lambs2(WHERE=(_TYPE_=1)) MEAN=;
RUN;
TITLE3;
TITLE4;
PROC PRINT DATA=lambs2;
	TITLE2 'The dataset as SAS sees it.';
RUN;

** ANCOVA Model ***;
** Add the quantitative predictor 'matwt' to form an ANCOVA model;
PROC GLM DATA=lambs;
	TITLE2 'TRY AGAIN WITH MATERNAL WEIGHT INCLUDED (AN ANCOVA MODEL)';
	TITLE3 'NOW LAMB WEIGHT SEEMS TO DEPEND MOSTLY ON MATERNAL WEIGHT.';
	TITLE4 'NOTE THE INCREASED MODEL RSQUARE';
	CLASS chow;
	MODEL lambwt=chow matwt;
RUN;

*** Further investigation about the interaction term *****;

* Let's look at simple regressions within each chow brand:;
** Plot the data;
PROC SORT DATA=lambs;
     BY chow matwt lambwt;  * To be safe;
RUN;
GOPTIONS VSIZE=0 HSIZE=0;
SYMBOL1 I=R V=PLUS C=RED;
SYMBOL2 I=R V=TRIANGLE C=BLUE;
SYMBOL3 I=R V=CIRCLE C=GREEN;
PROC GPLOT	DATA=lambs;
    TITLE 'OBSERVED DATA WITH SIMPLE REGRESSIONS';
   	PLOT lambwt*matwt=chow;
RUN;

* The `BY' command tells SAS to generate output for each lamb chow,  ;
*   here as three separate outputs:;
* To have high-resolution instead of text plots,  ;
*    omit the `lineprinter' ;

OPTIONS PS=50;

PROC REG DATA=lambs LINEPRINTER;
	TITLE2 "LET'S LOOK AT SIMPLE REGRESSIONS WITHIN EACH CHOW BRAND";
	TITLE3 "NOTE SLOPE ESTIMATIONs AND ROOT MSEs ARE DIFFERENT FOR EACH GROUP";
	TITLE4 "THIS IS DIFFERENT FROM ANCOVA MODEL";
    BY chow;
    MODEL lambwt=matwt;
      * This gives three separate plots of observed versus fitted values;
      *   within each treatment group;
    PLOT lambwt*matwt=chow  predicted.*matwt=feednum / OVERLAY;
RUN;

TITLE2 "WE COULD SHOW FITTED AND OBSERVED VALUES FOR EACH LAMB CHOW, BUT A PLOT";
TITLE3 "  WITH THE THREE FITTED REGRESSION LINES TOGETHER GIVES A CLEARER";
TITLE4 "  PICTURE OF THE CHOW*MATWT INTERACTION:";

PROC GLM DATA=lambs NOPRINT; /*This gives same result as in PROC REG and so suppress output*/
	BY chow;
	MODEL lambwt=matwt;
	OUTPUT P=pred;
RUN;

OPTIONS PS=40;
PROC PLOT;
	PLOT pred*matwt=chow;
RUN;
OPTIONS PS=60;

TITLE3;
TITLE4;
PROC CORR NOSIMPLE;
	TITLE2 "THEN, LET'S LOOK ARE CORRELATIONS WITHIN EACH CHOW:";
	BY chow;
	VAR lambwt matwt;
RUN;

PROC GLM;
	TITLE2 "FINALLY, FIT ANCOVA WITH THE chow*matwt 'INTERACTION'";
	TITLE3 "THIS ALLOWS DIFFERENT SLOPES FOR DIFFERENT TREATMENT GROUPS";
	TITLE4 "THE CHOW BRANDS NOW SEEM TO BE SIGNIFICANT AGAIN";
	TITLE5 "CAN YOU SEE WHY?";
	TITLE6 "IS THIS SAME WITH SIMPLE LINEAR REGRESSION WITHIN EACH GROUP?";
   	CLASS chow;
   	MODEL lambwt=chow matwt chow*matwt;
RUN;

QUIT;
*** Compare three different models: 
*Three Simple regressions in three treatments,
*ANCOVA without interaction (common slope across treatments),
*ANCOVA with interaction (different slopes).
;
PROC GLM DATA=lambs NOPRINT;
        BY chow;
        MODEL lambwt=matwt;
        OUTPUT OUT=t1 P=simple;
RUN;

PROC GLM DATA=lambs NOPRINT;
	CLASS chow;
         MODEL lambwt=chow   matwt;
        OUTPUT OUT=t2 P=additive; 
RUN;
PROC GLM DATA=lambs NOPRINT;
         CLASS chow;
         MODEL lambwt=chow |  matwt;         
         OUTPUT OUT=t3 P=full;          
RUN;

DATA fit;
	MERGE t1 t2 t3;
 	BY chow matwt lambwt;
RUN;

*** Comparison on three models;
GOPTIONS VSIZE=3 HSIZE=0;
SYMBOL1 I=JOIN V=NONE C=RED;
SYMBOL2 I=JOIN V=NONE C=BLUE;
SYMBOL3 I=JOIN V=NONE C=GREEN;

PROC GPLOT DATA=fit UNIFORM; *UNIFORM requests the same axes;
	TITLE 'COMPARISONS: SIMPLE REGRESSIONS, ANCOVA W/O INTERACTION';
	PLOT simple*matwt=chow additive*matwt=chow full*matwt=chow;
RUN;	
QUIT;





