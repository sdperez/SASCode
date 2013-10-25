data pain;
      input Dose Adverse $ Count @@;
      datalines;
   0 No 26   0 Yes  6
   1 No 26   1 Yes  7
   2 No 23   2 Yes  9
   3 No 18   3 Yes 14
   4 No  9   4 Yes 23
   ;
ods graphics on;
   proc freq data=Pain;
      tables Adverse*Dose / cmh trend plots=freqplot(twoway=stacked);
*trend measures cl
             ;
      *test smdrc;
      exact trend / maxtime=60;
      weight Count;
      title 'Clinical Trial for Treatment of Pain';
   run;
   ods graphics off;
