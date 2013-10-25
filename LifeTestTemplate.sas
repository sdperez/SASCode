proc template;
define statgraph Stat.Lifetest.Graphics.ProductLimitSurvival;
   dynamic NStrata xName plotAtRisk plotCensored plotCL plotHW
      plotEP labelCL labelHW labelEP maxTime StratumID
      classAtRisk plotBand plotTest GroupName yMin Transparency
      SecondTitle TestName pValue;
   BeginGraph;
      if (NSTRATA=1)
         if (EXISTS(STRATUMID))
         entrytitle "Kaplan-Meier Plot" " for "
         STRATUMID;
      else
         entrytitle "Kaplan-Meier Plot";
      endif;
      if (PLOTATRISK)
         entrytitle "with Number of Subjects at Risk" /
         textattrs=GRAPHVALUETEXT;
      endif;
      layout overlay / xaxisopts=(shortlabel=XNAME offsetmin=
         .05 linearopts=(viewmax=MAXTIME)) yaxisopts=(label=
         "Survival Probability" shortlabel="Survival"
         linearopts=(viewmin=0 viewmax=1 tickvaluelist=(0 .2 .4
         .6 .8 1.0)));
         if (PLOTHW=1 AND PLOTEP=0)
            bandplot LimitUpper=HW_UCL LimitLower=HW_LCL x=TIME
            / modelname="Survival" fillattrs=GRAPHCONFIDENCE
            name="HW" legendlabel=LABELHW;
         endif;
         if (PLOTHW=0 AND PLOTEP=1)
            bandplot LimitUpper=EP_UCL LimitLower=EP_LCL x=TIME
            / modelname="Survival" fillattrs=GRAPHCONFIDENCE
            name="EP" legendlabel=LABELEP;
         endif;
         if (PLOTHW=1 AND PLOTEP=1)
            bandplot LimitUpper=HW_UCL LimitLower=HW_LCL x=TIME
            / modelname="Survival" fillattrs=GRAPHDATA1
            datatransparency=.55 name="HW" legendlabel=LABELHW;
         bandplot LimitUpper=EP_UCL LimitLower=EP_LCL x=TIME /
            modelname="Survival" fillattrs=GRAPHDATA2
            datatransparency=.55 name="EP" legendlabel=LABELEP;
         endif;
         if (PLOTCL=1)
            if (PLOTHW=1 OR PLOTEP=1)
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=
            TIME / modelname="Survival" display=(outline)
            outlineattrs=GRAPHPREDICTIONLIMITS name="CL"
            legendlabel=LABELCL;
         else
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=
            TIME / modelname="Survival" fillattrs=
            GRAPHCONFIDENCE name="CL" legendlabel=LABELCL;
         endif;
         endif;
         stepplot y=SURVIVAL x=TIME / name="Survival" rolename=
            (_tip1=ATRISK _tip2=EVENT) tip=(y x Time _tip1
            _tip2) legendlabel="Survival";
         if (PLOTCENSORED=1)
            scatterplot y=CENSORED x=TIME / markerattrs=(symbol
            =plus) name="Censored" legendlabel="Censored";
         endif;
         if (PLOTCL=1 OR PLOTHW=1 OR PLOTEP=1)
            discretelegend "Censored" "CL" "HW" "EP" / location
            =outside halign=center;
         else
            if (PLOTCENSORED=1)
            discretelegend "Censored" / location=inside
            autoalign=(topright bottomleft);
         endif;
         endif;
         if (PLOTATRISK=1)
            innermargin / align=bottom;
            blockplot x=TATRISK block=ATRISK / repeatedvalues=
               true display=(values) valuehalign=start
               valuefitpolicy=truncate labelposition=left
               labelattrs=GRAPHVALUETEXT valueattrs=
               GRAPHDATATEXT (size=7pt) includemissingclass=
               false;
         endinnermargin;
         endif;
      endlayout;
      else
         entrytitle "Kaplan-Meier Plot";
      if (EXISTS(SECONDTITLE))
         entrytitle SECONDTITLE / textattrs=GRAPHVALUETEXT;
      endif;
      layout overlay / xaxisopts=(shortlabel=XNAME offsetmin=
         .05 linearopts=(viewmax=MAXTIME)) yaxisopts=(label=
         "Survival Probability" shortlabel="Survival"
         linearopts=(viewmin=0 viewmax=1 tickvaluelist=(0 .2 .4
         .6 .8 1.0)));
         if (PLOTHW)
            bandplot LimitUpper=HW_UCL LimitLower=HW_LCL x=TIME
            / group=STRATUM index=STRATUMNUM modelname=
            "Survival" datatransparency=Transparency;
         endif;
         if (PLOTEP)
            bandplot LimitUpper=EP_UCL LimitLower=EP_LCL x=TIME
            / group=STRATUM index=STRATUMNUM modelname=
            "Survival" datatransparency=Transparency;
         endif;
         if (PLOTCL)
            if (PLOTBAND)
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=
            TIME / group=STRATUM index=STRATUMNUM modelname=
            "Survival" display=(outline);
         else
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=
            TIME / group=STRATUM index=STRATUMNUM modelname=
            "Survival" datatransparency=Transparency;
         endif;
         endif;
         stepplot y=SURVIVAL x=TIME / group=STRATUM index=
            STRATUMNUM name="Survival" rolename=(_tip1=ATRISK
            _tip2=EVENT) tip=(y x Time _tip1 _tip2);
         if (PLOTCENSORED)
            scatterplot y=CENSORED x=TIME / group=STRATUM index
            =STRATUMNUM markerattrs=(symbol=plus);
         endif;
         if (PLOTATRISK)
            innermargin / align=bottom;
            blockplot x=TATRISK block=ATRISK / class=
               CLASSATRISK repeatedvalues=true display=(label
               values) valuehalign=start valuefitpolicy=
               truncate labelposition=left labelattrs=
               GRAPHVALUETEXT valueattrs=GRAPHDATATEXT (size=
               7pt) includemissingclass=false;
         endinnermargin;
         endif;
         DiscreteLegend "Survival" / title=GROUPNAME location=
            outside;
         if (PLOTCENSORED)
            if (PLOTTEST)
            layout gridded / rows=2 autoalign=(TOPRIGHT
            BOTTOMLEFT TOP BOTTOM) border=true BackgroundColor=
            GraphWalls:Color Opaque=true;
            entry "+ Censored";
            if (PVALUE < .0001)
               entry TESTNAME " p " eval (
               PUT(PVALUE, PVALUE6.4));
            else
               entry TESTNAME " p=" eval (
               PUT(PVALUE, PVALUE6.4));
            endif;
         endlayout;
         else
            layout gridded / rows=1 autoalign=(TOPRIGHT
            BOTTOMLEFT TOP BOTTOM) border=true BackgroundColor=
            GraphWalls:Color Opaque=true;
            entry "+ Censored";
         endlayout;
         endif;
         else
            if (PLOTTEST)
            layout gridded / rows=1 autoalign=(TOPRIGHT
            BOTTOMLEFT TOP BOTTOM) border=true BackgroundColor=
            GraphWalls:Color Opaque=true;
            if (PVALUE < .0001)
               entry TESTNAME " p " eval (
               PUT(PVALUE, PVALUE6.4));
            else
               entry TESTNAME " p=" eval (
               PUT(PVALUE, PVALUE6.4));
            endif;
         endlayout;
         endif;
         endif;
      endlayout;
      endif;
   EndGraph;
end;
