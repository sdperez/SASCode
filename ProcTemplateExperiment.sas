*************************************
Working with Proc Template to
 create simple customized graphs;
************************************
;

data Infections;
input month infnumber totalPats;
infrate=infnumber/totalPats;
datalines;
1 21 230
2 25 210
3 17 170
4 8  118
5 18 201
6 19 203
7 33 245
8 15 189
9 14 175
10 20 214
11 28 230
12 31 256
;
run;
proc template;
  define statgraph plotTest; 
  dynamic _pct; 
  begingraph / designwidth=600px designheight=400px;
  entrytitle "Scatterplot" / pad=(bottom=5px);
   *layout lattice / columns=2 columngutter=0 columnweights=(.76 .24 );   

layout overlay / walldisplay=(fill)
                   yaxisopts=(display=(tickvalues) offsetmin=_pct offsetmax=_pct 
					label="Infection Rate") 
                   xaxisopts=( offsetmin=0 offsetmax=0 
		           label="Month");
      entry halign=left "             LeftLabel" 
            halign=center "CenterLabel" / location=outside valign=top ;
      scatterplot x=month y=infrate ;
	  *referenceline x=1 / lineattrs=(pattern=solid); 
     innermargin / align=bottom;
	blockplot x=month block=TotalPats / repeatedvalues=
               true display=(values) valuehalign=start
               valuefitpolicy=truncate labelposition=left
               labelattrs=GRAPHVALUETEXT valueattrs=
               GRAPHDATATEXT (size=7pt) includemissingclass=
               false;
	endinnermargin;
endlayout; 

    /*layout overlay / walldisplay=none border=false
                   yaxisopts=(reverse=true type=discrete display=none)
                   xaxisopts=(display=none offsetmin=0.15 offsetmax=0.15);
      entry  halign=left "   OR" halign=center "  LCL" halign=right "UCL" / pad=(right=2.75%) location=outside valign=top;         
      scatterplot y=Study2 x=eval(constant*1) / markercharacter=OddsRatio;
	  scatterplot y=Study2 x=eval(constant*2) / markercharacter=LowerCL;
	  scatterplot y=Study2 x=eval(constant*3) / markercharacter=UpperCL;
    endlayout; */

  *endlayout;
  endgraph;
  end;
run;
ods html image_dpi=100  file='test.html'
path='C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Studies\SplenectomyNeha';
ods graphics / reset imagename="test" imagefmt=gif;
proc sgrender data=infections template=plotTest; 
  dynamic _pct=&pct;
run;
ods html close;
