data meta(keep=Study Stat Value) 
     overall(keep=overall overallvalue)
     labels(keep=Study2 OddsRatio LowerCL UpperCl constant); 
  input Study $1-16 OddsRatio LowerCL UpperCL Weight;
  length Stat $8;	
  format  OddsRatio LowerCL UpperCL 5.3;
  retain constant 1;
  Study2=right(Study);
  output Labels;
  if Study eq "Overall" then do;
    OverallValue=OddsRatio; 
    Overall="Overall";	
    output overall;
  end;
  else do;
    weight=weight*.05;
    Stat="MIN";      
    Value=LowerCL; 
    output meta;
    Stat="MAX";  	 
    Value=UpperCL; 
    output meta;
    Stat="Q1";       
    Value= OddsRatio/(10 ** (weight/2)); 
    output meta;
    Stat="Q3";       
   Value= OddsRatio*(10 ** (weight/2));
    output meta;
    Stat="BOXWIDTH"; 
    Value=weight*3; 
    output meta;
  end;
  datalines;
Modano  (1967)    0.590 0.096 3.634  1
Borodan (1981)    0.464 0.201 1.074  3.5
Leighton (1972)   0.394 0.076 2.055  2
Novak   (1992)    0.490 0.088 2.737  2
Stawer  (1998)    1.250 0.479 3.261  3
Truark   (2002)   0.129 0.027 0.605  2.5
Fayney   (2005)   0.313 0.054 1.805  2
Modano  (1969)    0.429 0.070 2.620  2
Soloway (2000)    0.718 0.237 2.179  3
Adams   (1999)    0.143 0.082 0.250  4
Truark2  (2002)   0.129 0.027 0.605  2.5
Fayney2  (2005)   0.313 0.054 1.805  2
Modano2 (1969)    0.429 0.070 2.620  2
Soloway2(2000)    0.718 0.237 2.179  3
Adams2   (1999)    0.143 0.082 0.250  4
Overall           0.328 0.233 0.462  .
;
run;

data forest; 
  merge meta overall labels; 
run;

data _null_;
  pct=1/nobs;
  call symputx("pct", pct);
  set labels nobs=nobs;
run;

proc template;
  define statgraph ForestPlot_2Col; 
  dynamic _pct; 
  begingraph / designwidth=600px designheight=400px;
  entrytitle "Impact of Treatment on Mortality" / pad=(bottom=5px);
  layout lattice / columns=2 columngutter=0 columnweights=(.76 .24 );   

    layout overlay / walldisplay=(fill)
                   yaxisopts=(display=(tickvalues) reverse=true offsetmin=_pct offsetmax=_pct) 
                   xaxisopts=(type=log offsetmin=0 offsetmax=0 
		           label="Favors Treatment                     Favors Placebo"
                   logopts=(base=10 minorticks=true viewmin=.01 viewmax=100 ));
      entry halign=left "             Study" 
            halign=center "Odds Ratio and 95% CL" / location=outside valign=top ;
      boxplotparm x=Study y=value stat=stat / orient=horizontal display=(fill notches);
      scatterplot x=OverallValue y=overall / markerattrs=(color=orange symbol=diamondfilled size=4pct);
	  referenceline x=1 / lineattrs=(pattern=solid); 
      referenceline x=.1 / lineattrs=(pattern=shortdash); 
      referenceline x=10 / lineattrs=(pattern=shortdash); 
      referenceline x=.01 / lineattrs=(pattern=shortdash); 
      referenceline x=100 / lineattrs=(pattern=shortdash); 
    endlayout;

    layout overlay / walldisplay=none border=false
                   yaxisopts=(reverse=true type=discrete display=none)
                   xaxisopts=(display=none offsetmin=0.15 offsetmax=0.15);
      entry  halign=left "   OR" halign=center "  LCL" halign=right "UCL" / pad=(right=2.75%) location=outside valign=top;         
      scatterplot y=Study2 x=eval(constant*1) / markercharacter=OddsRatio;
	  scatterplot y=Study2 x=eval(constant*2) / markercharacter=LowerCL;
	  scatterplot y=Study2 x=eval(constant*3) / markercharacter=UpperCL;
    endlayout; 

  endlayout;
  endgraph;
  end;
run;

proc template;
  define Style foreststyle;
    parent = styles.analysis;
    style GraphFonts from GraphFonts                                                      
      "Fonts used in graph styles" /  
      'GraphTitleFont' = (", ",10pt,bold)
      'GraphLabelFont' = (", ",8pt) 
      'GraphValueFont' = (", ",7pt)
      'GraphDataFont' = (", ",7pt);
  end;
run;

title;
options nodate nonumber;

ods listing close;
ods html image_dpi=100 style=foreststyle file='forestplot_2Col.html' path='.';

ods graphics / reset imagename="ForestPlot_2Col" imagefmt=gif;
proc sgrender data=forest template=ForestPlot_2Col; 
  dynamic _pct=&pct;
run;

ods html close;
ods listing;
