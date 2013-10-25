*********************************
Different types of plots;

*A scatter plot with the actual observations for two groups
with a line through the predicted values;
goptions reset;
symbol1 v=circle cv=blue i=none;
symbol2 v=circle cv=red i=none;
symbol3  cv=blue i=join;
symbol4  cv=red i=join;
proc gplot data=cd4pred;
format treatment treat.;
plot cd4naive*time=treatment /haxis=0 to 180 by 10 vaxis=1000 to 17000 by 500;
 plot2 pred*time=treatment/ vaxis=1000 to 17000 by 500;*these plots a put on the same plot but with 
 different axes. Here we set the same scale for both;
run;quit;

*A scatter plots between two variables showing the actual data points and a 
 fitted regression line through them. In this case I am using the residuals from previous
regressions to make partial plots; 
goptions reset;
symbol1 interpol=rl value=circle color=black;
proc gplot data=c10;
plot fev1res*cxcl10res;
run;

*Boxplots of data. The second variable must (obviously) be categorical;
PROC SGPLOT DATA=bios500.nilton;
VBOX glucose/
CATEGORY=diabetes;
RUN;


proc sgscatter data= bios500.nilton ;
matrix platelet rbc wbc neutroph 
       /
         diagonal=(histogram) ;
run;
